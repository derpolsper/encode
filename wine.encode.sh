#!/bin/bash

# Over the years, much great software for advanced video encoding has been
# written, unfortunately most of them for windows only. So linux users,
# who want to produce high quality encodings have to use a windows
# installation either natively or in a virtual machine - or use that windows
# runtime environment named wine, which is available for all major distri-
# butions.
# Thanks to all the great coders in the wine project, the most important
# windows tools do work at least sufficiently in a wine environment.

# This script was written to help me to produce test encodes in a kind of
# if not scientific ☺, at least methodical manner. it is a boring and often
# unstructered work. as a test encode may take twenty minutes, you may have to
# operate your pc after every 20 minutes to prompt the next encode.
# This script shall provide test encodes to compare parameters, and do some
# little bit more complex encoding with crosswise parameters, and afterwards
# doing all the work of encoding a whole movie.

# It uses native linux cli tools as far as available (which is not much right
# now), all the rest is done using windows tools via wine.

# It works for standard and high definition sources, getting along with VOB-
# containers as well as m2ts-Streams.

# As eac3to in wine does not support direct import into mkv, we have to walk
# around by taking either the mpeg2 or h264 stream. Afterwards, we mux them
# into a matroska container for further working with x264.

# Generally many AviSynth filters should work, but i did not do much testing
# here.

# Though some parameters can be set permanent, encoding needs
# a lot of trial and error to find the best possible result.
# There's lots of interaction. sorry for that.

# Right now, it does NOT
# decrypt sources
# de-telecine  video tracks
# do anything with demuxed audio files
# do anything with demuxed subtitles
# handle chapter files
# mux anything together
# 

# There are several steps to go on your way to an optimal encoding:
# 0 - check, if all necessary programs are installed and show|edit your default
#     settings
# 1 - VOB|m2ts -> mpeg2|h264 -> mkv
# 2 - suitable crf, first integers, then fractionals
# 3 - suitable qcomp, first bigger steps, then smaller steps
# 4 - aq strength and psy-rd
# 5 - psy-trellis
# 6 - different things
# 7 - another round of crf
# 8 - encoding the whole movie


# Credits to uncountable contributors at stackoverflow.com
# http://stackoverflow.com/questions/16571739/
# http://mywiki.wooledge.org/BashFAQ/073
# http://en.wikibooks.org/wiki/Eac3to/How_to_Use
# http://avisynth.nl
# http://mewiki.project357.com/wiki/X264_Settings
# and many people at ptp.me


# ********************************************************
# ********************************************************
# ********************************************************


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
echo "2 - crf integers and fractionals"
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
	read -e -p "(e) > " answer10

	case "$answer10" in

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
	echo ""
	echo "choose your source:"
	echo "either a de- or unencrypted rip from a (d)isk, bluray or dvd"
	echo "or a (r)emuxed file in a .mkv container"
	read -e -p "(d|r) > " source

	case "$source" in 

		d|D|dvd|DVD|b|B|bd|BD|bluray|Bluray)

			# check source0 for dir VIDEO_TS or file m2ts
			until [[  -e $source0 ]] && ( [[ $source0 == *VIDEO_TS* ]] || [[ $source0 == *.m2ts ]] ); do
				echo ""
				echo "set path to your VIDEO_TS directory"
				echo "or m2ts file respectively"
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

#TODONOTE dirty. problems when >1 mpeg2 file
				mkvmerge -v -o "$source1" $(ls "$source0"|grep mpeg2)

				# eac3to's Log file names contain spaces
				for i in ./*.txt; do mv -v "$i" $(echo "$i" | sed 's/ /_/g') ; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
				for file in ./*m2v ./*.mpeg* ./*.h264 ./*.dts* ./*.pcm ./*.flac ./*.ac3 ./*.aac ./*.wav ./*.w64 ./*.sup ./*.txt; do
				mv $file "${source1%/*}"/ ; done

				echo ""
				echo "you find the demuxed files in"
				echo "${source1%/*}/"

			elif [[ -f  $source0  && $source0 = *.m2ts ]]; then
				cd "${source0%/*}"

				wine ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe "${source0##*/}"

				until [[ $param1 = *.h264* ]]; do
					echo ""
					echo "extract all wanted tracks following this name pattern:"
					echo "[1-n]:name.extension, e.g. 2:name.h264 3:name.flac 4:name.ac3 5:name.sup etc"
					echo "the video stream HAS TO be given h264 as file extension"
					echo ""
					read -e -p "> " param1
				done

				# keep $param1 without parenthesis, otherwise eac3to fails while parsing the parameter
				wine ~/"$wine"/drive_c/Program\ Files/eac3to/eac3to.exe "${source0##*/}" $param1

#TODONOTE: dirty. problems when >1 h264 file
				mkvmerge -v -o "$source1" $(ls "${source0%/*}"|grep .h264)

				# get the spaces out of eac3to's log file name
				for i in ./*.txt; do mv -v "$i" $(echo $i | sed 's/ /_/g') ; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
				for file in ./*m2v ./*.mpeg* ./*.h264 ./*.dts* ./*.pcm ./*.flac ./*.ac3 ./*.aac ./*.wav ./*.w64 ./*.sup ./*.txt; do
				mv $file "${source1%/*}"/ ; done

				echo ""
				echo "you find the demuxed files in"
				echo "${source1%/*}/"
				echo ""
			else
				echo "something went wrong"
				echo ""
			fi

			if [ -e /usr/bin/beep ]; then beep $beep; fi
		;;

		r|R|remux|Remux|REMUX)

			# check source1 for file extension == mkv
			until [[ -e $source1 ]] && [[ $source1 == *.mkv ]]; do
				echo ""
				echo "set absolute path and name with .mkv file extension"
				echo ""
				read -e -p "> " source1
			done
		;;

		*)
			echo ""
			echo "neither d nor r"
			echo "exiting…"
			exit
		;;

	esac

	# source file name without file extension
	# bash parameter expansion does not allow nesting, so do it in two steps
	source2=${source1##*/}

	# if no config with encodings' name, generate it or exit
	if [[ ! -e  ${config%/*}/${source2%.*}.cfg ]]; then
		echo ""
		echo "it seems, your encoding does not have a config file yet"
		echo "do you want to generate a new one?"
		echo ""
		read -e -p "(y|n) > " answer05

		case "$answer05" in

			y|Y|yes|Yes|YES)

			echo ""
			echo "a new config file is generated:"
			echo "${config%/*}/${source2%.*}.cfg"
			cp "$config" "${config%/*}/${source2%.*}.cfg"
			echo ""
			sed -i '/source2/d' "${config%/*}/${source2%.*}.cfg"
			echo "source2=$source2" >> "${config%/*}/${source2%.*}.cfg"
			sed -i '/source1/d' "${config%/*}/${source2%.*}.cfg"
			echo "source1=$source1" >> "${config%/*}/${source2%.*}.cfg"
			echo "to make use of the corresponding config file"
			echo "from option 2 to option 8"
			echo "start the script like this:"
			echo "./wine.encode.sh ${source2%.*}"
			echo ""
			read -p "hit return to continue"
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
	else
		echo ""
		echo "from option 2 to option 8"
		echo "start the script like this:"
		echo "./wine.encode.sh ${source2%.*}"
		echo "to make use of the corresponding config file"
		echo ""
		read -p "hit return to continue"
	fi

	# get to know your DAR SAR PAR
	sarheight0=$(exiftool "$source1"|awk '/Image Height/ {print $4}')
	sarwidth0=$(exiftool "$source1"|awk '/Image Width/ {print $4}')
	darheight0=$(exiftool "$source1"|awk '/Display Height/ {print $4}')
	darwidth0=$(exiftool "$source1"|awk '/Display Width/ {print $4}')

	# keep cfg informed
	sed -i '/sarheight0/d' "${config%/*}/${source2%.*}.cfg"
	echo "sarheight0=$sarheight0" >> "${config%/*}/${source2%.*}.cfg"
	sed -i '/sarwidth0/d' "${config%/*}/${source2%.*}.cfg"
	echo "sarwidth0=$sarwidth0" >> "${config%/*}/${source2%.*}.cfg"
	sed -i '/darheight0/d' "${config%/*}/${source2%.*}.cfg"
	echo "darheight0=$darheight0" >> "${config%/*}/${source2%.*}.cfg"
	sed -i '/darwidth0/d' "${config%/*}/${source2%.*}.cfg"
	echo "darwidth0=$darwidth0" >> "${config%/*}/${source2%.*}.cfg"

	if [[ -z $sar ]]; then
		echo ""
		echo "the movies' storage aspect ratio is $sarwidth0×$sarheight0"
		echo ""
		echo "the movies' display aspect ratio is $darwidth0×$sarheight0"
		echo ""
		echo "look into the table to find your pixel aspect ratio"
		echo ""
		echo "________________SAR____|___PAR__|___DAR_____"
		echo "widescreen ntsc 720×480 -> 40:33 ->  704×480"
		echo "                        -> 32:27 ->  853×480"
		echo "widescreen pal  720×576 -> 64:45 -> 1024×576"
		echo "fullscreen ntsc 720×480 ->  8:9  ->  640×480"
		echo "fullscreen pal  720×576 -> 16:15 ->  768×576"
		echo ""
		echo "almost all bluray is 1:1"
		echo ""

		until [[ $sar = *:* ]]; do
			echo "set sar as fraction with a colon"
			echo "e.g. 16:15"
			echo ""
			read -e -p "> " sar
		done
		# keep cfg informed
		# 'sar=' instead of 'sar' to avoid deleting of sarheight0| sarwidth0
		sed -i '/sar=/d' "${config%/*}/${source2%.*}.cfg"
		echo "sar=$sar" >> "${config%/*}/${source2%.*}.cfg"
	else
		echo "sar is \"$sar\""
		echo ""
	fi

	ref0=$(echo "scale=0;32768/((("$darwidth0"/16)+0.5)/1 * (("$darheight0"/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref0/d' "${config%/*}/${source2%.*}.cfg"
	echo "ref0=$ref0" >> "${config%/*}/${source2%.*}.cfg"

	# generate a new avs file anyway
	# keep cfg informed
	sed -i '/testavs/d' "$config"
	echo "testavs=${source1%.*}.test.avs" >> "${config%/*}/${source2%.*}.cfg"
	echo "FFVideosource(\"$source1\")" > "${source1%.*}".test.avs

	echo ""
	echo "\"${source1%.*}.test.avs\""
	echo "is generated as your avs file for this encoding"

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
	read -e -p "check now? (y|n) > " answer30

	case "$answer30" in

		y|Y|yes|YES)

		wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".test.avs
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
	read -e -p "(i|t|n) > " answer40

	case "$answer40" in

		i|I) # interlaced

		echo "QTGMC().SelectEven()" >> "${source1%.*}".test.avs
		echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".test.avs
		;;

		t|T) # telecined
		echo "TFM().TDecimate()" >> "${source1%.*}".test.avs
		echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".test.avs
		;;

#		b|B) # interlaced and then telecined
#		echo "QTGMC().SelectEven()" >> "${source1%.*}".test.avs
#		echo "TFM().TDecimate()" >> "${source1%.*}".test.avs
#		echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".test.avs
#		;;

		n|N) # neither interlaced nor telecined

		echo "SelectRangeEvery($interval, $length, $offset)" >> "${source1%.*}".test.avs
		;;

		*)
		echo "that's not what was asked for"
		echo "you may try again"
		;;

	esac

	# copy content of $testavs into final.avs in same direct
	# write path to final.avs to CFG and delete line Select…
	# from final.avs
	cp "${source1%.*}".test.avs "${source1%.*}".final.avs
	# keep cfg informed
	sed -i '/^avs/d' "${config%/*}/${source2%.*}.cfg"
	echo "avs=${source1%.*}.final.avs" >> "${config%/*}/${source2%.*}.cfg"
	sleep 1
	sed -i '/SelectRangeEvery/d' "${source1%.*}".final.avs

	echo "remember:"
	echo "to make use of the corresponding config file"
	echo "from option 2 to option 8"
	echo "start the script like this:"
	echo "./wine.encode.sh ${source2%.*}"
	echo ""

	echo "you might go on with option 2"
	echo ""

	;;

	2)	# 2 - test encodes for crf

	if [[ ! -e $source1 ]]; then
	echo
	echo "it seems, you invoked the script without"
	echo "a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "better walk through option 1 again or edit"
	echo "your config file manually"
	exit
	fi

	until [[ ${crfhigh:-0} -ge ${crflow:-1} ]]; do
		echo ""
		echo "set minimum crf as integer, e.g. 15"
		echo ""
		read -e -p "crf, lowest value > " crflow

		echo ""
		echo "set maximum crf as integer, e.g. 20"
		echo ""
		read -e -p "crf, maximum value > " crfhigh
	done

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".crf.avs

	for ((crf1=$crflow; $crf1<=$crfhigh; crf1=$crf1+1));do
		echo ""
		echo "encoding ${source2%.*}.10.crf$crf1.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screen
		echo "=ffvideosource(\"${source1%.*}.10.crf$crf1.mkv\").subtitle(\"${source2%.*}.10.crf$crf1.mkv\", align=8)" >> "${source1%.*}".crf.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
		| x264 --stdin y4m \
		--crf "$crf1" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref0" \
		--sar "$sar" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--deblock "$deblock" \
		--no-psy \
		-o "${source1%.*}".10.crf$crf1.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.10.crf$crf1.mkv lasted $time"

	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for crf integers lasted $time"

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}"2.crf.avs
	done < "${source1%.*}".crf.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".crf.avs) *2 -1|bc)-154 >> "${source1%.*}"2.crf.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}"2.crf.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}"2.crf.avs
	mv "${source1%.*}"2.crf.avs "${source1%.*}".crf.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi
		
	echo ""
	echo "look at these first encodings. if you find any detail loss"
	echo "in still images, you have found your crf integer. go on"
	echo "find fractionals around this integer."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".crf.avs

	until [[ $crfhigh2 -ge $crflow2 ]] && [[ $crffractional -gt 0 ]]; do
		echo ""
		echo "set lowest crf value as hundreds,"
		echo "e.g. 168 for 16.8"
		echo ""
		read -e -p "crf > " crflow2

		echo ""
		echo "set highst crf value as hundreds,"
		echo "e.g. 176 for 17.6"
		echo ""
		read -e -p "crf > " crfhigh2

		echo ""
		echo "set fractional steps, e.g. 1 for 0.1"
		echo "≠0"
		echo ""
		read -e -p "fractionals > " crffractional
	done

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".crf2.avs

	for ((crf2=$crflow2; $crf2<=$crfhigh2; crf2+=$crffractional));do
		echo ""
		echo "encoding ${source2%.*}.20.crf$crf2.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screen
		echo "=ffvideosource(\"${source1%.*}.20.crf$crf2.mkv\").subtitle(\"${source2%.*}.20.crf$crf2.mkv\", align=8)" >> "${source1%.*}".crf2.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
		| x264 --stdin y4m \
		--crf $(printf '%s.%s' "$(($crf2/10))" "$(($crf2%10))") \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref0" \
		--sar "$sar" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--deblock "$deblock" \
		--no-psy \
		-o "${source1%.*}".20.crf$crf2.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.20.crf$crf2.mkv lasted $time"

	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for crf fractionals lasted $time"

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}"2.crf2.avs
	done < "${source1%.*}".crf2.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".crf2.avs) *2 -1|bc)-154 >> "${source1%.*}"2.crf2.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}"2.crf2.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}"2.crf2.avs
	mv "${source1%.*}"2.crf2.avs "${source1%.*}".crf2.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, which crf gave"
	echo "best results at acceptable file size."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".crf2.avs

	echo ""
	echo "set crf parameter"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " crf
	# keep cfg informed
	sed -i '/crf/d' "$config"
	echo "crf=$crf" >> "$config"

	echo ""
	echo "from here, run the script with"
	echo "option 3"
	echo ""

	;;

	3)	# 3 - test variations in qcomp

	if [[ ! -e $source1 ]]; then
	echo
	echo "please tell the script the name of a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "walk through option 1 again"
	exit
	fi

	until [[ $qcomphigh -ge $qcomplow ]] && [[ $qcompincrement -gt 0 ]]; do
		echo ""
		echo "qcomp: default is 0.60, test with values around 0.60 to 0.80"
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
		echo "set increments, e.g. 10 for 0.10"
		echo "≠0"
		echo ""
		read -e -p "increments > " qcompincrement
	done

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".qcomp.avs

	for ((qcompnumber=$qcomplow; $qcompnumber<=$qcomphigh; qcompnumber+=$qcompincrement));do
		echo ""
		echo "encoding ${source2%.*}.30.crf$crf.qc$qcompnumber.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screen
		echo "=ffvideosource(\"${source1%.*}.30.crf$crf.qc$qcompnumber.mkv\").subtitle(\"${source2%.*}.30.crf$crf.qc$qcompnumber.mkv\", align=8)" >> "${source1%.*}".qcomp.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
		| x264 --stdin y4m \
		--crf "$crf" \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--ref "$ref0" \
		--sar "$sar" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--aq-mode "$aqmode" \
		--deblock "$deblock" \
		--no-psy \
		--qcomp $(echo "scale=2;$qcompnumber/100"|bc) \
		-o "${source1%.*}".30.crf$crf.qc$qcompnumber.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.30.crf$crf.qc$qcompnumber.mkv lasted $time"

	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for qcomp lasted $time"

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".qcomp2.avs
	done < "${source1%.*}".qcomp.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".qcomp.avs) *2 -1|bc)-154 >> "${source1%.*}".qcomp2.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".qcomp2.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".qcomp2.avs
	mv "${source1%.*}".qcomp2.avs "${source1%.*}".qcomp.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, which qcomp gave"
	echo "best results."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".qcomp.avs

	echo ""
	echo "do you want to look for more subtle values in qcomp?"
	echo ""
	read -e -p "(y)es or (n)o > " answer55

	case $answer55 in
		y|Y|Yes|YES|yes)

		until [[ $qcomphigh2 -ge $qcomplow2 ]] && [[ $qcompincrement2 -gt 0 ]]; do
			echo ""
			echo "first, set lowest qcomp value"
			echo "e.g. 65 for 0.65"
			echo ""
			read -e -p "qcomp, lowest value > " qcomplow2

			echo ""
			echo "set maximum qcomp value"
			echo "e.g. 75 for 0.75"
			echo ""
			read -e -p "qcomp, maximum value > " qcomphigh2

			echo ""
			echo "set increment steps, e.g. 2 for 0.02"
			echo "≠0"
			echo ""
			read -e -p "increments > " qcompincrement2
		done

		start0=$(date +%s)

		# create comparison screen avs
		echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".qcomp2.avs

		for ((qcompnumber=$qcomplow2; $qcompnumber<=$qcomphigh2; qcompnumber+=$qcompincrement2));do
			echo ""
			echo "encoding ${source2%.*}.40.crf$crf.qc$qcompnumber.mkv"
			echo ""

			start1=$(date +%s)

			#comparison screen
			echo "=ffvideosource(\"${source1%.*}.40.crf$crf.qc$qcompnumber.mkv\").subtitle(\"${source2%.*}.40.crf$crf.qc$qcompnumber.mkv\", align=8)" >> "${source1%.*}".qcomp2.avs

			wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
			| x264 --stdin y4m \
			--crf "$crf" \
			--preset "$preset" \
			--tune "$tune" \
			--profile "$profile" \
			--ref "$ref0" \
			--sar "$sar" \
			--rc-lookahead "$lookahead" \
			--me "$me" \
			--merange "$merange" \
			--subme "$subme" \
			--aq-mode "$aqmode" \
			--deblock "$deblock" \
			--no-psy \
			--qcomp $(echo "scale=2;$qcompnumber/100"|bc) \
			-o "${source1%.*}".40.crf$crf.qc$qcompnumber.mkv -;

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${source2%.*}.40.crf$crf.qc$qcompnumber.mkv lasted $time"

		done

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
		echo "test encodings for qcomp lasted $time"

		#comparison screen
		prefixes=({a..z} {a..z}{a..z})
		i=0
		while IFS= read -r line; do
		printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".qcomp3.avs
		done < "${source1%.*}".qcomp2.avs
		echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".qcomp2.avs) *2 -1|bc)-154 >> "${source1%.*}".qcomp3.avs
		echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".qcomp3.avs
		echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".qcomp3.avs
		mv "${source1%.*}".qcomp3.avs "${source1%.*}".qcomp2.avs

		if [ -e /usr/bin/beep ]; then beep $beep; fi

		echo ""
		echo "thoroughly look through all your test"
		echo "encodings and decide, which qcomp gave"
		echo "best results."
		echo "then close AvsPmod."
		sleep 2
		wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".qcomp2.avs
		;;

		n|N|No|NO|no) # just nothing
		;;

		*) # layer 8 problem

 		echo "stupid, i take this for a no :-) "
		;;

	esac

	echo ""
	echo "set your qcomp parameter"
	echo "e.g. 0.71"
	echo ""
	read -e -p "qcomp > " qcomp

	# keep cfg informed
	sed -i '/qcomp/d' "$config"
	echo "qcomp=$qcomp" >> "$config"

	echo ""
	echo "from here, run the script with"
	echo "option 4"
	echo ""
	;;

	4)	# 4 - variations in aq strength and psy-rd

	if [[ ! -e $source1 ]]; then
	echo
	echo "please tell the script the name of a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "walk through option 1 again"
	exit
	fi

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
	echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".aqpsy.avs

	for ((aqnumber=$aqlow; $aqnumber<=$aqhigh; aqnumber+=$aqincrement));do
		for ((psy1number=$psy1low; $psy1number<=$psy1high; psy1number+=$psy1increment));do
			echo ""
			echo "encoding ${source2%.*}.50.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv"
			echo ""

			start1=$(date +%s)

			#comparison screen
			echo "=ffvideosource(\"${source1%.*}.50.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv\").subtitle(\"${source2%.*}.50.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv\", align=8)" >> "${source1%.*}".aqpsy.avs

			wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
			| x264 --stdin y4m \
			--crf "$crf" \
			--qcomp "$qcomp" \
			--preset "$preset" \
			--tune "$tune" \
			--profile "$profile" \
			--ref "$ref0" \
			--sar "$sar" \
			--rc-lookahead "$lookahead" \
			--me "$me" \
			--merange "$merange" \
			--subme "$subme" \
			--aq-mode "$aqmode" \
			--deblock "$deblock" \
			--aq-strength $(echo "scale=2;$aqnumber/100"|bc) \
			--psy-rd $(echo "scale=2;$psy1number/100"|bc):unset \
			-o "${source1%.*}".50.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv -;

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${source2%.*}.50.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv lasted $time"

		done
	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")

	echo "test encodings for aq strength and psy-rd lasted $time"

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".aqpsy2.avs
	done < "${source1%.*}".aqpsy.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".aqpsy.avs) *2 -1|bc)-154 >> "${source1%.*}".aqpsy2.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".aqpsy2.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".aqpsy2.avs
	mv "${source1%.*}".aqpsy2.avs "${source1%.*}".aqpsy.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test encodings"
	echo "and decide, which aq strength and which psy-rd"
	echo "parameters gave you best results."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".aqpsy.avs
	
	echo ""
	echo "set aq strength"
	echo "e.g. 0.85"
	echo ""
	read -e -p "aq strength > " aqs

	# keep cfg informed
	sed -i '/aqs/d' "$config"
	echo "aqs=$aqs" >> "$config"

	echo ""
	echo "set psy-rd"
	echo "e.g. 0.9"
	echo ""
	read -e -p "psy-rd > " psyrd

	# keep cfg informed
	sed -i '/psyrd/d' "$config"
	echo "psyrd=$psyrd" >> "$config"

	case $(echo "$psyrd" - 0.99999 | bc) in

		-*) # psy-rd <1 -> psytr unset
		echo "as psy-rd is set to a value <1 (or not at all)"
		echo "psy-trellis is set to \"unset\" automatically"
		echo ""
		echo "you might do further testing with"
		echo "option 6 (some more less common tests) or"
		echo "go on with option 7 (a last round for crf)"
		echo ""
		;;

		*) # psyrd >= 1
		echo "you might test for psy-trellis"
		echo "with option 5,"
		echo "do further testing with option 6"
		echo "(some more less common tests) or"
		echo "go on with option 7 (a last round for crf)"
		echo ""
		;;
	esac

		# keep cfg informed
		sed -i '/psytr/d' "$config"
		echo "psytr=unset" >> "$config"
	;;
	
	5)	# 5 - variations in psy-trellis

	if [[ ! -e $source1 ]]; then
	echo
	echo "please tell the script the name of a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "walk through option 1 again"
	exit
	fi

	case $(echo "$psyrd" - 0.99999 | bc) in

		-*) # psy-rd <1 -> psytr unset
		echo "as psy-rd is set to a value < 1 (or not at all)"
		echo "psy-trellis is set to \"unset\" automatically"
		echo ""

		# keep cfg informed
		sed -i '/psytr/d' "$config"
		echo "psytr=unset" >> "$config"
		;;

		*) # psyrd >= 1
		echo "as psy-rd is set to ≥1"
		echo "you may (t)est for psy-trellis"
		echo "or (u)nset psy-trellis"
		echo ""
		read -e -p "(t|u) > " answer60

			case $answer60 in

			t|T) # test for psy-trellis

			until [[ $psy2high -ge $psy2low ]] && [[ $psy2increment -gt 0 ]]; do
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
			echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".psytr.avs

			for ((psy2number=$psy2low; $psy2number<=$psy2high; psy2number+=$psy2increment));do
				echo ""
				echo "encoding ${source2%.*}.60.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv"
				echo ""

				start1=$(date +%s)

				#comparison screen
				echo "=ffvideosource(\"${source1%.*}.60.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv\").subtitle(\"${source2%.*}.60.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv\", align=8)" >> "${source1%.*}".psytr.avs

				wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
				| x264 --stdin y4m \
				--crf "$crf" \
				--qcomp "$qcomp" \
				--aq-strength "$aqs" \
				--preset "$preset" \
				--tune "$tune" \
				--profile "$profile" \
				--ref "$ref0" \
				--sar "$sar" \
				--rc-lookahead "$lookahead" \
				--me "$me" \
				--merange "$merange" \
				--subme "$subme" \
				--aq-mode "$aqmode" \
				--deblock "$deblock" \
				--psy-rd "$psyrd":$(echo "scale=2;$psy2number/100"|bc) \
				-o "${source1%.*}".60.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv -;

				stop=$(date +%s);
				time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
				echo "encoding ${source2%.*}.60.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv lasted $time"

			done

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
			echo "test encodings for psy-trellis lasted $time"

			#comparison screen
			prefixes=({a..z} {a..z}{a..z})
			i=0
			while IFS= read -r line; do
			printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}"2.psytr.avs
			done < "${source1%.*}".psytr.avs
			echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".psytr.avs) *2 -1|bc)-154 >> "${source1%.*}"2.psytr.avs
			echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}"2.psytr.avs
			echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}"2.psytr.avs
			mv "${source1%.*}"2.psytr.avs "${source1%.*}".psytr.avs

			if [ -e /usr/bin/beep ]; then beep $beep; fi

			echo ""
			echo "thoroughly look through this last test encodings and"
			echo "decide, which one is your best encode."
			echo "then close AvsPmod."
			sleep 2
			wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".psytr.avs

			echo ""
			echo "set psy-trellis"
			echo "e.g. 0.05"
			echo ""
			read -e -p "psy-trellis > " psytr

			# keep cfg informed
			sed -i '/psytr/d' "$config"
			echo "psytr=$psytr" >> "$config"
			;;

			u|U) # unset psy-trellis

			echo "psy trellis now is set to \"unset\"."
			echo ""

			# keep cfg informed
			sed -i '/psytr/d' "$config"
			echo "psytr=unset" >> "$config"
			echo ""
			;;

			*) # neither any of the above

			echo "that's neither \"t\" nor \"u\" :-) "
			echo "psy trellis is set to \"unset\"."
			echo ""

			# keep cfg informed
			sed -i '/psytr/d' "$config"
			echo "psytr=unset" >> "$config"
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
	echo
	echo "please tell the script the name of a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "walk through option 1 again"
	exit
	fi

	echo "what do you want to test?"
	echo ""
	echo "(c)hroma-qp-offset with a sensible range -2 - 2"
	echo "(n)othing right now"
	echo "(d)on't know yet"
	read -e -p "(c|n|d) > " answer65

	case $answer65 in

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
			echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".cqpo.avs

			for ((cqponumber=$cqpolow; $cqponumber<=$cqpohigh; cqponumber=$cqponumber+1));do
				echo ""
				echo "encoding ${source2%.*}.70.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqponumber.mkv"
				echo ""

				start1=$(date +%s)

				#comparison screen
				echo "=ffvideosource(\"${source1%.*}.70.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqponumber.mkv\").subtitle(\"${source2%.*}.70.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqponumber.mkv\", align=8)" >> "${source1%.*}".cqpo.avs

				wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
				| x264 --stdin y4m \
				--crf "$crf" \
				--qcomp "$qcomp" \
				--aq-strength "$aqs" \
				--preset "$preset" \
				--tune "$tune" \
				--profile "$profile" \
				--ref "$ref0" \
				--sar "$sar" \
				--rc-lookahead "$lookahead" \
				--me "$me" \
				--merange "$merange" \
				--subme "$subme" \
				--aq-mode "$aqmode" \
				--deblock "$deblock" \
				--psy-rd "$psyrd":"$psytr" \
				--chroma-qp-offset "$cqponumber" \
				-o "${source1%.*}".70.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqponumber.mkv -;

				stop=$(date +%s);
				time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
				echo "encoding ${source2%.*}.70.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqponumber.mkv lasted $time"

			done

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
			echo "test encodings for chroma-qp-offset lasted $time"
			#comparison screen
			prefixes=({a..z} {a..z}{a..z})
			i=0
			while IFS= read -r line; do
			printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}"2.cqpo.avs
			done < "${source1%.*}".cqpo.avs
			echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".cqpo.avs) *2 -1|bc)-154 >> "${source1%.*}"2.cqpo.avs
			echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}"2.cqpo.avs
			echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}"2.cqpo.avs
			mv "${source1%.*}"2.cqpo.avs "${source1%.*}".cqpo.avs

			if [ -e /usr/bin/beep ]; then beep $beep; fi

			echo ""
			echo "thoroughly look through this last test encodings and"
			echo "decide, which one is your best encode."			
			echo "then close AvsPmod."
			sleep 2
			wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".cqpo.avs

			echo ""
			echo "set chroma-qp-offset"
			echo "e.g. 1"
			echo ""
			read -e -p "chroma-qp-offset > " cqpo

			# keep cfg informed
			sed -i '/cqpo/d' "$config"
			echo "cqpo=$cqpo" >> "$config"
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
	echo
	echo "please tell the script the name of a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "walk through option 1 again"
	exit
	fi

	until 	[[ $crfhigh2 -ge $crflow2 ]] && [[ $crffractional2 -gt 0 ]]; do
		echo ""
		echo "after all that optimization, you may test for"
		echo "a new, probably more bitsaving value"
		echo ""
		echo "so far you tested with a crf of $crf"
		echo ""
		echo "once again, try a range of crf fractionals"
		echo "set lowest crf value as hundreds,"
		echo "e.g. 168 for 16.8"
		echo ""
		read -e -p "crf, lowest value > " crflow2

		echo ""
		echo "set highst crf value as hundreds,"
		echo "e.g. 172 for 17.2"
		echo ""
		read -e -p "crf, maximum value > " crfhigh2

		echo ""
		echo "set fractional steps, e.g. 1 for 0.1"
		echo "≠0"
		echo ""
		read -e -p "fractionals > " crffractional2
	done

	start0=$(date +%s)

	# create comparison screen avs
	echo "=import(\"$testavs\").subtitle(\"Source\", align=8)" > "${source1%.*}".finalcrf.avs

	for ((crfnumber2=$crflow2; $crfnumber2<=$crfhigh2; crfnumber2+=$crffractional2));do
		echo ""
		echo "encoding ${source2%.*}.80.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqpo.crf$crfnumber2.mkv"
		echo ""

		start1=$(date +%s)

		#comparison screen
		echo "=ffvideosource(\"${source1%.*}.80.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqpo.crf$crfnumber2.mkv\").subtitle(\"${source2%.*}.80.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqpo.crf$crfnumber2.mkv\", align=8)" >> "${source1%.*}".finalcrf.avs

		wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$testavs" - \
		| x264 --stdin y4m \
		--qcomp "$qcomp" \
		--aq-strength "$aqs" \
		--psy-rd "$psyrd":"$psytr": \
		--preset "$preset" \
		--tune "$tune" \
		--profile "$profile" \
		--sar "$sar" \
		--ref "$ref0" \
		--rc-lookahead "$lookahead" \
		--me "$me" \
		--merange "$merange" \
		--subme "$subme" \
		--deblock "$deblock" \
		--chroma-qp-offset "$cqpo" \
		--crf $(echo "scale=1;$crfnumber2/10"|bc) \
		-o "${source1%.*}".80.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqpo.crf$crfnumber2.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${source2%.*}.80.qc$qcomp.aq$aqs.psy$psyrd.$psytr.cqpo$cqpo.crf$crfnumber2.mkv lasted $time"

	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for a second round of crf lasted $time"

	#comparison screen
	prefixes=({a..z} {a..z}{a..z})
	i=0
	while IFS= read -r line; do
	printf "%s %s\n" "${prefixes[i++]}" "$line" >> "${source1%.*}".finalcrf2.avs
	done < "${source1%.*}".finalcrf.avs
	echo "interleave(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q,a,r,a,s,a,t,a,u,a,v,a,w,a,x,a,y,a,z,a,aa,a,ab,a,ac,a,ad,a,ae,a,af,a,ag,a,ah,a,ai,a,aj,a,ak,a,al,a,am,a,an,a,ao,a,ap,a,aq,a,ar,a,as,a,at,a,au,a,av,a,aw,a,ax,a,ay,a,az,a,ba,a,bb,a,bc,a,bd,a,be,a,bf,a,bg,a,bh,a,bi,a,bj,a,bk,a,bl,a,bm,a,bn,a,bo,a,bp,a,bq,a,br,a,bs,a,bt,a,bu,a,bv,a,bw,a,bx,a,by,a,bz,a)"|cut -d ',' --complement -f $(echo $(wc -l < "${source1%.*}".finalcrf.avs) *2 -1|bc)-154 >> "${source1%.*}".finalcrf2.avs
	echo "spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)" >> "${source1%.*}".finalcrf2.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".finalcrf2.avs
	mv "${source1%.*}".finalcrf2.avs "${source1%.*}".finalcrf.avs

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, with which crf you"
	echo "get best results at considerable bitrate."
	echo "then close AvsPmod."
	sleep 2
	wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "${source1%.*}".finalcrf.avs

	echo ""
	echo "set crf parameter"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " crf

	# keep cfg informed
	sed -i '/crf/d' "$config"
	echo "crf=$crf" >> "$config"

	echo ""
	echo "now you may run the script"
	echo "to encode the whole movie with"
	echo "option 8"
	echo ""

	;;

	8)	# 8 - encode the whole movie

	if [[ ! -e $source1 ]]; then
	echo
	echo "please tell the script the name of a valid config file:"
	echo "./wine.encode.sh <name.of.config.file.without.extension>"
	echo "walk through option 1 again"
	exit
	fi

	# video filter cropping
#TODONOTE: find a way to get all the numbers in one step

	function cropping {

			echo ""
			echo "if cropping is needed, check with"
			echo "AvsP > Video > Crop editor"
			echo "when checked, note values and close AvsPmod window"
			echo "do NOT hit »apply«"
			read -e -p "check now (y|n) > " answer65

			case "$answer65" in

				y|Y|yes|YES)

				wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "$avs"
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
			sed -i '/left/d' "$config"
			echo "left=$left" >> "$config"

			echo ""
			echo "number of pixels to be cropped on the"
			echo ""
			read -e -p "top > " top
			# keep cfg informed
			sed -i '/top/d' "$config"
			echo "top=$top" >> "$config"

			echo ""
			echo "number of pixels to be cropped on the"
			echo ""
			read -e -p "right > " right
			# keep cfg informed
			sed -i '/right/d' "$config"
			echo "right=$right" >> "$config"

			echo ""
			echo "number of pixels to be cropped on the"
			echo ""
			read -e -p "bottom > " bottom
			# keep cfg informed
			sed -i '/bottom/d' "$config"
			echo "bottom=$bottom" >> "$config"
			}

	if [[ ( -n $left && -n $right && -n $top && -n $bottom ) ]]; then
		echo ""
		echo "your config file"
		echo "$config"
		echo "has got some cropping values:"
		echo "left:  \"$left\""
		echo "top:   \"$top\""
		echo "right: \"$right\""
		echo "bottom:\"$bottom\""
		echo ""
		echo "are you (o)kay with that or"
		echo "do you want to (e)dit them?"
		read -e -p "(o|e) > " answer67

		case $answer67 in

			o|O|ok|okay|OK|Ok)
			# do nothing here
			;;

			e|E|edit|EDIT|Edit)
			cropping
			;;

			*)
			echo "that's neither \"edit\" nor \"ok\""
			echo "i take this for a \"ok\""
			;;
		esac
	else
		cropping
	fi

	# resizing hd sources
	if [[ $sarheight0 -gt 576 ]] && [[ $sarwidth0 -gt 720 ]]; then
	echo ""
	echo "if you want to resize, better check"
	echo "for correct target resolution!"
	echo ""
	echo "do you want to check with AvsPmod for correct"
	echo "target file resolution?"
	echo "AvsP > Tools > Resize calculator"
	echo "remember, the original video resolution is $darwidth0×$darheight0,"
	echo "the sar is $sar"
	echo "when checked, note values and close AvsPmod window"
	echo "do NOT hit »apply«"
	read -e -p "check now (y|n) > " answer70

	case "$answer70" in

		y|Y|yes|YES)

		wine ~/"$wine"/drive_c/Program\ Files/AvsPmod/AvsPmod.exe "$avs"
		;;

		n|N|no|NO)
		;;

		*)

		echo "that's neither yes or no :-)"
		echo "i take this for a no"
		;;

	esac
	fi

	# each encoding command a function
	function targetresolutionSD {
	if [[ -e $width5 && -e $height5 ]]; then
	echo "final resolution for SD encoding is $width5×$height5"
	echo "do you want to change the values?"
	read -e -p "(y|n) > " answer75

		case $answer75 in
			y|Y|yes|YES|Yes)

			echo ""
			echo "set final height for SD"
			echo ""
			read -e -p "height > " height5

			sed -i '/height5/d' "$config"
			echo "height5=$height5" >> "$config"

			echo ""
			echo "set final width for SD"
			echo ""
			read -e -p "width > " width5

			sed -i '/width5/d' "$config"
			echo "width5=$width5" >> "$config"
			;;

			n|N|no|NO|No)

			;;

			*)

			echo "i take this for a no"
			;;
		esac
	else
		echo ""
		echo "set final height for SD"
		echo ""
		read -e -p "height > " height5

		sed -i '/height5/d' "$config"
		echo "height5=$height5" >> "$config"

		echo ""
		echo "set final width for SD"
		echo ""
		read -e -p "width > " width5

		sed -i '/width5/d' "$config"
		echo "width5=$width5" >> "$config"
	fi
	}

	function targetresolution720 {
	if [[ -e $width7 && -e $height7 ]]; then
	echo "final resolution for 720p encoding is $width7×$height7"
	echo "do you want to change the values?"
	read -e -p "(y|n) > " answer77

		case $answer77 in
			y|Y|yes|YES|Yes)

			echo ""
			echo "set final height for 720p"
			echo ""
			read -e -p "height > " height7

			sed -i '/height7/d' "$config"
			echo "height7=$height7" >> "$config"

			echo ""
			echo "set final width for 720p"
			echo ""
			read -e -p "width > " width7

			sed -i '/width7/d' "$config"
			echo "width7=$width7" >> "$config"
			;;

			n|N|no|NO|No)

			;;

			*)

			echo "i take this for a no"
			;;
		esac
	else
		echo ""
		echo "set final height for 720p"
		echo ""
		read -e -p "height > " height7

		sed -i '/height7/d' "$config"
		echo "height7=$height7" >> "$config"

		echo ""
		echo "set final width for 720p"
		echo ""
		read -e -p "width > " width7

		sed -i '/width7/d' "$config"
		echo "width7=$width7" >> "$config"
	fi
	}

	function encodeSDfromSD {
	sarwidth1=$(echo "$sarwidth0-$left-$right"|bc)
	sarheight1=$(echo "$sarheight0-$top-$bottom"|bc)
	echo ""
	echo "now encoding ${source2%.*}.SD.mkv"
	echo "with a resolution of $sarwidth1×$sarheight1 and a sar of $sar…"
	echo ""

	# Get reframes for SD
	# though --preset Placebo sets reframes to 16, but
	# 1- that may set level ≥ 4.1
	# 2- cropping may change reframes value
	ref5=$(echo "scale=0;32768/((("$sarwidth1"/16)+0.5)/1 * (("$sarheight1"/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref5/d' "$config"
	echo "ref5=$ref5" >> "$config"

	start=$(date +%s)

	# create comparison screen avs
	echo "a=import(\"$avs\").Crop("$left", "$top", -"$right", -"$bottom").subtitle(\"Source\", align=8)" > "${source1%.*}".comparison.SD.avs
	echo "b=ffvideosource(\"${source1%.*}.SD.mkv\").subtitle(\"${source2%.*}.SD.mkv\", align=8)" >> "${source1%.*}".comparison.SD.avs
	echo "interleave(a,b)" >> "${source1%.*}".comparison.SD.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.SD.avs

	wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$avs" - \
	| x264 --stdin y4m \
	--crf "$crf" \
	--sar "$sar" \
	--ref "$ref5" \
	--qcomp "$qcomp" \
	--aq-strength "$aqs" \
	--psy-rd "$psyrd":"$psytr": \
	--preset "$preset" \
	--tune "$tune" \
	--profile "$profile" \
	--rc-lookahead "$lookahead" \
	--me "$me" \
	--merange "$merange" \
	--subme "$subme" \
	--aq-mode "$aqmode" \
	--deblock "$deblock" \
	--chroma-qp-offset "$cqpo" \
	--vf crop:"$left","$top","$right","$bottom" \
	-o "${source1%.*}".SD.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${source2%.*}.SD.mkv"
	echo "with $sarwidth1×$sarheight1 lasted $time"
	}

	function encodeSDfromHD {
	echo ""
	echo "now encoding ${source2%.*}.SD.mkv"
	echo "with a resolution of $width5×$height5…"
	echo ""

	# Get reframes for SD
	# though --preset Placebo sets reframes to 16, but
	# 1- that may set level ≥ 4.1
	# 2- cropping may change reframes value
	ref5=$(echo "scale=0;32768/((("$width5"/16)+0.5)/1 * (("$height5"/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref5/d' "$config"
	echo "ref5=$ref5" >> "$config"

	start=$(date +%s)

	# create comparison screen avs
	echo "a=import(\"$avs\").Crop("$left", "$top", -"$right", -"$bottom").Spline36Resize("$width5","$height5").subtitle(\"Source\", align=8)" > "${source1%.*}".comparison.SD.avs
	echo "b=ffvideosource(\"${source1%.*}.SD.mkv\").subtitle(\"${source2%.*}.SD.mkv\", align=8)" >> "${source1%.*}".comparison.SD.avs
	echo "interleave(a,b)" >> "${source1%.*}".comparison.SD.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.SD.avs

	wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$avs" - \
	| x264 --stdin y4m \
	--crf "$crf" \
	--sar "$sar" \
	--ref "$ref5" \
	--qcomp "$qcomp" \
	--aq-strength "$aqs" \
	--psy-rd "$psyrd":"$psytr": \
	--preset "$preset" \
	--tune "$tune" \
	--profile "$profile" \
	--rc-lookahead "$lookahead" \
	--me "$me" \
	--merange "$merange" \
	--subme "$subme" \
	--aq-mode "$aqmode" \
	--deblock "$deblock" \
	--chroma-qp-offset "$cqpo" \
	--vf crop:"$left","$top","$right","$bottom"/resize:"$width5","$height5" \
	-o "${source1%.*}".SD.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${source2%.*}.SD.mkv"
	echo "with $width5×$height5 lasted $time"
	}

	function encode720 {
	echo ""
	echo "now encoding ${source2%.*}.720.mkv"
	echo "with $width7×$height7…"
	echo ""

	# Get reframes for 720p
	ref7=$(echo "scale=0;32768/((("$width7"/16)+0.5)/1 * (("$height7"/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref7/d' "$config"
	echo "ref7=$ref7" >> "$config"

	start=$(date +%s)

	# create comparison screen avs
	echo "a=import(\"$testavs\").Crop("$left", "$top", -"$right", -"$bottom").Spline36Resize("$width7","$height7").subtitle(\"Source\", align=8)" > "${source1%.*}".comparison.720.avs
	echo "b=ffvideosource(\"${source1%.*}.720.mkv\").subtitle(\"${source2%.*}.720.mkv\", align=8)" >> "${source1%.*}".comparison.720.avs
	echo "interleave(a,b)" >> "${source1%.*}".comparison.720.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.720.avs

	wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$avs" - \
	| x264 --stdin y4m \
	--crf "$crf" \
	--qcomp "$qcomp" \
	--aq-strength "$aqs" \
	--psy-rd "$psyrd":"$psytr": \
	--preset "$preset" \
	--tune "$tune" \
	--profile "$profile" \
	--ref "$ref7" \
	--rc-lookahead "$lookahead" \
	--me "$me" \
	--merange "$merange" \
	--subme "$subme" \
	--aq-mode "$aqmode" \
	--deblock "$deblock" \
	--chroma-qp-offset "$cqpo" \
	--vf crop:"$left","$top","$right","$bottom"/resize:"$width7","$height7" \
	-o "${source1%.*}".720.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${source2%.*}.720.mkv"
	echo "with $width7×$height7 lasted $time"
	}

	function encode1080 {
	# Get reframes for 1080
	darwidth1=$(echo "$darwidth0-$left-$right"|bc)
	darheight1=$(echo "$darheight0-$top-$bottom"|bc)
	ref1=$(echo "scale=0;32768/((("$darwidth1"/16)+0.5)/1 * (("$darheight1"/16)+0.5)/1)"|bc)

	# keep cfg informed
	sed -i '/ref1/d' "$config"
	echo "ref1=$ref1" >> "$config"

	echo ""
	echo "now encoding ${source2%.*}.1080.mkv"
	echo "with $darwidth1×$darheight1…"
	echo ""

	start=$(date +%s)

	# create comparison screen avs
	echo "a=import(\"$testavs\").Crop("$left", "$top", -"$right", -"$bottom").Spline36Resize("$darwidth1","$darheight1").subtitle(\"Source\", align=8)" > "${source1%.*}".comparison.1080.avs
	echo "b=ffvideosource(\"${source1%.*}.1080.mkv\").subtitle(\"${source2%.*}.1080.mkv\", align=8)" >> "${source1%.*}".comparison.1080.avs
	echo "interleave(a,b)" >> "${source1%.*}".comparison.1080.avs
	echo "ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)" >> "${source1%.*}".comparison.1080.avs
	wine ~/"$wine"/drive_c/Program\ Files/avs2yuv/avs2yuv.exe "$avs" - \
	| x264 --stdin y4m \
	--crf "$crf" \
	--sar "$sar" \
	--qcomp "$qcomp" \
	--aq-strength "$aqs" \
	--psy-rd "$psyrd":"$psytr": \
	--preset "$preset" \
	--tune "$tune" \
	--profile "$profile" \
	--ref "$ref1" \
	--rc-lookahead "$lookahead" \
	--me "$me" \
	--merange "$merange" \
	--subme "$subme" \
	--aq-mode "$aqmode" \
	--deblock "$deblock" \
	--chroma-qp-offset "$cqpo" \
	--vf crop:"$left","$top","$right","$bottom" \
	-o "${source1%.*}".1080.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${source2%.*}.1080.mkv"
	echo "with $darwidth1×$darheight1 lasted $time"

	echo "encoding for ${source2%.*}.1080.mkv lasted $time"
	}

	function beep {
	if [ -e /usr/bin/beep ]; then beep $beep; fi
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

	echo ""
	echo "for encoding with or without resizing"
	echo "set your target resolutions: (S)D, (7)20p or (1)080p"
	echo "a subset of them or (a)ll three"
	echo ""
	echo "(S|7|1|a)"
	read -e -p "> " answer80

	case "$answer80" in

	1|10|108|1080|1080p|"")
	encode1080
	beep
	comparison1080
	;;

	7|72|720|720p)
	targetresolution720
	encode720
	beep
	comparison720
	;;

	s|S|sd|SD)

	if [[ $sarheight0 -le 576 ]] && [[ $sarwidth0 -le 720 ]]; then
		encodeSDfromSD
	else
		targetresolutionSD
		encodeSDfromHD
	fi
	beep
	comparisonSD
	;;

	1S|1s|s1|S1)
	targetresolutionSD
	encodeSDfromHD
	encode1080
	beep
	comparisonSD
	comparison1080
	;;

	7S|7s|s7|S7)
	targetresolutionSD
	targetresolution720
	encodeSDfromHD
	encode720
	beep
	comparisonSD
	comparison720
	;;

	17|71)
	targetresolution720
	encode720
	encode1080
	beep
	comparison720
	comparison1080
	;;

	a|A|s17|s71|1s7|17s|7s1|71s|S17|S71|1S7|17S|7S1|71S)

	echo ""
	echo "encoding in all three resolutions"
	echo "THAT will last long!"
	echo ""
	targetresolutionSD
	targetresolution720
	encodeSDfromHD
	encode720
	encode1080
	beep
	comparisonSD
	comparison720
	comparison1080
	;;

	esac
	;;

	*)	# neither any of the above

	echo ""
	echo "well, that's not a number between 0 and 8 :-) "
	exit

	;;

esac
exit