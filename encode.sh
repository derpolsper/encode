#!/bin/env bash

# path to default config file
config="$HOME/.config/encode/default.cfg"

# path to wine directory
winedir="$HOME/.wine.encode"

# path to eac3to
eac3to="$winedir/drive_c/Program Files/eac3to/eac3to.exe"

# path to avisynth.dll
avisynth="$winedir/drive_c/windows/system32/AviSynth.dll"
#avisynth="$winedir/drive_c/windows/syswow64/AviSynth.dll"

# path to AvsPmod
avspmod="$winedir/drive_c/Program Files/AvsPmod/AvsPmod.exe"

# store filters out of wine saves some escaping
# general path to filters
filters="$HOME/.config/encode/.filters"

# path to dgindex
dgindex="$filters/dgmpgdec2007/DGIndex.exe"

# path to DGDecode
dgdecode="$filters/dgmpgdec2007/x64/DGDecode.dll"

# path to D2VSource
d2vsource="$filters/D2VSource-1.2.2/x64/Release/D2VSource.dll"

# path to avs2yuv
avs2yuv="$filters/avs2yuv/avs2yuv64.exe"

# path to LSMASHSource
lsmashsource="$filters/LSMASHSource.dll"
lwlinfo="$filters/LWLInfo.avsi"

# path to z_resize
z_resize="$filters/avsresize.dll"
resize="z_Spline36Resize"

# path to fillborders/ fillmargins
# if in wine directory, prevent bash from expanding backslashes
# e.g. pathfillborders=/home/user/.wine\/drive_c\/Program\\ Files\/FillBorders\/FillBorders.dll
pathfb="$filters/FillBorders.dll"

# path to FixBrightnessProtect
# if in wine directory, prevent bash from expanding backslashes
pathfixbr="$filters/FixBrightnessProtect3.avsi"

# wine settings
export WINEPREFIX="$winedir"
export WINEARCH=win64

# zones
if [[ -e ${config%/*}/$1.$2.zones.txt ]]; then
    zones="$(cat ${config%/*}/$1.$2.zones.txt)"
fi

# beeps
# mario
# beep='-f 130 -l 100 -n -f 262 -l 100 -n -f 330 -l 100 -n -f 392 -l 100 -n -f 523 -l 100 -n -f 660 -l 100 -n -f 784 -l 300 -n -f 660 -l 300'
# simple
beep='-f 400 -r 2 -d 50'

# parameter $1 set or unset?
if [[ -z ${1+x} ]]; then
# if unset, read from default
    echo -e "\n*** Config file not yet generated ***"
    echo -e "***       for this encoding       ***\n"
else
# if set, but config not existing yet, cp default to $1
# and set $1-config as config
    if [[ ! -f ${config%/*}/$1.cfg ]]; then
        cp "$config" "${config%/*}"/"$1".cfg
    fi
    config="${HOME}/.config/encode/$1.cfg"
    echo -e "config file is $config\n"
fi

while IFS='=' read lhs rhs; do
    if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"        # delete in line right comments
        rhs="${rhs%"${rhs##*[^ ]}"}"    # delete trailing spaces
        rhs="${rhs%\"*}"        # delete opening string quotes
        rhs="${rhs#\"*}"        # delete closing string quotes
        declare $lhs="$rhs"
    fi
done < "$config"

echo -e "What do you want to do?\n"

function main_menu {
echo -e "00 - Check for available programs and\n     show|edit default settings"
echo "0  - Display current encoding parameters"
echo -e "1  - Transfer data from raw h264|remux|m2ts files\n     into a matroska container"
echo "2  - Create avs files"
echo "3  - First tests for crf"
echo "4  - Testing for deblock"
echo "5  - Testing for mb-tree"
echo "6  - Testing for qcomp"
echo "7  - Testing aq strength in different aq modes"
echo "8  - Test for deblock, again"
echo "9  - Testing for psy-rd"
echo "10 - Testing for psy-trellis"
echo "11 - More tests: chroma-qp-offset"
echo "12 - Another round of crf"
echo -e "13 - Encode the whole movie\n"
}

while true; do
    main_menu
read -p "> " answer_mainmenu

if [[ $answer_mainmenu -ge 0 && -e $2 && ! $2 = @(SD|480|576|720|1080) ]]; then
    echo -e "\n$2 is not a standard resolution."
    echo -e "Choose one: SD, 480, 576, 720 or 1080.\n"
    exit
fi


### Neccessary?
if [[ $answer_mainmenu -ge 2 && -z $1 ]]; then
    echo -e "\n$1 is unknown."
    echo -e "Choose a config file\n"
    echo -e "Start the script like this:\n"
    echo -e "./encode.sh <config>\n"
    echo -e "or begin with option 1:\n"
    echo -e "./encode.sh\n"
    exit
fi

### Neccessary?
if [[ $answer_mainmenu -ge 2 && -z ${source2%.*} ]]; then
echo ${source2%.*}
    echo -e "\nChoose another config file and"
    echo -e "start the script like this:\n"
    echo -e "./encode.sh <config>\n"
    echo -e "or begin with option 1:\n"
    echo -e "./encode.sh\n"
    exit
fi

if [[ $answer_mainmenu -ge 3 ]]; then
    if [[ -z $2 ]]; then
        echo -e "\nChoose a resolution."
        echo "Start the script like this:"
        echo -e "\n./encode.sh ${source2%.*} <resolution>\n"
        echo -e "where resolution might be SD, 480, 576, 720 or 1080\n"
        exit
    elif [[ ! $2 = @(SD|480|576|720|1080) ]]; then
        echo -e "\n$2 is not a standard resolution."
        echo -e "Choose one: SD, 480, 576, 720 or 1080.\n"
        exit
    fi
fi

if [[ $answer_mainmenu -ge 3 ]] || [[ -f ${config%/*}/$1.cfg && $2 = @(SD|480|576|720|1080) ]]; then
    avs=$(cat "$config"|grep testavs|grep $2=)
    finalavs=$(cat "$config"|grep finalavs|grep $2=)
    ref=$(cat "$config"|grep ref|grep $2=)
    crf=$(cat "$config"|grep crf|grep $2=)
    deblocka=$(cat "$config"|grep deblocka|grep $2=)
    deblockb=$(cat "$config"|grep deblockb|grep $2=)
    qcomp=$(cat "$config"|grep qcomp|grep $2=)
    aqmode=$(cat "$config"|grep aqmode|grep $2=)
    aqs=$(cat "$config"|grep aqs|grep $2=)
    psyrd=$(cat "$config"|grep psyrd|grep $2=)
    psytr=$(cat "$config"|grep psytr|grep $2=)
    cqpo=$(cat "$config"|grep cqpo|grep $2=)
    nombtree=$(cat "$config"|grep nombtree|grep $2=)
    lookahead=$(cat "$config"|grep lookahead|grep $2=)
    br=$(cat "$config"|grep br|grep $2=)
    width=$(cat "$config"|grep width|grep $2=)
    height=$(cat "$config"|grep height|grep $2=)
    ratectrl=$(cat "$config"|grep ratectrl|grep $2=)
    colormatrix=$(cat "$config"|grep colormatrix|grep $2=)
    colorprim=$(cat "$config"|grep colorprim|grep $2=)
fi

if [[ $2 = SD ]]; then
    res_dep_resize="Spline36Resize(ConvertToRGB(matrix=\"Rec601\"),FFSAR>1?round(Width*FFSAR):Width,FFSAR<1?round(Height/FFSAR):Height)"
else
    res_dep_resize="$resize(ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)"
fi

# for comparisons info on resolution can be placed depending on resolution
# topleft=7 topmiddle=8 topright=9
if [[ $answer_mainmenu -ge 3 ]] && [[ $2 = @(SD|480) ]]; then
    align_position="align=8"
elif [[ $answer_mainmenu -ge 3 ]] && [[ $2 = @(576|720|1080) ]]; then
    align_position="align=8"
fi

function set_bitrate {
    until [[ $br2 =~ ^[1-9][0-9]+*$ ]]; do
        echo "Set bitrate for further testing"
        read -e -p "Bitrate for $2 > " br2
    done
    # keep cfg informed
    sed -i "/br$2/d" "$config"
    echo "br$2=$br2" >> "$config"
    br="$br2"
}

function br_change {
    if [[ -n ${br##*=} ]]; then
        echo -e "\nTesting in 2pass mode\n"
        echo -e "Bitrate is ${br##*=}"
        echo "Return, if ok, or (e)dit"
        read -e -p "(RETURN|e) > " answer_br
        case $answer_br in
            e|E|edit|EDIT|Edit)
                set_bitrate $1 $2
            ;;

            *)    # do nothing here
            ;;
        esac
    else
        set_bitrate $1 $2
    fi
}

function encoding_starttime_global_tempfile {
    # Start measuring overall encoding time
    start0=$(date +%s)

    # Create a temporary file for comparisons
    temp_file=$(mktemp)
}

function encoding_starttime {
    # Start measuring encoding time
    start1=$(date +%s)
}

function encoding_stoptime {
    # Number of encodings left
    let encodings_left=$(( encodings_left - 1 ))

    # Stop measuring encoding time
    stop=$(date +%s);
    time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
}

function encoding_stoptime_global {
    stop=$(date +%s);
    days=$(( ($stop-$start0)/86400 ))
    time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
}

function create_interleave_pattern {
    local count=$1
    local pattern="interleave("

    # Add entries in the pattern: 'a,aa,a,ab,a,ac,a,ad', end with 'a'
    for ((i=0; i<count; i++)); do
        if [ $i -gt 0 ]; then
            pattern+=","
        fi
        pattern+="a,${prefixes[$i]}"
    done
    pattern+=",a)"

    echo "$pattern"
}

function screen_comparison_and_cleanup {
    local testing_avs=$1

    # Comparison screens
    # Create the prefix array using brace expansion
    prefixes=({a..z}{a..z})

    # Empty up possible former file
    echo "" > "$1" >/dev/null 2>&1

    # Read the temp file line by line and write with prefixes
    i=0
    while IFS= read -r line; do
        # Get the next prefix and print the line with it
        echo "${prefixes[i++]}$line" >> "$1"
    done < "$temp_file"

    # Get the number of lines in the input file
    avslines="$(wc -l < "$1")"

    # Add LSMASH and source at first lines
    sed -i "1i a=import(\"${avs##*=}\").subtitle(\"${source2%.*} source $2\", "$align_position").LWLInfo()#.trim(0,framecount)" "$1"
    sed -i "1i LoadPlugin(\""$lsmashsource"\")" "$1"
    sed -i "1i Import(\""$lwlinfo"\")" "$1"

    # Append the interleave pattern
    create_interleave_pattern "$avslines" >> "$1"

    # Append resize plugin
    echo "LoadPlugin(\"$z_resize\")" >> "$1"
    echo "$res_dep_resize" >> "$1"
    # Cleanup temporary files
    rm ${source1%.*}."$2".*.mbtree >/dev/null 2>&1
    rm ${source1%.*}."$2".*.stats >/dev/null 2>&1
}

case "$answer_mainmenu" in
    00) # 00 - installed programs - default settings

    # bash, bc, beep, exiftool, mediainfo, mkvmerge, wine, x264
    # eac3to, AviSynth, AvsPmod, avs2yuv, fillborders, ColorMatrix

    echo -e "\n*** check for available programs ***\n"

    if [ -e /bin/bash ]; then
        /bin/bash --version|head -1 ; echo
    else
        echo -e "***\n*** bash NOT installed ***\n***\n";
    fi

    if [ -e /usr/bin/bc ]; then
        /usr/bin/bc -v|head -1 ; echo
    else
        echo -e "***\n*** bc NOT installed ***\n***\n";
    fi

    if [ ! -e /usr/bin/beep ]; then
        echo -e "***\n*** info: beep not installed ***\n***\n";
    fi

    if [ -e /usr/bin/exiftool ]; then
        echo -n "exiftool "; /usr/bin/exiftool -ver; echo
    else
        echo -e "***\n*** exiftool NOT installed ***\n***\n";
    fi

    if [ -e /usr/bin/mediainfo ]; then
        /usr/bin/mediainfo --Version; echo
    else
        echo -e "***\n*** mediainfo NOT installed ***\n***\n";
    fi

    if [ -e /usr/bin/mkvmerge ]; then
        /usr/bin/mkvmerge -V; echo
    else
        echo -e "***\n*** mkvmerge NOT installed ***\n***\n";
    fi

    if [ -e /usr/bin/wine ]; then
        /usr/bin/wine --version; echo
    else
        echo -e "***\n*** wine NOT installed ***\n***\n";
    fi

    if [ -e /usr/bin/x264 ]; then
        /usr/bin/x264 -V|grep x264 -m 1 ; echo
    else
        echo -e "***\n*** x264 NOT installed ***\n***\n";
    fi

    if [ -e "$eac3to" ]; then
        wine "$eac3to" 2>/dev/null| grep 'eac3to v';
        echo
    else
        echo -e "***\n*** eac3to NOT found ***\n***\n";
    fi

    if [ -e "$avisynth" ]; then
        echo -e "avisynth found\n"
    else
        echo -e "***\n*** avisynth NOT found ***\n***\n";
    fi

    if [ -e "$avspmod" ]; then
        echo -e "AvsPmod found\n"
    else
        echo -e "***\n*** AvsPmod NOT found ***\n***\n";
    fi

    if [ -e "$avs2yuv" ]; then
        echo -e "avs2yuv found\n"
    else
        echo -e "***\n*** avs2yuv NOT found ***\n***\n";
    fi

    if [ -e "$dgindex" ]; then
        echo -e "DGIndex found\n"
    else
        echo -e "***\n*** DGIndex NOT found ***\n***\n";
    fi

    if [ -e "$pathfb" ]; then
        echo -e "FillBorders found\n"
    else
        echo -e "***\n*** FillBorders NOT found ***\n***\n";
    fi

    if [ -e "$pathfixbr" ]; then
        echo -e "FixBrightnessProtect3 found\n"
    else
        echo -e "***\n*** FixBrightnessProtect3 NOT found ***\n***\n";
    fi

    echo -e "Continue with option 1\n"
    ;;

    0)  # 0 - current settings

    echo -e "\n***       GENERAL SETTINGS       ***\n"

    echo -e "TUNE:\t\t\t ""$tune"
    echo -e "PROFILE:\t\t ""$profile"
    echo -e "PRESET:\t\t\t ""$preset\n"

    echo -e "ME:\t\t\t ""$me"
    echo -e "MERANGE:\t\t ""$merange"
    echo -e "SUBME:\t\t\t ""$subme"
    echo -e "LOOKAHEAD:\t\t ""${lookahead##*=}"

    echo -e "\n***       SelectRangeEvery       ***\n"

    echo -e "INTERVAL:\t\t" "$interval"
    echo -e "LENGTH:\t\t\t" "$length"
    echo -e "OFFSET:\t\t\t" "$offset\n"

        if [[ -n $1 ]]; then
            echo -e "***      SETTINGS ON SOURCE      ***\n"
            if [[ -n $left_crop || -n $top_crop || -n $right_crop || -n $bottom_crop ]]; then
                echo -e "CROPPING [ltrb]:\t ""$left_crop","$top_crop","$right_crop","$bottom_crop\n"
            fi

            if [[ -n $left_fb || -n $top_fb || -n $right_fb || -n $bottom_fb ]]; then
                echo -e "FILLBORDERS [ltrb]:\t ""$left_fb","$top_fb","$right_fb","$bottom_fb\n"
            fi

            if [[ -n $sarwidth0 || -n $sarheight0 ]]; then
                echo "STORAGE ASPECT"
                echo -e "before cropping:\t "$sarwidth0"×"$sarheight0""
            fi

            if [[ -n $sarwidth1 || -n $sarheight1 ]]; then
                echo -e "after cropping:\t\t "$sarwidth1"×"$sarheight1"\n"
            fi
        fi

        if [[ -n $2 ]] ; then
            echo -e "***     SETTINGS FOR ENCODE      ***\n"

                 if [[ -n ${darwidth1##*=} && -n ${sarheight1##*=} ]]; then
                     echo -e "DISPLAY ASPECT:\t\t ""${darwidth1##*=}"×"${sarheight1##*=}\n"
                 elif [[ -n ${darheight1##*=} && -n  ${sarwidth1##*=} ]]; then
                     echo -e "DISPLAY ASPECT:\t\t ""${sarwidth1##*=}"×"${darheight1##*=}\n"
                 else
                    echo -e "TARGET RESOLUTION:\t ""${width##*=}"×"${height##*=}\n"
                 fi

            echo -e "CRF:\t\t\t ${crf##*=}"
            if [[ -z ${nombtree##*=} ]]; then
                echo -e "MB-TREE:\t\t ""enabled"
            else
                echo -e "MB-TREE:\t\t ""disabled"
            fi
            echo -e "DEBLOCK:\t\t ""${deblocka##*=}":"${deblockb##*=}"
            echo -e "QCOMP:\t\t\t ""${qcomp##*=}"
            echo -e "AQMODE:\t\t\t ""${aqmode##*=}"
            echo -e "AQSTRENGTH:\t\t ""${aqs##*=}"
            echo -e "PSY-RD:\t\t\t ""${psyrd##*=}"
            if [[ -z ${psytr##*=} ]]; then
                echo -e "PSY-TR:\t\t\t unset"
            else
                echo -e "PSY-TR:\t\t\t ""${psytr##*=}"
            fi
            echo -e "CHROMA-QP-OFFSET:\t ${cqpo##*=}"

            if [[ ${ratectrl##*=} = c ]]; then
                echo -e "RATE CONTROL:\t\t CRF"
            elif [[ ${ratectrl##*=} = 2 ]]; then
                echo -e "RATE CONTROL:\t\t 2PASS"
            fi
            if [[ -n ${br##*=} ]]; then
                echo -e "Bit rate:\t\t ""${br##*=}"
            fi
        fi

    echo -e "\nYou may adjust them to your needs, e.g."
    echo "Change SelectRangeEvery values,"
    echo -e "e.g. in case of short film.\n"

    echo "If you want to adjust them manually,"
    echo -e "(e)dit, else return.\n"

    read -e -p "(RETURN|e) > " answer_defaultsettings
        case "$answer_defaultsettings" in
            e|E|edit) # edit either default of the encode/$1.cfg
                if [[ -f ${config%/*}/$1.cfg ]]; then
                    echo -e "\n\nHere you can edit the config for "$1"\n\n"
                    sleep 2
                    "${EDITOR:-vi}" "${config%/*}/$1.cfg"
                else
                    echo -e "\n\nHere you can edit the **default config**\n\n"
                    sleep 2
                    "${EDITOR:-vi}" "$config"
                fi
            ;;

            *) # no editing
            ;;
        esac

    echo -e "You may continue processing encodings\n"
    ;;

    1)  # 1 - prepare sources: rip/ remux/ m2ts → mkv

    # check source0 for being raw h264, a m2ts stream, a matroska container, a VOB or a m2v file
    until [[ -e $source0 ]] && ( [[ $source0 == @(*.h264|*.m2ts|*.m2v|*.d2v|*.mkv|*.mpls|*.VOB) ]] ); do
        echo -e "\nset path to source:"
        echo -e "raw h264, m2v, mkv, m2ts, mpls or any VOB file respectively\n"
        read -e -p "> " source0
    done

    # check source1 for file extension == mkv
    until [[ $source1 == @(*.mkv) ]] && [[ $source1 != $source0 ]]; do
        echo -e "\nsave the demuxed file"
        echo "absolute path AND name WITH file extension:"
        echo -e "e.g. /home/<user>/encoding/moviename.mkv\n"
        read -e -p "> " source1
        #prepare for logging
        mkdir -p "${source1%/*}"
    done

    # source file name without file extension
    # bash parameter expansion does not allow nesting, so do it in two steps
    source2=${source1##*/}

    function source_bd {
        cd "${source0%/*}"
        wine "$eac3to" "${source0##*/}" | tee "${source1%.*}".log

        until [[ $param1 == @(*\-demux*|*.ac3*|*.dts*|*.flac*|*.thd+ac3*|*.h264*|*.mpeg2*|*.sup*|*.txt*|*.vc1*|*.m2v*) ]]; do
            echo -e "\nextract all wanted tracks following this name pattern:"
            echo "[1-n]:moviename.extension, e.g. 2:moviename.h264"
            echo "3:moviename.flac 4:moviename.ac3 5:moviename.sup etc"
            echo -e "the video stream HAS TO be given h264, mpeg2, m2v or vc1 as file extension\n"
            echo -e "or just type -demux\n"
            read -e -p "> " param1
        done

        # keep $param1 without parenthesis, otherwise eac3to fails while parsing the parameter
        wine "$eac3to" "${source0##*/}" $param1 | tee -a "${source1%.*}".log

            mv *.h264 ${source2%.*}.h264
            mv *.mpeg2 ${source2%.*}.mpeg2
            mv *.vc1 ${source2%.*}.vc1
            mv *.m2v ${source2%.*}.m2v
# TODONOTE: dirty. problems when >1 h264|mpeg2|vc1|m2v file
        mkvmerge -v -o "$source1" $(ls "${source0%/*}"|grep -iE "h264|mpeg2|vc1|m2v" ) | tee -a "${source1%.*}".log
        # delete the h264|mpeg2|vc1 file
        rm "$(ls "${source0%/*}"|grep -iE "h264|mpeg2|vc1|m2v")" | tee -a "${source1%.*}".log
    }

    function source_raw {
        cd "${source0%/*}"
        wine "$eac3to" "${source0##*/}" | tee "${source1%.*}".log

# TODONOTE: dirty. problems when >1 h264 file
        mkvmerge -v -o "$source1" "$source0" | tee -a "${source1%.*}".log
    }

    function source_remux {
        cd "${source0%/*}"
        mkvmerge -i "${source0##*/}" | tee "${source1%.*}".log

        until [[ $param1 == @(*.ac3*|*.dts*|*.flac*|*.thd+ac3*|*.h264*|*.mpeg2*|*.sup*|*.txt*) ]]; do
            echo -e "\nExtract all wanted tracks following this name pattern:"
            echo "[0-n]:moviename.extension, e.g. 0:moviename.h264"
            echo "1:moviename.flac 2:moviename.ac3 3:moviename.sup etc"
            echo -e "the video stream HAS TO be given h264, mpeg2 or vc1 as file extension\n"
            read -e -p "> " param1
        done

        # keep $param1 without parenthesis, otherwise eac3to fails while parsing the parameter
        #wine $eac3to "${source0##*/}" $param1 | tee -a "${source1%.*}".log
        mkvextract tracks "$source0" $param1 | tee -a "${source1%.*}".log

        # TODONOTE: dirty. problems when >1 h264|mpeg2|vc1|m2v file
        mkvmerge -v -o "$source1" $(ls "${source0%/*}"|grep -iE "h264|mpeg2|vc1") | tee -a "${source1%.*}".log
        mkvextract chapters "$source0" -s >> "${source2%.*}.chapters.txt" | tee -a "${source1%.*}".log
        rm "$(ls|grep -iE "h264|mpeg2|vc1|m2v")"
    }

    function source_dvd {
        cd "${source0%/*}"
        echo -e "\nHere the available VOBs:\n\n$(ls *.VOB|grep -v 0.VOB|grep -v VIDEO)"
        until [[ $vob0 =~ ^[[:digit:]]+[[:digit:]]$ ]] ; do
        echo -e "\nChoose the VOB group you want to be remuxed,"
        echo -e "e.g. 01 or 02 or else"
        read -e -p "> " vob0
        done
        vob1="$(ls *.VOB | grep VTS_ | grep -v 0.VOB | grep $vob0 | tr "\n" " ")"
        wine "$dgindex" -i $vob1 -om 2 -od ${source2%.*} -exit
        mkvmerge -v -o "$source1" $(ls "${source0%/*}"|grep -iE ".m2v") | tee -a "${source1%.*}".log
        # rename audio tracks
        ls -v | grep .ac3 | cat -n | while read n f; do mv -n "$f" "${source2%.*}"."$n".ac3; done
    }

    if [[ $source0 == @(*.mpls|*.m2ts) ]] ; then
        source_bd
    elif [[ $source0 == @(*.h264|*.vc1|*.m2v) ]] ; then
        source_raw
    elif [[ $source0 == @(*.mkv) ]] ; then
        source_remux
    elif [[ $source0 == @(*.VOB) ]] ; then
        source_dvd
    else
        echo -e "Something went wrong :( .\n"
    fi

    # Remove spaces out of eac3to's log file name
#    for file in ./*.aac ./*.ac3 ./*.dts* ./*.flac ./*.thd+ac3 ./*.h264 ./*.idx ./*.pcm ./*.srt ./*.sub ./*.sup ./*.txt ./*.vc1 ./*.w64 ./*.wav ./*d2v ./*.d2v.bad ./*.m2v ./*log ; do mv "$file" $(echo $i | sed 's/ /./g') 2>/dev/null | tee -a "${source1%.*}".log; done
    for file in ./*.aac ./*.ac3 ./*.dts* ./*.flac ./*.thd+ac3 ./*.h264 ./*.idx ./*.mp2 ./*.pcm ./*.srt ./*.sub ./*.sup ./*.txt ./*.vc1 ./*.w64 ./*.wav ./*d2v ./*.d2v.bad ./*.m2v ./*log ; do mv "$file" $(echo $i | sed 's/ /./g') | tee -a "${source1%.*}".log; done
# TODONOTE move ALL eac3to/ D2V associated files to directory for demuxed files. does it?
#    for file in ./*.aac ./*.ac3 ./*.dts* ./*.flac ./*.thd+ac3 ./*.h264 ./*.idx ./*.pcm ./*.srt ./*.sub ./*.sup ./*.txt ./*.vc1 ./*.w64 ./*.wav ./*d2v ./*.d2v.bad ./*.m2v ./*log ; do mv "$file" "${source1%/*}"/ 2>/dev/null | tee -a "${source1%.*}".log; done
    for file in ./*.aac ./*.ac3 ./*.dts* ./*.flac ./*.thd+ac3 ./*.h264 ./*.idx ./*.mp2 ./*.pcm ./*.srt ./*.sub ./*.sup ./*.txt ./*.vc1 ./*.w64 ./*.wav ./*d2v ./*.d2v.bad ./*.m2v ./*log ; do mv "$file" "${source1%/*}"/ | tee -a "${source1%.*}".log; done
    rm ./*.d2v && rm ./*.log && rm ./*.m2v && rm ./.mpeg* | tee -a "${source1%.*}".log

    echo -e "\nYou find the demuxed files in"
    echo -e "${source1%/*}/\n"

    if [ -e /usr/bin/beep ]; then beep $beep; fi

    # if no config with encodings' name, generate it or exit
    if [[ ! -e  ${config%/*}/${source2%.*}.cfg ]]; then
        echo "Your encoding does not have a config file yet."
        echo "Return, if you want to generate one,"
        echo  -e "else (n)o\n"
        read -e -p "(RETURN|n) > " answer_generatecfg
            case "$answer_generatecfg" in
                n|N|no|No|NO)
                    echo "Exiting. Start again with a suitable parameter."
                    echo -e "./encode.sh <name.of.your.encoding>\n"
                    if [[  $(ls -1 ${config%/*}|wc -l) -ge 2 ]]; then
                    echo "Generate a completely new one or choose one"
                    echo -e "of these during the next run of option 1:\n"
                    ls -C ${config%/*}|grep -v default.cfg
                    else
                    echo -e "Generate a new config file by running option 1 again.\n"
                    fi
                    read -p "Return to continue."
                    exit
                ;;

                *)
                    echo "A new config file is generated:"
                    echo -e "${config%/*}/${source2%.*}.cfg\n"
                    cp "$config" "${config%/*}/${source2%.*}.cfg"
                    sed -i "/source2/d" "${config%/*}/${source2%.*}.cfg"
                    echo "source2=$source2" >> "${config%/*}/${source2%.*}.cfg"
                    sed -i "/source1/d" "${config%/*}/${source2%.*}.cfg"
                    echo "source1=$source1" >> "${config%/*}/${source2%.*}.cfg"

                    echo -e "Continue with option 2.\n"
                ;;
            esac
    else
        echo -e "Run the script:\n"
        echo -e "./encode.sh ${source2%.*}\n"
        echo -e "Continue with option 2.\n"
    fi

    # get to know DAR and SAR
    sarwidth0=$(exiftool "$source1"|awk '/Image Width/ {print $4}')
    sarheight0=$(exiftool "$source1"|awk '/Image Height/ {print $4}')
    darwidth0=$(exiftool "$source1"|awk '/Display Width/ {print $4}')
    darheight0=$(exiftool "$source1"|awk '/Display Height/ {print $4}')
    # keep cfg informed
    sed -i "/sarwidth0/d" "${config%/*}/${source2%.*}.cfg"
    echo "sarwidth0=$sarwidth0" >> "${config%/*}/${source2%.*}.cfg"
    sed -i "/sarheight0/d" "${config%/*}/${source2%.*}.cfg"
    echo "sarheight0=$sarheight0" >> "${config%/*}/${source2%.*}.cfg"
    sed -i "/darwidth0/d" "${config%/*}/${source2%.*}.cfg"
    echo "darwidth0=$darwidth0" >> "${config%/*}/${source2%.*}.cfg"
    sed -i "/darheight0/d" "${config%/*}/${source2%.*}.cfg"
    echo "darheight0=$darheight0" >> "${config%/*}/${source2%.*}.cfg"
    ;;

    2)  # 2 - create avs files

    function basic_avs {
        echo "LoadPlugin(\""$lsmashsource"\")" > "${source1%.*}".avs
        echo "LWLibavVideoSource(\"$source1\")" >> "${source1%.*}".avs
        echo "Import(\""$lwlinfo"\")" >> "${source1%.*}".avs
        echo "LWLInfo()" >> "${source1%.*}".avs
    }

    function par {
        echo -e "\nThe movies' storage aspect ratio is $sarwidth0×$sarheight0."
        echo -e "The movies' display aspect ratio is $darwidth0×$darheight0.\n"

        if [[ $sarwidth0 == 1920 && $sarheight0 == 1080 && $darwidth0 = 1920 && $darheight0 == 1080 ]] ; then
            echo -e "The correct PAR seems to be 1:1.\n"
            par="1:1"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 704 && $darheight0 == 480 ]] ; then
            echo -e "The correct PAR seems to be 40:33.\n"
            par="40:33"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 853 && $darheight0 == 480 ]] ; then
            echo -e "The correct PAR seems to be 32:27.\n"
            par="32:27"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 1024 && $darheight0 == 576 ]] ; then
            echo -e "The correct PAR seems to be 64:45.\n"
            par="64:45"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 1048 && $darheight0 == 576 ]] ; then
            echo -e "The correct PAR seems to be 16:11.\n"
            par="16:11"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 640 && $darheight0 == 480 ]] ; then
            echo -e "The correct PAR seems to be 8:9.\n"
            par="8:9"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 654 && $darheight0 == 480 ]] ; then
            echo -e "The correct PAR seems to be 10:11.\n"
            par="10:11"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 768 && $darheight0 == 576 ]] ; then
            echo -e "The correct PAR seems to be 16:15.\n"
            par="16:15"
        elif [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 786 && $darheight0 == 576 ]] ; then
            echo -e "The correct PAR seems to be 12:11.\n"
            par="12:11"
        else
            echo "Uh, there is something weird about the resolution or SAR."
            echo -e "You may set aspect ratios manually.\n"
        fi
        echo "If this seems correct to you, RETURN."
        echo "Else, set values (m)anually."
        read -e -p "> " par0
            case "$par0" in
                m|M)
                    echo -e "\nCheck the table to find the correct pixel aspect ratio.\n"

                    echo "________________SAR____|___PAR__|___DAR_____"
                    echo "Widescreen NTSC 720×480 -> 40:33 ->  704×480"
                    echo "                        -> 32:27 ->  853×480"
                    echo "Widescreen PAL  720×576 -> 64:45 -> 1024×576"
                    echo "                        -> 16:11 -> 1048×576"
                    echo "Fullscreen NTSC 720×480 ->  8:9  ->  640×480"
                    echo "                        -> 10:11 ->  654×480"
                    echo "Fullscreen PAL  720×576 -> 16:15 ->  768×576"
                    echo "                        -> 12:11 ->  786×576"
                    echo -e "\nAlmost all bluray is 1:1.\n"

                    unset par
                    until [[ $par =~ ^[[:digit:]]+:[[:digit:]]+$ ]] ; do
                    echo "Set PAR as fraction, use a colon."
                    echo -e "e.g. 16:15.\n"
                    read -e -p "> " par
                    done
                    # keep cfg informed
                    sed -i "/par/d" "${config%/*}/${source2%.*}.cfg"
                    echo "par=$par" >> "${config%/*}/${source2%.*}.cfg"
                ;;

                *)
                    # keep cfg informed
                    sed -i "/par/d" "${config%/*}/${source2%.*}.cfg"
                    echo "par=$par" >> "${config%/*}/${source2%.*}.cfg"
                ;;
            esac
    }

    function colormatrices {
        if [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 704 && $darheight0 == 480 ]] || [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 853 && $darheight0 == 480 ]] || [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 640 && $darheight0 == 480 ]] || [[ $sarwidth0 == 720 && $sarheight0 == 480 && $darwidth0 == 654 && $darheight0 == 480 ]] ; then
            # keep cfg informed
            sed -i "/colormatrixSD/d" "${config%/*}/${source2%.*}.cfg"
            echo "colormatrixSD=smpte170m" >> "${config%/*}/${source2%.*}.cfg"
            sed -i "/colorprimSD/d" "${config%/*}/${source2%.*}.cfg"
            echo "colorprimSD=smpte170m" >> "${config%/*}/${source2%.*}.cfg"

        elif [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 1024 && $darheight0 == 576 ]] || [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 1048 && $darheight0 == 576 ]] || [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 768 && $darheight0 == 576 ]] || [[ $sarwidth0 == 720 && $sarheight0 == 576 && $darwidth0 == 786 && $darheight0 == 576 ]] ; then
            sed -i "/colormatrixSD/d" "${config%/*}/${source2%.*}.cfg"
            echo "colormatrixSD=bt470bg" >> "${config%/*}/${source2%.*}.cfg"
            sed -i "/colorprimSD/d" "${config%/*}/${source2%.*}.cfg"
            echo "colorprimSD=bt470bg" >> "${config%/*}/${source2%.*}.cfg"
        fi
    }

    function cropping {
        echo -e "\nIf cropping may be needed,"
        echo -e "RETURN, else (n)o.\n"
        echo "AvsP > Video > Crop editor"
        echo "When checked, note values and close AvsPmod window."
        echo -e "»Apply«, then close with ALT+F4\n"

        read -e -p "Check now (RETURN|n) > " answer_crop
            case "$answer_crop" in
                n|no|N|No|NO) # do nothing here
                ;;

                *)
                    wine "$avspmod" "${source1%.*}".avs
                ;;
            esac

            echo -e "\nIf no cropping is needed, just type 0 (zero)."
            echo -e "All numbers unsigned, must be even.\n"

                    unset left_crop
                    unset top_crop
                    unset right_crop
                    unset bottom_crop

                    until [[ $left_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]]; do
                        echo "Number of pixels to be cropped on the"
                        read -e -p "left > " left_crop

                        # keep cfg informed
                        sed -i "/left_crop/d" "${config%/*}/${source2%.*}.cfg"
                        echo "left_crop=$left_crop" >> "${config%/*}/${source2%.*}.cfg"
                    done

                    until [[ $top_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]] ; do
                        echo "Number of pixels to be cropped on the"
                        read -e -p "top > " top_crop

                        # keep cfg informed
                        sed -i "/top_crop/d" "${config%/*}/${source2%.*}.cfg"
                        echo "top_crop=$top_crop" >> "${config%/*}/${source2%.*}.cfg"
                    done

                    until [[ $right_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]] ; do
                        echo "Number of pixels to be cropped on the"
                        read -e -p "right > " right_crop

                        # keep cfg informed
                        sed -i "/right_crop/d" "${config%/*}/${source2%.*}.cfg"
                        echo "right_crop=$right_crop" >> "${config%/*}/${source2%.*}.cfg"
                    done

                    until [[ $bottom_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]] ; do
                        echo "Number of pixels to be cropped on the"
                        read -e -p "bottom > " bottom_crop

                        # keep cfg informed
                        sed -i "/bottom_crop/d" "${config%/*}/${source2%.*}.cfg"
                        echo "bottom_crop=$bottom_crop" >> "${config%/*}/${source2%.*}.cfg"
                    done
    }

    function fillborders {
        unset left_fb
        unset top_fb
        unset right_fb
        unset bottom_fb

        echo -e "\nIf cropping left one or more dirty or black line"
        echo "of pixels on left or right side only, and top and bottom only,"
        echo -e "you can use fillborders.\n"
        echo "With one line of dirty or black pixels left AND right"
        echo "or top AND bottom, there are better solutions."
        echo -e "\nChoose not more than ONE pixel at each border!\n"
        echo "Do you want to use (f)illborders?"
        echo -e "Else, return\n"
        read -e -p "(RETURN|f) > " answer_fillborders
            case $answer_fillborders in
                f|F|fillborders|FillBorders)
                        # who needs more than 2 pixels for fillborders?
                    until [[ $left_fb =~ ^[0-2]$ ]] ; do
                        echo "Number of pixels on the"
                        read -e -p "left > " left_fb

                        # keep cfg informed
                        sed -i "/left_fb/d" "${config%/*}/${source2%.*}.cfg"
                        echo "left_fb=$left_fb" >> "${config%/*}/${source2%.*}.cfg"
                    done

                    until [[ $top_fb =~ ^[0-2]$ ]] ; do
                        echo "Number of pixels on the"
                        read -e -p "top > " top_fb

                        # keep cfg informed
                        sed -i "/top_fb/d" "${config%/*}/${source2%.*}.cfg"
                        echo "top_fb=$top_fb" >> "${config%/*}/${source2%.*}.cfg"
                    done

                    until [[ $right_fb =~ ^[0-2]$ ]] ; do
                        echo "Number of pixels on the"
                        read -e -p "right > " right_fb

                        # keep cfg informed
                        sed -i "/right_fb/d" "${config%/*}/${source2%.*}.cfg"
                        echo "right_fb=$right_fb" >> "${config%/*}/${source2%.*}.cfg"
                    done

                    until [[ $bottom_fb =~ ^[0-2]$ ]] ; do
                        echo "Number of pixels on the"
                        read -e -p "bottom > " bottom_fb

                        # keep cfg informed
                        sed -i "/bottom_fb/d" "${config%/*}/${source2%.*}.cfg"
                        echo "bottom_fb=$bottom_fb" >> "${config%/*}/${source2%.*}.cfg"
                    done
                ;;

                *)
                    # keep cfg informed
                    sed -i "/left_fb/d" "${config%/*}/${source2%.*}.cfg"
                    sed -i "/top_fb/d" "${config%/*}/${source2%.*}.cfg"
                    sed -i "/right_fb/d" "${config%/*}/${source2%.*}.cfg"
                    sed -i "/bottom_fb/d" "${config%/*}/${source2%.*}.cfg"
                ;;
            esac
    }

    function getresolutionSD {
        # if resolution is SD has to be checked before function is used
        refSD=$(echo "scale=0;32768/((("$sarwidth1"/16)+0.5)/1 * (("$sarheight1"/16)+0.5)/1)"|bc)
        # keep cfg informed
        sed -i "/refSD/d" "${config%/*}/${source2%.*}.cfg"
        echo "refSD=$refSD" >> "${config%/*}/${source2%.*}.cfg"
    }

    function setresolution480 {
        max480width="854"
        unset width480
        until (( $width480 <= $max480width )) 2> /dev/null && [[ $width480 =~ ^[[:digit:]]+$ && $width480 -gt 0  ]]; do
            echo -e "\nSet width for 480p\n"
            read -e -p "width > " width480

            sed -i "/width480/d" "${config%/*}/${source2%.*}.cfg"
            echo "width480=$width480" >> "${config%/*}/${source2%.*}.cfg"
        done

        max480height="480"
        unset height480
        until (( $height480 <= $max480height )) 2> /dev/null && [[ $height480 =~ ^[[:digit:]]+$ && $height480 -gt  0 ]] ; do
            echo -e "\nSet height for 480p\n"
            read -e -p "height > " height480

            sed -i "/height480/d" "${config%/*}/${source2%.*}.cfg"
            echo "height480=$height480" >> "${config%/*}/${source2%.*}.cfg"
        done

        ref480=$(echo "scale=0;32768/((("$width480"/16)+0.5)/1 * (("$height480"/16)+0.5)/1)"|bc)
        # keep cfg informed
        sed -i "/ref480/d" "${config%/*}/${source2%.*}.cfg"
        echo "ref480=$ref480" >> "${config%/*}/${source2%.*}.cfg"
    }

    function targetresolution480 {
        if [[ -e $width480 && -e $height480 ]]; then
            echo "Resolution for 480p encoding is $width480×$height480"
            echo "Do you want to (e)dit the values?"
            read -e -p "(Return|e) > " answer_targetres480

            case $answer_targetres480 in
                e|E|edit|Edit)
                setresolution480
                ;;

                *)
                ;;
            esac
        else
            setresolution480
        fi
    }

    function setresolution576 {
        max576width="1024"
        unset width576
        until (( $width576 <= $max576width )) 2> /dev/null && [[ $width576 =~ ^[[:digit:]]+$ && $width576 -gt  0 ]] ; do
            echo -e "\nSet width for 576p\n"
            read -e -p "width > " width576

            sed -i "/width576/d" "${config%/*}/${source2%.*}.cfg"
            echo "width576=$width576" >> "${config%/*}/${source2%.*}.cfg"
        done

        max576height="576"
        unset height576
        until (( $height576 <= $max576height )) 2> /dev/null && [[ $height576 =~ ^[[:digit:]]+$ && $height576 -gt  0 ]] ; do
            echo -e "\nSet height for 576p\n"
            read -e -p "height > " height576

            sed -i "/height576/d" "${config%/*}/${source2%.*}.cfg"
            echo "height576=$height576" >> "${config%/*}/${source2%.*}.cfg"
        done

        ref576=$(echo "scale=0;32768/((("$width576"/16)+0.5)/1 * (("$height576"/16)+0.5)/1)"|bc)
        # keep cfg informed
        sed -i "/ref576/d" "${config%/*}/${source2%.*}.cfg"
        echo "ref576=$ref576" >> "${config%/*}/${source2%.*}.cfg"
    }

    function targetresolution576 {
        if [[ -e $width576 && -e $height576 ]]; then
            echo "Resolution for 576p encoding is $width576×$height576"
            echo "Do you want to (e)dit the values?"
            read -e -p "(Return|e) > " answer_targetres576

            case $answer_targetres576 in
                e|E|edit|Edit)
                setresolution576
                ;;

                *)
                ;;
            esac
        else
            setresolution576
        fi
    }

    function setresolution720 {
        max720width="1280"
        unset width720
        until (( $width720 <= $max720width )) 2> /dev/null && [[ $width720 =~ ^[[:digit:]]+$ && $width720 -gt  0 ]] ; do
            echo -e "\nSet width for 720p\n"
            read -e -p "width > " width720

            sed -i "/width720/d" "${config%/*}/${source2%.*}.cfg"
            echo "width720=$width720" >> "${config%/*}/${source2%.*}.cfg"
        done

        max720height="720"
        unset height720
        until (( $height720 <= $max720height )) 2> /dev/null && [[ $height720 =~ ^[[:digit:]]+$ && $height720 -gt  0 ]] ; do
            echo -e "Set height for 720p\n"
            read -e -p "height > " height720

            sed -i "/height720/d" "${config%/*}/${source2%.*}.cfg"
            echo "height720=$height720" >> "${config%/*}/${source2%.*}.cfg"
        done

        ref720=$(echo "scale=0;32768/((("$width720"/16)+0.5)/1 * (("$height720"/16)+0.5)/1)"|bc)
        # keep cfg informed
        sed -i "/ref720/d" "${config%/*}/${source2%.*}.cfg"
        echo "ref720=$ref720" >> "${config%/*}/${source2%.*}.cfg"
    }

    function targetresolution720 {
        if [[ -e $width720 && -e $height720 ]]; then
        echo "Resolution for 720p encoding is $width720×$height720"
        echo "Do you want to (e)dit the values?"
        read -e -p "(RETURN|e) > " answer_targetres720
            case $answer_targetres720 in
                e|E|edit|Edit)
                    setresolution720
                ;;

                *)
                ;;
            esac
        else
            setresolution720
        fi
    }

    function getresolution1080 {
        # if resolution is 1080 will be checked before function is used
        width1080=$(echo "$sarwidth0-$left_crop-$right_crop"|bc)
        height1080=$(echo "$sarheight0-$top_crop-$bottom_crop"|bc)

        sed -i "/width1080/d" "${config%/*}/${source2%.*}.cfg"
        echo "width1080=$width1080" >> "${config%/*}/${source2%.*}.cfg"
        sed -i "/height1080/d" "${config%/*}/${source2%.*}.cfg"
        echo "height1080=$height1080" >> "${config%/*}/${source2%.*}.cfg"

        ref1080=$(echo "scale=0;32768/((("$width1080"/16)+0.5)/1 * (("$height1080"/16)+0.5)/1)"|bc)
        # keep cfg informed
        sed -i "/ref1080/d" "${config%/*}/${source2%.*}.cfg"
        echo "ref1080=$ref1080" >> "${config%/*}/${source2%.*}.cfg"
    }

    function avsSD {
        # generate a new avs file anyway
        # keep cfg informed
        sed -i "/finalavsSD/d" "${config%/*}/${source2%.*}.cfg"
        echo "finalavsSD=${source1%.*}.SD.final.avs" >> "${config%/*}/${source2%.*}.cfg"
        echo "LoadPlugin(\""$lsmashsource"\")" > "${source1%.*}".SD.final.avs
        echo "LWLibavVideoSource(\"$source1\").propDelete(\"_FieldBased\")" >> "${source1%.*}".SD.final.avs
        echo "#greyscale" >> "${source1%.*}".SD.final.avs
        echo "#interlaced" >> "${source1%.*}".SD.final.avs
        echo "#telecined" >> "${source1%.*}".SD.final.avs
        echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".SD.final.avs
        echo "#fillborders0" >> "${source1%.*}".SD.final.avs
        echo "#fillborders1" >> "${source1%.*}".SD.final.avs
    }

    function avs480 {
        # generate a new avs file anyway
        # keep cfg informed
        sed -i "/finalavs480/d" "${config%/*}/${source2%.*}.cfg"
        echo "finalavs480=${source1%.*}.480.final.avs" >> "${config%/*}/${source2%.*}.cfg"
        echo "LoadPlugin(\""$lsmashsource"\")" > "${source1%.*}".480.final.avs
        echo "LWLibavVideoSource(\"$source1\")" >> "${source1%.*}".480.final.avs
        echo "#greyscale" >> "${source1%.*}".480.final.avs
        echo "#interlaced" >> "${source1%.*}".480.final.avs
        echo "#telecined" >> "${source1%.*}".480.final.avs
        echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".480.final.avs
        echo "#fillborders0" >> "${source1%.*}".480.final.avs
        echo "#fillborders1" >> "${source1%.*}".480.final.avs
        echo "LoadPlugin (\"$z_resize\")" >> "${source1%.*}".480.final.avs
        ### To BE CHECKED FF
        if [[ ( -n $left_fb && -n $right_fb && -n $top_fb && -n $bottom_fb ) ]]; then
            echo "$resize($width480, $height480, $left_fb, $top_fb, -$right_fb, -$bottom_fb, dither=\"error_diffusion\")" >> "${source1%.*}".480.final.avs
        else
            echo "$resize($width480, $height480)" >> "${source1%.*}".480.final.avs
        fi
    }

    function avs576 {
        # generate a new avs file anyway
        # keep cfg informed
        sed -i "/finalavs576/d" "${config%/*}/${source2%.*}.cfg"
        echo "finalavs576=${source1%.*}.576.final.avs" >> "${config%/*}/${source2%.*}.cfg"
        echo "LoadPlugin(\""$lsmashsource"\")" > "${source1%.*}".576.final.avs
        echo "LWLibavVideoSource(\"$source1\")" >> "${source1%.*}".576.final.avs
        echo "#greyscale" >> "${source1%.*}".576.final.avs
        echo "#interlaced" >> "${source1%.*}".576.final.avs
        echo "#telecined" >> "${source1%.*}".576.final.avs
        echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".576.final.avs
        echo "#fillborders0" >> "${source1%.*}".576.final.avs
        echo "#fillborders1" >> "${source1%.*}".576.final.avs
        echo "LoadPlugin (\"$z_resize\")" >> "${source1%.*}".576.final.avs
        if [[ ( -n $left_fb && -n $right_fb && -n $top_fb && -n $bottom_fb ) ]]; then
            echo "$resize($width576, $height576, $left_fb, $top_fb, -$right_fb, -$bottom_fb, dither=\"error_diffusion\")" >> "${source1%.*}".576.final.avs
        else
            echo "$resize($width576, $height576)" >> "${source1%.*}".576.final.avs
        fi
    }

    function avs720 {
        # generate a new avs file anyway
        # keep cfg informed
        sed -i "/finalavs720/d" "${config%/*}/${source2%.*}.cfg"
        echo "finalavs720=${source1%.*}.720.final.avs" >> "${config%/*}/${source2%.*}.cfg"
        echo "LoadPlugin(\""$lsmashsource"\")" > "${source1%.*}".720.final.avs
        echo "LWLibavVideoSource(\"$source1\")" >> "${source1%.*}".720.final.avs
        echo "#greyscale" >> "${source1%.*}".720.final.avs
        echo "#interlaced" >> "${source1%.*}".720.final.avs
        echo "#telecined" >> "${source1%.*}".720.final.avs
        echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".720.final.avs
        echo "#fillborders0" >> "${source1%.*}".720.final.avs
        echo "#fillborders1" >> "${source1%.*}".720.final.avs
        echo "LoadPlugin (\"$z_resize\")" >> "${source1%.*}".720.final.avs
        if [[ ( -n $left_fb && -n $right_fb && -n $top_fb && -n $bottom_fb ) ]]; then
            echo "$resize($width720, $height720, $left_fb, $top_fb, -$right_fb, -$bottom_fb, dither=\"error_diffusion\")" >> "${source1%.*}".720.final.avs
        else
            echo "$resize($width720, $height720)" >> "${source1%.*}".720.final.avs
        fi
    }

    function avs1080 {
        # generate a new avs file anyway
        # keep cfg informed
        sed -i "/finalavs1080/d" "${config%/*}/${source2%.*}.cfg"
        echo "finalavs1080=${source1%.*}.1080.final.avs" >> "${config%/*}/${source2%.*}.cfg"
        echo "LoadPlugin(\""$lsmashsource"\")" > "${source1%.*}".1080.final.avs
        echo "LWLibavVideoSource(\"$source1\")" >> "${source1%.*}".1080.final.avs
        echo "#greyscale" >> "${source1%.*}".1080.final.avs
        echo "#interlaced" >> "${source1%.*}".1080.final.avs
        echo "#telecined" >> "${source1%.*}".1080.final.avs
        echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".1080.final.avs
        echo "#fillborders0" >> "${source1%.*}".1080.final.avs
        echo "#fillborders1" >> "${source1%.*}".1080.final.avs
        # no resize necessary
    }

    function testavsSD {
        cp "${source1%.*}".SD.final.avs "${source1%.*}".SD.test.avs
        echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".SD.test.avs
        # keep cfg informed
        sed -i "/testavsSD/d" "${config%/*}/${source2%.*}.cfg"
        echo "testavsSD=${source1%.*}.SD.test.avs" >> "${config%/*}/${source2%.*}.cfg"
    }

    function testavs480 {
        cp "${source1%.*}".480.final.avs "${source1%.*}".480.test.avs
        echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".480.test.avs
        # keep cfg informed
        sed -i "/testavs480/d" "${config%/*}/${source2%.*}.cfg"
        echo "testavs480=${source1%.*}.480.test.avs" >> "${config%/*}/${source2%.*}.cfg"
    }

    function testavs576 {
        cp "${source1%.*}".576.final.avs "${source1%.*}".576.test.avs
        echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".576.test.avs
        # keep cfg informed
        sed -i "/testavs576/d" "${config%/*}/${source2%.*}.cfg"
        echo "testavs576=${source1%.*}.576.test.avs" >> "${config%/*}/${source2%.*}.cfg"
    }

    function testavs720 {
        cp "${source1%.*}".720.final.avs "${source1%.*}".720.test.avs
        echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".720.test.avs
        # keep cfg informed
        sed -i "/testavs720/d" "${config%/*}/${source2%.*}.cfg"
        echo "testavs720=${source1%.*}.720.test.avs" >> "${config%/*}/${source2%.*}.cfg"
    }

    function testavs1080 {
        cp "${source1%.*}".1080.final.avs "${source1%.*}".1080.test.avs
        echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".1080.test.avs
        # keep cfg informed
        sed -i "/testavs1080/d" "${config%/*}/${source2%.*}.cfg"
        echo "testavs1080=${source1%.*}.1080.test.avs" >> "${config%/*}/${source2%.*}.cfg"
    }

    basic_avs

    if [[ -z $par ]]; then
        par
    else
        echo -e "\nPAR for "$source2" is ${par##*=}\n"
        echo "RETURN to continue"
        echo -e "To change it, (p)ar\n"
        read -e -p "(RETURN|p) > " answer_par
            case $answer_par in
                p|P|par|PAR)
                    par
                ;;

                *) # nothing
                ;;
            esac
    fi
    # keep cfg informed
    sed -i "/par/d" "${config%/*}/${source2%.*}.cfg"
    echo "par=$par" >> "${config%/*}/${source2%.*}.cfg"
    # for anamorphic sources SAR -> DAR calculation needed
    par_divider=$(echo $par|cut -d: -f1)
    par_denominator=$(echo $par|cut -d: -f2)

    colormatrices

    if [[ ( -n $left_crop && -n $right_crop && -n $top_crop && -n $bottom_crop ) ]]; then
        echo -e "\nCropping values for "$source2":"
        echo "Left:   $left_crop"
        echo "Top:    $top_crop"
        echo "Right:  $right_crop"
        echo -e "Bottom: $bottom_crop\n"
        echo "Do you want to (e)dit them?"
        echo "Else, RETURN"
        read -e -p "(RETURN|e) > " answer_cropedit
            case $answer_cropedit in
                e|E|edit|EDIT|Edit)
                    cropping
                ;;

                *) # do nothing here
                ;;
            esac
    else
        cropping
    fi

    # resolution after cropping, independent from target resolution
    sarwidth1=$(echo "$sarwidth0-$left_crop-$right_crop"|bc)
    sarheight1=$(echo "$sarheight0-$top_crop-$bottom_crop"|bc)
    sed -i "/sarwidth1/d" "${config%/*}/${source2%.*}.cfg"
    echo "sarwidth1=$sarwidth1" >> "${config%/*}/${source2%.*}.cfg"
    sed -i "/sarheight1/d" "${config%/*}/${source2%.*}.cfg"
    echo "sarheight1=$sarheight1" >> "${config%/*}/${source2%.*}.cfg"

    # fillborders in case of 1 line of black or dirty pixels
    # note: editing the avs files will happen at the very end of option 2
    if [[ ( -n $left_fb && -n $right_fb && -n $top_fb && -n $bottom_fb ) ]]; then
        echo -e "\nFillborders values for "$source2":"
        echo -e "Left:\t $left_fb"
        echo -e "Top:\t $top_fb"
        echo -e "right:\t $right_fb"
        echo -e "Bottom:\t $bottom_fb\n"
        echo "Do you want to (e)dit them?"
        echo "Else, RETURN"
        read -e -p "(RETURN|e) > " answer_fillbordersedit
            case $answer_fillbordersedit in
                e|E|edit|EDIT|Edit)
                    fillborders
                ;;

                *) # do nothing here
                ;;
            esac
    else
        fillborders
    fi

    function avscollection {
        targetresolution480
        targetresolution576
        targetresolution720
        getresolution1080
        avs480
        testavs480
        avs576
        testavs576
        avs720
        testavs720
        avs1080
        testavs1080
    }

    # resizing only for hd sources
    # generate final.avs and test.avs for all resolutions
    # if sarheight0 and sarwidth0 indicate standard resolution, treat as SD
    if [[ $sarheight0 -gt 576 && $sarwidth0 -gt 720 ]]; then
        echo -e "\nIf you want to resize, check"
        echo -e "for correct target resolution!\n"

        echo "To check with AvsPmod for correct"
        echo "target file resolution, RETURN"
        echo -e "Else, e(x)it\n"

        echo "AvsP > Tools > Resize calculator"
        echo "After cropping, the source's resolution is $sarwidth1×$sarheight1,"
        echo "The PAR is $par"
        echo "When checked, note values and do NOT »apply«"
        echo "Close AvsPmod window with ALT+F4"
        read -e -p "(RETURN|x) > " answer_resizecalc
            case "$answer_resizecalc" in
                x|X)
                avscollection
                ;;

                *)
                    wine "$avspmod" "${source1%.*}".avs
                    unset width480
                    unset height480
                    unset width576
                    unset height576
                    unset width720
                    unset height720
                    unset width1080
                    unset height1080
                    avscollection
                ;;
            esac
    else
        getresolutionSD
        avsSD
        testavsSD
        echo "Encoding $1 with SAR $sarwidth1×$sarheight1 and PAR=$par,"

        if [[ $par = @(32:27|64:45|16:11|16:15|12:11) ]]; then
            darwidth1=$(echo "$sarwidth1 * $par_divider/$par_denominator"|bc)
            echo "Resulting in a DAR of ~$darwidth1×$sarheight1"
            # keep cfg informed
            sed -i "/darwidth1/d" "${config%/*}/${source2%.*}.cfg"
            echo "darwidth1=$darwidth1" >> "${config%/*}/${source2%.*}.cfg"

        elif [[ $par = @(40:33|8:9|10:11) ]]; then
            darheight1=$(echo "$sarheight1 * $par_denominator/$par_divider"|bc)
            echo "Resulting in a DAR of ~$sarwidth1×$darheight1"
            # keep cfg informed
            sed -i "/darheight1/d" "${config%/*}/${source2%.*}.cfg"
            echo "darheight1=$darheight1" >> "${config%/*}/${source2%.*}.cfg"
        fi
    fi

    echo -e "\nIs source or should the encode be"
    echo -e "black and white?"
    echo -e "(y)es, else RETURN\n"
    read -e -p "(RETURN|y) > " answer_blackwhite
        case "$answer_blackwhite" in
            y|Y|yes|YES) # blackwhite
                sed -i "/greyscale/d" ${config%/*}/${source2%.*}.cfg
                echo "greyscale=1" >> ${config%/*}/${source2%.*}.cfg
                for i in "${source1%.*}"*.avs ; do
                    sed -i "s/#greyscale/greyscale()/" "$i"
                done
            ;;

            *) # color
                sed -i "/greyscale/d" ${config%/*}/${source2%.*}.cfg
                echo "greyscale=0" >> ${config%/*}/${source2%.*}.cfg
            ;;
        esac

    # check source for being interlaced and/or telecined
    echo -e "\nCheck, if movie is interlaced\n"

    if [[ $(mediainfo "$source1"|awk '/Scan type/{print $4}'|wc -c) -ne 0 ]]; then
        echo -n "Mediainfo says: "
        echo -e "$(mediainfo "$source1"|awk '/Scan type/{print $4}')\n"
    fi

    if [[ $(exiftool "$source1"|awk '/Scan Type/{print $5}'|wc -c) -ne 0 ]]; then
        echo -n "Exiftool says: "
        echo -e "$(exiftool "$source1"|awk '/Scan Type/{print $5}')\n"
    fi
    read -p "RETURN to continue"

    echo -e "\nDo you want to (c)heck with AvsPmod frame by frame,"
    echo "if movie is interlaced and/or telecined?"
    echo "If yes, close AvsPmod window afterwards."
    echo -e "Else, RETURN\n"
    read -e -p "(RETURN|c) > " answer_check_interlaced_telecined
        case "$answer_check_interlaced_telecined" in
            c|C|check|Check)
                wine "$avspmod" "${source1%.*}".avs
            ;;

            *)
            ;;
        esac

    echo -e "\nCharacteristics of video source:"
    echo "(i)nterlaced"
    echo "(t)elecined"
    echo "(b)oth: interlaced and telecined"
    echo -e "(n)either nor\n"
    read -e -p "(i|t|b|n) > " answer_interlaced_telecined
        case "$answer_interlaced_telecined" in
            i|I) # interlaced
                sed -i "/interlaced/d" ${config%/*}/${source2%.*}.cfg
                echo "interlaced=1" >> ${config%/*}/${source2%.*}.cfg
                for i in "${source1%.*}"*.avs ; do
                    sed -i "s/#interlaced/QTGMC().SelectEven()/" "$i"
                done
            ;;

            t|T) # telecined
                sed -i "/telecined/d" ${config%/*}/${source2%.*}.cfg
                echo "telecined=1" >> ${config%/*}/${source2%.*}.cfg
                for i in "${source1%.*}"*.avs ; do
                    sed -i "s/#telecined/TFM(pp=0).TDecimate()/" "$i"
                done
            ;;

            b|B) # interlaced and telecined
                sed -i "/interlaced/d" "${config%/*}/${source2%.*}.cfg"
                echo "interlaced=1" >> "${config%/*}/${source2%.*}.cfg"
                sed -i "/telecined/d" "${config%/*}/${source2%.*}.cfg"
                echo "telecined=1" >> "${config%/*}/${source2%.*}.cfg"
                for i in "${source1%.*}"*.avs ; do
                    sed -i "s/#interlaced/QTGMC().SelectEven()/" "$i"
                    sed -i "s/#telecined/TFM(pp=0).TDecimate()/" "$i"
                done
            ;;

            n|N) # neither interlaced nor telecined
                sed -i "/interlaced/d" "${config%/*}/${source2%.*}.cfg"
                echo "interlaced=0" >> "${config%/*}/${source2%.*}.cfg"
                sed -i "/telecined/d" "${config%/*}/${source2%.*}.cfg"
                echo "telecined=0" >> "${config%/*}/${source2%.*}.cfg"
            ;;
        esac

    # fillborders editing the avs files
    if [[ $left_fb -ne 0 || $top_fb -ne 0 || $right_fb -ne 0 || $bottom_fb -ne 0 ]]; then
        for i in ${source1%.*}.*.avs ; do
            sed -i "s|#fillborders0|LoadPlugin(\"$pathfb\")|" "$i"
            sed -i "s|#fillborders1|FillBorders($left_fb,$top_fb,$right_fb,$bottom_fb)|" "$i"
        done
     fi

     # generate a qpfile for frameexact chapter marks
    function makeqpfile {
    echo -e "\nEnter path to chapter file"
    echo -e "If there is no chapter file, press (n)o.\n"
        read -e -p "(PATH|n) > " chapter_file_exist
            case "$chapter_file_exist" in
                n|N|no|No|NO)
                    touch > "${config%/*}/${source2%.*}.qpfile.txt"
                ;;

                *)
                    # read the framerate from the source file
                    framerate=$(mediainfo ${source1}|grep -m 1 FPS|cut -d ':' -f2|cut -d ' ' -f2)
                    # empty a prevalent qpfile
                    touch > "${config%/*}/${source2%.*}.qpfile.txt"
                    # check on and correct the timings in your chapter file
                    echo -e "\nCheck timings in your chapter file and correct them as neccessary\n"
                    $EDITOR "$chapter_file_exist" & wine "$avspmod" "${source1%.*}".avs
                    # read the timings and translate to framenumbers
                    while IFS= read -r line ; do
                        if [[ ! $line =~ NAME= ]] ; then
                            timings=$(echo $line|cut -d '=' -f2| awk -F: '{print ($1*3600)+($2*60)+($3)}')
                            framenumber=$(echo "scale=0;((($timings)*($framerate))+0.5)/1"|bc )
                            printf "$framenumber I\n" >> "${config%/*}/${source2%.*}.qpfile.txt"
                        fi
                    done < $chapter_file_exist
                ;;
            esac
}

    makeqpfile

    # if sarheight0 and sarwidth0 indicate standard resolution, treat as SD
    # else adequate to chosen <resolution>
    echo -e "\nUse the corresponding config file"
    echo "Start the script like this:"

    if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
        echo -e "\n./encode.sh ${source2%.*} SD\n"
    else
        echo -e "\n./encode.sh ${source2%.*} <resolution>"
        echo -e "where resolution might be 480, 576, 720 or 1080\n"
    fi

    echo -e "\nContinue with option 3.\n"
    ;;

    3)  # 3 - test encodes for crf

    function test_crf1 {
        # until high>low and crf1low 1-530 and crf1high 1-530 and increment 1-530; do
        until [[ $crf1high -ge $crf1low && $crf1low =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf1high =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf1increment =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ ]]; do
            echo "crf: values 1 through 53, default is 23"
            echo -e "Test with values around 15 through 19\n"
            echo "Set lowest crf value as hundreds,"
            echo -e "e.g. 164 for 16.4\n"

            read -e -p "crf, lowest value > " crf1low

            echo -e "Set highst crf value as hundreds,"
            echo -e "e.g. 186 for 18.6\n"

            read -e -p "crf, maximum value > " crf1high

            echo "Set increment steps, e.g. 1 for 0.1,"
            echo -e "but ≠0\n"
            read -e -p "Increments > " crf1increment
        done

        # Number of test encodings
        number_encodings=$(echo "((($crf1high-$crf1low)/$crf1increment)+1)"|bc)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting crf will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for (( crf1=$crf1low; $crf1<=$crf1high; crf1+=$crf1increment)); do
            if [[ $crf1 = $crf1low ]]; then
                echo -e "\nRange crf *$crf1low* → $crf1high, increment $crf1increment; $encodings_left of $number_encodings encodings left."
            elif [[ $crf1 = $crf1high ]]; then
                echo -e "\nRange crf $crf1low → *$crf1high*, increment $crf1increment; $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange crf $crf1low → *$crf1* → $crf1high, increment $crf1increment; $encodings_left of $number_encodings encodings left."
            fi

            # Name the files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.crf$crf1.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

            # Write CRF values into log files, no newline at the end of line
            echo -en "\ncrf $(echo "scale=1;$crf1/10"|bc) : " | tee -a "${source1%.*}".$2.crf1.log >/dev/null

             wine "$avs2yuv" "${avs##*=}" - \
             | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
             --crf $(printf '%s.%s' "$(($crf1/10))" "$(($crf1%10))") \
             --preset "$preset" \
             --profile "$profile" \
             --ref "${ref##*=}" \
             --sar "$par" \
             --rc-lookahead "${lookahead##*=}" \
             --me "$me" \
             --merange "$merange" \
             --subme "$subme" \
             --deblock "${deblocka##*=}":"${deblockb##*=}" \
             --aq-strength "${aqs##*=}" \
             --aq-mode "${aqmode##*=}" \
             --no-psy \
             --chroma-qp-offset "${cqpo##*=}" \
             -o "${source1%.*}".$2.$count.crf$crf1.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log|tee "${source1%.*}".$2.crf1-raw.log;

            # Append file name into avs file
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.crf$crf1.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 crf$crf1\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            # Write the encodings bit rate into the crf1 log file
            egrep 'x264 \[info\]: kb\/s:' "${source1%.*}".$2.crf1-raw.log|cut -d':' -f3|tail -1 >> "${source1%.*}".$2.crf1.log
            rm "${source1%.*}".$2.crf1-raw.log

            encoding_stoptime
            echo -e "\nEncoding "${source2%.*}".$2.$count.crf$crf1.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for crf integers lasted $time"

        screen_comparison_and_cleanup "${source1%.*}".$2.crf1.$crf1low-$crf1high-$crf1increment.avs $2

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        # Display bitrate from logfile
        if [[ -e "${source1%.*}".$2.crf1.log ]] ; then
            echo -e "\nbit rates:"
            column -t "${source1%.*}".$2.crf1.log|sort -u
            echo
        fi

        echo "Examine these encodings."
        echo "When you recognize detail loss in still images,"
        echo "you may have found your crf."
        echo -e "Then close AvsPmod.\n"
        echo "There will be another round of testing"
        echo -e "you can determine the final crf value.\n"
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.crf1.*.avs
}

    function set_crf1 {
        until [[ $crf_1 =~ ^[0-4][0-9]\.[0-9]|[5][0-2]\.[0-9]|53\.0$ ]] ; do
            echo "Set crf value for $2"
            echo "e.g. 17.3"
            read -e -p "crf > " crf_1
        done
        # keep cfg informed
        sed -i "/crf$2/d" "$config"
        echo "crf$2=$crf_1" >> "$config"
        # corresponding bit rate
        br=$(cat "${source1%.*}".$2.crf1.log|grep "crf $crf_1"|cut -d':' -f2|cut -d' ' -f2|cut -d'.' -f1|sort -u)
        # keep cfg informed
        sed -i "/br$2/d" "$config"
        echo "br$2=$br" >> "$config"

        br_change $1 $2
}

while true; do
        echo "Choose crf values for"
        echo "your test encodings of "${source2%.*}" in $2."
        echo -e "\nCrf is ${crf##*=}."

        echo "RETURN for more testing on crf,"
        echo -e "else e(x)it\n"

        read -e -p "(RETURN|x) > " answer_crf1
            case $answer_crf1 in
                x|X) # get out of the loop
                    break
                ;;

                *)
                    unset crf1low
                    unset crf1high
                    unset crf1increment
                    test_crf1 $1 $2
                ;;
            esac
    done
    set_crf1 $1 $2

    echo -e "\nContinue with option 4.\n"
    ;;

    4)  # 4 - first round testing for deblock values

    function test_deblocka1 {
        deblockahigh=-1
        deblockalow=-3
        # Number of test encodings
        number_encodings=$(expr "$deblockahigh" - "$deblockalow" + 1)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting deblock alpha will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((deblocka=$deblockalow; $deblocka<=$deblockahigh; deblocka=$deblocka+1));do
            if [[ $deblocka = $deblockalow ]]; then
                echo -e "\nRange deblock alpha *$deblockalow* → $deblockahigh, $encodings_left of $number_encodings encodings left."
            elif [[ $deblocka = $deblockahigh ]]; then
                echo -e "\nRange deblock alpha $deblockalow → *$deblockahigh*, $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange deblock alpha $deblockalow → *$deblocka* → $deblockahigh, $encodings_left of $number_encodings encodings left."
            fi

            # Name the files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.dba1$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

             wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 1 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.dba1.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "$deblocka":"$deblocka" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

            wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 2 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.dba1.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "$deblocka":"$deblocka" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o ""${source1%.*}".$2.$count.br${br##*=}.dba1$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv" - 2>&1|tee -a "${source1%.*}".$2.log;

            # Append name into avs file for comparisons
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.dba1$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 deblock $deblocka:$deblocka\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            encoding_stoptime
            echo -e "\nEncoding "${source2%.*}".$2.$count.br${br##*=}.dba1$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for deblock lasted $time\n"

        screen_comparison_and_cleanup "${source1%.*}".$2.dba1.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo "Have a look at these encodings."
        echo "Which deblock alpha looks best?"
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.dba1.avs
    }

    function test_deblockb1 {
        deblockbhigh=-1
        deblockblow=-3
        # Number of test encodings
        number_encodings=$(expr "$deblockbhigh" - "$deblockblow" + 1)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting deblock beta will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((deblockb=$deblockblow; $deblockb<=$deblockbhigh; deblockb=$deblockb+1));do
            if [[ $deblockb = $deblockblow ]]; then
                echo -e "\nRange deblock beta *$deblockblow* → $deblockbhigh, $encodings_left of $number_encodings encodings left."
            elif [[ $deblockb = $deblockbhigh ]]; then
                echo -e "\nRange deblock beta $deblockblow → *$deblockbhigh*, $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange deblock beta $deblockblow → *$deblockb* → $deblockbhigh, $encodings_left of $number_encodings encodings left."
            fi

            # Name the files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.dbb1${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

            wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 1 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.dbb1.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "${deblocka##*=}":"$deblockb" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

            wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 2 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.dbb1.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "${deblocka##*=}":"$deblockb" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o ""${source1%.*}".$2.$count.br${br##*=}.dbb1${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv" - 2>&1|tee -a "${source1%.*}".$2.log;

            # Append name into avs file for comparisons
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.dbb1${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 deblock ${deblocka##*=}:$deblockb\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            encoding_stoptime
            echo -e "\nEncoding "${source2%.*}".$2.$count.br${br##*=}.dbb1${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for deblock lasted $time\n"

        screen_comparison_and_cleanup "${source1%.*}".$2.dbb1.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo "Have a look at these encodings."
        echo "Which deblock beta looks best?"
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.dbb1.avs
    }

    function set_deblocka {
        until [[ $deblocka =~ ^[-+]?[1-3]$ ]] ; do
            echo "Set deblock alpha value for $2 of "${source2%.*}""
            echo "Sensible values between -3 and -1"
            read -e -p "(-3 up to 3) > " deblocka
        done
        # keep cfg informed
            sed -i "/deblocka$2/d" "$config"
            echo "deblocka$2=$deblocka" >> "$config"
    }

    function set_deblockb {
        until [[ $deblockb =~ ^[-+]?[1-3]$ ]] ; do
            echo -e "\nSet deblock beta value for $2 of "${source2%.*}""
            echo "Sensible values near deblock alpha, (${deblocka##*=})"
            read -e -p "(-3 up to 3) > " deblockb
        done
            # keep cfg informed
            sed -i "/deblockb$2/d" "$config"
            echo "deblockb$2=$deblockb" >> "$config"
    }

    while true; do
        echo -e "\nTest for deblock settings in "${source2%.*}" in $2"
        echo -e "deblock alpha is ${deblocka##*=} and deblock beta is ${deblockb##*=}\n"

        echo "Press (a)lpha for test for deblock alpha."
        echo "Press (b)eta for test for deblock beta."
        echo "Press (s)et for setting values without further testing"
        echo -e "or e(x)it.\n"
        read -e -p "(a|b|s|x) > " answer_db
            case $answer_db in
                x|X) #nothing here
                    break
                ;;

                s|S|set|SET)
                    set_deblocka $1 $2
                    set_deblockb $1 $2
                    br_change $1 $2
                    break
                ;;

                a|A|alpha|ALPHA)
                    unset deblocka
                    test_deblocka1 $1 $2
                    set_deblocka $1 $2
                    br_change $1 $2
                ;;

                b|B|beta|BETA)
                    unset deblockb
                    test_deblockb1 $1 $2
                    set_deblockb $1 $2
                    br_change $1 $2
                ;;
            esac
    done

    echo -e "\nContinue with option 5 - mbtree"
    echo -e "or option 6 - variations in qcomp.\n"
    ;;

    5)  # 5 - testing for mb-tree

    function test_mbtree {
        echo -e "\nThis will result in 2 encodings:"
        echo "mb-tree enabled and --no-mbtree."

        encoding_starttime_global_tempfile

        # Name the files in ascending order depending on the number of existing mkv in directory
        count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

        echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.mbt.cqpo${cqpo##*=}.mkv…\n"

        encoding_starttime

        wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m \
            --bitrate "${br##*=}" \
            --pass 1 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.mbt.cqpo${cqpo##*=}.stats" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "$lookaheadno" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-strength "${aqs##*=}" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --no-psy \
            --chroma-qp-offset "${cqpo##*=}" \
            --qcomp "${qcomp##*=}" \
            -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

        wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m \
            --bitrate "${br##*=}" \
            --pass 2 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.mbt.cqpo${cqpo##*=}.stats" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "$lookaheadno" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-strength "${aqs##*=}" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --no-psy \
            --chroma-qp-offset "${cqpo##*=}" \
            --qcomp "${qcomp##*=}" \
            -o ""${source1%.*}".$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.mbt.cqpo${cqpo##*=}.mkv" - 2>&1|tee -a "${source1%.*}".$2.log;

        # Append list of encodings into comparison screen avs file
        echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 mbtree\", "$align_position").LWLInfo()#.trim(0,framecount)" > "$temp_file"

        # Name the files in ascending order depending on the number of existing mkv in directory
        count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

        echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.no-mbt.cqpo${cqpo##*=}.mkv…\n"

        wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m --no-mbtree \
            --bitrate "${br##*=}" \
            --pass 1 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.no-mbt.cqpo${cqpo##*=}.stats" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "$lookaheadmb" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-strength "${aqs##*=}" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --no-psy \
            --chroma-qp-offset "${cqpo##*=}" \
            --qcomp "${qcomp##*=}" \
            -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

        wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m --no-mbtree \
            --bitrate "${br##*=}" \
            --pass 2 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.no-mbt.cqpo${cqpo##*=}.stats" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "$lookaheadmb" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-strength "${aqs##*=}" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --no-psy \
            --chroma-qp-offset "${cqpo##*=}" \
            --qcomp "${qcomp##*=}" \
            -o ""${source1%.*}".$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.no-mbt.cqpo${cqpo##*=}.mkv" - 2>&1|tee -a "${source1%.*}".$2.log;

        # Append list of encodings into comparison screen avs file
        echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.no-mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 no-mbtree\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for mbtree lasted $time.\n"

        screen_comparison_and_cleanup "${source1%.*}".$2.mbt.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo -e "\nHave a look at these encodings."
        if [[ -z ${nombtree##*=-x} ]]; then
            echo "Do you want to set --no-mbtree,"
            echo -e "or stay with the default (mb-tree enabled)?\n"
        else
            echo "Do you want set the default (mb-tree enabled),"
            echo -e "or stay with --no-mbtree?"
        fi
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.mbt.avs
    }

    while true; do
        #if [[ -z ${nombtree##*=+x} ]]; then
        if [[ -z ${nombtree##*=-x} ]]; then
            echo -e "\nMb-tree is on, which is the default setting."
        else
            echo -e "\nMb-tree is set to --no-mbtree."
        fi

        echo "Test for mb-tree settings in "${source2%.*}""
        echo -e "in $2 with a bitrate of "${br##*=}".\n"
        echo "RETURN for test encodings with these values,"
        echo -e "or e(x)it.\n"
        read -e -p "(RETURN|x) > " answer_mbtree
            case $answer_mbtree in
                x|X) #nothing here
                    break
                ;;

                *)
                    unset mbt
                    test_mbtree $1 $2
                    unset br2
                    br_change $1 $2
                ;;
            esac
    done

    until [[ $mbt =~ ^[0-1]$ ]] ; do
        echo "0: --no-mbtree or"
        echo -e "1: mb-tree enabled\n"
        read -e -p "(0|1) > " mbt
        # keep cfg informed
        sed -i "/nombtree$2/d" "$config"
        sed -i "/lookahead$2/d" "$config"
        case $mbt in
            0)
                echo "nombtree$2=no-" >> "$config"
                echo "lookahead$2=100" >> "$config"
            ;;

            1)
                echo "lookahead$2=240" >> "$config"
            ;;
            esac
    done

    echo -e "\nContinue with option 6 - qcomp"
    echo -e "or option 7 - aq modes and aq strength.\n"
    ;;

    6)  # 6 - test variations in qcomp

    function test_qcomp {
        # until qcomplow 0-100 and qcomphigh 0-100 and high>low and increment 0-100; do
        until [[ $qcomplow =~ ^[0-9]$|^[1-9][0-9]$|^100$ && $qcomphigh =~ ^[0-9]$|^[1-9][0-9]$|^100$ && $qcomphigh -ge $qcomplow && $qcompincrement =~ ^[1-9]$|^[1-9][0-9]$|^100$ ]]; do
            echo "Qcomp: values 0.0 through 1.0, default is 0.60"
            echo -e "Test with values around 0.50 through 0.80\n"

            echo "Set lowest qcomp value,"
            echo -e "e.g. 55 for 0.55\n"
            read -e -p "Qcomp, lowest value > " qcomplow

            echo "Set maximum qcomp value,"
            echo -e "e.g. 80 for 0.80\n"
            read -e -p "Qcomp, maximum value > " qcomphigh

            echo "Set increments, e.g. 5 for 0.05"
            echo -e "≠0\n"
            read -e -p "Increments > " qcompincrement
        done

        # Number of test encodings
        number_encodings=$(echo "((($qcomphigh-$qcomplow)/$qcompincrement)+1)"|bc)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting qcomp will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((qcomp0=$qcomplow; $qcomp0<=$qcomphigh; qcomp0+=$qcompincrement)); do
            if [[ $qcomp0 = $qcomplow ]]; then
                echo -e "\nRange qcomp *$qcomplow* → $qcomphigh, increment $qcompincrement; $encodings_left of $number_encodings encodings left."
            elif [[ $qcomp0 = $qcomphigh ]]; then
                echo -e "\nRange qcomp $qcomplow → *$qcomphigh*, increment $qcompincrement; $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange qcomp $qcomplow → *$qcomp0* → $qcomphigh, increment $qcompincrement; $encodings_left of $number_encodings encodings left."
            fi

            # Name files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc$qcomp0.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

            wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --bitrate "${br##*=}" \
            --pass 1 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc$qcomp0.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-strength "${aqs##*=}" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --no-psy \
            --chroma-qp-offset "${cqpo##*=}" \
            --qcomp $(echo "scale=2;$qcomp0/100"|bc) \
            -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

            wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --bitrate "${br##*=}" \
            --pass 2 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc$qcomp0.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-strength "${aqs##*=}" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --no-psy \
            --chroma-qp-offset "${cqpo##*=}" \
            --qcomp $(echo "scale=2;$qcomp0/100"|bc) \
            -o ""${source1%.*}".$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc$qcomp0.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv" - 2>&1|tee -a "${source1%.*}".$2.log;

            # Append name into avs file for comparisons
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc$qcomp0.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 br${br##*=} qc$qcomp0\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            encoding_stoptime
            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc$qcomp0.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"

        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for qcomp lasted $days days and $time"

        screen_comparison_and_cleanup "${source1%.*}".$2.qcomp.$qcomplow-$qcomphigh-$qcompincrement.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo -e "\nLook through all test encodings"
        echo "and decide, which qcomp value"
        echo "gave best results."
        echo "Then close AvsPmod."
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.qcomp.*.avs
    }

    while true; do
        echo -e "\nChoose qcomp values for"
        echo -e "test encodings of "${source2%.*}" in $2\n"
        echo "Qcomp is ${qcomp##*=}"

        echo -e "\nRETURN for (more) testing on qcomp,"
        echo -e "else e(x)it.\n"
        read -e -p "(RETURN|x) > " answer_qcomp
            case $answer_qcomp in
                x|X) # get out of the loop
                    break
                ;;

                *)
                    unset qcomplow
                    unset qcomphigh
                    unset qcompincrement
                    test_qcomp $1 $2
                    unset br2
                    br_change $1 $2

                ;;
            esac
    done

    until [[ $qcomp =~ ^0\.[0-9][0-9]$|^1\.0$ ]] ; do
        echo -e "\nSet qcomp value for $2 of "${source2%.*}""
        echo -e "e.g. 0.70\n"
        read -e -p "Qcomp > " qcomp
    done
    # keep cfg informed
    sed -i "/qcomp$2/d" "$config"
    echo "qcomp$2=$qcomp" >> "$config"

    echo -e "\nContinue with option 7 - test for aq-mode and aq-strength.\n"
    ;;

    7)  # 7 - testings for variations in aq-mode and aq strength

    function test_aqmode_aqs {

        # DIRTY! what range aq strength? all parameters 0-100
        until [[ $aqshigh -ge $aqslow && $aqslow =~ ^[0-9]$|^[1-9][0-9]$|^100$ && $aqshigh =~ ^[0-9]$|^[1-9][0-9]$|^100$ && $aqsincrement =~ ^[1-9]$|^[1-9][0-9]$|^100$ ]]; do
            echo -e "\nAq-strength: default is 1.0"
            echo -e "Hint: film ~1.0, animation ~0.6, grain ~0.5\n"
            echo -e "Set lowest value of aq strength, e.g. 50 for 0.5\n"
            read -e -p "Aq-strength, lowest value > " aqslow

            echo -e "\nSet maximum value of aq strength, e.g. 100 for 1.0\n"
            read -e -p "Aq-strength, maximum value > " aqshigh

            echo -e "\nSet increment steps, e.g. 5 for 0.05 or 10 for 0.10,"
            echo -e "but ≠0\n"
            read -e -p "increments > " aqsincrement
        done

        # Number of test encodings
        number_encodings=$(echo "(((($aqshigh-$aqslow)/$aqsincrement)+1)*${#answer_aqmode})"|bc)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting aq-strength and aq-mode will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for aqmode0 in ${answer_aqmode:0:1} ${answer_aqmode:1:1} ${answer_aqmode:2:3} ;do
            for ((aqs0=$aqslow; $aqs0<=$aqshigh; aqs0+=$aqsincrement));do

                if [[ $aqs0 = $aqslow ]]; then
                    echo -e "\nRange aq strength *$aqslow* → $aqshigh, increment $aqsincrement; aq-mode $aqmode0; $encodings_left of $number_encodings encodings left."
                elif [[ $aqs0 = $aqshigh ]]; then
                    echo -e "\nRange aq strength $aqslow → *$aqshigh*, increment $aqsincrement; aq-mode $aqmode0; $encodings_left of $number_encodings encodings left."
                else
                    echo -e "\nRange aq strength $aqslow → *$aqs0* → $aqshigh, increment $aqsincrement; aq-mode $aqmode0; $encodings_left of $number_encodings encodings left."
                fi

                # Name files in ascending order depending on the number of existing mkv in directory
                count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq$aqmode0.$aqs0.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

                encoding_starttime

                wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
                --bitrate "${br##*=}" \
                --pass 1 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq$aqmode0.$aqs0.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --qcomp "${qcomp##*=}" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "${lookahead##*=}" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-mode "$aqmode0" \
                --deblock "${deblocka##*=}":"${deblockb##*=}" \
                --chroma-qp-offset "${cqpo##*=}" \
                --aq-strength $(echo "scale=2;$aqs0/100"|bc) \
                --psy-rd "${psyrd##*=}" \
                -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

                wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
                --bitrate "${br##*=}" \
                --pass 2 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq$aqmode0.$aqs0.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --qcomp "${qcomp##*=}" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "${lookahead##*=}" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-mode "$aqmode0" \
                --chroma-qp-offset "${cqpo##*=}" \
                --deblock "${deblocka##*=}":"${deblockb##*=}" \
                --aq-strength $(echo "scale=2;$aqs0/100"|bc) \
                --psy-rd "${psyrd##*=}" \
                -o "${source1%.*}".$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq$aqmode0.$aqs0.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log;

                # Append name into avs file for comparisons
                echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq$aqmode0.$aqs0.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 br${br##*=} aq$aqmode0.$aqs0 psy${psyrd##*=} pt${psytr##*=}\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

                encoding_stoptime
                echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq$aqmode0.$aqs0.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
            done
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for aq modes and aq strength lasted $days days and $time"

        screen_comparison_and_cleanup "${source1%.*}".$2.aqmode$answer_aqmode-$aqslow-$aqshigh-$aqsincrement.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo -e "\nLook through all test encodings"
        echo "and decide, which aq strength"
        echo "values gave best results."
        echo "Then close AvsPmod."
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.aqmode*.avs
    }

    function set_aqmode {
        until [[ $aqmode =~ ^[1-3]$ ]] ; do
            echo "Set aq-mode for $2 of "${source2%.*}""
            echo -e "1, 2 or 3\n"
            read -e -p "Aq-mode > " aqmode
        done
        # keep cfg informed
        sed -i "/aqmode$2/d" "$config"
        echo "aqmode$2=$aqmode" >> "$config"
    }

    function set_aqs {
        until [[ $aqs =~ ^[0-2]\.[0-9]+$ ]] ; do
            echo "Set aq-strength for $2 of "${source2%.*}""
            echo -e "e.g. 0.7\n"
            read -e -p "Aq-strength > " aqs
        done
        # keep cfg informed
        sed -i "/aqs$2/d" "$config"
        echo "aqs$2=$aqs" >> "$config"
    }

    while true; do
        echo -e "\nTest for aq-strength with"
        echo "maybe several aq-modes."
        echo "Default is 3."
        echo "Try 1 and 2 if results with 3 are unsatisfying"
        echo "Aq-mode is ${aqmode##*=}"
        echo -e "and aq-strength is ${aqs##*=}.\n"
        echo "Choose test modes: (1), (2), (3), (13), (23) or (123);"
        echo -e "or RETURN to end testing\n"
        read -e -p "(1|2|3|13|23|123|RETURN) > " answer_aqmode
            case $answer_aqmode in
                1|2|3|12|13|21|23|31|32|123|132|213|231|312|321) # only test for chosen aq-mode
                    unset aqmode0
                    unset aqshigh
                    unset aqslow
                    unset aqsincrement
                    test_aqmode_aqs $1 $2
                    unset br2
                    br_change $1 $2
                ;;

                *) # nothing
                    break
                ;;
            esac
    done

    set_aqmode $1 $2
    set_aqs $1 $2

    echo "\nContinue with option 8"
    echo -e "and test for another round of deblock\n"
    ;;

    8)  # 8 - second round testing for deblock values
    function test_deblocka2 {
        deblockahigh=-1
        deblockalow=-3
        # Number of test encodings
        number_encodings=$(expr "$deblockahigh" - "$deblockalow" + 1)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting deblock alpha will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((deblocka=$deblockalow; $deblocka<=$deblockahigh; deblocka=$deblocka+1));do
            if [[ $deblocka = $deblockalow ]]; then
                echo -e "\nRange deblock alpha *$deblockalow* → $deblockahigh, $encodings_left of $number_encodings encodings left."
            elif [[ $deblocka = $deblockahigh ]]; then
                echo -e "\nRange deblock alpha $deblockalow → *$deblockahigh*, $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange deblock alpha $deblockalow → *$deblocka* → $deblockahigh, $encodings_left of $number_encodings encodings left."
            fi

            # Name the files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.dba2$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

            wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 1 \
                --stats "${source2%.*}.$2.$count.br${br##*=}.dba2$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "$deblocka":"$deblocka" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

            wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 2 \
                --stats "${source2%.*}.$2.$count.br${br##*=}.dba2$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "$deblocka":"$deblocka" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o ""${source1%.*}".$2.$count.br${br##*=}.dba2$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv" - 2>&1|tee -a "${source1%.*}".$2.log;

            # Append name into avs file for comparisons
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.dba2$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 deblock $deblocka:$deblocka\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            encoding_stoptime
            echo -e "\nEncoding "${source2%.*}".$2.$count.br${br##*=}.dba2$deblocka.$deblocka.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for deblock lasted $time\n"

        screen_comparison_and_cleanup "${source1%.*}".$2.dba2.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo "Have a look at these encodings."
        echo "Which deblock alpha looks best?"
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.dba2.avs
    }

    function test_deblockb2 {
        deblockbhigh=-1
        deblockblow=-3
        # Number of test encodings
        number_encodings=$(expr "$deblockbhigh" - "$deblockblow" + 1)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting deblock beta will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((deblockb=$deblockblow; $deblockb<=$deblockbhigh; deblockb=$deblockb+1));do
            if [[ $deblockb = $deblockblow ]]; then
                echo -e "\nRange deblock beta *$deblockblow* → $deblockbhigh, $encodings_left of $number_encodings encodings left."
            elif [[ $deblockb = $deblockbhigh ]]; then
                echo -e "\nRange deblock beta $deblockblow → *$deblockbhigh*, $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange deblock beta $deblockblow → *$deblockb* → $deblockbhigh, $encodings_left of $number_encodings encodings left."
            fi

            # Name the files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.dbb2${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

            wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 1 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.dbb2${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "${deblocka##*=}":"$deblockb" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

            wine "$avs2yuv" "${avs##*=}" - \
                | x264 --stdin y4m \
                --bitrate "${br##*=}" \
                --pass 2 \
                --stats "${source1%.*}.$2.$count.br${br##*=}.dbb2${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
                --preset "$preset" \
                --profile "$profile" \
                --ref "${ref##*=}" \
                --sar "$par" \
                --rc-lookahead "$lookaheadno" \
                --me "$me" \
                --merange "$merange" \
                --subme "$subme" \
                --aq-strength "${aqs##*=}" \
                --aq-mode "${aqmode##*=}" \
                --deblock "${deblocka##*=}":"$deblockb" \
                --no-psy \
                --chroma-qp-offset "${cqpo##*=}" \
                --qcomp "${qcomp##*=}" \
                -o ""${source1%.*}".$2.$count.br${br##*=}.dbb2${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv" - 2>&1|tee -a "${source1%.*}".$2.log;

            # Append name into avs file for comparisons
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.dbb2${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 deblock ${deblocka##*=}:$deblockb\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            encoding_stoptime
            echo -e "\nEncoding "${source2%.*}".$2.$count.br${br##*=}.dbb2${deblocka##*=}.$deblockb.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for deblock lasted $time\n"

        screen_comparison_and_cleanup "${source1%.*}".$2.dbb2.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo "Have a look at these encodings."
        echo "Which deblock beta looks best?"
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.dbb2.avs
    }

    function set_deblocka {
        until [[ $deblocka =~ ^[-+]?[1-3]$ ]] ; do
            echo "Set deblock alpha value for $2 of "${source2%.*}""
            echo "Sensible values between -3 and -1"
            read -e -p "(-3 up to 3) > " deblocka
        done
        # keep cfg informed
            sed -i "/deblocka$2/d" "$config"
            echo "deblocka$2=$deblocka" >> "$config"
    }

    function set_deblockb {
        until [[ $deblockb =~ ^[-+]?[1-3]$ ]] ; do
            echo -e "\nSet deblock beta value for $2 of "${source2%.*}""
            echo "Sensible values near deblock alpha, (${deblocka##*=})"
            read -e -p "(-3 up to 3) > " deblockb
        done
            # keep cfg informed
            sed -i "/deblockb$2/d" "$config"
            echo "deblockb$2=$deblockb" >> "$config"
    }

    while true; do
        echo -e "\nTest for deblock settings in "${source2%.*}" in $2"
        echo -e "deblock alpha is ${deblocka##*=} and deblock beta is ${deblockb##*=}\n"

        echo "Press (a)lpha for test for deblock alpha."
        echo "Press (b)eta for test for deblock beta."
        echo "Press (s)et for setting values without further testing"
        echo -e "or e(x)it.\n"
        read -e -p "(a|b|s|x) > " answer_db
            case $answer_db in
                x|X) #nothing here
                    break
                ;;

                s|S|set|SET)
                    set_deblocka $1 $2
                    set_deblockb $1 $2
                    br_change $1 $2
                    break
                ;;

                a|A|alpha|ALPHA)
                    unset deblocka
                    test_deblocka2 $1 $2
                    set_deblocka $1 $2
                    unset br2
                    br_change $1 $2
                ;;

                b|B|beta|BETA)
                    unset deblockb
                    test_deblockb2 $1 $2
                    set_deblockb $1 $2
                    unset br2
                    br_change $1 $2
                ;;
            esac
    done

    echo -e "\nContinue with option 9 - psyrd,"
    echo "option 10 - psytrellis,"
    echo -e "or option 11 for some less common testing.\n"
    ;;

    9)  # 9 - testing for psyrd

    function test_psyrd {
        ### DIRTY! what range for psy-rdo? all parameters 1-200
        until [[ $psyrdhigh -ge $psyrdlow && $psyrdlow =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ && $psyrdhigh =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ && $psyrdincrement =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ ]]; do
            echo -e "\nPsy-rd: default is 1.0."
            echo "Test with values around 0.8 through 1.2."
            echo "Hint: Psy-rd 0.35-0.80 for animation"
            echo -e "Set lowest value of psy-rd, e.g. 80 for 0.8\n"
            read -e -p "Psy-rd, lowest value > " psyrdlow

            echo -e "\nSet maximum value of psy-rd, e.g. 120 for 1.2\n"
            read -e -p "Psy-rd, maximum value > " psyrdhigh

            echo -e "\nIncrement steps for psy-rd values"
            echo "e.g. 5 for 0.05 or 10 for 0.1,"
            echo -e "but ≠0\n"
            read -e -p "increments > " psyrdincrement
        done

        # Number of test encodings
        number_encodings=$(echo "(($psyrdhigh-$psyrdlow)/$psyrdincrement)+1"|bc)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting psy-rd will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((psyrd0=$psyrdlow; $psyrd0<=$psyrdhigh; psyrd0+=$psyrdincrement));do
            if [[ $psyrd0 = $psyrdlow ]]; then
                echo -e "\nRange psy-rdo *$psyrdlow* → $psyrdhigh, increment $psyrdincrement; $encodings_left of $number_encodings encodings left."
            elif [[ $psyrd0 = $psyrdhigh ]]; then
                echo -e "\nRange psy-rdo $psyrdlow → *$psyrdhigh*, increment $psyrdincrement; $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange psy-rdo $psyrdlow → *$psyrd0* → $psyrdhigh, increment $psyrdincrement; $encodings_left of $number_encodings encodings left."
            fi

            # Name files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy$psyrd0.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

            wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --bitrate "${br##*=}" \
            --pass 1 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy$psyrd0.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
            --qcomp "${qcomp##*=}" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --chroma-qp-offset "${cqpo##*=}" \
            --aq-strength "${aqs##*=}" \
            --psy-rd $(echo "scale=2;$psyrd0/100"|bc):unset \
            -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

            wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --bitrate "${br##*=}" \
            --pass 2 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy$psyrd0.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
            --qcomp "${qcomp##*=}" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-mode "${aqmode##*=}" \
            --chroma-qp-offset "${cqpo##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --aq-strength "${aqs##*=}" \
            --psy-rd $(echo "scale=2;$psyrd0/100"|bc):unset \
            -o "${source1%.*}".$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy$psyrd0.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log;

            # Append name into avs file for comparisons
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy$psyrd0.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 br${br##*=} aq${aqmode##*=}.${aqs##*=} psy$psyrd0 pt${psytr##*=}\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            encoding_stoptime
            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy$psyrd0.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for psy-rd lasted $days days and $time"

        screen_comparison_and_cleanup "${source1%.*}".$2.psy.$psyrdlow-$psyrdhigh-$psyrdincrement.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo -e "\nThoroughly look through all test"
        echo "encodings and decide, which psy-rd"
        echo "values gave best results."
        echo "Then close AvsPmod."
        sleep 0.6

        wine "$avspmod" "${source1%.*}".$2.psy.*.avs
    }

    while true; do
        echo "Choose psy-rd for test encodings"
        echo -e "of "${source2%.*}" in $2\n"
        echo -e "Psy-rd is ${psyrd##*=}\n"
        echo "RETURN for (more) testing on psy-rd,"
        echo -e "else e(x)it\n"
        read -e -p "(RETURN|x) > " answer_psyrd
            case $answer_psyrd in
                x|X) # just nothing
                    break
                ;;

                *)
                    unset psyrdhigh
                    unset psyrdlow
                    unset psyrdincrement
                    test_psyrd $1 $2
                    unset br2
                    br_change $1 $2
                ;;
            esac
    done

    until [[ $psyrd =~ ^[0-2]\.[0-9]+$ ]] ; do
        echo -e "\nSet psy-rd for $2 of "${source2%.*}""
        echo -e "e.g. 0.9\n"
        read -e -p "psy-rd > " psyrd
    done
    # keep cfg informed
    sed -i "/psyrd$2/d" "$config"
    echo "psyrd$2=$psyrd" >> "$config"

    case $(echo "$psyrd" - 0.99999 | bc) in
        -*) # psy-rd <1 -> psytr unset
            echo -e "\nAs psy-rd is set to a value <1 (or not at all),"
            echo -e "psy-trellis is 'unset' automatically.\n"
            echo "You might do further testing with"
            echo "option 11 (some more less common tests) or"
            echo -e "continue with option 12 (a last round for crf)\n"
            # keep cfg informed
            sed -i "/psytr$2/d" "$config"
            echo "psytr$2=unset" >> "$config"
        ;;

        *) # psyrd >= 1
            echo -e "\nYou might test for psy-trellis (option 10),"
            echo "do further testing with option 11"
            echo "(some more less common tests), or"
            echo -e "continue with option 12 (a last round for crf).\n"
        ;;
    esac
    ;;

    10)  # 10 - variations in psy-trellis

    function test_psytrellis {
        #until psy2low 1-99 and psy2high 1-199 and psy2increment 1-99; do
        until [[  $psy2high -ge $psy2low && $psy2low =~ ^[0-9]$|^[1-9][0-9]$ && $psy2high =~ ^[0-9]$|^[1-9][0-9]$|^1[0-9][0-9]$ && $psy2increment =~ ^[1-9]$|^[1-9][0-9]$ ]]; do
            echo -e "\nPsy-trellis: default is 0.0."
            echo "Test for values ~0.0 through 0.15"
            echo -e "Set lowest value for psy-trellis, e.g. 0\n"
            read -e -p "Psy-trellis, lowest value > " psy2low

            echo -e "Set maximum value for psy-trellis, e.g. 20 for 0.2\n"
            read -e -p "Psy-trellis, maximum value > " psy2high

            echo -e "set increment steps, e.g. 2 for 0.02\n"
            read -e -p "Increments > " psy2increment
        done

        # Number of test encodings
        number_encodings=$(echo "((($psy2high-$psy2low)/$psy2increment)+1)"|bc)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting psy-trellis will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((psy2=$psy2low; $psy2<=$psy2high; psy2+=$psy2increment));do
            if [[ $psy2 = $psy2low ]]; then
                echo -e "\nRange psy-trellis *$psy2low* → $psy2high, increment $psy2increment; $encodings_left of $number_encodings encodings left."
            elif [[ $psy2 = $psy2high ]]; then
                echo -e "\nRange psy-trellis $psy2low → *$psy2high*, increment $psy2increment; $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange psy-trellis $psy2low → *$psy2* → $psy2high, increment $psy2increment; $encodings_left of $number_encodings encodings left."
            fi

            # Name files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt$psy2.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            encoding_starttime

            wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --bitrate "${br##*=}" \
            --pass 1 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt$psy2.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
            --qcomp "${qcomp##*=}" \
            --aq-mode "${aqmode##*=}" \
            --aq-strength "${aqs##*=}" \
            --chroma-qp-offset "${cqpo##*=}" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --psy-rd "${psyrd##*=}":$(echo "scale=2;$psy2/100"|bc) \
            -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log

            wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --bitrate "${br##*=}" \
            --pass 2 \
            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt$psy2.${nombtree##*=}mbt.cqpo${cqpo##*=}.stats" \
            --qcomp "${qcomp##*=}" \
            --aq-mode "${aqmode##*=}" \
            --aq-strength "${aqs##*=}" \
            --chroma-qp-offset "${cqpo##*=}" \
            --preset "$preset" \
            --profile "$profile" \
            --ref "${ref##*=}" \
            --sar "$par" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --psy-rd "${psyrd##*=}":$(echo "scale=2;$psy2/100"|bc) \
            -o "${source1%.*}".$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt$psy2.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log;

            # Append name into avs file for comparisons
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt$psy2.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 pt$psy2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            encoding_stoptime
            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt$psy2.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for psy-trellis lasted $days days and $time"

        screen_comparison_and_cleanup "${source1%.*}".$2.psytr.$psy2low-$psy2high-$psy2increment.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo -e "\nLook through this last test encodings"
        echo "and decide, which one is your best encode."
        echo "Then close AvsPmod."
        sleep 0.6
        wine "$avspmod" "${source1%.*}".$2.psytr.*.avs
    }

    if [[ $(echo "scale=0;${psyrd##*=}/1"|bc) -lt 1 ]]; then
        # psy-rd <1 -> psytr unset
        echo "As psy-rd is set to a value < 1 (${psyrd##*=}),"
        echo "psy-trellis is 'unset' automatically"
        # keep cfg informed
        sed -i "/psytr$2/d" "$config"
        echo "psytr$2=unset" >> "$config"
    elif [[ $(echo "scale=0;${psyrd##*=}/1"|bc) -ge 1 ]]; then
        while true; do
            if [[ -z ${psytr##*=} ]]; then
                echo -e "\nPsy-trellis is 'unset'\n"
            else
                echo -e "\nPsy-trellis is '${psytr##*=}'\n"
            fi
            echo -e "As psy-rd is set to ≥1 (${psyrd##*=}),"
            echo "you may test for psy-trellis,"
            echo -e "else, e(x)it\n"

            read -e -p "(RETURN|x) > " answer_psytr
                case $answer_psytr in
                    x|X) # unset psy-trellis
                        if [[ ${psytr##*=} =~ 0 || -z ${psytr##*=} ]] ; then
                            echo "Psy trellis is 'unset'."
                            # keep cfg informed
                            sed -i "/psytr$2/d" "$config"
                            echo "psytr$2=unset" >> "$config"
                        fi
                        break
                    ;;

                    *) # test for psy-trellis
                    unset psy2high
                    unset psy2low
                    unset psy2increment
                    test_psytrellis $1 $2
                    unset br2
                    br_change $1 $2
                    ;;
                esac
        done

        until [[ $psytr =~ ^0$|^[0-1]\.[0-9]$|^[0-1]\.[0-9][0-9]$|^2\.00$  ]] ; do
            echo "Set psy-trellis"
            echo -e "e.g. 0.05\n"
            read -e -p "Psy-trellis > " psytr
        done
        # keep cfg informed
        sed -i "/psytr$2/d" "$config"
        echo "psytr$2=$psytr" >> "$config"
    fi

    echo -e "\nDo some testing for e.g. chroma-qp-offset"
    echo "(option 11) or"
    echo "try another (maybe last) round for optimal crf"
    echo -e "(option 12).\n"
    ;;

    11)  # 11 - More testing on less common parameters

    until [[ $answer_various =~ [c,C,x,X] ]] ; do
        echo -e "What do you want to test?\n"
        echo -e "(c)hroma-qp-offset\n"
        #echo -e "(x) nothing\n"
        read -e -p "(c) > " answer_various
            case $answer_various in
                c|C)    # chroma-qp-offset
                    function test_cqpo {
                        # until cqpohigh -12 through 12 and cqpolow -12 through 12 and cqpohigh greater or equal cqpolow; do
                        until [[ $cqpohigh =~ ^-{0,1}[0-9]$|^-{0,1}1[0-2]$ && $cqpolow =~ ^-{0,1}[0-9]$|^-{0,1}1[0-2]$ && $cqpohigh -ge $cqpolow ]]; do
                            echo -e "\nTest for chroma-qp-offset: default 0,"
                            echo "range -12 through 12; sensible ranges -3 through 3."
                            echo "Set lowest value for chroma-qp-offset, e.g. -2"
                            echo -e "Beware: -6 is lower than -4 :-)\n"
                            read -e -p "Chroma-qp-offset, lowest value > " cqpolow

                            echo -e "Set maximum value for chroma-qp-offset, e.g. 2\n"
                            read -e -p "Chroma-qp-offset, maximum value > " cqpohigh
                        done

                        # Number of test encodings
                        number_encodings=$(expr "$cqpohigh" - "$cqpolow" + 1)
                        # Number of encodings left
                        encodings_left=$number_encodings

                        echo -e "\nTesting cqpo will result in $number_encodings encodings."
                        sleep 0.6

                        encoding_starttime_global_tempfile

                        for ((cqpo0=$cqpolow; $cqpo0<=$cqpohigh; cqpo0=$cqpo0+1));do
                            if [[ $cqpo0 = $cqpolow ]]; then
                                echo -e "\nRange chroma qp offset *$cqpolow* → $cqpohigh, increment $cqpoincrement; $encodings_left of $number_encodings encodings left."
                            elif [[ $cqpo0 = $cqpohigh ]]; then
                                echo -e "\nRange chroma qp offset $cqpolow → *$cqpohigh*, increment $cqpoincrement; $encodings_left of $number_encodings encodings left."
                            else
                                echo -e "\nRange chroma qp offset $cqpolow → *$cqpo0* → $cqpohigh, increment $cqpoincrement; $encodings_left of $number_encodings encodings left."
                            fi

                            # Name files in ascending order depending on the number of existing mkv in directory
                            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo$cqpo0.mkv…\n"

                            encoding_starttime

                            wine "$avs2yuv" "${avs##*=}" - \
                            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
                            --bitrate "${br##*=}" \
                            --pass 1 \
                            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo$cqpo0.stats" \
                            --qcomp "${qcomp##*=}" \
                            --aq-mode "${aqmode##*=}" \
                            --aq-strength "${aqs##*=}" \
                            --chroma-qp-offset "${cqpo##*=}" \
                            --preset "$preset" \
                            --profile "$profile" \
                            --ref "${ref##*=}" \
                            --sar "$par" \
                            --rc-lookahead "${lookahead##*=}" \
                            --me "$me" \
                            --merange "$merange" \
                            --subme "$subme" \
                            --deblock "${deblocka##*=}":"${deblockb##*=}" \
                            --psy-rd "${psyrd##*=}":"${psytr##*=}" \
                            -o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

                            wine "$avs2yuv" "${avs##*=}" - \
                            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
                            --bitrate "${br##*=}" \
                            --pass 2 \
                            --stats "${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo$cqpo0.stats" \
                            --qcomp "${qcomp##*=}" \
                            --aq-mode "${aqmode##*=}" \
                            --aq-strength "${aqs##*=}" \
                            --chroma-qp-offset "${cqpo##*=}" \
                            --preset "$preset" \
                            --profile "$profile" \
                            --ref "${ref##*=}" \
                            --sar "$par" \
                            --rc-lookahead "${lookahead##*=}" \
                            --me "$me" \
                            --merange "$merange" \
                            --subme "$subme" \
                            --deblock "${deblocka##*=}":"${deblockb##*=}" \
                            --psy-rd "${psyrd##*=}":"${psytr##*=}" \
                            -o "${source1%.*}".$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo$cqpo0.mkv - 2>&1|tee -a "${source1%.*}".$2.log;

                            # Append name into avs file for comparisons
                            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo$cqpo0.mkv\").subtitle(\"${source2%.*} encode $2 cqpo$cqpo0\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

                            encoding_stoptime
                            echo -e "\nEncoding ${source2%.*}.$2.$count.br${br##*=}.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo$cqpo0.mkv lasted $time"
                        done

                        encoding_stoptime_global
                        echo -e "\n$1 $2: Test encodings for chroma-qp-offset lasted $days days and $time"

                        screen_comparison_and_cleanup "${source1%.*}".$2.cqpo.$cqpolow-$cqpohigh.avs

                        if [ -e /usr/bin/beep ]; then beep $beep; fi

                        echo "Check these last test encodings"
                        echo "and decide, which one is your best encode."
                        echo "Then close AvsPmod."
                        sleep 0.6
                        wine "$avspmod" "${source1%.*}".$2.cqpo.*.avs
                    }

                    while true; do
                        echo "Set chroma-qp-offset value"
                        echo "e.g. -2"
                        echo -e "else, X for more testing."
                            read -e -p "(RETURN|*) > " answer_cqpo
                                case $answer_cqpo in
                                    x|X)
                                        unset cqpo0
                                        test_cqpo0
                                    ;;

                                    *)
                                        #break
                                    ;;
                                esac
                    done

                    until [[ $cqpo =~ ^-?[0-9]$|^-?1[0-2]$ ]]; do
                        read -e -p "Chroma-qp-offset > " cqpo
                    done

                    # keep cfg informed
                    sed -i "/cqpo$2/d" "$config"
                    echo "cqpo$2=$cqpo" >> "$config"
                ;;

                x|X)    # nothing
                ;;

                *) # nothing
                    echo -e "\nIf you don't want to test any of this"
                    echo "hit x"
                ;;
            esac
    done

    echo -e "\nContinue with option 12 and test"
    echo -e "for an optimized value in crf.\n"
    ;;

    12)  # 12 - second round of crf testing

    function test_crf2 {
        until [[ $crf2high -ge $crf2low && $crf2low =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf2high =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf2increment =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ ]]; do
            echo "Again, try a range of crf increments."
            echo "Set lowest crf value as hundreds,"
            echo -e "e.g. 168 for 16.8\n"

            read -e -p "crf, lowest value > " crf2low

            echo "Set highst crf value as hundreds,"
            echo -e "e.g. 172 for 17.2\n"

            read -e -p "crf, maximum value > " crf2high

            echo "Set increment steps, e.g. 1 for 0.1,"
            echo -e "but ≠0\n"
            read -e -p "Increments > " crf2increment
        done

        # Number of test encodings
        number_encodings=$(echo "((($crf2high-$crf2low)/$crf2increment)+1)"|bc)
        # Number of encodings left
        encodings_left=$number_encodings

        echo -e "\nTesting crf will result in $number_encodings encodings."
        sleep 0.6

        encoding_starttime_global_tempfile

        for ((crf2=$crf2low; $crf2<=$crf2high; crf2+=$crf2increment));do
            if [[ $crf2 = $crf2low ]]; then
                echo -e "\nRange crf *$crf2low* → $crf2high, increment $crf2increment; $encodings_left of $number_encodings encodings left."
            elif [[ $crf2 = $crf2high ]]; then
                echo -e "\nRange crf $crf2low → *$crf2high*, increment $crf2increment; $encodings_left of $number_encodings encodings left."
            else
                echo -e "\nRange crf $crf2low → *$crf2* → $crf2high, increment $crf2increment; $encodings_left of $number_encodings encodings left."
            fi

            # Name files in ascending order depending on the number of existing mkv in directory
            count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

            echo -e "\nEncoding ${source2%.*}.$2.$count.crf$crf2.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv…\n"

            # Write CRF values into log files, no newline at the end of line
            echo -en "\ncrf $(echo "scale=1;$crf2/10"|bc) : " | tee -a "${source1%.*}".$2.crf2.log >/dev/null

            encoding_starttime

            wine "$avs2yuv" "${avs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --qcomp "${qcomp##*=}" \
            --aq-strength "${aqs##*=}" \
            --aq-mode "${aqmode##*=}" \
            --psy-rd "${psyrd##*=}":"${psytr##*=}" \
            --preset "$preset" \
            --profile "$profile" \
            --sar "$par" \
            --ref "${ref##*=}" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --chroma-qp-offset "${cqpo##*=}" \
            --crf $(echo "scale=1;$crf2/10"|bc) \
            -o "${source1%.*}".$2.$count.crf$crf2.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log|tee "${source1%.*}".$2.crf2-raw.log;

            # Append file name into avs file
            echo "=LWLibavVideoSource(\"${source1%.*}.$2.$count.crf$crf2.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv\").subtitle(\"${source2%.*} encode $2 crf$crf2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "$temp_file"

            # Write the encodings bit rate into the crf2 log file
            egrep 'x264 \[info\]: kb\/s:' "${source1%.*}".$2.crf2-raw.log|cut -d':' -f3|tail -1 >> "${source1%.*}".$2.crf2.log
            rm "${source1%.*}".$2.crf2-raw.log

            encoding_stoptime
            echo -e "\nEncoding ${source2%.*}.$2.$count.crf$crf2.db${deblocka##*=}${deblockb##*=}.qc${qcomp##*=}.aq${aqmode##*=}.${aqs##*=}.psy${psyrd##*=}.pt${psytr##*=}.${nombtree##*=}mbt.cqpo${cqpo##*=}.mkv lasted $time"
        done

        encoding_stoptime_global
        echo -e "\n$1 $2: Test encodings for a second round of crf lasted $days days and $time"

        screen_comparison_and_cleanup "${source1%.*}".$2.crf2.$crf2low-$crf2high-$crf2increment.avs

        if [ -e /usr/bin/beep ]; then beep $beep; fi

        echo "As a reminder, here are your crf/ bitrate values"
        echo -e "from your first round testing for crf:\n"
        # Display bitrate from logfile
        if [[ -e "${source1%.*}".$2.crf1.log ]] ; then
            column -t "${source1%.*}".$2.crf1.log|sort -u
            echo
        fi

        # Display bitrate from logfile
        if [[ -e "${source1%.*}".$2.crf2.log ]] ; then
            echo -e "\nBit rates for this round of crf testing:"
            column -t "${source1%.*}".$2.crf2.log|sort -u
        fi

        echo "Look through all test encodings"
        echo "and decide, with which crf you"
        echo "get best results at considerable bitrate."
        echo "Then close AvsPmod."
        sleep 0.6
        wine "$avspmod" "${source1%.*}".$2.crf2.*.avs
    }

    while true; do
        echo -e "\nAfter all that optimization, you may test for"
        echo "another, probably more bitsaving value of crf."

        echo -e "\nSo far you tested with a crf of ${crf##*=}.\n"
        echo "Choose crf values for test encodings of"
        echo -e ""${source2%.*}" in $2\n"

        echo "RETURN for more testing on crf,"
        echo -e "else e(x)it.\n"

        read -e -p "(RETURN|x) > " answer_crf2
            case $answer_crf2 in
                x|X) # just nothing
                    break
                ;;

                *)
                    unset crf2low
                    unset crf2high
                    unset crf2increment
                    test_crf2 $1 $2
                ;;
            esac
    done

    until [[ $crf_2 =~ ^[0-4][0-9]\.[0-9]|[5][0-2]\.[0-9]|53\.0$ ]] ; do
        echo "Set crf value for $2."
        echo "So far you tested with a crf of ${crf##*=}."
        read -e -p "New crf > " crf_2
    done
    # keep cfg informed
    sed -i "/crf$2/d" "$config"
    echo "crf$2=$crf_2" >> "$config"
    # corresponding bit rate
    br=$(cat "${source1%.*}".$2.crf2.log|grep "crf $crf_2"|cut -d':' -f2|cut -d' ' -f2|cut -d'.' -f1|sort -u)
    # keep cfg informed
    sed -i "/br$2/d" "$config"
    echo "br$2=$br" >> "$config"

    echo -e "\nNow you may encode the whole movie."
    echo -e "Continue with option 13.\n"
    ;;

    13) # 13 - encode the whole movie

    function set_bitrate_final {
        until [[ $br2 =~ ^[1-9][0-9]+*$ ]]; do
            echo "Set bitrate for final encoding"
            read -e -p "Bitrate for $2 > " br2
        done
        # keep cfg informed
        sed -i "/br$2/d" "$config"
        echo "br$2=$br2" >> "$config"
        br="$br2"
    }

    function br_change_final {
        if [[ -n ${br##*=} ]]; then
            echo -e "\nFinal encoding in 2pass mode"
            echo -e "Bitrate is ${br##*=}\n"
            echo "RETURN, if ok"
            echo "else, (e)dit"
            read -e -p "(RETURN|e) > " answer_br
            case $answer_br in
                e|E|edit|EDIT|Edit)
                    set_bitrate_final $1 $2
                ;;

                *)    # do nothing here
                ;;
            esac
        else
            set_bitrate_final $1 $2
        fi
    }

    function encoding_pre {
        if [[ ${ratectrl##*=} == c ]]; then
            echo -n "Now encoding ${source2%.*}.final.$2.crf"${crf##*=}".mkv"
        elif [[ ${ratectrl##*=} == 2 ]]; then
            echo -n "Now encoding ${source2%.*}.final.$2.br"${br##*=}".mkv"
        fi
        if [[ -n ${darwidth1##*=} && -n ${sarheight1##*=} ]]; then
            echo -n " with a resolution of ${darwidth1##*=}×${sarheight1##*=}"
        elif [[ -n ${darheight1##*=} && -n ${sarwidth1##*=} ]]; then
            echo -n " with a resolution of ${sarwidth1##*=}×${darheight1##*=}"
        else
            echo -n " with a resolution of ${width##*=}×${height##*=}"
        fi
        if [[ $par != 1:1 ]]; then
            echo -n ", a PAR of $par"
        fi
        if [[ $ratectrl == 2 ]]; then
            echo -e " and ${br##*=} kb/s\n"
        elif [[ $ratectrl == c ]]; then
            echo -e " and constant ratecontrol of ${crf##*=}\n"
        fi
        # Remove content from old log files
        echo "" > ${source2%.*}.final.$2.log >/dev/null 2>&1
    }

    function SDcomparison {
        # Create comparison screen avs
        echo "Import(\""$lwlinfo"\")" > "${source1%.*}".comparison.$2.avs
        echo "LoadPlugin(\""$lsmashsource"\")" >> "${source1%.*}".comparison.$2.avs
        echo "a=import(\"${finalavs##*=}\").subtitle(\"${source2%.*} source $2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "${source1%.*}".comparison.$2.avs
        if [[ ${ratectrl##*=} == c ]]; then
        echo "b=LWLibavVideoSource(\"${source1%.*}.final.$2.crf"${crf##*=}".mkv\").subtitle(\"${source2%.*} encode $2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "${source1%.*}".comparison.$2.avs
        elif [[ ${ratectrl##*=} == 2 ]]; then
        echo "b=LWLibavVideoSource(\"${source1%.*}.final.$2.br"${br##*=}".mkv\").subtitle(\"${source2%.*} encode $2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "${source1%.*}".comparison.$2.avs
        fi
        echo "interleave(a,b)" >> "${source1%.*}".comparison.$2.avs

        echo "LoadPlugin(\"$z_resize\")" >> "${source1%.*}".comparison.$2.avs
        echo "$res_dep_resize" >> "${source1%.*}".comparison.$2.avs
    }

    function HDcomparison {
        # Create comparison screen avs
        echo "Import(\""$lwlinfo"\")" > "${source1%.*}".comparison.$2.avs
        echo "LoadPlugin(\""$lsmashsource"\")" >> "${source1%.*}".comparison.$2.avs
        if [[ -n ${darwidth1##*=} && -n ${sarheight1##*=} ]]; then
            echo "a=import(\"${finalavs##*=}\").Spline36Resize("${darwidth1##*=}","${sarheight1##*=}").subtitle(\"${source2%.*} source $2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "${source1%.*}".comparison.$2.avs
        elif [[ -n ${darheight1##*=} && -n  ${sarwidth1##*=} ]]; then
            echo "a=import(\"${finalavs##*=}\").Spline36Resize("${sarwidth1##*=}","${darheight1##*=}").subtitle(\"${source2%.*} source $2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "${source1%.*}".comparison.$2.avs
        else
            echo "a=import(\"${finalavs##*=}\").Spline36Resize("${width##*=}","${height##*=}").subtitle(\"${source2%.*} source $2\", "$align_position").LWLInfo()#.trim(0,framecount)" > "${source1%.*}".comparison.$2.avs
        fi
        if [[ ${ratectrl##*=} == c ]]; then
        echo "b=LWLibavVideoSource(\"${source1%.*}.final.$2.crf"${crf##*=}".mkv\").subtitle(\"${source2%.*} encode $2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "${source1%.*}".comparison.$2.avs
        elif [[ ${ratectrl##*=} == 2 ]]; then
        echo "b=LWLibavVideoSource(\"${source1%.*}.final.$2.br"${br##*=}".mkv\").subtitle(\"${source2%.*} encode $2\", "$align_position").LWLInfo()#.trim(0,framecount)" >> "${source1%.*}".comparison.$2.avs
        fi
        echo "interleave(a,b)" >> "${source1%.*}".comparison.$2.avs
    }

    function encode2pass {
        start=$(date +%s)

        # 1. pass
        wine "$avs2yuv" "${finalavs##*=}" - \
        | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
        --qpfile "${config%/*}/${source2%.*}.qpfile.txt" \
        --pass 1 \
        --bitrate "${br##*=}" \
        --sar "$par" \
        --stats "${source1%.*}.$2.stats" \
        --ref "${ref##*=}" \
        --qcomp "${qcomp##*=}" \
        --aq-strength "${aqs##*=}" \
        --psy-rd "${psyrd##*=}":"${psytr##*=}" \
        --preset "$preset" \
        --tune "$tune" \
        --profile "$profile" \
        --rc-lookahead "${lookahead##*=}" \
        --me "$me" \
        --merange "$merange" \
        --subme "$subme" \
        --aq-mode "${aqmode##*=}" \
        --deblock "${deblocka##*=}":"${deblockb##*=}" \
        --chroma-qp-offset "${cqpo##*=}" \
        --colormatrix "${colormatrix##*=}" --colorprim "${colorprim##*=}" \
        -o /dev/null - 2>&1|tee -a "${source1%.*}".final.$2.log;

        # 2. pass
        wine "$avs2yuv" "${finalavs##*=}" - \
        | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
        --qpfile "${config%/*}/${source2%.*}.qpfile.txt" \
        --pass 3 \
        --bitrate "${br##*=}" \
        --stats "${source1%.*}.$2.stats" \
        --sar "$par" \
        --ref "${ref##*=}" \
        --qcomp "${qcomp##*=}" \
        --aq-strength "${aqs##*=}" \
        --psy-rd "${psyrd##*=}":"${psytr##*=}" \
        --preset "$preset" \
        --tune "$tune" \
        --profile "$profile" \
        --rc-lookahead "${lookahead##*=}" \
        --me "$me" \
        --merange "$merange" \
        --subme "$subme" \
        --aq-mode "${aqmode##*=}" \
        --deblock "${deblocka##*=}":"${deblockb##*=}" \
        --chroma-qp-offset "${cqpo##*=}" \
        --colormatrix "${colormatrix##*=}" --colorprim "${colorprim##*=}" \
        -o "${source1%.*}".final.$2.br"${br##*=}".mkv - 2>&1|tee -a "${source1%.*}".final.$2.log;

        stop=$(date +%s);
        days=$(( ($stop-$start)/86400 ))
        time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")

        # Remove stats file
        rm ${source1%.*}.$2.*.stats
        rm ${source1%.*}.$2.*.mbtree
    }

    function encodecrf {
        start=$(date +%s)
        if [[ -e ${config%/*}/$1.$2.zones.txt ]]; then
            wine "$avs2yuv" "${finalavs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --zones "${zones}" \
            --qpfile "${config%/*}/${source2%.*}.qpfile.txt" \
            --crf "${crf##*=}" \
            --sar "$par" \
            --ref "${ref##*=}" \
            --qcomp "${qcomp##*=}" \
            --aq-strength "${aqs##*=}" \
            --psy-rd "${psyrd##*=}":"${psytr##*=}" \
            --preset "$preset" \
            --tune "$tune" \
            --profile "$profile" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --chroma-qp-offset "${cqpo##*=}" \
            --colormatrix "${colormatrix##*=}" --colorprim "${colorprim##*=}" \
            -o "${source1%.*}".final.$2.crf"${crf##*=}".mkv - 2>&1|tee -a "${source1%.*}".final.$2.log;
        else
            wine "$avs2yuv" "${finalavs##*=}" - \
            | x264 --stdin y4m ${nombtree:+"--no-mbtree"} \
            --qpfile "${config%/*}/${source2%.*}.qpfile.txt" \
            --crf "${crf##*=}" \
            --sar "$par" \
            --ref "${ref##*=}" \
            --qcomp "${qcomp##*=}" \
            --aq-strength "${aqs##*=}" \
            --psy-rd "${psyrd##*=}":"${psytr##*=}" \
            --preset "$preset" \
            --tune "$tune" \
            --profile "$profile" \
            --rc-lookahead "${lookahead##*=}" \
            --me "$me" \
            --merange "$merange" \
            --subme "$subme" \
            --aq-mode "${aqmode##*=}" \
            --deblock "${deblocka##*=}":"${deblockb##*=}" \
            --chroma-qp-offset "${cqpo##*=}" \
            --colormatrix "${colormatrix##*=}" --colorprim "${colorprim##*=}" \
            -o "${source1%.*}".final.$2.crf"${crf##*=}".mkv - 2>&1|tee -a "${source1%.*}".final.$2.log
        fi
        stop=$(date +%s);
        days=$(( ($stop-$start)/86400 ))
        time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
    }

    function encoding_post {
        if [[ $ratectrl == 2 ]]; then
        echo -n "Encoding ${source2%.*}.final.$2.br"${br##*=}".mkv"
        elif [[ $ratectrl == c ]]; then
        echo -n "Encoding ${source2%.*}.final.$2.crf"${crf##*=}".mkv"
        fi
        if [[ -n ${darwidth1##*=} && -n ${sarheight1##*=} ]]; then
            echo -n " with a resolution of ${darwidth1##*=}×${sarheight1##*=}"
        elif [[ -n ${darheight1##*=} && -n  ${sarwidth1##*=} ]]; then
            echo -n " with a resolution of ${sarwidth1##*=}×${darheight1##*=}"
        else
            echo -n " with a resolution of ${width##*=}×${height##*=}"
        fi
        if [[ $par != 1:1 ]]; then
            echo -n ", a PAR of $par"
        fi
        if [[ $ratectrl == 2 ]]; then
            echo -n " and $br kb/s"
        elif [[ $ratectrl == c ]]; then
            echo -n " and constant ratecontrol of ${crf##*=}"
        fi
        echo -e " lasted $days days and $time\n"

        # Extract relevant info from final encode log
        # Replace windows-like CR (^M) with new line (\n)
        sed -i "s/\r/\n/g" ${source2%.*}.final.$2.log
        grep -B 20 "encoded" "${source2%.*}".final.$2.log > ${source2%.*}.final.$2.summary.log
    }

    function comparison {
        echo "Take some comparison screen shots,"
        echo "then close AvsPmod."
        sleep 1
        wine "$avspmod" "${source1%.*}".comparison.$2.avs && exit
    }

    echo -e "\nFinally encode the movie"
    echo "with ratecontrol as bitrate fixed 2pass"
    echo "or ratecontrol via crf"
    if [[ ${ratectrl##*=} == c ]]; then
        echo -e "\nRate control is set to crf"
    elif [[ ${ratectrl##*=} == 2 ]]; then
        echo -e "\nRate control is set to 2pass"
    fi

    until [[ $ratectrl_final =~ 2|c ]]; do
        echo "Choose (c)rf or (2)pass"
        read -e -p "(c|2) > " ratectrl_final
            case $ratectrl_final in
                c|C)
                    echo -e "\nRatecontrol set to crf\n"
                ;;

                2)
                    echo -e "\nRatecontrol set to 2pass\n"
                    br_change_final $1 $2
                ;;
            esac
                    # keep cfg informed
                    sed -i "/ratectrl$2/d" "$config"
                    echo "ratectrl$2=$ratectrl_final" >> "$config"
                    ratectrl=$ratectrl_final
    done

    encoding_pre $1 $2
    if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]] ; then
        SDcomparison $1 $2
    elif [[ $sarheight0 -gt 576 ]] && [[ $sarwidth0 -gt 720 ]] ; then
        HDcomparison $1 $2
    fi
    if [[ ${ratectrl##*=} == c ]]; then
        encodecrf $1 $2
    elif [[ ${ratectrl##*=} = 2 ]]; then
        encode2pass $1 $2
    fi
    encoding_post $1 $2
    if [ -e /usr/bin/beep ]; then beep $beep; fi
    comparison $1 $2
    ;;

    *)  # neither any of the above
        echo "Exiting…"
        exit 0
    ;;
esac
done
