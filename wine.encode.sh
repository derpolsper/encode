#!/bin/bash

# path to your config file
config="$HOME/.config/wine.encode/default.cfg"

# path to wine directory
winedir="$HOME/.wine"

# filters
# path to your fillmargins
# if in wine directory, prevent bash from expanding (back)slashes
# e.g. pathfillmargins=/home/user/.wine\/drive_c\/Program\\ Files\/FillMargins\/FillMargins.dll:
pathfillmargins="$HOME/.config/wine.encode/.filters/FillMargins/FillMargins.dll"

# path to your f3kdb
# if in wine directory, prevent bash from expanding (back)slashes
# e.g. pathfillmargins=/home/user\/.wine\/drive_c\/Program\\ Files\/f3kdb\/flash3kyuu_deband.dll:
pathf3kdb="$HOME/.config/wine.encode/.filters/f3kdb/flash3kyuu_deband.dll"

# path to ColorMatrix.dll
# if in wine directory, prevent bash from expanding (back)slashes
# e.g. pathfillmargins=/home/user\/.wine\/drive_c\/windows\/system32\/ColorMatrix\/ColorMatrix.dll:
pathcolormatrix="$HOME/.config/wine.encode/.filters/ColorMatrix/ColorMatrix.dll"

# beeps
# mario
#beep='-f 130 -l 100 -n -f 262 -l 100 -n -f 330 -l 100 -n -f 392 -l 100 -n -f 523 -l 100 -n -f 660 -l 100 -n -f 784 -l 300 -n -f 660 -l 300'
# simple
beep='-f 400 -r 2 -d 50'

#set -o pipefail # if command in pipe fails, exit script
#set -e          # if command fails, exit script

# parameter $1 set or unset?
if [[ -z ${1+x} ]]; then
# if unset, read from default
	while IFS='=' read lhs rhs; do
		if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
			rhs="${rhs%%\#*}"		# delete in line right comments
			rhs="${rhs%"${rhs##*[^ ]}"}"	# delete trailing spaces
			rhs="${rhs%\"*}"		# delete opening string quotes
			rhs="${rhs#\"*}"		# delete closing string quotes
			declare $lhs="$rhs"
		fi
	done < "$config"

	echo ""
	echo "***  no config file generated ***"
	echo "***   yet for this encoding   ***"
	echo ""

else
# if set, but config not existing yet, cp default to $1
# and set $1-config as config
	if [[ ! -f ${config%/*}/$1.cfg ]]; then
		cp "$config" "${config%/*}"/"$1".cfg
	fi
	config="${HOME}/.config/wine.encode/$1.cfg"
	echo ""
	echo "your config file is $config"
	echo ""

	while IFS='=' read lhs rhs; do
		if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
			rhs="${rhs%%\#*}"		# delete in line right comments
			rhs="${rhs%"${rhs##*[^ ]}"}"	# delete trailing spaces
			rhs="${rhs%\"*}"		# delete opening string quotes
			rhs="${rhs#\"*}"		# delete closing string quotes
			declare $lhs="$rhs"
		fi
	done < "$config"
fi

function checks0 {

	if [[ ! -e $source1 ]]; then
	echo ""
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "you may walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
		echo ""
		echo "source is SD"
        else
                echo ""
                echo "source is HD"
	fi
}

echo ""
echo "what do you want to do?"
echo ""
echo "00 - check for necessary programs and"
echo "     show|edit default settings"
echo ""
echo "0  - display current encoding parameters"
echo ""
echo "1  - rip your remux|m2ts|VOB files into a matroska container,"
echo ""
echo "2  - create avs files"
echo ""
echo "3  - testing for crf"
echo ""
echo "4  - variations in qcomp"
echo ""
echo "5  - variations in aq strength and psy-rd"
echo ""
echo "6  - variations in psy-trellis"
echo ""
echo "7  - some more things: chroma-qp-offset etc"
echo ""
echo "8  - another round of crf"
echo ""
echo "9  - encode the whole movie"
echo ""
read -p "> " answer_00

case "$answer_00" in

	00) # 00 - installed programs - default settings

	# bash, x264, avconv/ffmpeg, mkvmerge, mediainfo, exiftool, wine,
	# eac3to, AviSynth, AvsPmod, avs2yuv, fillmargins, f3kdb, ColorMatrix, 
	# beep

	#clear terminal
	clear

	echo ""
	echo "*** check for required programs ***"
	echo ""

	if [ -e /bin/bash ]; then
		/bin/bash --version|head -1 ; echo ""
        else
		echo ""
		echo "***"
		echo "*** bash NOT installed!"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/x264 ]; then
		/usr/bin/x264 -V|grep x264 -m 1 ; echo ""
        else
                echo ""
		echo "***"
		echo "*** x264 NOT installed!"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/mkvmerge ]; then 
		/usr/bin/mkvmerge -V; echo ""
        else
                echo ""
		echo "***"
		echo "*** mkvmerge NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/mediainfo ]; then
		/usr/bin/mediainfo --Version; echo ""
	else
                echo ""
		echo "***"
		echo "*** mediainfo NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/exiftool ]; then
		echo -n "exiftool "; /usr/bin/exiftool -ver; echo ""
        else
		echo ""
		echo "***"
		echo "*** exiftool NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/wine ]; then
		/usr/bin/wine --version; echo ""
        else
                echo ""
		echo "***"
		echo "*** wine NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e "$winedir"/drive_c/Program\ Files/eac3to/eac3to.exe ]; then
		wine "$winedir"/drive_c/Program\ Files/eac3to/eac3to.exe|grep 'eac3to v'; echo ""
        else
                echo ""
		echo "***"
		echo "*** eac3to seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e "$winedir"/drive_c/windows/system32/avisynth.dll ]; then
		echo "avisynth seems to be installed"
		echo ""
        else
		echo ""
		echo "***"
		echo "*** avisynth seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe ]; then
		echo "AvsPmod seems to be installed"
		echo ""
        else
                echo ""
		echo "***"
		echo "*** AvsPmod seems not to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe ]; then
		echo "avs2yuv seems to be installed"
		echo ""
	else
		echo ""
		echo "***"
		echo "*** avs2yuv seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e "${config%/*}"/.filters/FillMargins/FillMargins.dll ]; then
		echo "FillMargins seems to be installed"
		echo ""
        else
		echo ""
		echo "***"
		echo "*** FillMargins seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e "${config%/*}"/.filters/f3kdb/flash3kyuu_deband.dll ]; then
		echo "f3kdb seems to be installed"
		echo ""
	else
		echo ""
		echo "***"
		echo "*** f3kdb seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e "${config%/*}"/.filters/ColorMatrix/ColorMatrix.dll ]; then
		echo "ColorMatrix seems to be installed"
		echo ""
	else
		echo ""
		echo "***"
		echo "*** ColorMatrix seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ ! -e /usr/bin/beep ]; then
		echo ""
		echo "***"
		echo "*** info: beep not installed"
		echo "***"
	fi

	echo ""
	read -p "hit return to continue"

	#clear terminal
	clear

	echo ""
	echo "*** default settings ***"
	echo ""
	echo -e "TUNE:\t\t ""$tune"
	echo -e "PROFILE:\t ""$profile"
	echo -e "PRESET:\t\t ""$preset"
	echo ""
	echo -e "ME:\t\t ""$me"
	echo -e "MERANGE:\t ""$merange"
	echo -e "SUBME:\t\t ""$subme"
	echo -e "AQMODE:\t\t ""$aqmode"
	echo -e "DEBLOCK:\t ""$deblock"
	echo -e "LOOKAHEAD:\t ""$lookahead"
	echo ""
	echo "*** SelectRangeEvery ***"
	echo ""
	echo -e "INTERVAL:\t" "$interval"
	echo -e "LENGTH:\t\t" "$length"
	echo -e "OFFSET:\t\t" "$offset"
	echo ""
	echo "reframes are calculated automatically"
	echo ""
	echo "if you want to adjust settings to your needs,"
	echo "hit (e)dit now, else return"
	echo ""
	read -e -p "(return|e) > " answer_defaultsettings
	echo ""

	case "$answer_defaultsettings" in

		e|E|edit) # edit the wine.encode/default.cfg

			"${EDITOR:-vi}" "$config"
		;;

		*) # no editing
		;;
	esac

	echo "you might go on with option 1"
	echo ""
	;;

	0)  # 0 - current settings

        checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)
	width=$(cat "$config"|grep width|grep $2)
	height=$(cat "$config"|grep height|grep $2)

	echo ""
	echo "*** general settings ***"
	echo ""
	echo -e "TUNE:\t\t ""$tune"
	echo -e "PROFILE:\t ""$profile"
	echo -e "PRESET:\t\t ""$preset"
	echo ""
	echo -e "ME:\t\t ""$me"
	echo -e "MERANGE:\t ""$merange"
	echo -e "SUBME:\t\t ""$subme"
	echo -e "AQMODE:\t\t ""$aqmode"
	echo -e "DEBLOCK:\t ""$deblock"
	echo -e "LOOKAHEAD:\t ""$lookahead"
	echo ""
	echo "*** SelectRangeEvery ***"
	echo ""
	echo -e "INTERVAL:\t" "$interval"
	echo -e "LENGTH:\t\t" "$length"
	echo -e "OFFSET:\t\t" "$offset"
	echo ""
	echo ""
	echo "*** current settings for $2 ***"
	echo ""
	echo -e "WIDTH:\t\t\t ""${width##*=}"
	echo -e "HEIGHT:\t\t\t ""${height##*=}"
	echo ""
	echo -e "CROPPING (ltrb):\t ""${left_crop##*=}","${top_crop##*=}","${right_crop##*=}","${bottom_crop##*=}"
	echo -e "FILLMARGINS (ltrb):\t ""${left_fillmargins##*=},${top_fillmargins##*=},${right_fillmargins##*=},${bottom_fillmargins##*=}"
	echo ""
	echo -e "ratecontrol:\t\t ""${ratecontrol##*=}"
	echo ""
	echo -e "CRF:\t\t\t ""${crf##*=}"
	echo -e "QCOMP:\t\t\t ""${qcomp##*=}"
	echo -e "AQSTRENGTH:\t\t ""${aqs##*=}"
	echo -e "PSY-RD:\t\t\t ""${psyrd##*=}"
	echo -e "PSY-TR:\t\t\t ""${psytr##*=}"
	echo -e "CHROMA-QP-OFFSET:\t ""${cqpo##*=}"

	echo ""
	echo "you may adjust them to your needs, e.g."
	echo "change SelectRangeEvery values in case of"
	echo "short film"
	echo ""
	echo "if you want to adjust them to your needs"
	echo "manually, hit (e)dit now, else return"
	echo ""
	read -e -p "(return|e) > " answer_defaultsettings
	echo ""

	case "$answer_defaultsettings" in

		e|E|edit) # edit the wine.encode/default.cfg

			"${EDITOR:-vi}" "$config"
		;;

		*) # no editing
		;;
	esac

	echo "you may go on with your process of encoding"
	echo ""
	;;

	1)  # 1 - prepare sources: rip your remux/ m2ts/ VOB → mkv

	# check source0 for dir VIDEO_TS or file m2ts
	until [[  -e $source0 ]] && ( [[ $source0 == *VIDEO_TS* || $source0 == *.m2ts || $source0 == *.mkv ]] ); do
		echo ""
		echo "set path to your source: a VIDEO_TS directory,"
		echo "mkv or m2ts file respectively"
		echo ""
		read -e -p "> " source0
		echo ""
	done

	# check source1 for file extension == mkv
	until [[ $source1 == *.mkv ]]; do
		echo "save the demuxed file to a directory"
		echo ""
		echo "DO NOT save it in same directory and"
		echo "under same name as source file!"
		echo ""
		echo "absolute path AND name WITH file extension:"
		echo "e.g. /home/encoding/moviename.mkv"
		echo ""
		read -e -p "> " source1
		echo ""
	done

	# source file name without file extension
	# bash parameter expansion does not allow nesting, so do it in two steps
	source2=${source1##*/}

# TODONOTE quite hacky: if dir -> dvd, if file -> bluray|remux
	if [ -d "$source0" ]; then
                # VOBs -> mkv
		cd "$source0"
		until [[ $param0 == *VTS*.VOB* ]]; do
			echo "choose out of these VOB containers:"
			echo ""
			ls -l "$source0"|awk '!/VIDEO/ {print}'| awk '/VOB$/ {print }'|awk '!/0.VOB/ { printf $9 "%12i\n", $5}'
			echo ""
			echo "which group of VOB containers do you"
			echo "want to encode? add them like this:"
			echo "VTS_02_1.VOB+VTS_02_2.VOB+VTS_02_3.VOB(+…)"
			echo ""
			read -e -p "> " param0
			echo ""
		done

		wine "$winedir"/drive_c/Program\ Files/eac3to/eac3to.exe "$param0"

		until [[ $param1 == *.mpeg2* || $param1 == *.ac3* || $param1 == *.sup* ]]; do
			echo ""
			echo "extract all wanted tracks following this name pattern:"
			echo "[1-n]:name.extension, e.g. 2:name.mpeg2 3:name.ac3 4:name.eng.sup 5:name.spa.sup etc"
			echo "the video stream HAS TO be given mpeg2 as file extension"
			echo ""
			read -e -p "> " param1
			echo ""
		done

		# keep $param1 without parenthesis, otherwise eac3to fails while parsing the parameter
		wine "$winedir"/drive_c/Program\ Files/eac3to/eac3to.exe "$param0" $param1

# TODONOTE dirty. problems when >1 mpeg2 file
		mkvmerge -v -o "$source1" $(ls "$source0"|grep mpeg2)

		# remove the h264|mpeg2|vc1 file
                rm -v $(ls "${source0%/*}"|grep -iE "h264|mpeg2|vc1" )
		# eac3to's Log file names contain spaces
		for i in ./*.txt; do mv -v "$i" $(echo "$i" | sed 's/ /_/g') ; done
# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in ./*m2v ./*.mpeg* ./*.h264 ./*.dts* ./*.pcm ./*vc1 ./*.flac ./*.ac3 ./*.aac ./*.wav ./*.w64 ./*.sup ./*.txt ./*.srt; do
		mv $file "${source1%/*}"/ &>/dev/null; done

		echo ""
		echo "you find the demuxed files in"
		echo "${source1%/*}/"
		echo ""

	elif [[ -f  $source0 ]]  && [[ $source0 == *.m2ts || $source0 == *.mkv || $source0 == *.vc1 ]] ; then
		cd "${source0%/*}"

		wine "$winedir"/drive_c/Program\ Files/eac3to/eac3to.exe "${source0##*/}"

		until [[ $param1 == *.h264* || $param1 == *.mpeg2* || $param1 == *.vc1*  || $param1 == *.sup*  || $param1 == *.flac*  || $param1 == *.ac3*  || $param1 == *.dts* || $param1 == *.* ]]; do
			echo ""
			echo "extract all wanted tracks following this name pattern:"
			echo "[1-n]:name.extension, e.g. 2:name.h264 3:name.flac 4:name.ac3 5:name.sup etc"
			echo "the video stream HAS TO be given h264, mpeg2 or vc1 as file extension"
			echo ""
			read -e -p "> " param1
			echo ""
		done

		# keep $param1 without parenthesis, otherwise eac3to fails while parsing the parameter
		wine "$winedir"/drive_c/Program\ Files/eac3to/eac3to.exe "${source0##*/}" $param1

# TODONOTE: dirty. problems when >1 h264|mpeg2|vc1 file
		mkvmerge -v -o "$source1" $(ls "${source0%/*}"|grep -iE "h264|mpeg2|vc1" )

		# remove the h264|mpeg2|vc1 file
                rm -v $(ls "${source0%/*}"|grep -iE "h264|mpeg2|vc1" )
		# remove spaces out of eac3to's log file name
		for i in ./*.txt; do mv -v "$i" $(echo $i | sed 's/ /_/g') ; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in ./*m2v ./*.mpeg* ./*.h264 ./*.vc1 ./*.dts* ./*.pcm ./*.flac ./*.ac3 ./*.aac ./*.wav ./*.w64 ./*.sup ./*.txt ./*.srt; do
		mv $file "${source1%/*}"/ &>/dev/null; done

		echo ""
		echo "you find the demuxed files in"
		echo "${source1%/*}/"
		echo ""

	else
		echo "something went wrong"
		echo ""
	fi

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	# if no config with encodings' name, generate it or exit
	if [[ ! -e  ${config%/*}/${source2%.*}.cfg ]]; then
		echo "it seems, your encoding does not have a config file yet"
		echo "hit return, if you want to generate a new one"
		echo  "else (n)o"
		echo ""
		read -e -p "(return|n) > " answer_generatecfg
		echo ""

		case "$answer_generatecfg" in

			n|N|no|No|NO)
				echo "exiting, start again with a suitable parameter"
				echo "e.g.: ./wine.encode.sh <name.of.your.encoding>"
				if [[  $(ls -l ${config%/*}|wc -l) -ge 2 ]]; then
				echo "generate a completely new one or choose from these:"
				ls -l ${config%/*}|grep -v default.cfg|awk '/cfg/{print $9}'
				else
				echo "generate a new config file by running option 1 again"
				fi
				echo ""
				read -p "hit return to continue"
				exit
			;;

			*)
				echo "a new config file is generated:"
				echo "${config%/*}/${source2%.*}.cfg"
				cp "$config" "${config%/*}/${source2%.*}.cfg"
				echo ""
				sed -i "/source2/d" "${config%/*}/${source2%.*}.cfg"
				echo "source2=$source2" >> "${config%/*}/${source2%.*}.cfg"
				sed -i "/source1/d" "${config%/*}/${source2%.*}.cfg"
				echo "source1=$source1" >> "${config%/*}/${source2%.*}.cfg"

                                echo "use the corresponding config file"
                                echo "start the script like this:"
                                echo ""
                                echo "./wine.encode.sh ${source2%.*}"
                                echo ""
                                echo "go on with option 2"
                                echo ""
                        ;;
		esac
	fi
        ;;

        2)  # 2 - create avs files

	# get to know your DAR SAR PAR
	sarwidth0=$(exiftool "$source1"|awk '/Image Width/ {print $4}')
	sarheight0=$(exiftool "$source1"|awk '/Image Height/ {print $4}')
	darwidth0=$(exiftool "$source1"|awk '/Display Width/ {print $4}')
	darheight0=$(exiftool "$source1"|awk '/Display Height/ {print $4}')

	# keep cfg informed
	sed -i "/sarheight0/d" "${config%/*}/${source2%.*}.cfg"
	echo "sarheight0=$sarheight0" >> "${config%/*}/${source2%.*}.cfg"
	sed -i "/sarwidth0/d" "${config%/*}/${source2%.*}.cfg"
	echo "sarwidth0=$sarwidth0" >> "${config%/*}/${source2%.*}.cfg"
	sed -i "/darheight0/d" "${config%/*}/${source2%.*}.cfg"
	echo "darheight0=$darheight0" >> "${config%/*}/${source2%.*}.cfg"
	sed -i "/darwidth0/d" "${config%/*}/${source2%.*}.cfg"
	echo "darwidth0=$darwidth0" >> "${config%/*}/${source2%.*}.cfg"
	sed -i "/source2/d" "${config%/*}/${source2%.*}.cfg"
	echo "source2=$source2" >> "${config%/*}/${source2%.*}.cfg"
	sed -i "/source1/d" "${config%/*}/${source2%.*}.cfg"
	echo "source1=$source1" >> "${config%/*}/${source2%.*}.cfg"

	if [[ -z $sar ]]; then
		echo ""
		echo "the movies' storage aspect ratio is $sarwidth0×$sarheight0"
		echo ""
		echo "the movies' display aspect ratio is $darwidth0×$darheight0"
		echo ""
		echo "look into the table to find your pixel aspect ratio"
		echo ""
		echo "________________SAR____|___PAR__|___DAR_____"
		echo "widescreen ntsc 720×480 -> 40:33 ->  704×480"
		echo "                        -> 32:27 ->  853×480"
		echo "widescreen pal  720×576 -> 64:45 -> 1024×576"
		echo "                        -> 16:11 -> 1048×576"

		echo "fullscreen ntsc 720×480 ->  8:9  ->  640×480"
		echo "                        -> 10:11 ->  654×480"
		echo "fullscreen pal  720×576 -> 16:15 ->  768×576"
		echo "                        -> 12:11 ->  786×576"

		echo ""
		echo "almost all bluray is 1:1"
		echo ""

		until [[ $sar =~ ^[[:digit:]]+:[[:digit:]]+$ ]] ; do
			echo "set sar as fraction, use a colon!"
			echo "e.g. 16:15"
			echo ""
			read -e -p "> " sar
				if [[ ! $sar =~ ^[[:digit:]]+:[[:digit:]]+$ ]]; then
					echo "exactly: set as fraction, use a colon!"
					echo "e.g. 16:15"
				fi
			echo ""
		done
		# keep cfg informed
		# DIRTY! 'sar=' instead of 'sar' to avoid deleting of sarheight0| sarwidth0
		sed -i "/sar=/d" "${config%/*}/${source2%.*}.cfg"
		echo "sar=$sar" >> "${config%/*}/${source2%.*}.cfg"
	else
		echo "sar for "$source2" is $sar"
		echo ""
	fi

	function cropping {
		echo ""
		echo "if no cropping is needed"
		echo "hit return"
		echo "else hit (n)o"
		echo "AvsP > Video > Crop editor"
		echo "when checked, note values and close AvsPmod window"
		echo "do NOT hit »apply«"

		read -e -p "check now (return|n) > " answer_crop
		echo ""
			case "$answer_crop" in

				n|no|N|No|NO)
				# do nothing here
				;;

                                *)
					echo "FFVideosource(\"$source1\")" > "${source1%.*}".avs
					wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".avs
				;;

			esac

		echo ""
		echo "if no cropping is needed, just type 0 (zero)"
		echo "all numbers unsigned, must be even"

			until [[ $left_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]]; do
				echo "number of pixels to be cropped on the"
				echo ""
				read -e -p "left > " left_crop
				echo ""
				# keep cfg informed
				sed -i "/left_crop/d" "${config%/*}/${source2%.*}.cfg"
				echo "left_crop=$left_crop" >> "${config%/*}/${source2%.*}.cfg"
			done

			until [[ $top_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]] ; do
				echo "number of pixels to be cropped on the"
				echo ""
				read -e -p "top > " top_crop
				echo ""
				# keep cfg informed
				sed -i "/top_crop/d" "${config%/*}/${source2%.*}.cfg"
				echo "top_crop=$top_crop" >> "${config%/*}/${source2%.*}.cfg"
			done

			until [[ $right_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]] ; do
				echo "number of pixels to be cropped on the"
				echo ""
				read -e -p "right > " right_crop
				echo ""
				# keep cfg informed
				sed -i "/right_crop/d" "${config%/*}/${source2%.*}.cfg"
				echo "right_crop=$right_crop" >> "${config%/*}/${source2%.*}.cfg"
			done

			until [[ $bottom_crop =~ ^[1-9][0-9]*[02468]$|^[02468]$ ]] ; do
				echo "number of pixels to be cropped on the"
				echo ""
				read -e -p "bottom > " bottom_crop
				echo ""
				# keep cfg informed
				sed -i "/bottom_crop/d" "${config%/*}/${source2%.*}.cfg"
				echo "bottom_crop=$bottom_crop" >> "${config%/*}/${source2%.*}.cfg"
			done
	}

	if [[ ( -n $left_crop && -n $right_crop && -n $top_crop && -n $bottom_crop ) ]]; then
		echo ""
		echo "cropping values for "$source2":"
		echo "left:  $left_crop"
		echo "top:   $top_crop"
		echo "right: $right_crop"
		echo "bottom:$bottom_crop"
		echo ""
		echo "do you want to (e)dit them?"
		echo "else, return"
		read -e -p "(return|e) > " answer_cropedit
		echo ""

		case $answer_cropedit in

			e|E|edit|EDIT|Edit)
			cropping
			;;

			*)
			# do nothing here
			;;
		esac
	else
		cropping
	fi

	# fillmargins in case of 1 line of black or dirty pixels
	# note: editing the avs files will happen at the end of option 1

	function fillmargins {
		echo ""
		echo "if cropping left one line of black or dirty"
		echo "pixels elsewhere, you can use fillmargins"
		echo ""
		echo "choose as few pixels as possible"
		echo ""
		echo "do you want to use (f)illmargins?"
		echo "else, return"
		read -e -p "(return|f) > " answer_fillmargins
		echo ""

		case $answer_fillmargins in
			f|F|fillmargins|FillMargins)
					# who needs more than 5 pixels for fillmargins?
				until [[ $left_fillmargins =~ ^[0-5]$ ]] ; do
					echo "number of pixels on the"
					echo ""
					read -e -p "left > " left_fillmargins

					# keep cfg informed
					sed -i "/left_fillmargins/d" "${config%/*}/${source2%.*}.cfg"
					echo "left_fillmargins=$left_fillmargins" >> "${config%/*}/${source2%.*}.cfg"
				done

				until [[ $top_fillmargins =~ ^[0-5]$ ]] ; do
					echo "number of pixels on the"
					echo ""
					read -e -p "top > " top_fillmargins
					# keep cfg informed
					sed -i "/top_fillmargins/d" "${config%/*}/${source2%.*}.cfg"
					echo "top_fillmargins=$top_fillmargins" >> "${config%/*}/${source2%.*}.cfg"
				done

				until [[ $right_fillmargins =~ ^[0-5]$ ]] ; do
					echo "number of pixels on the"
					echo ""
					read -e -p "right > " right_fillmargins
					# keep cfg informed
					sed -i "/right_fillmargins/d" "${config%/*}/${source2%.*}.cfg"
					echo "right_fillmargins=$right_fillmargins" >> "${config%/*}/${source2%.*}.cfg"
				done

				until [[ $bottom_fillmargins =~ ^[0-5]$ ]] ; do
					echo "number of pixels on the"
					echo ""
					read -e -p "bottom > " bottom_fillmargins
					echo ""
					# keep cfg informed
					sed -i "/bottom_fillmargins/d" "${config%/*}/${source2%.*}.cfg"
					echo "bottom_fillmargins=$bottom_fillmargins" >> "${config%/*}/${source2%.*}.cfg"
				done
			;;
			*)
			# do nothing here
			;;
		esac
	}

	if [[ ( -n $left_fillmargins && -n $right_fillmargins && -n $top_fillmargins && -n $bottom_fillmargins ) ]]; then
		echo ""
		echo "fillmargin values for $2:"
		echo "left:  $left_fillmargins"
		echo "top:   $top_fillmargins"
		echo "right: $right_fillmargins"
		echo "bottom:$bottom_fillmargins"
		echo ""
		echo "do you want to (e)dit them?"
		echo "else, return"
		read -e -p "(return|e) > " answer_fillmarginsedit
		echo ""

		case $answer_fillmarginsedit in

			e|E|edit|EDIT|Edit)
			fillmargins
			;;

			*)
			# do nothing here
			;;
		esac
	else
		fillmargins
	fi

	sarwidth1=$(echo "$sarwidth0-$left_crop-$right_crop"|bc)
	sarheight1=$(echo "$sarheight0-$top_crop-$bottom_crop"|bc)
	sed -i "/sarwidth1/d" "${config%/*}/${source2%.*}.cfg"
	echo "sarwidth1=$sarwidth1" >> "${config%/*}/${source2%.*}.cfg"
	sed -i "/sarheight1/d" "${config%/*}/${source2%.*}.cfg"
	echo "sarheight1=$sarheight1" >> "${config%/*}/${source2%.*}.cfg"

	function ratecontrol {
		until [[ $answer_ratecontrol0 =~ [2,c,C] ]]; do
                        echo ""
                        echo "bitrate control with (c)rf or (2)pass?"
                        read -e -p "(c|2) > " answer_ratecontrol0
                        echo ""
                        case "$answer_ratecontrol0" in
                            c|C)
                                # keep cfg informed
                                sed -i "/ratecontrol/d" "$config"
                                echo "ratecontrol=c" >> "$config"
                                echo "ratecontrol toggled to crf"
                            ;;

                            2)
                                # keep cfg informed
                                sed -i "/ratecontrol/d" "$config"
                                echo "ratecontrol=2" >> "$config"
                                echo "ratecontrol toggled to 2pass"
                            ;;
                        esac
                done
	}

	function ratecontrolchange {
                if [[ ${ratecontrol##*=} = 2 && ${ratecontrol##*=} != c ]]; then
                    sed -i "/ratecontrol/d" "${config%/*}/${source2%.*}.cfg"
                    echo "ratecontrol=c" >> "${config%/*}/${source2%.*}.cfg"
                    echo ""
                    echo "ratecontrol toggled to crf"
                elif [[ ${ratecontrol##*=} != 2 && ${ratecontrol##*=} = c ]]; then
                    sed -i "/ratecontrol/d" "${config%/*}/${source2%.*}.cfg"
                    echo "ratecontrol=2" >> "${config%/*}/${source2%.*}.cfg"
                    echo ""
                    echo "ratecontrol toggled to 2pass"
                fi
	}

	if [[  ${ratecontrol##*=} = c || ${ratecontrol##*=} = 2 ]]; then
                if [[ ${ratecontrol##*=} == c ]]; then
                    echo "right now, rate control is set to crf"

		elif [[ ${ratecontrol##*=} == 2 ]]; then
                    echo "right now, rate control is set to 2pass"
		fi

		echo ""
		echo "do you want to (c)hange this?"
		echo "else, return"
		echo ""
		read -e -p "(return|c) > " answer_ratecontrol

		case $answer_ratecontrol in
			c|C|change|Change)
                            ratecontrolchange
			;;

			*)
                            echo ""
                            echo "ratecontrol unchanged" # do nothing here
			;;
		esac
	else
		ratecontrol
	fi

	# check source for being interlaced and/or telecined
	echo ""
	echo "check, if your movie is interlaced"
	echo ""
	echo -n "mediainfo says: "
	mediainfo "$source1"|awk '/Scan type/{print $4}'
	echo ""
	echo -n "exiftool says: "
	exiftool "$source1"|awk '/Scan Type/{print $5}'
	echo ""
	read -p "hit return to continue"

	echo ""
	echo "do you want to (c)heck with AvsPmod frame by frame,"
	echo "if your movie is interlaced and/or telecined?"
	echo "if yes, close AvsPmod window afterwards"
	echo "else, return"
	echo ""
	read -e -p "(return|c) > " answer_check_interlaced_telecined
	echo ""

	case "$answer_check_interlaced_telecined" in
		c|C|check|Check)
			# generate an almost empty avs just to check if movie is interlaced or telecined
	#		sed -i "/checkavs/d" "$config"
	#		echo "checkavs=${source1%.*}.avs" >> "${config%/*}/${source2%.*}.cfg"
			echo "FFVideosource(\"$source1\")" > "${source1%.*}".avs
			wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".avs
		;;

		*)
		;;
	esac

	echo ""
	echo "characteristics of your video source:"
	echo "(i)nterlaced?"
	echo "(t)elecined?"
#	echo "(b)oth: first interlaced, then telecined?"
	echo "(n)either nor?"
	echo ""
	read -e -p "(i|t|n) > " answer_interlaced_telecined
	echo ""

		case "$answer_interlaced_telecined" in
			i|I) # interlaced
				sed -i "/interlaced/d" ${config%/*}/${source2%.*}.cfg
				echo "interlaced=1" >> ${config%/*}/${source2%.*}.cfg
				for i in "${source1%.*}".*.avs ; do
                                        sed -i "s/#interlaced/QTGMC().SelectEven()/" "$i"
				done
                            ;;

			t|T) # telecined
				sed -i "/telecined/d" ${config%/*}/${source2%.*}.cfg
				echo "telecined=1" >> ${config%/*}/${source2%.*}.cfg
				for i in "${source1%.*}".*.avs ; do
					sed -i "s/#telecined/TFM().TDecimate()/" "$i"
				done
			;;

	#		b|B) # interlaced and then telecined
	#			sed -i "/interlaced/d" "${config%/*}/${source2%.*}.cfg"
	#			echo "interlaced=1" >> "${config%/*}/${source2%.*}.cfg"
	#			sed -i "/telecined/d" "${config%/*}/${source2%.*}.cfg"
	#			echo "telecined=1" >> "${config%/*}/${source2%.*}.cfg"
	#			for i in "${source1%.*}".*.avs ; do
	#				sed -i "s/#interlaced/QTGMC().SelectEven()/" "$i"
	#			done
	#			for i in "${source1%.*}".*.avs ; do
	#				sed -i "s/#telecined/TFM().TDecimate()/" "$i"
	#			done
	#		;;

			n|N) # neither interlaced nor telecined
				sed -i "/interlaced/d" "${config%/*}/${source2%.*}.cfg"
				echo "interlaced=0" >> "${config%/*}/${source2%.*}.cfg"
				sed -i "/telecined/d" "${config%/*}/${source2%.*}.cfg"
				echo "telecined=0" >> "${config%/*}/${source2%.*}.cfg"
			;;

			*)
			# do nothing here
		esac

	function getresolutionSDfromSD {
		# if resolution is SD will be checked when function is used
		widthSD=$(echo "$sarwidth0-$left_crop-$right_crop"|bc)
		heightSD=$(echo "$sarheight0-$top_crop-$bottom_crop"|bc)

		sed -i "/heightSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "heightSD=$heightSD" >> "${config%/*}/${source2%.*}.cfg"
		sed -i "/widthSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "widthSD=$widthSD" >> "${config%/*}/${source2%.*}.cfg"

		refSD=$(echo "scale=0;32768/((("$widthSD"/16)+0.5)/1 * (("$heightSD"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "refSD=$refSD" >> "${config%/*}/${source2%.*}.cfg"
	}

	function setresolutionSDfromHD {
		until [[ $widthSD =~ ^[[:digit:]]+$ ]] ; do
			echo ""
			echo "set final width for SD"
			echo ""
			read -e -p "width > " widthSD
			echo ""
			sed -i "/widthSD/d" "${config%/*}/${source2%.*}.cfg"
			echo "widthSD=$widthSD" >> "${config%/*}/${source2%.*}.cfg"
		done

		until [[ $heightSD =~ ^[[:digit:]]+$ ]] ; do
			echo "set final height for SD"
			echo ""
			read -e -p "height > " heightSD
			echo ""
			sed -i "/heightSD/d" "${config%/*}/${source2%.*}.cfg"
			echo "heightSD=$heightSD" >> "${config%/*}/${source2%.*}.cfg"
		done

		refSD=$(echo "scale=0;32768/((("$widthSD"/16)+0.5)/1 * (("$heightSD"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "refSD=$refSD" >> "${config%/*}/${source2%.*}.cfg"
	}

	function targetresolutionSDfromHD {
		if [[ -e $widthSD && -e $heightSD ]]; then
			echo "final resolution for SD encoding is $widthSD×$heightSD"
			echo "do you want to (e)dit the values?"
			read -e -p "(return|e) > " answer_targetresSD
			echo ""

			case $answer_targetresSD in
				e|E|edit|Edit)
				setresolutionSDfromHD
				;;

				*)
				;;
			esac
		else
			setresolutionSDfromHD
		fi
	}

	function setresolution720 {
		until [[ $width720 =~ ^[[:digit:]]+$ ]] ; do
			echo ""
			echo "set final width for 720p"
			echo ""
			read -e -p "width > " width720
			echo ""
			sed -i "/width720/d" "${config%/*}/${source2%.*}.cfg"
			echo "width720=$width720" >> "${config%/*}/${source2%.*}.cfg"
		done

		until [[ $height720 =~ ^[[:digit:]]+$ ]] ; do
			echo "set final height for 720p"
			echo ""
			read -e -p "height > " height720
			echo ""
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
		echo "final resolution for 720p encoding is $width720×$height720"
		echo "do you want to (e)dit the values?"
		read -e -p "(return|e) > " answer_targetres720
		echo ""

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
		width1080=$(echo "$sarwidth0-$left_crop-$right_crop"|bc)
		height1080=$(echo "$sarheight0-$top_crop-$bottom_crop"|bc)

		echo ""
		sed -i "/width1080/d" "${config%/*}/${source2%.*}.cfg"
		echo "width1080=$width1080" >> "${config%/*}/${source2%.*}.cfg"

		echo""
		sed -i "/height1080/d" "${config%/*}/${source2%.*}.cfg"
		echo "height1080=$height1080" >> "${config%/*}/${source2%.*}.cfg"

		ref1080=$(echo "scale=0;32768/((("$width1080"/16)+0.5)/1 * (("$height1080"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/ref1080/d" "${config%/*}/${source2%.*}.cfg"
		echo "ref1080=$ref1080" >> "${config%/*}/${source2%.*}.cfg"
	}

	function setresolution1080 {
		until [[ $width1080 =~ ^[[:digit:]]+$ ]] ; do
			echo ""
			echo "set final width for 1080p"
			echo ""
			read -e -p "width > " width1080
			echo ""
			sed -i "/width1080/d" "${config%/*}/${source2%.*}.cfg"
			echo "width1080=$width1080" >> "${config%/*}/${source2%.*}.cfg"
		done

		until [[ $height1080 =~ ^[[:digit:]]+$ ]] ; do
			echo "set final height for 1080p"
			echo ""
			read -e -p "height > " height1080
			echo ""
			sed -i "/height1080/d" "${config%/*}/${source2%.*}.cfg"
			echo "height1080=$height1080" >> "${config%/*}/${source2%.*}.cfg"
		done

		ref1080=$(echo "scale=0;32768/((("$width1080"/16)+0.5)/1 * (("$height1080"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/ref1080/d" "${config%/*}/${source2%.*}.cfg"
		echo "ref1080=$ref1080" >> "${config%/*}/${source2%.*}.cfg"
	}

	function targetresolution1080 {
		if [[ -e $width1080 && -e $height1080 ]]; then
		echo "final resolution for 1080p encoding is $width1080×$height1080"
		echo "do you want to (e)dit the values?"
		echo "else, return"
		read -e -p "(return|e) > " answer_targetres1080
		echo ""

			case $answer_targetres1080 in
				e|E|edit|Edit)
					setresolution1080
				;;

				*)
				;;
			esac
		else
			getresolution1080
		fi
	}

	function  avsSDfromHD {
		# generate a new avs file anyway
		# keep cfg informed
		sed -i "/finalavsSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "finalavsSD=${source1%.*}.SD.final.avs" >> "${config%/*}/${source2%.*}.cfg"
		echo "FFVideosource(\"$source1\")" > "${source1%.*}".SD.final.avs
		echo "#interlaced" >> "${source1%.*}".SD.final.avs
		echo "#telecined" >> "${source1%.*}".SD.final.avs
		echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".SD.final.avs
		echo "#fillmargins0" >> "${source1%.*}".SD.final.avs
		echo "#fillmargins1" >> "${source1%.*}".SD.final.avs
		echo "#f3kdb0" >> "${source1%.*}".SD.final.avs
                echo "#f3kdb1" >> "${source1%.*}".SD.final.avs
                echo "LoadPlugin(\"$pathcolormatrix\")" >> "${source1%.*}".SD.final.avs
                echo "ColorMatrix(mode=\"Rec.709-\>Rec.601\", clamp=0)" >> "${source1%.*}".SD.final.avs
                echo "Spline36Resize($widthSD, $heightSD)" >> "${source1%.*}".SD.final.avs
	}

	function  avsSDfromSD {
		# generate a new avs file anyway
		# keep cfg informed
		sed -i "/finalavsSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "finalavsSD=${source1%.*}.SD.final.avs" >> "${config%/*}/${source2%.*}.cfg"
		echo "FFVideosource(\"$source1\")" > "${source1%.*}".SD.final.avs
		echo "#interlaced" >> "${source1%.*}".SD.final.avs
		echo "#telecined" >> "${source1%.*}".SD.final.avs
		echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".SD.final.avs
		echo "#fillmargins0" >> "${source1%.*}".SD.final.avs
		echo "#fillmargins1" >> "${source1%.*}".SD.final.avs
		echo "#f3kdb0" >> "${source1%.*}".SD.final.avs
		echo "#f3kdb1" >> "${source1%.*}".SD.final.avs
	}

	function  avs720 {
		# generate a new avs file anyway
		# keep cfg informed
		sed -i "/finalavs720/d" "${config%/*}/${source2%.*}.cfg"
		echo "finalavs720=${source1%.*}.720.final.avs" >> "${config%/*}/${source2%.*}.cfg"
		echo "FFVideosource(\"$source1\")" > "${source1%.*}".720.final.avs
		echo "#interlaced" >> "${source1%.*}".720.final.avs
		echo "#telecined" >> "${source1%.*}".720.final.avs
		echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".720.final.avs
		echo "#fillmargins0" >> "${source1%.*}".720.final.avs
		echo "#fillmargins1" >> "${source1%.*}".720.final.avs
		echo "#f3kdb0" >> "${source1%.*}".720.final.avs
		echo "#f3kdb1" >> "${source1%.*}".720.final.avs
		echo "Spline36Resize($width720, $height720)" >> "${source1%.*}".720.final.avs
	}

	function  avs1080 {
		# generate a new avs file anyway
		# keep cfg informed
		sed -i "/finalavs1080/d" "${config%/*}/${source2%.*}.cfg"
		echo "finalavs1080=${source1%.*}.1080.final.avs" >> "${config%/*}/${source2%.*}.cfg"
		echo "FFVideosource(\"$source1\")" > "${source1%.*}".1080.final.avs
		echo "#interlaced" >> "${source1%.*}".1080.final.avs
		echo "#telecined" >> "${source1%.*}".1080.final.avs
		echo "Crop($left_crop, $top_crop, -$right_crop, -$bottom_crop)" >> "${source1%.*}".1080.final.avs
		echo "#fillmargins0" >> "${source1%.*}".1080.final.avs
		echo "#fillmargins1" >> "${source1%.*}".1080.final.avs
                echo "#f3kdb0" >> "${source1%.*}".1080.final.avs
                echo "#f3kdb1" >> "${source1%.*}".1080.final.avs
		# no spline36resize necessary
	}

	function testavsSD {
		cp "${source1%.*}".SD.final.avs "${source1%.*}".SD.test.avs
		echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".SD.test.avs
		# keep cfg informed
		sed -i "/testavsSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "testavsSD=${source1%.*}.SD.test.avs" >> "${config%/*}/${source2%.*}.cfg"
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

	# resizing parameters for hd sources
	if [[ $sarheight0 -gt 576 && $sarwidth0 -gt 720 ]]; then
		echo ""
		echo "if you want to resize, better check"
		echo "for correct target resolution!"
		echo ""
		echo "do you want to (c)heck with AvsPmod for correct"
		echo "target file resolution?"
		echo "else, return"
		echo ""
		echo "AvsP > Tools > Resize calculator"
		echo "after cropping, the source's resolution is $sarwidth1×$sarheight1,"
		echo "the sar is $sar"
		echo "when (c)hecked, note values and close AvsPmod window"
		echo "do NOT hit »apply«"
		read -e -p "(c|return) > " answer_resizecalc
		echo ""

		case "$answer_resizecalc" in

			c|C|check|Check)
				wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".avs
			;;

			*)
			;;
		esac
	fi

	# generate final.avs and test.avs for all resolutions

	# if sarheight0 and sarwidth0 indicate standard resolution, treat as SD
	if [[ $sarheight0 -le 576 && $sarwidth0 -le 720 ]]; then
		echo "no resizing of SD sources"
		echo ""
		echo "encoding in $sarwidth1×$sarheight1 with sar=$sar"
                echo "resulting in $darwidth1×$darheight1"
		getresolutionSDfromSD
		#targetresolutionSDfromSD
		avsSDfromSD
		testavsSD
	else
		echo "for encoding with or without resizing"
		echo "set your target resolutions: (S)D, (7)20p, (1)080p,"
		echo "a subset of them or (a)ll three"
		echo "(it does not cost not anything to choose all)"
		echo ""
		echo "(S|7|1|a)"
		read -e -p "> " answer_resize
		echo ""

		case "$answer_resize" in

			1|10|108|1080|1080p|"")
				targetresolution1080
				avs1080
				testavs1080
			;;

			7|72|720|720p)
				targetresolution720
				avs720
				testavs720
			;;

			s|S|sd|SD)
				targetresolutionSDfromHD
				avsSDfromHD
				testavsSD
			;;

			1S|1s|s1|S1)
				targetresolutionSDfromHD
				avsSDfromHD
				testavsSD
				targetresolution1080
				avs1080
				testavs1080
			;;

			7S|7s|s7|S7)
				targetresolutionSDfromHD
				avsSDfromHD
				testavsSD
				targetresolution720
				avs720
				testavs720
			;;

			17|71)
				targetresolution720
				avs720
				testavs720
				targetresolution1080
				avs1080
				testavs1080
			;;

			a|A|s17|s71|1s7|17s|7s1|71s|S17|S71|1S7|17S|7S1|71S)
				targetresolutionSDfromHD
				targetresolution720
				targetresolution1080
				avsSDfromHD
				testavsSD
				avs720
				testavs720
				avs1080
				testavs1080
		;;
		esac
	fi

	# fillmargins editing the avs files
	if [[ ! $left_fillmargins -eq 0 || ! $top_fillmargins -eq 0 || ! $right_fillmargins -eq 0 || ! $bottom_fillmargins -eq 0 ]]; then
		for i in ${source1%.*}.*.avs ; do
                        sed -i "s|#fillmargins0|LoadPlugin(\"$pathfillmargins\")|" "$i"
			sed -i "s|#fillmargins1|FillMargins($left_fillmargins,$top_fillmargins,$right_fillmargins,$bottom_fillmargins)|" "$i"
		done
#  	else
#  		for i in "${source1%.*}".*.avs ; do
#  			sed -i "/#fillmargins0/d" "$i"
#  			sed -i "/#fillmargins1/d" "$i"
#  		done
 	fi

	# if sarheight0 and sarwidth0 indicate standard resolution, treat as SD
	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		echo ""
		echo "hint:"
		echo "use the corresponding config file"
		echo "start the script like this:"
		echo ""
		echo "./wine.encode.sh ${source2%.*}"
		echo ""
		echo "go on with option 3"
		echo ""
	else
		echo ""
		echo "hint:"
		echo "use the corresponding config file"
		echo "start the script like this:"
		echo ""
		if [[ ! -e "${source1%.*}".SD.final.avs && -e "${source1%.*}".720.final.avs && ! -e "${source1%.*}".1080.final.avs ]]; then
                    echo "./wine.encode.sh ${source2%.*} 720p"
		elif [[ ! -e "${source1%.*}".SD.final.avs && ! -e "${source1%.*}".720.final.avs && -e "${source1%.*}".1080.final.avs ]]; then
                    echo "./wine.encode.sh ${source2%.*} 1080"
		else
                    echo "./wine.encode.sh ${source2%.*} <resolution>"

                    if [[ -e "${source1%.*}".SD.final.avs && -e "${source1%.*}".720.final.avs && -e "${source1%.*}".1080.final.avs ]]; then
                        echo ""
                        echo "where resolution might be SD, 720 or 1080"
                    elif [[ -e "${source1%.*}".SD.final.avs && -e "${source1%.*}".720.final.avs && ! -e "${source1%.*}".1080.final.avs ]]; then
                        echo ""
                        echo "where resolution might be SD or 720"
                    elif [[ -e "${source1%.*}".SD.final.avs && ! -e "${source1%.*}".720.final.avs && -e "${source1%.*}".1080.final.avs ]]; then
                        echo ""
                        echo "where resolution might be SD or 1080"
                    else [[ ! -e "${source1%.*}".SD.final.avs && -e "${source1%.*}".720.final.avs && -e "${source1%.*}".1080.final.avs ]]
                        echo ""
                        echo "where resolution might be 720 or 1080"
                    fi
                fi
                echo ""
                echo "go on with option 3"
		echo ""
	fi
	;;

	3)  # 3 - test encodes for crf

	checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)

	function crf1 {
			# until high>low and crf1low 1-530 and crf1high 1-530 and increment 1-530; do
		until [[ $crf1high -ge $crf1low && $crf1low =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf1high =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf1increment =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ ]]; do
			echo ""
			echo "crf: values from 1 to 53, default is 23"
			echo "test with values around 15 to 19"

			echo "set lowest crf value as hundreds,"
			echo "e.g. 168 for 16.8"
			echo ""
			read -e -p "crf > " crf1low
			echo ""

			echo "set highst crf value as hundreds,"
			echo "e.g. 176 for 17.6"
			echo ""
			read -e -p "crf > " crf1high
			echo ""

			echo "set increment steps, e.g. 1 for 0.1"
			echo "≠0"
			echo ""
			read -e -p "increments > " crf1increment
			echo ""
		done

		# start measuring overall encoding time
		start0=$(date +%s)

		# empty existing crf1-log files
		> "${source1%.*}".$2.crf1.log

		# create comparison screen avs
		echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.crf1.avs

		for (( crf1=$crf1low; $crf1<=$crf1high; crf1+=$crf1increment )); do

                        #name the files in ascending order depending on the number of existing mkv in directory
                        count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                        echo ""
			echo "encoding ${source2%.*}.$2.$count.crf$crf1.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv"
			echo ""

			# start measuring encoding time
			start1=$(date +%s)

			# write list of encodings into avs file
			echo "=ffvideosource(\"${source1%.*}.$2.$count.crf$crf1.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv\").subtitle(\"crf$crf1 encode $2\", align=8)" >> "${source1%.*}".$2.crf1.avs

			# write information to log files, no newline at the end of line
			echo -n "crf $crf1 : " | tee -a "${source1%.*}".$2.crf1.log >/dev/null

			wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
				| x264 --stdin y4m \
				--crf $(printf '%s.%s' "$(($crf1/10))" "$(($crf1%10))") \
				--preset "$preset" \
				--tune "$tune" \
				--profile "$profile" \
				--ref "${ref##*=}" \
				--sar "$sar" \
				--rc-lookahead "$lookahead" \
				--me "$me" \
				--merange "$merange" \
				--subme "$subme" \
				--deblock "$deblock" \
				--no-psy \
				-o "${source1%.*}".$2.$count.crf$crf1.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log|tee "${source1%.*}".$2.crf1-raw.log;

			# write the encodings bit rate into the crf1 specific log file
			egrep 'x264 \[info\]: kb\/s:' "${source1%.*}".$2.crf1-raw.log|cut -d ':' -f3|tail -1 >> "${source1%.*}".$2.crf1.log
			rm "${source1%.*}".$2.crf1-raw.log

			# stop measuring encoding time
			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding "${source1%.*}".$2.$count.crf$crf1.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv lasted $time"
			echo ""
			echo "range crf $crf1low → $crf1high, increment $crf1increment"
		done

			# stop measuring overall encoding time
			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
			echo "test encodings for crf integers in $2 lasted $time"

			#comparison screen
			prefixes=({a..z} {a..z}{a..z})
			i=0
			while IFS= read -r line; do
			printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2crf1.avs
			done < "${source1%.*}".$2.crf1.avs
			echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a,da,a,db,a,dc,a,dd,a,de,a,df,a,dg,a,dh,a,di,a,dj,a,dk,a,dl,a,dm,a,dn,a,do,a,dp,a,dq,a,dr,a,ds,a,dt,a,du,a,dv,a,dw,a,dx,a,dy,a,dz,a,ea,a,eb,a,ec,a,ed,a,ee,a,ef,a,eg,a,eh,a,ei,a,ej,a,ek,a,el,a,em,a,en,a,eo,a,ep,a,eq,a,er,a,es,a,et,a,eu,a,ev,a,ew,a,ex,a,ey,a,ez,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.crf1.avs) *2 -1|bc)-310 >> "${source1%.*}".$2.2crf1.avs
			echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2crf1.avs
			echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2crf1.avs
			mv "${source1%.*}".$2.2crf1.avs "${source1%.*}".$2.crf1.avs

		if [ -e /usr/bin/beep ]; then beep $beep; fi

		echo ""
		echo "look at these encodings. where you find any detail loss"
		echo "in still images, you may have found your crf."
		echo "then close AvsPmod."
		echo "after this round, you may want to go on and"
		echo "find some more precise value."
		sleep 2

		wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.crf1.avs
	}

	while true; do
	echo ""
	echo "choose crf values for"
	echo "your test encodings in $2"
	echo ""
	echo "right now, crf is ${crf##*=}"
	# show bitrate from logfile
	if [[ -e "${source1%.*}".$2.crf1.log ]] ; then
		echo "bit rates:"
		column -c 56 "${source1%.*}".$2.crf1.log
		echo ""
	fi

	echo ""
	echo "hit return to continue"
	echo "else e(x)it"
	echo ""
	read -e -p "(return|x) > " answer_crf1
	echo ""

		case $answer_crf1 in
			x|X) # get out of the loop
				break
			;;

			*)
				unset crf1low
				unset crf1high
				unset crf1increment
				crf1 $1 $2
			;;
		esac
	done

	until [[ $crf =~ ^[0-4][0-9]\.[0-9]|[5][0-2]\.[0-9]|53\.0$ ]] ; do
		echo "set crf parameter for $2"
		echo "e.g. 17.3"
		echo ""
		read -e -p "crf > " crf
		echo ""
	done

	# keep cfg informed
	sed -i "/crf$2/d" "$config"
	echo "crf$2=$crf" >> "$config"

	echo "from here, run the script with"
	echo "option 4"
	echo ""
	;;

	4)  # 4 - test variations in qcomp

        checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)

	function qcomp {
			# until qcomplow 0-100 and qcomphigh 0-100 and high>low and increment 0-100; do
		until [[ $qcomplow =~ ^[0-9]$|^[1-9][0-9]$|^100$ && $qcomphigh =~ ^[0-9]$|^[1-9][0-9]$|^100$ && $qcomphigh -ge $qcomplow && $qcompincrement =~ ^[0-9]$|^[1-9][0-9]$|^100$ ]]; do
			echo "qcomp: values from 0.0 to 1.0, default is 0.60"
			echo "test with values around 0.60 to 0.80"

			echo "first, set lowest qcomp value"
			echo "e.g. 60 for 0.60"
			echo ""
			read -e -p "qcomp, lowest value > " qcomplow
			echo ""

			echo "set maximum qcomp value"
			echo "e.g. 80 for 0.80"
			echo ""
			read -e -p "qcomp, maximum value > " qcomphigh
			echo ""

			echo "set increments, e.g. 5 for 0.05"
			echo "≠0"
			echo ""
			read -e -p "increments > " qcompincrement
			echo ""
		done

		# start measuring overall encoding time
		start0=$(date +%s)

		# empty existing qcomp-log files
		> "${source1%.*}".$2.qcomp.log

		# create comparison screen avs
		echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.qcomp.avs

		for ((qcomp=$qcomplow; $qcomp<=$qcomphigh; qcomp+=$qcompincrement));do

                        # name the files in ascending order depending on the number of existing mkv in directory
                        count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                        echo ""
			echo "encoding ${source2%.*}.$2.$count.crf${crf##*=}.qc$qcomp.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv"
			echo ""

			# start measuring encoding time
			start1=$(date +%s)

			# create comparison screen avs
			echo "=ffvideosource(\"${source1%.*}.$2.$count.crf${crf##*=}.qc$qcomp.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv\").subtitle(\"encode crf${crf##*=} qc$qcomp $2\", align=8)" >> "${source1%.*}".$2.qcomp.avs

			# write information to log files, no newline at the end of line
			echo -n "qcomp $qcomp : " | tee -a "${source1%.*}".$2.qcomp.log >/dev/null

			wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
			| x264 --stdin y4m \
			--crf "${crf##*=}" \
			--preset "$preset" \
			--tune "$tune" \
			--profile "$profile" \
			--ref "${ref##*=}" \
			--sar "$sar" \
			--rc-lookahead "$lookahead" \
			--me "$me" \
			--merange "$merange" \
			--subme "$subme" \
			--aq-mode "$aqmode" \
			--deblock "$deblock" \
			--no-psy \
			--qcomp $(echo "scale=2;$qcomp/100"|bc) \
			-o "${source1%.*}".$2.$count.crf${crf##*=}.qc$qcomp.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log|tee "${source1%.*}".$2.qcomp-raw.log;

			# write the encodings bit rate into the qcomp specific log file
			egrep 'x264 \[info\]: kb\/s:' "${source1%.*}".$2.qcomp-raw.log|cut -d ':' -f3|tail -1 >> "${source1%.*}".$2.qcomp.log
			rm "${source1%.*}".$2.qcomp-raw.log

			# stop measuring encoding time
			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${source2%.*}.$2.$count.crf${crf##*=}.qc$qcomp.aq${aq##*=}.pr${psyrd##*=}.pt${psytr##*=}.mkv lasted $time"
			echo ""
			echo "range qcomp $qcomplow → $qcomphigh; increment $qcompincrement"
		done

		# stop measuring overall encoding time
		stop=$(date +%s);
		days=$(( ($stop-$start0)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
		echo "test encodings for qcomp in $2 lasted $days days and $time"

		#comparison screen
		prefixes=({a..z} {a..z}{a..z})
		i=0
		while IFS= read -r line; do
		printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2qcomp.avs
		done < "${source1%.*}".$2.qcomp.avs
		echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a,da,a,db,a,dc,a,dd,a,de,a,df,a,dg,a,dh,a,di,a,dj,a,dk,a,dl,a,dm,a,dn,a,do,a,dp,a,dq,a,dr,a,ds,a,dt,a,du,a,dv,a,dw,a,dx,a,dy,a,dz,a,ea,a,eb,a,ec,a,ed,a,ee,a,ef,a,eg,a,eh,a,ei,a,ej,a,ek,a,el,a,em,a,en,a,eo,a,ep,a,eq,a,er,a,es,a,et,a,eu,a,ev,a,ew,a,ex,a,ey,a,ez,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.qcomp.avs) *2 -1|bc)-310 >> "${source1%.*}".$2.2qcomp.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2qcomp.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2qcomp.avs
		mv "${source1%.*}".$2.2qcomp.avs "${source1%.*}".$2.qcomp.avs

		if [ -e /usr/bin/beep ]; then beep $beep; fi

		echo ""
		echo "thoroughly look through all your test"
		echo "encodings and decide, which qcomp gave"
		echo "best results."
		echo "then close AvsPmod."
		sleep 2

		wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.qcomp.avs
	}

	while true; do
		echo ""
		echo "choose qcomp values for"
		echo "your test encodings in $2"
		echo ""
		echo "right now, qcomp is ${qcomp##*=}"


		echo ""
		echo "hit return to continue"
		echo "else e(x)it"
		echo ""
		read -e -p "(return|x) > " answer_qcomp

			case $answer_qcomp in
				x|X) # get out of the loop
					break
				;;

				*)
					unset qcomplow
					unset qcomphigh
					unset qcompincrement
					qcomp $1 $2
				;;
			esac
	done

	until [[ $qcomp =~ ^0\.[0-9][0-9]$|^1\.0$ ]] ; do
		echo ""
		echo "set qcomp parameter for $2"
		echo "e.g. 0.71"
		echo ""
		read -e -p "qcomp > " qcomp
		echo ""
	done

	# keep cfg informed
	sed -i "/qcomp$2/d" "$config"
	echo "qcomp$2=$qcomp" >> "$config"

	# show bitrate from logfile
	echo "bitrates:"
	column -c 56 "${source1%.*}".$2.qcomp.log
	echo ""
	echo "choose, at which bitrate to test"
	echo "for aq strength and psy-rd"
	echo "e.g. 2850"
	echo ""
	read -e -p "bitrate in kb/s > " br_aqpsy
	echo ""

	# keep cfg informed
	sed -i "/br_aqpsy$2/d" "$config"
	echo "br_aqpsy$2=$br_aqpsy" >> "$config"

	echo "from here, run the script with"
	echo "option 5"
	echo ""
	;;

	5)  # 5 - variations in aq strength and psy-rd

	checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)
	br_aqpsy=$(cat "$config"|grep br_aqpsy|grep $2)

	function aqpsy {
		echo ""
		echo "encoding with 2pass, given bitrate is ${br_aqpsy##*=}"
		echo ""
		echo "hit return if ok"
		echo "or (e)dit"
		read -e -p "(return|e) > " answer_br_aqpsy

			case $answer_br_aqpsy in

				e|E|edit|EDIT|Edit)
					echo ""
					echo "set bitrate for aq strength and psy-rd"
					echo ""
					read -e -p "bitrate for $2 > " br_aqpsy
					# keep cfg informed
					sed -i "/br_aqpsy$2/d" "$config"
					echo "br_aqpsy$2=$br_aqpsy" >> "$config"
					br_aqpsy="$br_aqpsy"
					;;

					*)	# do nothing here
					;;
			esac

			# DIRTY! what range aq strength? all parameters 1-200
		until [[ $aqhigh -ge $aqlow && $aqlow =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ && $aqhigh =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ && $aqincrement =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ ]]; do
			echo ""
			echo "aq strength: default is 1.0"
			echo "film ~1.0, animation ~0.6, grain ~0.5"
			echo ""
			echo "set lowest value of aq strength, e.g. 50 for 0.5"
			echo ""
			read -e -p "aq strength, lowest value > " aqlow

			echo ""
			echo "set maximum value of aq strength, e.g. 100 for 1.0"
			echo ""
			read -e -p "aq strength, maximum value > " aqhigh

			echo ""
			echo "set increment steps, e.g. 5 for 0.05 or 10 for 0.10"
			echo "≠0"
			echo ""
			read -e -p "increments > " aqincrement
		done

			# DIRTY! what range for psy-rdo? all parameters 1-200
		until [[ $psy1high -ge $psy1low && $psy1low =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ && $psy1high =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ && $psy1increment =~ ^[1-9]$|^[1-9][0-9]$|^1[0-9][0-9]$|^200$ ]]; do
			echo ""
			echo "psy-rd: default is 1.0"
			echo "test with values around 0.9 to 1.2"
			echo ""
			echo "set lowest value of psy-rd, e.g. 90 for 0.9"
			echo ""
			read -e -p "psy-rd, lowest value > " psy1low

			echo ""
			echo "maximum value of psy-rd, e.g. 120 for 1.2"
			echo ""
			read -e -p "psy-rd, maximum value > " psy1high

			echo ""
			echo "increment steps for psy-rd values"
			echo "e.g. 5 for 0.05 or 10 for 0.1"
			echo "≠0"
			echo ""
			read -e -p "increments > " psy1increment
		done

		# number of test encodings
		number_encodings=`echo "(((($aqhigh-$aqlow)/$aqincrement)+1)*((($psy1high-$psy1low)/$psy1increment)+1))"|bc`

		echo ""
		echo "these settings will result"
		echo "in $number_encodings encodings and will take some time…"
		echo ""

		# start measuring overall encoding time
		start0=$(date +%s)

		# empty existing aqs-psyrd-log files
		> "${source1%.*}".$2.aqpsy.log

		# create comparison screen avs
		echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.aqpsy.avs

		for ((aq=$aqlow; $aq<=$aqhigh; aq+=$aqincrement));do
			for ((psy1=$psy1low; $psy1<=$psy1high; psy1+=$psy1increment));do

                                # name the files in ascending order depending on the number of existing mkv in directory
                                count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                                echo ""
				echo "encoding ${source2%.*}.$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.mkv"
				echo ""

				# start measuring encoding time
				start1=$(date +%s)

				#comparison screen
				echo "=ffvideosource(\"${source1%.*}.$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.mkv\").subtitle(\"encode bitrate${br_aqpsy##*=} qc${qcomp##*=} aq$aq psy$psy1 $2\", align=8)" >> "${source1%.*}".$2.aqpsy.avs

				# write information to log files, no newline at the end of line
				echo -n "aqs $aq psy $psy1 : " | tee -a "${source1%.*}".$2.aqpsy.log >/dev/null

				wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
				| x264 --stdin y4m \
				--bitrate "${br_aqpsy##*=}" \
				--pass 1 \
				--stats "${source1%.*}.$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.stats" \
				--qcomp "${qcomp##*=}" \
				--preset "$preset" \
				--tune "$tune" \
				--profile "$profile" \
				--ref "${ref##*=}" \
				--sar "$sar" \
				--rc-lookahead "$lookahead" \
				--me "$me" \
				--merange "$merange" \
				--subme "$subme" \
				--aq-mode "$aqmode" \
				--deblock "$deblock" \
				--aq-strength $(echo "scale=2;$aq/100"|bc) \
				--psy-rd $(echo "scale=2;$psy1/100"|bc):unset \
				-o /dev/null - 2>&1|tee -a "${source1%.*}".$2.log;

				wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
				| x264 --stdin y4m \
				--bitrate "${br_aqpsy##*=}" \
				--pass 2 \
				--stats "${source1%.*}.$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.stats" \
				--qcomp "${qcomp##*=}" \
				--preset "$preset" \
				--tune "$tune" \
				--profile "$profile" \
				--ref "${ref##*=}" \
				--sar "$sar" \
				--rc-lookahead "$lookahead" \
				--me "$me" \
				--merange "$merange" \
				--subme "$subme" \
				--aq-mode "$aqmode" \
				--deblock "$deblock" \
				--aq-strength $(echo "scale=2;$aq/100"|bc) \
				--psy-rd $(echo "scale=2;$psy1/100"|bc):unset \
				-o "${source1%.*}".$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.mkv - 2>&1|tee -a "${source1%.*}".$2.log|tee "${source1%.*}".$2.aqpsy-raw.log;

				# write the encodings bit rate into the qcomp specific log file
				egrep 'x264 \[info\]: kb\/s:' "${source1%.*}".$2.aqpsy-raw.log|cut -d ':' -f3|tail -1 >> "${source1%.*}".$2.aqpsy.log
				rm "${source1%.*}".$2.aqpsy-raw.log

				# remove the used stats file
				rm "${source1%.*}.$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.stats"
				rm "${source1%.*}.$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.stats.mbtree"

				# stop measuring encoding time
				stop=$(date +%s);
				time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
				echo "encoding ${source2%.*}.$2.$count.bit${br_aqpsy##*=}.qc${qcomp##*=}.aq$aq.psy$psy1.pt${psytr##*=}.mkv lasted $time"
				echo ""
				echo "range aq strength $aqlow → $aqhigh; increment $aqincrement"
				echo "range psy-rd      $psy1low → $psy1high; increment $psy1increment"
			done
		done

		# stop measuring overall encoding time
		stop=$(date +%s);
		days=$(( ($stop-$start0)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
		echo "test encodings for aq strength and psy-rd lasted $days days and $time"

		#comparison screen
		prefixes=({a..z} {a..z}{a..z})
		i=0
		while IFS= read -r line; do
		printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2aqpsy.avs
		done < "${source1%.*}".$2.aqpsy.avs
		echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a,da,a,db,a,dc,a,dd,a,de,a,df,a,dg,a,dh,a,di,a,dj,a,dk,a,dl,a,dm,a,dn,a,do,a,dp,a,dq,a,dr,a,ds,a,dt,a,du,a,dv,a,dw,a,dx,a,dy,a,dz,a,ea,a,eb,a,ec,a,ed,a,ee,a,ef,a,eg,a,eh,a,ei,a,ej,a,ek,a,el,a,em,a,en,a,eo,a,ep,a,eq,a,er,a,es,a,et,a,eu,a,ev,a,ew,a,ex,a,ey,a,ez,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.aqpsy.avs) *2 -1|bc)-310 >> "${source1%.*}".$2.2aqpsy.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2aqpsy.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2aqpsy.avs
		mv "${source1%.*}".$2.2aqpsy.avs "${source1%.*}".$2.aqpsy.avs

		if [ -e /usr/bin/beep ]; then beep $beep; fi

		echo ""
		echo "thoroughly look through all your test encodings"
		echo "and decide, which aq strength and which psy-rd"
		echo "parameters gave best results."
		echo "then close AvsPmod."
		sleep 2

		wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.aqpsy.avs
        }

	while true; do
		echo ""
		echo "choose aq strength and psyrd values for"
		echo "your test encodings in $2"
		echo ""
		echo "right now, aq strength is ${aqs##*=}"
		echo "and psyrd is ${psyrd##*=}"
		echo ""

		echo "hit return to continue"
		echo "else e(x)it"
		echo ""
		read -e -p "(return|x) > " answer_aqpsy

			case $answer_aqpsy in
				x|X) # just nothing
					break
				;;

				*)
					unset aqhigh
					unset aqlow
					unset aqincrement
					unset psy1high
					unset psy1low
					unset psy1increment
					aqpsy $1 $2
				;;
			esac
	done

	# show bitrates from logfile
	echo ""
	echo "bitrates in kb/s:"
	column -c 56 "${source1%.*}".$2.aqpsy.log

	echo ""
	echo "set aq strength for $2"
	echo "e.g. 0.85"
	echo ""
	until [[ $aqs =~ ^[0-2]\.[0-9]+$ ]] ; do
		read -e -p "aq strength > " aqs
		echo ""
	done

	# keep cfg informed
	sed -i "/aqs$2/d" "$config"
	echo "aqs$2=$aqs" >> "$config"

	echo "set psy-rd for $2"
	echo "e.g. 0.9"
	echo ""
	until [[ $psyrd =~ ^[0-2]\.[0-9]+$ ]] ; do
		read -e -p "psy-rd > " psyrd
		echo ""
	done

	# keep cfg informed
	sed -i "/psyrd$2/d" "$config"
	echo "psyrd$2=$psyrd" >> "$config"

	case $(echo "$psyrd" - 0.99999 | bc) in

		-*) # psy-rd <1 -> psytr unset
		echo "as psy-rd is set to a value <1 (or not at all)"
		echo "psy-trellis is 'unset' automatically"
		echo ""
		echo "you might do further testing with"
		echo "option 7 (some more less common tests) or"
		echo "go on with option 8 (a last round for crf)"
		echo ""
                # keep cfg informed
                sed -i "/psytr$2/d" "$config"
                echo "psytr$2=unset" >> "$config"
		;;

		*) # psyrd >= 1
		echo "you might test for psy-trellis"
		echo "with option 6,"
		echo "do further testing with option 7"
		echo "(some more less common tests) or"
		echo "go on with option 8 (a last round for crf)"
		echo ""
		;;
	esac
	;;

	6)  # 6 - variations in psy-trellis

	checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	case $(echo "${psyrd##*=}" - 0.99999 | bc) in

		-*) # psy-rd <1 -> psytr unset
		echo ""
		echo "as psy-rd is set to a value < 1 (or "
		echo "not at all) (${psyrd##*=})"
		echo "psy-trellis is 'unset' automatically"
		echo ""

		# keep cfg informed
		sed -i "/psytr$2/d" "$config"
		echo "psytr$2=unset" >> "$config"
		;;

		*) # psyrd >= 1
		echo ""
		echo "as psy-rd is set to ≥1 (${psyrd##*=})"
		echo "you may (t)est for psy-trellis"
		echo "else, return"
		echo ""
		read -e -p "(return|t) > " answer_psytr

			case $answer_psytr in

			t|T) # test for psy-trellis

					#until psy2low 1-99 and psy2high 1-199 and psy2increment 1-99; do
				until [[  $psy2high -ge $psy2low && $psy2low =~ ^[0-9]$|^[1-9][0-9]$ && $psy2high =~ ^[0-9]$|^[1-9][0-9]$|^1[0-9][0-9]$ && $psy2increment =~ ^[1-9]$|^[1-9][0-9]$ ]]; do
					echo "psy-trellis: default is 0.0"
					echo "test for values ~0.0 to 0.15"
					echo "set lowest value for psy-trellis, e.g. 10 for 0.1"
					echo ""
					read -e -p "psy-trellis, lowest value > " psy2low
					echo ""

					echo "set maximum value for psy-trellis, e.g. 20 for 0.2"
					echo ""
					read -e -p "psy-trellis, maximum value > " psy2high
					echo ""

					echo "set increment steps, e.g. 5 for 0.05"
					echo ""
					read -e -p "increments > " psy2increment
					echo ""
				done

			start0=$(date +%s)

			# create comparison screen avs
			echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.psytr.avs

			for ((psy2=$psy2low; $psy2<=$psy2high; psy2+=$psy2increment));do

                                # name the files in ascending order depending on the number of existing mkv in directory
                                count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                                echo ""
				echo "encoding ${source2%.*}.$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt$psy2.mkv"
				echo ""

				start1=$(date +%s)

				#comparison screen
				echo "=ffvideosource(\"${source1%.*}.$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt$psy2.mkv\").subtitle(\"encode crf${crf##*=} qc${qcomp##*=} aq${aqs##*=} pr${psyrd##*=} pt$psy2 $2\", align=8)" >> "${source1%.*}".$2.psytr.avs

				wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
				| x264 --stdin y4m \
				--crf "${crf##*=}" \
				--qcomp "${qcomp##*=}" \
				--aq-strength "${aqs##*=}" \
				--preset "$preset" \
				--tune "$tune" \
				--profile "$profile" \
				--ref "${ref##*=}" \
				--sar "$sar" \
				--rc-lookahead "$lookahead" \
				--me "$me" \
				--merange "$merange" \
				--subme "$subme" \
				--aq-mode "$aqmode" \
				--deblock "$deblock" \
				--psy-rd "${psyrd##*=}":$(echo "scale=2;$psy2/100"|bc) \
				-o "${source1%.*}".$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt$psy2.mkv -;

				stop=$(date +%s);
				time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
				echo "encoding ${source2%.*}.$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt$psy2.mkv lasted $time"
				echo ""
				echo "range psy-trellis $psy2low → $psy2high; increment $psy2increment"

			done

			stop=$(date +%s);
			days=$(( ($stop-$start0)/86400 ))
			time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
			echo "test encodings for psy-trellis lasted $days days and $time"

			#comparison screen
			prefixes=({a..z} {a..z}{a..z})
			i=0
			while IFS= read -r line; do
			printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2psytr.avs
			done < "${source1%.*}".$2.psytr.avs
			echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a,da,a,db,a,dc,a,dd,a,de,a,df,a,dg,a,dh,a,di,a,dj,a,dk,a,dl,a,dm,a,dn,a,do,a,dp,a,dq,a,dr,a,ds,a,dt,a,du,a,dv,a,dw,a,dx,a,dy,a,dz,a,ea,a,eb,a,ec,a,ed,a,ee,a,ef,a,eg,a,eh,a,ei,a,ej,a,ek,a,el,a,em,a,en,a,eo,a,ep,a,eq,a,er,a,es,a,et,a,eu,a,ev,a,ew,a,ex,a,ey,a,ez,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.psytr.avs) *2 -1|bc)-310 >> "${source1%.*}".$2.2psytr.avs
			echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2psytr.avs
			echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2psytr.avs
			mv "${source1%.*}".$2.2psytr.avs "${source1%.*}".$2.psytr.avs

			if [ -e /usr/bin/beep ]; then beep $beep; fi

			echo ""
			echo "thoroughly look through this last test encodings and"
			echo "decide, which one is your best encode."
			echo "then close AvsPmod."
			sleep 2
			wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.psytr.avs

			echo ""
			echo "set psy-trellis"
			echo "e.g. 0.05"
			echo ""
			until [[ $psytr =~ ^0$|^[0-1]\.[0-9]$|^[0-1]\.[0-9][0-9]$|^2\.00$  ]] ; do
				read -e -p "psy-trellis > " psytr
				echo ""
			done

			# keep cfg informed
			sed -i "/psytr$2/d" "$config"
			echo "psytr$2=$psytr" >> "$config"
			;;

			*) # unset psy-trellis

			echo "psy trellis is 'unset'."
			echo ""

			# keep cfg informed
			sed -i "/psytr$2/d" "$config"
			echo "psytr$2=unset" >> "$config"
			echo ""
			;;
			esac
		;;
	esac

	echo "do some testing for e.g. chroma-qp-offset"
	echo "(option 7) or"
	echo "try another (maybe last) round for optimal crf"
	echo "(option 8)"
	echo ""
	;;

	7)  # 7 - some more testing with different parameters

	checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	echo "what do you want to test?"
	echo ""
	echo "(c)hroma-qp-offset"
	echo "(d)ebanding with f3kdbt"
	echo "(n)othing right now"
		read -e -p "(c|d|n) > " answer_various
		until [[ $answer_various =~ ^[c,C,d,D,n,N]$ ]] ; do
                    case $answer_various in

				c|C)	# chroma-qp-offset
						# until cqpohigh -12 to 12 and cqpolow -12 to 12 and cqpohigh greater or equal cqpolow; do
					until [[ $cqpohigh =~ ^-{0,1}[0-9]$|^-{0,1}1[0-2]$ && $cqpolow =~ ^-{0,1}[0-9]$|^-{0,1}1[0-2]$ && $cqpohigh -ge $cqpolow ]]; do
						echo ""
						echo "test for chroma-qp-offset: default 0,"
						echo "range -12 to 12; sensible ranges -3 to 3"
						echo "set lowest value for chroma-qp-offset, e.g. -2"
						echo "take care: -6 is lower than -4 :-)"
						echo ""
						read -e -p "chroma-qp-offset, lowest value > " cqpolow

						echo ""
						echo "set maximum value for chroma-qp-offset, e.g. 2"
						echo ""
						read -e -p "chroma-qp-offset, maximum value > " cqpohigh
					done
					start0=$(date +%s)

					# create comparison screen avs
					echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.cqpo.avs

					for ((cqpo=$cqpolow; $cqpo<=$cqpohigh; cqpo=$cqpo+1));do

                                                # name the files in ascending order depending on the number of existing mkv in directory
                                                count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                                                echo ""
						echo "encoding ${source2%.*}.$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo$cqpo.mkv"
						echo ""

						start1=$(date +%s)

                                                #comparison screen
						echo "=ffvideosource(\"${source1%.*}.$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo$cqpo.mkv\").subtitle(\"encode crf${crf##*=} qc${qcomp##*=} aq${aqs##*=} pr${psyrd##*=} pt${psytr##*=} cqpo$cqpo $2\", align=8)" >> "${source1%.*}".$2.cqpo.avs

						wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
						| x264 --stdin y4m \
						--crf "${crf##*=}" \
						--qcomp "${qcomp##*=}" \
						--aq-strength "${aqs##*=}" \
						--preset "$preset" \
						--tune "$tune" \
						--profile "$profile" \
						--ref "${ref##*=}" \
						--sar "$sar" \
						--rc-lookahead "$lookahead" \
						--me "$me" \
						--merange "$merange" \
						--subme "$subme" \
						--aq-mode "$aqmode" \
						--deblock "$deblock" \
						--psy-rd "${psyrd##*=}":"${psytr##*=}" \
						--chroma-qp-offset "$cqpo" \
						-o "${source1%.*}".$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo$cqpo.mkv -;

						stop=$(date +%s);
						time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
						echo "encoding ${source1%.*}.$2.$count.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo$cqpo.mkv lasted $time"
						echo ""
						echo "range chroma-qp-offset $cqpolow → $cqpohigh"

					done

					stop=$(date +%s);
					days=$(( ($stop-$start0)/86400 ))
					time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
					echo "test encodings for chroma-qp-offset lasted $days days and $time"
					#comparison screen
					prefixes=({a..z} {a..z}{a..z})
					i=0
					while IFS= read -r line; do
					printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2cqpo.avs
					done < "${source1%.*}".$2.cqpo.avs
					echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a,da,a,db,a,dc,a,dd,a,de,a,df,a,dg,a,dh,a,di,a,dj,a,dk,a,dl,a,dm,a,dn,a,do,a,dp,a,dq,a,dr,a,ds,a,dt,a,du,a,dv,a,dw,a,dx,a,dy,a,dz,a,ea,a,eb,a,ec,a,ed,a,ee,a,ef,a,eg,a,eh,a,ei,a,ej,a,ek,a,el,a,em,a,en,a,eo,a,ep,a,eq,a,er,a,es,a,et,a,eu,a,ev,a,ew,a,ex,a,ey,a,ez,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.cqpo.avs) *2 -1|bc)-310 >> "${source1%.*}".$2.2cqpo.avs
					echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2cqpo.avs
					echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2cqpo.avs
					mv "${source1%.*}".$2.2cqpo.avs "${source1%.*}".$2.cqpo.avs

					if [ -e /usr/bin/beep ]; then beep $beep; fi

					echo ""
					echo "thoroughly look through this last test encodings and"
					echo "decide, which one is your best encode."
					echo "then close AvsPmod."
					sleep 2
					wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.cqpo.avs

					echo ""
					echo "set chroma-qp-offset"
					echo "e.g. 1"
					echo ""
					read -e -p "chroma-qp-offset > " cqpo
					echo ""

					# keep cfg informed
					sed -i "/cqpo$2/d" "$config"
					echo "cqpo$2=$cqpo" >> "$config"
				;;

				d|D)	# debanding with flash3kyuu_deband
                                        # yet to be done
				;;

				n|N)	# nothing

				;;
			esac
		done

	echo "go on with option 8 and test"
	echo "for a good value in crf"
	echo ""

	;;

	8)  # 8 - another round of crf

	checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	function crf2 {
		until [[ $crf2high -ge $crf2low && $crf2low =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf2high =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ && $crf2increment =~ ^[1-9]$|^[1-9][0-9]$|[1-4][0-9][0-9]$|5[0-2][0-9]$|^530$ ]]; do
			echo "once again, try a range of crf increments"
			echo "set lowest crf value as hundreds,"
			echo "e.g. 168 for 16.8"
			echo ""
			read -e -p "crf, lowest value > " crf2low
			echo ""

			echo "set highst crf value as hundreds,"
			echo "e.g. 172 for 17.2"
			echo ""
			read -e -p "crf, maximum value > " crf2high
			echo ""

			echo "set increment steps, e.g. 1 for 0.1"
			echo "≠0"
			echo ""
			read -e -p "increments > " crf2increment
			echo ""
		done

		start0=$(date +%s)

                # empty existing crf1-log files
		> "${source1%.*}".$2.crf2.log

		# create comparison screen avs
		echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.crf2.avs

		for ((crf2=$crf2low; $crf2<=$crf2high; crf2+=$crf2increment));do

                        # name the files in ascending order depending on the number of existing mkv in directory
                        count=$( printf '%03d\n'  $(ls ${source1%/*}|grep "$2"| grep -c .mkv$))

                        echo ""
			echo "encoding ${source2%.*}.$2.$count.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo${cqpo##*=}.crf$crf2.mkv"
			echo ""

                        # start measuring encoding time
			start1=$(date +%s)

                        #comparison screen
			echo "=ffvideosource(\"${source2%.*}.$2.$count.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo${cqpo##*=}.crf$crf2.mkv\").subtitle(\"encode qc${qcomp##*=} aq${aqs##*=} pr${psyrd##*=} pt${psytr##*=} cqpo${cqpo##*=} crf$crf2 $2\", align=8)" >> "${source1%.*}".$2.crf2.avs

			# write information to log files, no newline at the end of line
			echo -n "crf $crf2 : " | tee -a "${source1%.*}".$2.crf2.log >/dev/null

			wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
			| x264 --stdin y4m \
			--qcomp "${qcomp##*=}" \
			--aq-strength "${aqs##*=}" \
			--psy-rd "${psyrd##*=}":"${psytr##*=}" \
			--preset "$preset" \
			--tune "$tune" \
			--profile "$profile" \
			--sar "$sar" \
			--ref "${ref##*=}" \
			--rc-lookahead "$lookahead" \
			--me "$me" \
			--merange "$merange" \
			--subme "$subme" \
			--deblock "$deblock" \
			--chroma-qp-offset "${cqpo##*=}" \
			--crf $(echo "scale=1;$crf2/10"|bc) \
			-o "${source1%.*}".$2.$count.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo${cqpo##*=}.crf$crf2.mkv - 2>&1|tee -a "${source1%.*}".$2.log|tee "${source1%.*}".$2.crf2-raw.log;

			# write the encodings bit rate into the crf1 specific log file
			egrep 'x264 \[info\]: kb\/s:' "${source1%.*}".$2.crf2-raw.log|cut -d ':' -f3|tail -1 >> "${source1%.*}".$2.crf2.log
			rm "${source1%.*}".$2.crf2-raw.log

			# stop measuring encoding time
			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${source2%.*}.$2.$count.qc${qcomp##*=}.aq${aqs##*=}.pr${psyrd##*=}.pt${psytr##*=}.cqpo${cqpo##*=}.crf$crf2.mkv lasted $time"
			echo ""
			echo "range crf $crf2low → $crf2high; increment $crf2increment"

		done

		stop=$(date +%s);
		days=$(( ($stop-$start0)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
		echo "test encodings for a second round of crf lasted $days days and $time"

		#comparison screen
		prefixes=({a..z} {a..z}{a..z})
		i=0
		while IFS= read -r line; do
		printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2crf2.avs
		done < "${source1%.*}".$2.crf2.avs
		echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a,da,a,db,a,dc,a,dd,a,de,a,df,a,dg,a,dh,a,di,a,dj,a,dk,a,dl,a,dm,a,dn,a,do,a,dp,a,dq,a,dr,a,ds,a,dt,a,du,a,dv,a,dw,a,dx,a,dy,a,dz,a,ea,a,eb,a,ec,a,ed,a,ee,a,ef,a,eg,a,eh,a,ei,a,ej,a,ek,a,el,a,em,a,en,a,eo,a,ep,a,eq,a,er,a,es,a,et,a,eu,a,ev,a,ew,a,ex,a,ey,a,ez,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.crf2.avs) *2 -1|bc)-310 >> "${source1%.*}".$2.2crf2.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2crf2.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2crf2.avs
		mv "${source1%.*}".$2.2crf2.avs "${source1%.*}".$2.crf2.avs

		if [ -e /usr/bin/beep ]; then beep $beep; fi

		echo ""
		echo "thoroughly look through all your test"
		echo "encodings and decide, with which crf you"
		echo "get best results at considerable bitrate."
		echo "then close AvsPmod."
		sleep 2
		wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.crf2.avs
	}

	while true; do
                echo ""
		echo "after all that optimization, you may test for"
		echo "a new, probably more bitsaving value of crf"
		echo ""
		echo "so far you tested with a crf of ${crf##*=}"
		echo ""
                echo "choose crf values for"
                echo "your test encodings in $2"
	# show bitrate from logfile
	if [[ -e "${source1%.*}".$2.crf2.log ]] ; then
		echo "bit rates:"
		column -c 56 "${source1%.*}".$2.crf2.log
		echo ""
	fi

	echo ""
	echo "hit return to continue"
	echo "else e(x)it"
	echo ""
	read -e -p "(return|x) > " answer_crf2
	echo ""

		case $answer_crf2 in
			x|X) # just nothing
				break
			;;

			*)
				unset crf2low
				unset crf2high
				unset crf2increment
				crf2 $1 $2
			;;
		esac
	done

	until [[ $crf =~ ^[0-4][0-9]\.[0-9]|[5][0-2]\.[0-9]|53\.0$ ]] ; do
            echo ""
            echo "set crf parameter"
            echo "so far you tested with a crf of ${crf##*=}"
            echo ""
            read -e -p "crf > " crf
            echo ""
        done

	# keep cfg informed
	sed -i "/crf$2/d" "$config"
	echo "crf$2=$crf" >> "$config"

	echo "now you may encode the whole movie"
	echo "run the script like this:"
	echo ""

	# if sarheight0 and sarwidth0 indicate standard resolution, treat as SD
	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		echo "./wine.encode.sh ${source2%.*}"
	else
		echo "./wine.encode.sh ${source2%.*} <resolution>"
		echo ""
		echo "where resolution might be SD, 720 or 1080"
	fi

	echo ""
	echo "option 9"
	echo ""
	;;

	9)  # 9 - encode the whole movie

	checks0

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo "test encodings in SD"
	fi

	avs=$(cat "$config"|grep finalavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)

        ref=$(cat "$config"|grep ref|grep $2)
        width=$(cat "$config"|grep width|grep $2)
        height=$(cat "$config"|grep height|grep $2)
        br_final=$(cat "$config"|grep br_final|grep $2)

        function ratecontrol {
		echo ""
		echo "do you want to do the final encode"
		echo "with (c)rf or (2)pass?"
                echo ""
		read -e -p "(c|2) > " answer_c2_ratecontrol
		echo ""

		case "$answer_c2_ratecontrol" in

			2)
			# keep cfg informed
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=2" >> "$config"

                        echo ""
                        echo "choose final bitrate for $2"
                        echo "e.g. 4500"
                        echo ""
                        read -e -p "bitrate in kb/s > " br_final
                        echo ""

                        # keep cfg informed
                        sed -i "/br_final$2/d" "$config"
                        echo "br_final$2=$br_final" >> "$config"

                        br_final="$br_final"
                        ;;

			*)
			# keep cfg informed
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=c" >> "$config"
			;;
		esac
	}

	if [[  ${ratecontrol##*=} == c || ${ratecontrol##*=} == 2 ]]; then
                echo ""
                if [[  ${ratecontrol##*=} == c ]] ; then
                    echo "right now, rate control is set to crf"
		fi
		if [[  ${ratecontrol##*=} == 2 ]] ; then
                    echo "right now, rate control is set to 2pass"
		fi
		echo ""
		echo "do you want to (c)hange this?"
		echo "else, return"
		echo ""
		read -e -p "(return|c) > " answer_ratecontrol
		echo ""

		case $answer_ratecontrol in

			c|C|change|Change)
			ratecontrol $1 $2
                        # re-set ratecontrol, as changes in config are not read during script running
                        ratecontrol="$ratecontrol"
			;;

			*)
			# do nothing here
			;;
		esac
	else
		ratecontrol $1 $2
                # re-set ratecontrol, as changes in config are not read during script running
		ratecontrol="$ratecontrol"
	fi

	function encodeSD2pass {
		echo ""
		echo "now encoding ${source2%.*}.$2.mkv"
		echo "with a resolution of $sarheight1×$sarheight and a sar of $sar"
		echo ""

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.$2.avs
		echo "b=ffvideosource(\"${source1%.*}.$2.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.$2.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.$2.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".comparison.$2.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.$2.avs

		# 1. pass
		wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 1 \
		--bitrate "${br_final##*=}" \
		--sar "$sar" \
		--stats "${source1%.*}$2.stats" \
		--ref "${ref##*=}" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}": \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o /dev/null -;

		# 2. pass
		wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 3 \
		--bitrate "${br_final##*=}" \
		--stats "${source1%.*}$2.stats" \
		--sar "$sar" \
		--ref "${ref##*=}" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}": \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".$2.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.mkv"
		echo "with $sarwidth1×$sarheight1 and a sar of $sar lasted $days days and $time"
	}

	function encodeHD2pass {
		echo ""
		echo "now encoding ${source2%.*}.$2.mkv"
		echo "with a resolution of ${width##*=}×${height##*=}"
		echo ""

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("${width##*=}","${height##*=}").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.$2.avs
		echo "b=ffvideosource(\"${source1%.*}.$2.mkv\").subtitle(\"encode $2\", align=8)" >> "${source1%.*}".comparison.$2.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.$2.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".comparison.$2.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.$2.avs

		# 1. pass
		wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 1 \
		--bitrate "${br_final##*=}" \
		--sar "$sar" \
		--stats "${source1%.*}$2.stats" \
		--ref "${ref##*=}" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o /dev/null -;

		# 2. pass
		wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 3 \
		--bitrate "${br_final##*=}" \
		--stats "${source1%.*}$2.stats" \
		--sar "$sar" \
		--ref "${ref##*=}" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".$2.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.mkv"
		echo "with ${width##*=}×${height##*=} lasted $days days and $time"
	}

	function encodeSD {
		echo ""
		echo "now encoding ${source2%.*}.$2.mkv"
		echo "with a resolution of $sarwidth1×$sarheight1 and a sar of $sar…"
		echo ""

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.$2.avs
		echo "b=ffvideosource(\"${source1%.*}.$2.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.$2.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.$2.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".comparison.$2.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.$2.avs

		wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--crf "${crf##*=}" \
		--sar "$sar" \
		--ref "${ref##*=}" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".$2.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.mkv"
		echo "with a resolution of $sarwidth1×$sarheight1 and a sar of $sar lasted $days days $time"
	}

	function encodeHD {
		echo ""
		echo "now encoding ${source2%.*}.$2.mkv"
		echo "with a resolution of ${width##*=}×${height##*=}…"
		echo ""

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("${width##*=}","${height##*=}").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.$2.avs
		echo "b=ffvideosource(\"${source1%.*}.$2.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.$2.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.$2.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".comparison.$2.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.$2.avs

		wine "$winedir"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--crf "${crf##*=}" \
		--sar "$sar" \
		--ref "${ref##*=}" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".$2.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.mkv"
		echo "with ${width##*=}×${height##*=} lasted $days days and $time"
	}

	function comparison {
		echo "take some comparison screen shots"
		echo "then close AvsPmod"
		sleep 1
		wine "$winedir"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".comparison.$2.avs
	}

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		if [[ ${ratecontrol##*=} =~ c ]]; then
			encodeSD $1 $2
		elif [[ $ratecontrol =~ 2 ]]; then
			encodeSD2pass $1 $2
		fi
		if [ -e /usr/bin/beep ]; then beep $beep; fi
		comparison $1 $2
	fi

	if [[ $sarheight0 -gt 576 ]] && [[ $sarwidth0 -gt 720 ]]; then
		if [[ $ratecontrol =~ c ]]; then
			encodeHD $1 $2
		elif [[ $ratecontrol =~ 2 ]]; then
			encodeHD2pass $1 $2
		fi
		if [ -e /usr/bin/beep ]; then beep $beep; fi
		comparison $1 $2
	fi

	if [[ -z $2 ]] ;then #|| [[ $2 != SD || $2 != 720 || $2 != 1080 ]]; then
		echo ""
		echo "ambiguious. 576p, 720p or 1080p?"
	fi

	;;

	*)  # neither any of the above

	echo ""
	echo "well, that's not a number between 0 and 9 :-) "
	exit

	;;

esac
exit
