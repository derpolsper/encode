#!/bin/bash

# path to your config file
config="${HOME}/.config/wine.encode/default.cfg"

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
	echo "*** no individual config file       ***"
	echo "*** generated yet for this encoding ***"
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


echo ""
echo "what do you want to do?"
echo ""
echo "0 - check for necessary programs and"
echo "    show|edit your default settings"
echo ""
echo "1 - rip your m2ts|VOB files into a matroska container,"
echo "    point to remux file, create an avs file"
echo ""
echo "2 - crf integers and increments"
echo ""
echo "3 - variations in qcomp"
echo ""
echo "4 - variations in aq strength and psy-rd"
echo ""
echo "5 - variations in psy-trellis"
echo ""
echo "6 - different things: chroma-qp-offset etc"
echo ""
echo "7 - another round of crf"
echo ""
echo "8 - encode the whole movie"
echo ""
read -p "> " answer00

case "$answer00" in

	0)	# 0 - installed programs - default settings - edit default settings
	
	# x264, avconv/ffmpeg, mkvmerge, mediainfo, wine, eac3to, AviSynth,
	# AvsPmod, avs2yuv, Haali MatroskaSplitter, beep

	#clear terminal
	clear

	echo ""
	echo "*** check for required programs ***"
	echo ""

	if [ -e /usr/bin/x264 ]; then
		/usr/bin/x264 -V |grep x264 -m 1 ; echo ""
		else echo ""
		echo "***"
		echo "*** x264 NOT installed!"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/mkvmerge ]; then 
		/usr/bin/mkvmerge -V; echo ""
		else echo ""
		echo "***"
		echo "*** mkvmerge NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/mediainfo ]; then
		/usr/bin/mediainfo --Version; echo ""
		else echo ""
		echo "***"
		echo "*** mediainfo NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/exiftool ]; then
		echo -n "exiftool "; /usr/bin/exiftool -ver; echo ""
		else echo ""
		echo "***"
		echo "*** exiftool NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/wine ]; then
		/usr/bin/wine --version; echo ""
		else echo ""
		echo "***"
		echo "*** wine NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe ]; then
		wine ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe|grep 'eac3to v'; echo ""
		else echo ""
		echo "***"
		echo "*** eac3to seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/"$wine"/drive_c/windows/system32/avisynth.dll ]; then
		echo "avisynth seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** avisynth seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe ]; then
		echo "AvsPmod seems to be installed"
		echo ""
		else echo ""
		echo "***"
		echo "*** AvsPmod seems not to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe ]; then
		echo "avs2yuv seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** avs2yuv seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/"$wine"/drive_c/Program\ Files/Haali/MatroskaSplitter/uninstall.exe ]; then
# TODONOTE: where and what to  search for?
		echo "MatroskaSplitter seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** MatroskaSplitter seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ ! -e /usr/bin/beep ]; then
		echo ""
		echo "***"
		echo "*** info: beep not installed"
		echo "***"
	fi

# TODONOTE: anything else necessary?
	echo ""
	read -p "hit return to continue"

	#clear terminal
	clear

	echo ""
	echo "*** these are default encode settings ***"
	echo ""
	echo -e "TUNE:\t\t ""$tune"
	echo -e "PROFILE:\t ""$profile"
	echo -e "PRESET:\t\t ""$preset"
	echo ""
	echo -e "*** more specific settings ***"
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
	echo "parameters for reframes are calculated"
	echo "automatically from source file"
	echo ""
	echo "if you want to adjust them to your needs,"
	echo "hit (e)dit now, else return"
	echo ""
	read -e -p "(e) > " answer_defaultsettings

	case "$answer_defaultsettings" in

		e|E|edit) # edit the wine.encode/default.cfg

			"${EDITOR:-vi}" "$config"
		;;

		*) # no editing

			echo "i take this for a no"
			exit
		;;
	esac

	echo "you might go on with option 1"
	echo ""
	;;

	1)	# 1 - prepare your sources: rip your m2ts/ VOB files into a matroska container
		#     or point to remux file, generate a avs file
	# check source0 for dir VIDEO_TS or file m2ts
	until [[  -e $source0 ]] && ( [[ $source0 == *VIDEO_TS* ]] || [[ $source0 == *.m2ts ]] || [[ $source0 == *.mkv ]] ); do
		echo ""
		echo "set path to your source: a VIDEO_TS directory,"
		echo "mkv or m2ts file respectively"
		echo ""
		read -e -p "> " source0
	done

	# check source1 for file extension == mkv
	until [[ $source1 == *.mkv ]]; do
		echo ""
		echo "where you want to place the demuxed file?"
		echo "absolute path AND name WITH file extension:"
		echo "e.g. /home/encoding/moviename.mkv"
		echo ""
		read -e -p "> " source1
	done

# TODONOTE quite hacky: if dir -> dvd, if file -> bluray
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
		done

		wine ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe "$param0"

		until [[ $param1 == *.mpeg2* ]]; do
			echo ""
			echo "extract all wanted tracks following this name pattern:"
			echo "[1-n]:name.extension, e.g. 2:name.mpeg2 3:name.ac3 4:name.eng.sup 5:name.spa.sup etc"
			echo "the video stream HAS TO be given mpeg2 as file extension"
			echo ""
			read -e -p "> " param1
		done

		# keep $param1 without parenthesis, otherwise eac3to fails while parsing the parameter
		wine ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe "$param0" $param1

# TODONOTE dirty. problems when >1 mpeg2 file
		mkvmerge -v -o "$source1" $(ls "$source0"|grep mpeg2)

		# eac3to's Log file names contain spaces
		for i in ./*.txt; do mv -v "$i" $(echo "$i" | sed 's/ /_/g') ; done
# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in ./*m2v ./*.mpeg* ./*.h264 ./*.dts* ./*.pcm ./*vc1 ./*.flac ./*.ac3 ./*.aac ./*.wav ./*.w64 ./*.sup ./*.txt; do
		mv $file "${source1%/*}"/ &>/dev/null; done

		echo ""
		echo "you find the demuxed files in"
		echo "${source1%/*}/"

	elif [[ -f  $source0 ]]  && [[ ( $source0 = *.m2ts ) || ( $source0 = *.mkv ) || ( $source0 = *.vc1 ) ]] ; then
		cd "${source0%/*}"

		wine ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe "${source0##*/}"

		until [[ $param1 = *.h264* || $param1 = *.mpeg2* || $param1 = *.vc1* ]]; do
			echo ""
			echo "extract all wanted tracks following this name pattern:"
			echo "[1-n]:name.extension, e.g. 2:name.h264 3:name.flac 4:name.ac3 5:name.sup etc"
			echo "the video stream HAS TO be given h264, mpeg2 or vc1 as file extension"
			echo ""
			read -e -p "> " param1
		done

		# keep $param1 without parenthesis, otherwise eac3to fails while parsing the parameter
		wine ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe "${source0##*/}" $param1

# TODONOTE: dirty. problems when >1 h264|mpeg2 file
		mkvmerge -v -o "$source1" $(ls "${source0%/*}"|grep -iE "h264|mpeg2|vc1" )

		# get the spaces out of eac3to's log file name
		for i in ./*.txt; do mv -v "$i" $(echo $i | sed 's/ /_/g') ; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in ./*m2v ./*.mpeg* ./*.h264 ./*.vc1 ./*.dts* ./*.pcm ./*.flac ./*.ac3 ./*.aac ./*.wav ./*.w64 ./*.sup ./*.txt; do
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

	# source file name without file extension
	# bash parameter expansion does not allow nesting, so do it in two steps
	source2=${source1##*/}

	# if no config with encodings' name, generate it or exit
	if [[ ! -e  ${config%/*}/${source2%.*}.cfg ]]; then
		echo ""
		echo "it seems, your encoding does not have a config file yet"
		echo "do you want to generate a new one?"
		echo ""
		read -e -p "(y|n) > " answer_generatecfg

		case "$answer_generatecfg" in
			y|Y|yes|Yes|YES)
				echo ""
				echo "a new config file is generated:"
				echo "${config%/*}/${source2%.*}.cfg"
				cp "$config" "${config%/*}/${source2%.*}.cfg"
				echo ""
				sed -i "/source2/d" "${config%/*}/${source2%.*}.cfg"
				echo "source2=$source2" >> "${config%/*}/${source2%.*}.cfg"
				sed -i "/source1/d" "${config%/*}/${source2%.*}.cfg"
				echo "source1=$source1" >> "${config%/*}/${source2%.*}.cfg"
			;;

			n|N|no|No|NO)
				echo ""
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
		esac
	fi

	# get to know your DAR SAR PAR
	sarheight0=$(exiftool "$source1"|awk '/Image Height/ {print $4}')
	sarwidth0=$(exiftool "$source1"|awk '/Image Width/ {print $4}')
	darheight0=$(exiftool "$source1"|awk '/Display Height/ {print $4}')
	darwidth0=$(exiftool "$source1"|awk '/Display Width/ {print $4}')

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

		until [[ $sar = *:* ]]; do
			echo "set sar as fraction using a colon"
			echo "e.g. 16:15"
			echo ""
			read -e -p "> " sar
		done
		# keep cfg informed
		# 'sar=' instead of 'sar' to avoid deleting of sarheight0| sarwidth0
		sed -i "/sar=/d" "${config%/*}/${source2%.*}.cfg"
		echo "sar=$sar" >> "${config%/*}/${source2%.*}.cfg"
	else
		echo "sar is $sar"
		echo ""
	fi

	echo ""
	echo "check, if your movie is interlaced"
	echo ""
	echo -n "mediainfo says: "
	mediainfo "$source1"|awk '/Scan type/{print $4}'
	echo -n "exiftool says: "
	exiftool "$source1"|awk '/Scan Type/{print $5}'
	echo ""
	read -p "hit return to continue"

	echo ""
	echo "do you want to check with AvsPmod frame by frame,"
	echo "if your movie is interlaced and/or telecined?"
	echo "if yes, close AvsPmod window afterwards"
	echo ""
	read -e -p "check now? (y|n) > " answer_checkit

	case "$answer_checkit" in
		y|Y|yes|YES)
			# generate an almost empty avs just to check if movie is interlaced or telecined
	#		sed -i "/checkavs/d" "$config"
	#		echo "checkavs=${source1%.*}.avs" >> "${config%/*}/${source2%.*}.cfg"
			echo "FFVideosource(\"$source1\")" > "${source1%.*}".avs
			wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".avs
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
	read -e -p "(i|t|n) > " answer_intertele

	case "$answer_intertele" in
		i|I) # interlaced
			sed -i "/interlaced/d" "${config%/*}/${source2%.*}.cfg"
			echo "interlaced=1" >> "${config%/*}/${source2%.*}.cfg"
#			echo "FFVideosource(\"$source1\")" > "${source1%.*}".SD.final.avs
#			echo "QTGMC().SelectEven()" >> "${source1%.*}".SD.final.avs
		;;

		t|T) # telecined
			sed -i "/telecined/d" "${config%/*}/${source2%.*}.cfg"
			echo "telecined=1" >> "${config%/*}/${source2%.*}.cfg"
#			echo "TFM().TDecimate()" >> "${source1%.*}".test.avs
		;;

#		b|B) # interlaced and then telecined
#			sed -i "/interlaced/d" "${config%/*}/${source2%.*}.cfg"
#			echo "interlaced=1" >> "${config%/*}/${source2%.*}.cfg"
#			sed -i "/telecined/d" "${config%/*}/${source2%.*}.cfg"
#			echo "telecined=1" >> "${config%/*}/${source2%.*}.cfg"
#			echo "QTGMC().SelectEven()" >> "${source1%.*}".test.avs
#			echo "TFM().TDecimate()" >> "${source1%.*}".test.avs
#			echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".test.avs
#		;;

		n|N) # neither interlaced nor telecined
			sed -i "/interlaced/d" "${config%/*}/${source2%.*}.cfg"
			echo "interlaced=0" >> "${config%/*}/${source2%.*}.cfg"
			sed -i "/telecined/d" "${config%/*}/${source2%.*}.cfg"
			echo "telecined=0" >> "${config%/*}/${source2%.*}.cfg"
		;;

		*)
			echo "that's not what was asked for"
			echo "you may try again"
		;;
	esac

	function cropping {
		echo ""
		echo "check if cropping is needed"
		echo "AvsP > Video > Crop editor"
		echo "when checked, note values and close AvsPmod window"
		echo "do NOT hit »apply«"
		read -e -p "check now (y|n) > " answer_crop

			case "$answer_crop" in
				y|Y|yes|YES)
					echo "FFVideosource(\"$source1\")" > "${source1%.*}".avs
					wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".avs
				;;

				n|N|no|NO)
				;;

				*)
					echo "that's neither yes nor no :-) "
					echo "i take this for a no"
				;;
			esac

		echo ""
		echo "if no cropping is needed, just type 0 (zero)"
		echo "all numbers unsigned, must be even"
		echo "number of pixels to be cropped on the"
		echo ""
		read -e -p "left > " left
		# keep cfg informed
		sed -i "/left/d" "${config%/*}/${source2%.*}.cfg"
		echo "left=$left" >> "${config%/*}/${source2%.*}.cfg"

		echo ""
		echo "number of pixels to be cropped on the"
		echo ""
		read -e -p "top > " top
		# keep cfg informed
		sed -i "/top/d" "${config%/*}/${source2%.*}.cfg"
		echo "top=$top" >> "${config%/*}/${source2%.*}.cfg"

		echo ""
		echo "number of pixels to be cropped on the"
		echo ""
		read -e -p "right > " right
		# keep cfg informed
		sed -i "/right/d" "${config%/*}/${source2%.*}.cfg"
		echo "right=$right" >> "${config%/*}/${source2%.*}.cfg"

		echo ""
		echo "number of pixels to be cropped on the"
		echo ""
		read -e -p "bottom > " bottom
		# keep cfg informed
		sed -i "/bottom/d" "${config%/*}/${source2%.*}.cfg"
		echo "bottom=$bottom" >> "${config%/*}/${source2%.*}.cfg"
	}

	if [[ ( -n $left && -n $right && -n $top && -n $bottom ) ]]; then
		echo ""
		echo "your config file"
		echo "${config%/*}/${source2%.*}.cfg"
		echo "has got some cropping values:"
		echo "left:  $left"
		echo "top:   $top"
		echo "right: $right"
		echo "bottom:$bottom"
		echo ""
		echo "are you (o)kay with that or"
		echo "do you want to (e)dit them?"
		read -e -p "(o|e) > " answer_cropedit

		case $answer_cropedit in
			o|O|ok|okay|OK|Ok)
			# do nothing here
			;;

			e|E|edit|EDIT|Edit)
			cropping
			;;

			*)
			echo "that's neither 'edit' nor 'ok'"
			echo "i take this for a 'ok'"
			;;
		esac
	else
		cropping
	fi

		
	sarwidth1=$(echo "$sarwidth0-$left-$right"|bc)
	sarheight1=$(echo "$sarheight0-$top-$bottom"|bc)
	sed -i "/sarwidth1/d" "${config%/*}/${source2%.*}.cfg"
	echo "sarwidth1=$sarwidth1" >> "${config%/*}/${source2%.*}.cfg"
	sed -i "/sarheight1/d" "${config%/*}/${source2%.*}.cfg"
	echo "sarheight1=$sarheight1" >> "${config%/*}/${source2%.*}.cfg"

	function getresolutionSDfromSD {
		widthSD=$(echo "$darwidth0-$left-$right"|bc)
		heightSD=$(echo "$darheight0-$top-$bottom"|bc)
		
		sed -i "/heightSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "heightSD=$heightSD" >> "${config%/*}/${source2%.*}.cfg"
		sed -i "/widthSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "widthSD=$widthSD" >> "${config%/*}/${source2%.*}.cfg"

		refSD=$(echo "scale=0;32768/((("$widthSD"/16)+0.5)/1 * (("$heightSD"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "refSD=$refSD" >> "${config%/*}/${source2%.*}.cfg"
	}

	function targetresolutionSDfromSD {
		if [[ -e $widthSD && -e $heightSD ]]; then
			echo "final resolution for SD encoding is $widthSD×$heightSD"
			echo "do you want to change the values?"
			read -e -p "(y|n) > " answer_targetresSD

			case $answer_targetresSD in
				y|Y|yes|YES|Yes)
				getresolutionSDfromSD
				;;

				n|N|no|NO|No)
				;;

				*)
				echo "i take this for a no"
				;;
			esac
		else
			getresolutionSDfromSD
		fi
	}

	function getresolutionSDfromHD {
		echo ""
		echo "set final height for SD"
		echo ""
		read -e -p "height > " heightSD
		sed -i "/heightSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "heightSD=$heightSD" >> "${config%/*}/${source2%.*}.cfg"
		echo ""
		echo "set final width for SD"
		echo ""
		read -e -p "width > " widthSD
		sed -i "/widthSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "widthSD=$widthSD" >> "${config%/*}/${source2%.*}.cfg"

		refSD=$(echo "scale=0;32768/((("$widthSD"/16)+0.5)/1 * (("$heightSD"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "refSD=$refSD" >> "${config%/*}/${source2%.*}.cfg"
	}

	function targetresolutionSDfromHD {
		if [[ -e $widthSD && -e $heightSD ]]; then
			echo "final resolution for SD encoding is $widthSD×$heightSD"
			echo "do you want to change the values?"
			read -e -p "(y|n) > " answer_targetresSD

			case $answer_targetresSD in
				y|Y|yes|YES|Yes)
				getresolutionSDfromHD
				;;

				n|N|no|NO|No)
				;;

				*)
				echo "i take this for a no"
				;;
			esac
		else
			getresolutionSDfromHD
		fi
	}

	function getresolution720 {
		echo""
		echo "set final height for 720p"
		echo ""
		read -e -p "height > " height720
		sed -i "/height720/d" "${config%/*}/${source2%.*}.cfg"
		echo "height720=$height720" >> "${config%/*}/${source2%.*}.cfg"
		echo ""
		echo "set final width for 720p"
		echo ""
		read -e -p "width > " width720
		sed -i "/width720/d" "${config%/*}/${source2%.*}.cfg"
		echo "width720=$width720" >> "${config%/*}/${source2%.*}.cfg"

		ref720=$(echo "scale=0;32768/((("$width720"/16)+0.5)/1 * (("$height720"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/ref720/d" "${config%/*}/${source2%.*}.cfg"
		echo "ref720=$ref720" >> "${config%/*}/${source2%.*}.cfg"
	}

	function targetresolution720 {
		if [[ -e $width720 && -e $height720 ]]; then
		echo "final resolution for 720p encoding is $width720×$height720"
		echo "do you want to change the values?"
		read -e -p "(y|n) > " answer_targetres720

			case $answer_targetres720 in
				y|Y|yes|YES|Yes)
					getresolution720
				;;

				n|N|no|NO|No)
				;;

				*)
					echo "i take this for a no"
				;;
			esac
		else
			getresolution720
		fi
	}

	function getresolution1080 {
		ref1080=$(echo "scale=0;32768/((("$sarwidth1"/16)+0.5)/1 * (("$sarheight1"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/ref1080/d" "${config%/*}/${source2%.*}.cfg"
		echo "ref1080=$ref1080" >> "${config%/*}/${source2%.*}.cfg"
	}

	function targetresolution1080 {
		if [[ -e $width1080 && -e $height1080 ]]; then
		echo "final resolution for 1080p encoding is $width1080×$height1080"
		echo "do you want to change the values?"
		read -e -p "(y|n) > " answer_targetres1080

			case $answer_targetres1080 in
				y|Y|yes|YES|Yes)
					getresolution1080
				;;

				n|N|no|NO|No)
				;;

				*)
					echo "i take this for a no"
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

		if [[ $interlaced -gt 0 ]]; then
			echo "QTGMC().SelectEven()" >> "${source1%.*}".SD.final.avs
		fi

		if [[ $telecined -gt 0 ]]; then
			echo "TFM().TDecimate()" >> "${source1%.*}".SD.final.avs
		fi

		echo "Crop($left, $top, -$right, -$bottom)" >> "${source1%.*}".SD.final.avs
		echo "Spline36Resize($widthSD, $heightSD)" >> "${source1%.*}".SD.final.avs
	}

	function  avsSDfromSD {
		# generate a new avs file anyway
		# keep cfg informed
		sed -i "/finalavsSD/d" "${config%/*}/${source2%.*}.cfg"
		echo "finalavsSD=${source1%.*}.SD.final.avs" >> "${config%/*}/${source2%.*}.cfg"
		echo "FFVideosource(\"$source1\")" > "${source1%.*}".SD.final.avs

		if [[ $interlaced -gt 0 ]]; then
			echo "QTGMC().SelectEven()" >> "${source1%.*}".SD.final.avs
		fi

		if [[ $telecined -gt 0 ]]; then
			echo "TFM().TDecimate()" >> "${source1%.*}".SD.final.avs
		fi

		echo "Crop($left, $top, -$right, -$bottom)" >> "${source1%.*}".SD.final.avs
	}

	function  avs720 {
		# generate a new avs file anyway
		# keep cfg informed
		sed -i "/finalavs720/d" "${config%/*}/${source2%.*}.cfg"
		echo "finalavs720=${source1%.*}.720.final.avs" >> "${config%/*}/${source2%.*}.cfg"
		echo "FFVideosource(\"$source1\")" > "${source1%.*}".720.final.avs

		if [[ $interlaced -gt 0 ]]; then
			echo "QTGMC().SelectEven()" >> "${source1%.*}".720.final.avs
		fi

		if [[ $telecined -gt 0 ]]; then
			echo "TFM().TDecimate()" >> "${source1%.*}".720.final.avs
		fi

		echo "Crop($left, $top, -$right, -$bottom)" >> "${source1%.*}".720.final.avs
		echo "Spline36Resize($width720, $height720)" >> "${source1%.*}".720.final.avs
	}

	function  avs1080 {
		# generate a new avs file anyway
		# keep cfg informed
		sed -i "/finalavs1080/d" "${config%/*}/${source2%.*}.cfg"
		echo "finalavs1080=${source1%.*}.1080.final.avs" >> "${config%/*}/${source2%.*}.cfg"
		echo "FFVideosource(\"$source1\")" > "${source1%.*}".1080.final.avs

		if [[ $interlaced -gt 0 ]]; then
			echo "QTGMC().SelectEven()" >> "${source1%.*}".1080.final.avs
		fi

		if [[ $telecined -gt 0 ]]; then
			echo "TFM().TDecimate()" >> "${source1%.*}".1080.final.avs
		fi

		echo "Crop($left, $top, -$right, -$bottom)" >> "${source1%.*}".1080.final.avs
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
	if [[ $sarheight0 -gt 576 ]] && [[ $sarwidth0 -gt 720 ]]; then
		echo ""
		echo "if you want to resize, better check"
		echo "for correct target resolution!"
		echo ""
		echo "do you want to check with AvsPmod for correct"
		echo "target file resolution?"
		echo "AvsP > Tools > Resize calculator"
		echo "after cropping, the source's resolution is $sarwidth1×$sarheight1,"
		echo "the sar is $sar"
		echo "when checked, note values and close AvsPmod window"
		echo "do NOT hit »apply«"
		read -e -p "check now (y|n) > " answer_resizecalc

		case "$answer_resizecalc" in

			y|Y|yes|YES)
				wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".avs
			;;

			n|N|no|NO)
			;;

			*)
				echo "that's neither yes or no :-)"
				echo "i take this for a no"
			;;

		esac
	fi

	# generate final.avs and test.avs for all resolutions

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		echo ""
		echo "no resizing of SD sources!"
		echo ""
		echo "encoding in $sarwidth1×$sarheight1 with sar=$sar"
		targetresolutionSDfromSD
		avsSDfromSD
		testavsSD
	else
		echo ""
		echo "for encoding with or without resizing"
		echo "set your target resolutions: (S)D, (7)20p, (1)080p,"
		echo "a subset of them or (a)ll three"
		echo ""
		echo "(S|7|1|a)"
		read -e -p "> " answer_resize

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
				targetresolutionSD
				avsSDfromHD
				testavsSD
			;;

			1S|1s|s1|S1)
				targetresolutionSD
				avsSDfromHD
				testavsSD
				targetresolution1080
				avs1080
				testavs1080
			;;

			7S|7s|s7|S7)
				targetresolutionSD
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
				targetresolutionSD
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

	function ratecontrol {

		echo ""
		echo "last question here:"
		echo "do you want to encode using (c)rf or (2)pass?"
		read -e -p "(c|2) > " ratecontrol

		case "$ratecontrol" in

			c|C)
			# keep cfg informed
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=crf" >> "$config"
			;;

			2)
			# keep cfg informed
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=2pass" >> "$config"
			;;

			*)
			# keep cfg informed
			echo "that's neither c nor 2"
			echo "but i take this for a c"
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=crf" >> "$config"
			;;
		esac
	}

	if [[  ${ratecontrol##*=} == crf || ${ratecontrol##*=} == 2pass ]]; then
		echo ""
		echo "your config file"
		echo "$config"
		echo "says: encoding with"
		echo "$ratecontrol"
		echo ""
		echo "are you (o)kay with that or"
		echo "do you want to (e)dit them?"
		read -e -p "(o|e) > " answerratecontrol

		case $answerratecontrol in

			o|O|ok|okay|OK|Ok)
			# do nothing here
			;;

			e|E|edit|EDIT|Edit)
			ratecontrol
			;;

			*)
			echo "that's neither 'edit' nor 'ok'"
			echo "i take this for a 'ok'"
			;;
		esac
	else
		ratecontrol
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		echo ""
		echo "remember:"
		echo "to make use of the corresponding config file"
		echo "from option 2 to option 8"
		echo "start the script like this:"
		echo ""
		echo "./wine.encode.sh ${source2%.*}"
		echo ""
		echo "go on with option 2"
		echo ""
	else
		echo ""
		echo "remember:"
		echo "to make use of the corresponding config file"
		echo "from option 2 to option 8"
		echo "start the script like this:"
		echo ""
		echo "./wine.encode.sh ${source2%.*} <resolution>"
		echo ""
		echo "where resolution might be SD, 720 or 1080"
		echo "go on with option 2"
		echo ""
	fi
	;;

	2)	# 2 - test encodes for crf

	if [[ ! -e $source1 ]]; then
	echo ""
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "better walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
	fi

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
		echo ""
		echo "as the source is SD"
		echo "or target resolution is not set or set to SD,"
		echo "the test encodings will be in SD"
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	until [[ ${crf1high:-0} -ge ${crf1low:-1} ]]; do
		echo ""
		echo "set minimum crf as integer, e.g. 15"
		echo ""
		read -e -p "crf, lowest value > " crf1low

		echo ""
		echo "set maximum crf as integer, e.g. 20"
		echo ""
		read -e -p "crf, maximum value > " crf1high
	done

	start0=$(date +%s)

 	echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.crf1.avs

	for (( crf1=$crf1low; $crf1<=$crf1high; crf1=$crf1+1 ));do
		echo ""
		echo "encoding ${source2%.*}.$2.10.crf$crf1.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screens
		echo "=ffvideosource(\"${source1%.*}.$2.10.crf$crf1.mkv\").subtitle(\"crf $crf1 encode $2\", align=8)" >> "${source1%.*}".$2.crf1.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
			| x264 --stdin y4m \
			--crf "$crf1" \
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
			-o "${source1%.*}".$2.10.crf$crf1.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.10.crf$crf1.mkv lasted $time"
		echo ""
		echo "range crf $crf1low → $crf1high"
	done
		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
		echo "test encodings for crf integers in $2 lasted $time"

		#comparison screen
		prefixes=({a..z} {a..z}{a..z})
		i=0
		while IFS= read -r line; do
		printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2crf1.avs
		done < "${source1%.*}".$2.crf1.avs
		echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.crf1.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2crf1.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2crf1.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2crf1.avs
		mv "${source1%.*}".$2.2crf1.avs "${source1%.*}".$2.crf1.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi
		
	echo ""
	echo "look at these first encodings. where you find any detail loss"
	echo "in still images, you have found your crf integer. go on"
	echo "find increments around this integer."
	echo "then close AvsPmod."
	sleep 2

	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.crf1.avs

	until [[ $crf2high -ge $crf2low ]] && [[ $crf2increment -gt 0 ]]; do
		echo ""
		echo "$2 test encoding"
		echo ""
		echo "set lowest crf value as hundreds,"
		echo "e.g. 168 for 16.8"
		echo ""
		read -e -p "crf > " crf2low

		echo ""
		echo "set highst crf value as hundreds,"
		echo "e.g. 176 for 17.6"
		echo ""
		read -e -p "crf > " crf2high

		echo ""
		echo "set increment steps, e.g. 1 for 0.1"
		echo "≠0"
		echo ""
		read -e -p "increments > " crf2increment
	done

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.crf2.avs

	for ((crf2=$crf2low; $crf2<=$crf2high; crf2+=$crf2increment));do
		echo ""
		echo "encoding ${source2%.*}.$2.20.crf$crf2.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screen
		echo "=ffvideosource(\"${source1%.*}.$2.20.crf$crf2.mkv\").subtitle(\"crf $crf2 encode $2\", align=8)" >> "${source1%.*}".$2.crf2.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--crf $(printf '%s.%s' "$(($crf2/10))" "$(($crf2%10))") \
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
		-o "${source1%.*}".$2.20.crf$crf2.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.20.crf$crf2.mkv lasted $time"
		echo "encoding crf from $crf2low to $crf2high with increment $crf2increment"

	done

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2crf2.avs
	done < "${source1%.*}".$2.crf2.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.crf2.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2crf2.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2crf2.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2crf2.avs
	mv "${source1%.*}".$2.2crf2.avs "${source1%.*}".$2.crf2.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through your test"
	echo "encodings and decide, which crf gave"
	echo "best results at acceptable file size."
	echo "then close AvsPmod."
	sleep 2

	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.crf2.avs
	echo ""
	echo "set crf parameter for $2"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " crf
	# keep cfg informed
	echo ""
	sed -i "/crf$2/d" "$config"
	echo "crf$2=$crf" >> "$config"

	echo ""
	echo "from here, run the script with"
	echo "option 3"
	echo ""

	;;

	3)	# 3 - test variations in qcomp

	if [[ ! -e $source1 ]]; then
	echo ""
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "better walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
	fi

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	until [[ $qcomp1high -ge $qcomp1low ]] && [[ $qcomp1increment -gt 0 ]]; do
		echo ""
		echo "qcomp: default is 0.60, test with values around 0.60 to 0.80"
		echo "first, set lowest qcomp value"
		echo "e.g. 60 for 0.60"
		echo ""
		read -e -p "qcomp, lowest value > " qcomp1low

		echo ""
		echo "set maximum qcomp value"
		echo "e.g. 80 for 0.80"
		echo ""
		read -e -p "qcomp, maximum value > " qcomp1high

		echo ""
		echo "set increments, e.g. 10 for 0.10"
		echo "≠0"
		echo ""
		read -e -p "increments > " qcomp1increment
	done

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.qcomp1.avs

	for ((qcomp1number=$qcomp1low; $qcomp1number<=$qcomp1high; qcomp1number+=$qcomp1increment));do
		echo ""
		echo "encoding ${source2%.*}.$2.30.crf${crf##*=}.qc$qcomp1number.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screen
		echo "=ffvideosource(\"${source1%.*}.$2.30.crf${crf##*=}.qc$qcomp1number.mkv\").subtitle(\"encode crf${crf##*=} qc$qcomp1number $2\", align=8)" >> "${source1%.*}".$2.qcomp1.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
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
		--qcomp $(echo "scale=2;$qcomp1number/100"|bc) \
		-o "${source1%.*}".$2.30.crf${crf##*=}.qc$qcomp1number.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.30.crf${crf##*=}.qc$qcomp1number.mkv lasted $time"
		echo ""
		echo "range qcomp $qcomp1low → $qcomp1high; increment $qcomp1increment"

	done

	stop=$(date +%s);
	days=$(( ($stop-$start0)/86400 ))
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for qcomp in $2 lasted $days days and $time"

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2qcomp1.avs
	done < "${source1%.*}".$2.qcomp1.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.qcomp1.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2qcomp1.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2qcomp1.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2qcomp1.avs
	mv "${source1%.*}".$2.2qcomp1.avs "${source1%.*}".$2.qcomp1.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, which qcomp gave"
	echo "best results."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.qcomp1.avs

	echo ""
	echo "do you want to look for more subtle values in qcomp?"
	echo ""
	read -e -p "(y)es or (n)o > " answerqcomp2

	case $answerqcomp2 in
		y|Y|Yes|YES|yes)

		until [[ $qcomp2high -ge $qcomp2low ]] && [[ $qcomp2increment -gt 0 ]]; do
			echo ""
			echo "first, set lowest qcomp value"
			echo "e.g. 65 for 0.65"
			echo ""
			read -e -p "qcomp, lowest value > " qcomp2low

			echo ""
			echo "set maximum qcomp value"
			echo "e.g. 75 for 0.75"
			echo ""
			read -e -p "qcomp, maximum value > " qcomp2high

			echo ""
			echo "set increment steps, e.g. 2 for 0.02"
			echo "≠0"
			echo ""
			read -e -p "increments > " qcomp2increment
		done

		start0=$(date +%s)

		# create comparison screen avs
		echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.qcomp2.avs

		for ((qcomp2number=$qcomp2low; $qcomp2number<=$qcomp2high; qcomp2number+=$qcomp2increment));do
			echo ""
			echo "encoding ${source2%.*}.$2.40.crf${crf##*=}.qc$qcomp2number.mkv"
			echo ""

			start1=$(date +%s)

			#comparison screen
			echo "=ffvideosource(\"${source1%.*}.$2.40.crf${crf##*=}.qc$qcomp2number.mkv\").subtitle(\"encode crf${crf##*=} qc$qcomp2number $2\", align=8)" >> "${source1%.*}".$2.qcomp2.avs

			wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
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
			--qcomp $(echo "scale=2;$qcomp2number/100"|bc) \
			-o "${source1%.*}".$2.40.crf${crf##*=}.qc$qcomp2number.mkv -;

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${source2%.*}.$2.40.crf${crf##*=}.qc$qcomp2number.mkv lasted $time"
			echo ""
			echo "range qcomp $qcomp2low → $qcomp2high; increment $qcomp2increment"

		done

		stop=$(date +%s);
		days=$(( ($stop-$start0)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
		echo "test encodings for qcomp lasted $days days and $time"

		#comparison screen
		prefixes=({a..z} {a..z}{a..z})
		i=0
		while IFS= read -r line; do
		printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2qcomp2.avs
		done < "${source1%.*}".$2.qcomp2.avs
		echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.qcomp2.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2qcomp2.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2qcomp2.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2qcomp2.avs
		mv "${source1%.*}".$2.2qcomp2.avs "${source1%.*}".$2.qcomp2.avs

		if [ -e /usr/bin/beep ]; then beep $beep; fi

		echo ""
		echo "thoroughly look through all your test"
		echo "encodings and decide, which qcomp gave"
		echo "best results."
		echo "then close AvsPmod."
		sleep 2
		wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.qcomp2.avs
		;;

		n|N|No|NO|no) # just nothing
		;;

		*) # layer 8 problem

		echo "i take this for a no :-) "
		;;

	esac

	echo ""
	echo "set your qcomp parameter"
	echo "e.g. 0.71"
	echo ""
	read -e -p "qcomp > " qcomp

	# keep cfg informed
	sed -i "/qcomp$2/d" "$config"
	echo "qcomp$2=$qcomp" >> "$config"

	echo ""
	echo "from here, run the script with"
	echo "option 4"
	echo ""

	;;

	4)	# 4 - variations in aq strength and psy-rd



	if [[ ! -e $source1 ]]; then
	echo ""
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "better walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
	fi

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	until [[ $aqhigh -ge $aqlow ]] && [[ $aqincrement -gt 0 ]]; do
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

	until [[ $psy1high -ge $psy1low ]] && [[ $psy1increment -gt 0 ]]; do
		echo ""
		echo "psy-rd: default is 1.0, test with values around 0.9 to 1.2"
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

	echo ""
	echo "this will last some time…"
	echo ""

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.aqpsy.avs

	for ((aqnumber=$aqlow; $aqnumber<=$aqhigh; aqnumber+=$aqincrement));do
		for ((psy1number=$psy1low; $psy1number<=$psy1high; psy1number+=$psy1increment));do
			echo ""
			echo "encoding ${source2%.*}.$2.50.crf${crf##*=}.qc${qcomp##*=}.aq$aqnumber.psy$psy1number.mkv"
			echo ""

			start1=$(date +%s)

			#comparison screen
			echo "=ffvideosource(\"${source1%.*}.$2.50.crf${crf##*=}.qc${qcomp##*=}.aq$aqnumber.psy$psy1number.mkv\").subtitle(\"encode crf${crf##*=} qc${qcomp##*=} aq$aqnumber psy$psy1number $2\", align=8)" >> "${source1%.*}".$2.aqpsy.avs

			wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
			| x264 --stdin y4m \
			--crf "${crf##*=}" \
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
			--aq-strength $(echo "scale=2;$aqnumber/100"|bc) \
			--psy-rd $(echo "scale=2;$psy1number/100"|bc):unset \
			-o "${source1%.*}".$2.50.crf${crf##*=}.qc${qcomp##*=}.aq$aqnumber.psy$psy1number.mkv -;

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${source2%.*}.$2.50.crf${crf##*=}.qc${qcomp##*=}.aq$aqnumber.psy$psy1number.mkv lasted $time"
			echo ""
			echo "range aq strength $aqlow → $aqhigh; increment $aqincrement"
			echo "range psy-rd $psy1low → $psy1high; increment $psy1increment"

		done
	done

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
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.aqpsy.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2aqpsy.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2aqpsy.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2aqpsy.avs
	mv "${source1%.*}".$2.2aqpsy.avs "${source1%.*}".$2.aqpsy.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test encodings"
	echo "and decide, which aq strength and which psy-rd"
	echo "parameters gave you best results."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.aqpsy.avs
	
	echo ""
	echo "set aq strength for $2"
	echo "e.g. 0.85"
	echo ""
	read -e -p "aq strength > " aqs

	# keep cfg informed
	sed -i "/aqs$2/d" "$config"
	echo "aqs$2=$aqs" >> "$config"

	echo ""
	echo "set psy-rd for $2"
	echo "e.g. 0.9"
	echo ""
	read -e -p "psy-rd > " psyrd

	# keep cfg informed
	sed -i "/psyrd$2/d" "$config"
	echo "psyrd$2=$psyrd" >> "$config"

	case $(echo "$psyrd" - 0.99999 | bc) in

		-*) # psy-rd <1 -> psytr unset
		echo ""
		echo "as psy-rd is set to a value <1 (or not at all)"
		echo "psy-trellis is set to 'unset' automatically"
		echo ""
		echo "you might do further testing with"
		echo "option 6 (some more less common tests) or"
		echo "go on with option 7 (a last round for crf)"
		echo ""
		;;

		*) # psyrd >= 1
		echo ""
		echo "you might test for psy-trellis"
		echo "with option 5,"
		echo "do further testing with option 6"
		echo "(some more less common tests) or"
		echo "go on with option 7 (a last round for crf)"
		echo ""
		;;
	esac

	# keep cfg informed
	sed -i "/psytr$2/d" "$config"
	echo "psytr$2=unset" >> "$config"
	;;
	
	5)	# 5 - variations in psy-trellis

	if [[ ! -e $source1 ]]; then
	echo ""
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "better walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
	fi

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	echo "${psyrd##*=}"

	case $(echo "${psyrd##*=}" - 0.99999 | bc) in

		-*) # psy-rd <1 -> psytr unset
		echo ""
		echo "as psy-rd is set to a value < 1 (or not at all)"
		echo "psy-trellis is set to 'unset' automatically"
		echo ""

		# keep cfg informed
		sed -i "/psytr$2/d" "$config"
		echo "psytr$2=unset" >> "$config"
		;;

		*) # psyrd >= 1
		echo ""
		echo "as psy-rd is set to ≥1"
		echo "you may (t)est for psy-trellis"
		echo "or (u)nset psy-trellis"
		echo ""
		read -e -p "(t|u) > " answerpsytr

			case $answerpsytr in

			t|T) # test for psy-trellis

			until [[ $psy2high -ge $psy2low ]] && [[ $psy2increment -gt 0 ]]; do
				echo ""
				echo "psy-trellis: default is 0.0"
				echo "test for values ~0.0 to 0.15"
				echo "set lowest value for psy-trellis, e.g. 0 for 0.0"
				echo ""
				read -e -p "psy-trellis, lowest value > " psy2low

				echo ""
				echo "set maximum value for psy-trellis, e.g. 10 for 0.1"
				echo ""
				read -e -p "psy-trellis, maximum value > " psy2high

				echo ""
				echo "set increment steps, e.g. 5 for 0.05"
				echo ""
				read -e -p "increments > " psy2increment
			done

			start0=$(date +%s)

			# create comparison screen avs
			echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.psytr.avs

			for ((psy2number=$psy2low; $psy2number<=$psy2high; psy2number+=$psy2increment));do
				echo ""
				echo "encoding ${source2%.*}.$2.60.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.$psy2number.mkv"
				echo ""

				start1=$(date +%s)

				#comparison screen
				echo "=ffvideosource(\"${source1%.*}.$2.60.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.$psy2number.mkv\").subtitle(\"encode crf${crf##*=} qc${qcomp##*=} aq${aqs##*=} psy${psyrd##*=} $psy2number $2\", align=8)" >> "${source1%.*}".$2.psytr.avs

				wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
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
				--psy-rd "${psyrd##*=}":$(echo "scale=2;$psy2number/100"|bc) \
				-o "${source1%.*}".$2.60.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.$psy2number.mkv -;

				stop=$(date +%s);
				time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
				echo "encoding ${source2%.*}.$2.60.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.$psy2number.mkv lasted $time"
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
			echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.psytr.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2psytr.avs
			echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2psytr.avs
			echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2psytr.avs
			mv "${source1%.*}".$2.2psytr.avs "${source1%.*}".$2.psytr.avs

			if [ -e /usr/bin/beep ]; then beep $beep; fi

			echo ""
			echo "thoroughly look through this last test encodings and"
			echo "decide, which one is your best encode."
			echo "then close AvsPmod."
			sleep 2
			wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.psytr.avs

			echo ""
			echo "set psy-trellis"
			echo "e.g. 0.05"
			echo ""
			read -e -p "psy-trellis > " psytr

			# keep cfg informed
			sed -i "/psytr$2/d" "$config"
			echo "psytr$2=$psytr" >> "$config"
			;;

			u|U) # unset psy-trellis

			echo ""
			echo "psy trellis now is set to 'unset'."
			echo ""

			# keep cfg informed
			sed -i "/psytr$2/d" "$config"
			echo "psytr$2=unset" >> "$config"
			echo ""
			;;

			*) # neither any of the above

			echo ""
			echo "that's neither 't' nor 'u' :-) "
			echo "psy trellis is set to 'unset'."
			echo ""

			# keep cfg informed
			sed -i "/psytr$2/d" "$config"
			echo "psytr$2=unset" >> "$config"
			echo ""
			;;

			esac
		;;

	esac

	echo "do some testing for chroma-qp-offset"
	echo "(option 6) or"
	echo "try another (maybe last) round for optimal crf"
	echo "(option 7)"
	echo ""
	;;

	6)	# 6 - some more testing with different parameters

	if [[ ! -e $source1 ]]; then
	echo ""
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "better walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
	fi

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
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
	echo "(c)hroma-qp-offset with a sensible range -2 - 2"
	echo "(n)othing right now"
	echo "(d)on't know yet"
	read -e -p "(c|n|d) > " answerchroma

	case $answerchroma in

		c|C)	# chroma-qp-offset

			until [[ ${cqpohigh:-0} -ge ${cqpolow:-1} ]]; do
				echo "test for chroma-qp-offset, default 0, sensible ranges -3 to 3"
				echo "set lowest value for chroma-qp-offset, e.g. -2"
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

			for ((cqponumber=$cqpolow; $cqponumber<=$cqpohigh; cqponumber=$cqponumber+1));do
				echo ""
				echo "encoding ${source2%.*}.$2.70.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo$cqponumber.mkv"
				echo ""

				start1=$(date +%s)

				#comparison screen
				echo "=ffvideosource(\"${source1%.*}.$2.70.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo$cqponumber.mkv\").subtitle(\"encode crf${crf##*=} qc${qcomp##*=} aq${aqs##*=} psy${psyrd##*=}.${psytr##*=} cqpo$cqponumber $2\", align=8)" >> "${source1%.*}".$2.cqpo.avs

				wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
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
				--chroma-qp-offset "$cqponumber" \
				-o "${source1%.*}".$2.70.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo$cqponumber.mkv -;

				stop=$(date +%s);
				time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
				echo "encoding ${source1%.*}.$2.70.crf${crf##*=}.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo$cqponumber.mkv lasted $time"
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
			echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.cqpo.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2cqpo.avs
			echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2cqpo.avs
			echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2cqpo.avs
			mv "${source1%.*}".$2.2cqpo.avs "${source1%.*}".$2.cqpo.avs

			if [ -e /usr/bin/beep ]; then beep $beep; fi

			echo ""
			echo "thoroughly look through this last test encodings and"
			echo "decide, which one is your best encode."			
			echo "then close AvsPmod."
			sleep 2
			wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.cqpo.avs

			echo ""
			echo "set chroma-qp-offset"
			echo "e.g. 1"
			echo ""
			read -e -p "chroma-qp-offset > " cqpo

			# keep cfg informed
			sed -i "/cqpo$2/d" "$config"
			echo "cqpo$2=$cqpo" >> "$config"
		;;

		n|N)	# nothing

		;;

		d|D)	# don't know yet

		;;

	esac

	echo "you might go on with option 7"
	echo "and test for a new value in crf"
	echo ""

	;;

	7)	# 7 - another round of crf

	if [[ ! -e $source1 ]]; then
	echo ""
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "better walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
	fi

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
	fi

	avs=$(cat "$config"|grep testavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)
	ref=$(cat "$config"|grep ref|grep $2)

	until 	[[ $crf3high -ge $crf3low ]] && [[ $crf3increment -gt 0 ]]; do
		echo ""
		echo "after all that optimization, you may test for"
		echo "a new, probably more bitsaving value, especially"
		echo "if you are to encode with crf instead 2pass"
		echo ""
		echo "so far you tested with a crf of ${crf##*=}"
		echo ""
		echo "once again, try a range of crf increments"
		echo "set lowest crf value as hundreds,"
		echo "e.g. 168 for 16.8"
		echo ""
		read -e -p "crf, lowest value > " crf3low

		echo ""
		echo "set highst crf value as hundreds,"
		echo "e.g. 172 for 17.2"
		echo ""
		read -e -p "crf, maximum value > " crf3high

		echo ""
		echo "set increment steps, e.g. 1 for 0.1"
		echo "≠0"
		echo ""
		read -e -p "increments > " crf3increment
	done

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".$2.crf3.avs

	for ((crf3number=$crf3low; $crf3number<=$crf3high; crf3number+=$crf3increment));do
		echo ""
		echo "encoding ${source2%.*}.$2.80.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo${cqpo##*=}.crf$crf3number.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screen
		echo "=ffvideosource(\"${source2%.*}.$2.80.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo${cqpo##*=}.crf$crf3number.mkv\").subtitle(\"encode qc${qcomp##*=} aq${aqs##*=} psy${psyrd##*=}.${psytr##*=} cqpo${cqpo##*=} crf$crf3number $2\", align=8)" >> "${source1%.*}".$2.crf3.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
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
		--crf $(echo "scale=1;$crf3number/10"|bc) \
		-o "${source1%.*}".$2.80.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo${cqpo##*=}.crf$crf3number.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.$2.80.qc${qcomp##*=}.aq${aqs##*=}.psy${psyrd##*=}.${psytr##*=}.cqpo${cqpo##*=}.crf$crf3number.mkv lasted $time"
		echo ""
		echo "range crf $crf3low → $crf3high; increment $crf3increment"

	done

	stop=$(date +%s);
	days=$(( ($stop-$start0)/86400 ))
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for a second round of crf lasted $days days and $time"

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".$2.2crf3.avs
	done < "${source1%.*}".$2.crf3.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a,ca,a,cb,a,cc,a,cd,a,ce,a,cf,a,cg,a,ch,a,ci,a,cj,a,ck,a,cl,a,cm,a,cn,a,co,a,cp,a,cq,a,cr,a,cs,a,ct,a,cu,a,cv,a,cw,a,cx,a,cy,a,cz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".$2.crf3.avs) *2 -1|bc)-206 >> "${source1%.*}".$2.2crf3.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".$2.2crf3.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".$2.2crf3.avs
	mv "${source1%.*}".$2.2crf3.avs "${source1%.*}".$2.crf3.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, with which crf you"
	echo "get best results at considerable bitrate."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".$2.crf3.avs

	echo ""
	echo "set crf parameter"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " crf

	# keep cfg informed
	sed -i "/crf$2/d" "$config"
	echo "crf$2=$crf" >> "$config"

	echo ""
	echo "now you may encode the whole movie"
	echo "run the script like this:"
	echo ""
	echo "./wine.encode.sh ${source2%.*} <resolution>"
	echo ""
	echo "where resolution might be SD, 720 or 1080"
	echo ""
	echo "option 8"
	echo ""

	;;

	8)	# 8 - encode the whole movie

	if [[ ! -e $source1 ]]; then
		echo ""
		echo "it seems, you invoked the script without"
		echo "a valid config file:"
		echo "./wine.encode.sh <name.of.config.file.without.extension>"
		echo "better walk through option 1 again or edit"
		echo "your config file manually"
		exit
	fi

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		set -- "$1" SD
	fi

	if [[ -z $2 ]] || [[ $2 != 720 && $2 != 1080 ]]; then
		set -- "$1" SD
	fi

	avs=$(cat "$config"|grep finalavs|grep $2)
	crf=$(cat "$config"|grep crf|grep $2)
	qcomp=$(cat "$config"|grep qcomp|grep $2)
	aqs=$(cat "$config"|grep aqs|grep $2)
	psyrd=$(cat "$config"|grep psyrd|grep $2)
	psytr=$(cat "$config"|grep psytr|grep $2)
	cqpo=$(cat "$config"|grep cqpo|grep $2)

	function ratecontrol {

		echo ""
		echo "do you want to encode using (c)rf or (2)pass?"
		read -e -p "(c|2) > " ratecontrol

		case "$ratecontrol" in

			c|C)
			# keep cfg informed
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=crf" >> "$config"
			;;

			2)
			# keep cfg informed
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=2pass" >> "$config"
			;;

			*)
			# keep cfg informed
			echo "that's neither c nor 2"
			echo "but i take this for a c"
			sed -i "/ratecontrol/d" "$config"
			echo "ratecontrol=crf" >> "$config"
			;;
		esac
	}

	if [[  ${ratecontrol##*=} == crf || ${ratecontrol##*=} == 2pass ]]; then
		echo ""
		echo "your config file"
		echo "$config"
		echo "says: encoding with"
		echo "$ratecontrol"
		echo ""
		echo "are you (o)kay with that or"
		echo "do you want to (e)dit them?"
		read -e -p "(o|e) > " answerratecontrol

		case $answerratecontrol in

			o|O|ok|okay|OK|Ok)
			# do nothing here
			;;

			e|E|edit|EDIT|Edit)
			ratecontrol
			;;

			*)
			echo "that's neither 'edit' nor 'ok'"
			echo "i take this for an 'ok'"
			;;
		esac
	else
		ratecontrol
	fi

	# 2pass functions
	function bitrateSD {
		echo ""
		echo "have a look at your best test encoding"
		echo "at sensible file size"
		echo "that bitrate in kbps is your aim for the final encoding in SD"
		read -e -p "bitrate: " bitrateSD

		# keep cfg informed
		sed -i "/bitrateSD/d" "$config"
		echo "bitrateSD=$bitrateSD" >> "$config"
	}

	function bitrate720 {
		echo ""
		echo "bitrate in kbps for the final encoding in 720p"
		read -e -p "bitrate: " bitrate720

		# keep cfg informed
		sed -i "/bitrate720/d" "$config"
		echo "bitrate720=$bitrate720" >> "$config"
	}

	function bitrate1080 {
		echo ""
		echo "bitrate in kbps for the final encoding in 1080p"
		read -e -p "bitrate: " bitrate1080

		# keep cfg informed
		sed -i "/bitrate1080/d" "$config"
		echo "bitrate1080=$bitrate1080" >> "$config"
	}

	function encodeSDfromSD2pass {

		echo ""
		echo "now encoding ${source2%.*}.SD.mkv"
		echo "with a resolution of $sarwidth1×$sarheight1, sar=$sar…"
		echo ""

		# Get reframes for SD
		# though --preset Placebo sets reframes to 16, but
		# 1- that may set level ≥ 4.1
		# 2- cropping may change reframes value
		refSD=$(echo "scale=0;32768/((("$sarwidth1"/16)+0.5)/1 * (("$sarheight1"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "$config"
		echo "refSD=$refSD" >> "$config"

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.SD.avs
		echo "b=ffvideosource(\"${source1%.*}.SD.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.SD.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.SD.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".comparison.SD.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.SD.avs

		# 1. pass
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 1 \
		--bitrate "$bitrateSD" \
		--sar "$sar" \
		--stats "${source1%.*}SD.stats" \
		--ref "$refSD" \
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
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 3 \
		--bitrate "$bitrateSD" \
		--stats "${source1%.*}SD.stats" \
		--sar "$sar" \
		--ref "$refSD" \
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
		-o "${source1%.*}".SD.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.SD.mkv"
		echo "with $sarwidth1×$sarheight1 lasted $days days and $time"
	}

	function encodeSDfromHD2pass {
		echo ""
		echo "now encoding ${source2%.*}.SD.mkv"
		echo "with a resolution of $widthSD×$heightSD…"
		echo ""

		# Get reframes for SD
		# though --preset Placebo sets reframes to 16, but
		# 1- that may set level ≥ 4.1
		# 2- cropping may change reframes value
		refSD=$(echo "scale=0;32768/((("$widthSD"/16)+0.5)/1 * (("$heightSD"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "$config"
		echo "refSD=$refSD" >> "$config"

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("$widthSD","$heightSD").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.SD.avs
		echo "b=ffvideosource(\"${source1%.*}.SD.mkv\").subtitle(\"encode SD\", align=8)" >> "${source1%.*}".comparison.SD.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.SD.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.SD.avs

		# 1. pass
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 1 \
		--bitrate "$bitratesd" \
		--sar "$sar" \
		--stats "${source1%.*}SD.stats" \
		--ref "$refSD" \
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
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 3 \
		--bitrate "$bitratesd" \
		--stats "${source1%.*}SD.stats" \
		--sar "$sar" \
		--ref "$refSD" \
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
		-o "${source1%.*}".SD.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.SD.mkv"
		echo "with $widthSD×$heightSD lasted $days days and $time"
	}

	function encode7202pass {
		echo ""
		echo "now encoding ${source2%.*}.720.mkv"
		echo "with $width720×$height720…"
		echo ""

		# Get reframes for 720p
		ref720=$(echo "scale=0;32768/((("$width720"/16)+0.5)/1 * (("$height720"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/ref720/d" "$config"
		echo "ref720=$ref720" >> "$config"

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("$width720","$height720").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.720.avs
		echo "b=ffvideosource(\"${source1%.*}.720.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.720.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.720.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".comparison.720.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.720.avs

		# 1. pass
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 1 \
		--bitrate "$bitrate720" \
		--sar "$sar" \
		--stats "${source1%.*}720.stats" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref720" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o /dev/null -;

		# 2. pass
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 3 \
		--bitrate "$bitrate720" \
		--sar "$sar" \
		--stats "${source1%.*}720.stats" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref720" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".720.mkv -;
		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.720.mkv"
		echo "with $width720×$height720 lasted $days days and $time"
	}

	function encode10802pass {
		# Get reframes for 1080
		darwidth1=$(echo "$darwidth0-$left-$right"|bc)
		darheight1=$(echo "$darheight0-$top-$bottom"|bc)
		ref1080=$(echo "scale=0;32768/((("$darwidth1"/16)+0.5)/1 * (("$darheight1"/16)+0.5)/1)"|bc)

		# keep cfg informed
		sed -i "/ref1080/d" "$config"
		echo "ref1080=$ref1080" >> "$config"

		echo ""
		echo "now encoding ${source2%.*}.1080.mkv"
		echo "with $darwidth1×$darheight1…"
		echo ""

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("$darwidth1","$darheight1").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.1080.avs
		echo "b=ffvideosource(\"${source1%.*}.1080.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.1080.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.1080.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".comparison.1080.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.1080.avs

		# 1. pass
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 1 \
		--bitrate "$bitrate1080" \
		--sar "$sar" \
		--stats "${source1%.*}1080.stats" \
		--sar "$sar" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref1080" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o /dev/null -;

		# 2. pass
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--pass 3 \
		--bitrate "$bitrate1080" \
		--sar "$sar" \
		--stats "${source1%.*}1080.stats" \
		--sar "$sar" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref1080" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".1080.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.1080.mkv"
		echo "with $darwidth1×$darheight1 lasted $days days and $time"
	}

	function encodeSDfromSD {

		echo ""
		echo "now encoding ${source2%.*}.SD.mkv"
		echo "with a resolution of $sarwidth1×$sarheight1 and a sar of $sar…"
		echo ""

		# Get reframes for SD
		# though --preset Placebo sets reframes to 16, but
		# 1- that may set level ≥ 4.1
		# 2- cropping may change reframes value
		refSD=$(echo "scale=0;32768/((("$sarwidth1"/16)+0.5)/1 * (("$sarheight1"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "$config"
		echo "refSD=$refSD" >> "$config"

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.SD.avs
		echo "b=ffvideosource(\"${source1%.*}.SD.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.SD.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.SD.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.SD.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--crf "${crf##*=}" \
		--sar "$sar" \
		--ref "$refSD" \
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
		-o "${source1%.*}".SD.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.SD.mkv"
		echo "with $sarwidth1×$sarheight1 lasted $days days $time"
	}

	function encodeSDfromHD {
		echo ""
		echo "now encoding ${source2%.*}.SD.mkv"
		echo "with a resolution of $widthSD×$heightSD…"
		echo ""

		# Get reframes for SD
		# though --preset Placebo sets reframes to 16, but
		# 1- that may set level ≥ 4.1
		# 2- cropping may change reframes value
		refSD=$(echo "scale=0;32768/((("$widthSD"/16)+0.5)/1 * (("$heightSD"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/refSD/d" "$config"
		echo "refSD=$refSD" >> "$config"

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("$widthSD","$heightSD").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.SD.avs
		echo "b=ffvideosource(\"${source1%.*}.SD.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.SD.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.SD.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.SD.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--crf "${crf##*=}" \
		--sar "$sar" \
		--ref "$refSD" \
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
		-o "${source1%.*}".SD.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.SD.mkv"
		echo "with $widthSD×$heightSD lasted $days days and $time"
	}

	function encode720 {
		echo ""
		echo "now encoding ${source2%.*}.720.mkv"
		echo "with $width720×$height720…"
		echo ""

		# Get reframes for 720p
		ref720=$(echo "scale=0;32768/((("$width720"/16)+0.5)/1 * (("$height720"/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i "/ref720/d" "$config"
		echo "ref720=$ref720" >> "$config"

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("$width720","$height720").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.720.avs
		echo "b=ffvideosource(\"${source1%.*}.720.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.720.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.720.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.720.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--crf "${crf##*=}" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref720" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".720.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.720.mkv"
		echo "with $width720×$height720 lasted $days days and $time"
	}

	function encode1080 {

		echo ""
		echo "now encoding ${source2%.*}.1080.mkv"
		echo "with $sarwidth1×$sarheight1…"
		echo ""

		start=$(date +%s)

		# create comparison screen avs
		echo "a=import(\"${avs##*=}\").Spline36Resize("$darwidth1","$darheight1").subtitle(\"source\", align=8)" > "${source1%.*}".comparison.1080.avs
		echo "b=ffvideosource(\"${source1%.*}.1080.mkv\").subtitle(\"encode $2 ${source2%.*}\", align=8)" >> "${source1%.*}".comparison.1080.avs
		echo "interleave(a,b)" >> "${source1%.*}".comparison.1080.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.1080.avs
		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "${avs##*=}" - \
		| x264 --stdin y4m \
		--crf "${crf##*=}" \
		--sar "$sar" \
		--qcomp "${qcomp##*=}" \
		--aq-strength "${aqs##*=}" \
		--psy-rd "${psyrd##*=}":"${psytr##*=}" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref1080" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--chroma-qp-offset "${cqpo##*=}" \
		-o "${source1%.*}".1080.mkv -;

		stop=$(date +%s);
		days=$(( ($stop-$start)/86400 ))
		time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.1080.mkv"
		echo "with $darwidth1×$darheight1 lasted $days days and $time"

		echo "encoding for ${source2%.*}.1080.mkv lasted $time"
	}

	function comparisonSD {
		echo "take some comparison screen shots"
		echo "then close AvsPmod"
		sleep 2
		wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".comparison.SD.avs
	}

	function comparison720 {
		echo "take some comparison screen shots"
		echo "then close AvsPmod"
		sleep 2
		wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".comparison.720.avs
	}

	function comparison1080 {
		echo "take some comparison screen shots"
		echo "then close AvsPmod"
		sleep 2
		wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".comparison.1080.avs
	}

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		if [[ $ratecontrol == crf ]]; then
			encodeSDfromSD
		elif [[ $ratecontrol == 2pass ]]; then
			bitrateSD
			encodeSDfromSD2pass
		fi
		if [ -e /usr/bin/beep ]; then beep $beep; fi
		comparisonSD
	fi

	if [[ $sarheight0 -gt 576 ]] && [[ $sarwidth0 -gt 720 ]] && [[ $2 == SD ]]; then
		if [[ $ratecontrol == crf ]]; then
			encodeSDfromHD
		elif [[ $ratecontrol == 2pass ]]; then
			bitrateSD
			encodeSDfromHD
		fi
		if [ -e /usr/bin/beep ]; then beep $beep; fi
		comparisonSD
	fi

	if [[ $2 == 720 ]]; then
		if [[ $ratecontrol == crf ]]; then
			encode720
		elif [[ $ratecontrol == 2pass ]]; then
			bitrate720
			encode7202pass
		fi
		if [ -e /usr/bin/beep ]; then beep $beep; fi
		comparison720
	fi	

	if [[ $2 == 1080 ]]; then
		if [[ $ratecontrol == crf ]]; then
			encode1080
		elif [[ $ratecontrol == 2pass ]]; then
			bitrate1080
			encode10802pass
		fi
			if [ -e /usr/bin/beep ]; then beep $beep; fi
			comparison1080
	fi

	if [[ -z $2 ]] ;then #|| [[ $2 != SD || $2 != 720 || $2 != 1080 ]]; then
		echo ""
		echo "ambiguious. 576p, 720p or 1080p?"
	fi

	;;

	*)	# neither any of the above

	echo ""
	echo "well, that's not a number between 0 and 8 :-) "
	exit

	;;

esac
exit

