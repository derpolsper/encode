#!/bin/bash

# During the years, much great software for advanced video encoding has been
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
# around by taking either the mpeg2 or h264 stream. Though technically not
# necessary, we mux them into a matroska container.

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
# take comparison screenshots
# mux anything together
# 

# There are several steps to go on your way to an optimal encoding:
# 0 - check, if all necessary programs are installed and show your default
#     settings
# 1 - VOB|m2ts -> mpeg2|h264 -> mkv
# 2 - suitable crf
# 3 - suitable fractionals of crf
# 4 - qcomp
# 5 - aq strength and and psy-rd
# 6 - psy-trellis
# 7 - another round of crf
# 8 - encoding the whole movie


# Credits to dozens of contributors at stackoverflow.com
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
#CONFIG="${HOME}/.config/wine.encode.cfg"
CONFIG="${HOME}/.config/wine.encode.cfg"

while IFS='= ' read lhs rhs
do
    if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"		# delete in line right comments
        rhs="${rhs%"${rhs##*[^ ]}"}"	# delete trailing spaces
        rhs="${rhs%\"*}"		# delete opening string quotes
        rhs="${rhs#\"*}"		# delete closing string quotes
        declare $lhs="$rhs"
    fi
done < $CONFIG


echo ""
echo "what do you want to do?"
echo ""
echo "0 - check for necessary programs and"
echo "    show your default settings"
echo ""
echo "1 - rip your m2ts/ VOB files into a matroska container"
echo ""
echo "2 - create your .avs and do first test encodes with crf integers"
echo ""
echo "3 - a second round for fractionals of crf"
echo ""
echo "4 - variations in qcomp"
echo ""
echo "5 - variations in aq strength and psy-rd"
echo ""
echo "6 - variations in psy-trellis"
echo ""
echo "7 - another round of crf"
echo ""
echo "8 - encode the whole movie"
echo ""
read -p "> " ANSWER10

case "$ANSWER10" in

	0)	# installed programs - default settings
	
	# x264, avconv/ffmpeg, mkvmerge, mediainfo, wine, eac3to, AviSynth,
	# AvsPmod, avs2yuv, Haali MatroskaSplitter, beep

	#clear terminal
	clear

	echo ""
	echo "*** check for required programs ***"
	echo ""

	if [ -e /usr/bin/x264 ]
		then /usr/bin/x264 -V |grep x264 -m 1 ; echo ""
		else echo ""
		echo "***"
		echo "*** x264 NOT installed!"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/mkvmerge ]
		then /usr/bin/mkvmerge -V; echo ""
		else echo ""
		echo "***"
		echo "*** mkvmerge NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/mediainfo ]
		then /usr/bin/mediainfo --Version; echo ""
		else echo ""
		echo "***"
		echo "*** mediainfo NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e /usr/bin/wine ]
		then /usr/bin/wine --version; echo ""
		else echo ""
		echo "***"
		echo "*** wine NOT installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$WINE/drive_c/Program\ Files/eac3to/eac3to.exe ]
		then wine ~/$WINE/drive_c/Program\ Files/eac3to/eac3to.exe|grep 'eac3to v'; echo ""
		else echo ""
		echo "***"
		echo "*** eac3to seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$WINE/drive_c/windows/system32/avisynth.dll ]
		then echo "avisynth seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** avisynth seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$WINE/drive_c/Program\ Files/AvsPmod/AvsPmod.exe ]
		then echo "AvsPmod seems to be installed"
		echo ""
		else echo ""
		echo "***"
		echo "*** AvsPmod seems not to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe ]
		then echo "avs2yuv seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** avs2yuv seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$WINE/drive_c/Program\ Files/Haali/MatroskaSplitter/uninstall.exe ]
# TODONOTE: where and what to  search for?
		then echo "MatroskaSplitter seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** MatroskaSplitter seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ ! -e /usr/bin/beep ]
		then echo ""
		echo "***"
		echo "*** info: beep not installed"
		echo "***"
	fi

# TODONOTE: what else is necessary?

	echo ""
	read -p "press enter to continue"

	#clear terminal
	clear

	echo ""
	echo "*** these are default encode settings ***"
	echo ""
	echo -e "TUNE:\t\t "$TUNE
	echo -e "PROFILE:\t "$PROFILE
	echo -e "PRESET:\t\t "$PRESET
	echo ""
	echo -e "*** more specific settings ***"
	echo ""
	echo -e "ME:\t\t "$ME
	echo -e "MERANGE:\t "$MERANGE
	echo -e "SUBME:\t\t "$SUBME
	echo -e "AQMODE:\t\t "$AQMODE
	echo -e "DEBLOCK:\t "$DEBLOCK
	echo -e "LOOKAHEAD:\t "$LOOKAHEAD
	echo ""
	echo "please note, parameters for REF are"
	echo "calculated from source file"
	echo ""
	echo "if you want to adjust them to your needs,"
	echo "stop the script (hit return), edit the"
	echo "wine.encode.cfg and begin again."
	echo ""
	read -p "press enter to continue"
	;;

	1)	# 1 - copy your m2ts/ VOB files into a h264/ mpeg2 file
		# locate the desired m2ts-file in STREAM directory or
		# locate the desired group of VOB files
	echo ""
	echo "we start from a de- or unencrypted"
	echo "dvd or bluray directory"
	echo ""
	echo "set path to your VIDEO_TS directory or"
	echo "to your m2ts file respectively"
	echo ""
	read -e -p "> " SOURCE0

# TODONOTE dirty: if dir then dvd, if file then bluray
	if [ -d $SOURCE0 ];
	then

		cd $SOURCE0
		echo "choose out of these VOB containers:"
		echo ""
		ls -l $SOURCE0|grep VOB$ |grep -v _0.VOB|grep -v VIDEO|awk '{print $9, $5}'
		echo ""
		echo "which group(s) of VOB containers do you"
		echo "want to encode? add them like this:"
		echo "VTS_02_1.VOB+VTS_02_2.VOB+VTS_02_3.VOB(+…)"
		echo ""
		read -e -p "> " PARAM0

		wine ~/$WINE/drive_c/Program\ Files/eac3to/eac3to.exe $PARAM0

		echo ""
		echo "extract all wanted tracks following this name pattern:"
		echo "[1-n]:name.extension, e.g. 2:name.h264 3:name.flac 4:name.ac3 5:name.sup etc"
		echo "the video stream MUST be given mpeg2 as file extension"
		echo ""
		read -e -p "> " PARAM1

		wine ~/$WINE/drive_c/Program\ Files/eac3to/eac3to.exe $PARAM0 $PARAM1

		echo ""
		echo "where you want to place the demuxed file?"
		echo "absolute path and name with file extension"
		echo ""
		read -e -p "> " SOURCE

		# keep cfg informed
		sed -i '/SOURCE/d' $CONFIG
		echo "SOURCE=$SOURCE" >> $CONFIG

#TODONOTE dirty. problems when >1 mpeg2 file
		mkvmerge -v -o $SOURCE $(ls $SOURCE0|grep .mpeg2)

		# eac3to's Log file names contain spaces
		for i in *.txt; do mv -v "$i" $(echo $i | sed 's/ /_/g') &>/dev/null; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in *.mpeg* *.h264 *.dts* *.pcm *.flac *.ac3 *.aac *.wav *.w64 *.sup *.txt; do mv $file ${SOURCE%/*}/ &>/dev/null; done

		echo ""
		echo "you find the demuxed files in"
		echo "${SOURCE%/*}"
		echo ""

	elif [ -f $SOURCE0 ];
	then

		cd ${SOURCE0%/*}

		wine ~/$WINE/drive_c/Program\ Files/eac3to/eac3to.exe ${SOURCE0##*/}

		echo ""
		echo "extract all wanted tracks following this name pattern:"
		echo "[1-n]:name.extension, e.g. 2:name.h264 3:name.flac 4:name.ac3 5:name.sup etc"
		echo "the video stream MUST be given h264 as file extension"
		echo ""
		read -e -p "> " PARAM1

		wine ~/$WINE/drive_c/Program\ Files/eac3to/eac3to.exe ${SOURCE0##*/} $PARAM1

		echo ""
		echo "where you want to place the demuxed file?"
		echo "absolute path and name with file extension"
		echo ""
		read -e -p "> " SOURCE

		# keep cfg informed
		sed -i '/SOURCE/d' $CONFIG
		echo "SOURCE=$SOURCE" >> $CONFIG

		
#TODONOTE: dirty. problems when >1 h264 file
		mkvmerge -v -o $SOURCE $(ls ${SOURCE0%/*}|grep .h264)

		# eac3to's Log file names contain spaces
		for i in *.txt; do mv -v "$i" $(echo $i | sed 's/ /_/g') &>/dev/null; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in *.mpeg* *.h264 *.dts* *.pcm *.flac *.ac3 *.aac *.wav *.w64 *.sup *.txt; do mv $file ${SOURCE%/*}/ &>/dev/null; done

		echo ""
		echo "you find the demuxed files in"
		echo "${SOURCE%/*}"
		echo ""

	else
		echo "something went wrong"
		echo ""

	fi

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi
	;;

	2)	# 2 - create a avs file for first test and test encode with suitable integer crf

	echo ""
	echo "your movie source is"
	echo "$SOURCE, right?"

	echo ""
	echo "do you have a suitable test avs file already? (y|n)"
	read -e -p "> " ANSWER20
	echo ""

	case "$ANSWER20" in

		y|Y|yes|YES) # do nothing

		echo ""
		echo "full path to your test avs file with .avs file extension"
		echo ""
		read -e -p "> " TESTAVS

		# keep cfg informed
		sed -i '/TESTAVS/d' $CONFIG
		echo "TESTAVS=$TESTAVS" >> $CONFIG
		;;

		n|N|No|NO) # write a .avs

		echo ""
		echo "create your test avs file"
		echo "full path to your test avs file with .avs file extension"
		echo ""
		read -e -p "> " TESTAVS

		# keep cfg informed
		sed -i '/TESTAVS/d' $CONFIG
		echo "TESTAVS=$TESTAVS" >> $CONFIG

		echo "FFVideoSource(\"$SOURCE\")" > $TESTAVS

		echo ""
		echo "check, if your movie is interlaced"
		echo ""
		echo "mediainfo says:"

		mediainfo $SOURCE|grep 'Scan type'|awk '{print $4}'

		echo ""
		read -p "press enter to continue"

		echo ""
		echo "do you want to check with AvsPmod frame by frame,"
		echo "if your movie is interlaced and/or telecined?"
		echo "after this, close AvsPmod window"
		echo ""
		read -e -p "check now? (y|n) > " ANSWER30

		case "$ANSWER30" in

			y|Y|yes|YES)

			wine ~/$WINE/drive_c/Program\ Files/AvsPmod/AvsPmod.exe $TESTAVS

			;;

			n|N|no|NO)

			;;
		esac

		echo ""
		echo "qualities of your video source:"
		echo "(i)nterlaced? (t)elecined? (b)oth? (n)either nor?"
		echo ""
		read -e -p "> " ANSWER40

		case "$ANSWER40" in

			i|I) # interlaced

			echo "QTGMC().SelectEven()" >> $TESTAVS
			echo "SelectRangeEvery(20000, 500, 10000)" >> $TESTAVS

			;;

			t|T) # telecined
# TODONOTE: how to integrate de-telecine?
			echo "# placeholder de-telecine >> $TESTAVS"
			echo "SelectRangeEvery(20000, 500, 10000)" >> $TESTAVS

			;;

			b|B) # interlaced and telecined
# TODONOTE: how to integrate de-telecine?
			echo "QTGMC().SelectEven()" >> $TESTAVS
			echo "# placeholder de-telecine >> $TESTAVS"
			echo "SelectRangeEvery(20000, 500, 10000)" >> $TESTAVS

			;;

			n|N) # neither interlaced nor telecined

			echo "SelectRangeEvery(20000, 500, 10000)" >> $TESTAVS

			;;

		esac

		;;

		*)
		echo "stupid, that's neither yes or no :-) "
		exit

		;;

	esac
		# copy content of TESTAVS into final.avs in same direct
		# write path to final.avs to CFG and delete line Select…
		# from final.avs
#TODONOTE: thats quite circumstantial, can be done by ${TESTAVS%/*}/final.avs only
		cat  $TESTAVS > ${TESTAVS%/*}/final.avs
		# keep cfg informed
		sed -i '/^AVS/d' $CONFIG
		echo "AVS=${TESTAVS%/*}/final.avs" >> $CONFIG
		sleep 1
		sed -i '/SelectRangeEvery/d' ${TESTAVS%/*}/final.avs

	

		echo ""
		echo "________________SAR_______|_PAR_|____DAR____"
		echo "widescreen ntsc 720x480 -> 40/33 ->  704x480"
		echo "                        -> 32/27 ->  853x480"
		echo "widescreen pal  720x576 -> 64/45 -> 1024x576"
		echo "fullscreen ntsc 720x480 ->  8/9  ->  640x480" 
		echo "fullscreen pal  720x576 -> 16/15 ->  768x576"
		echo ""
		echo "almost all bluray is 1/1"
		echo ""
		echo "if you don't know,check with"
		echo "AvsPmod > Tools > Resize calculator"
		echo ""
		read -e -p "check now? (y|n) > " ANSWER50

		case $ANSWER50 in 

			y|Y|yes|YES) # check sar with AvsPmod

			wine ~/$WINE/drive_c/Program\ Files/AvsPmod/AvsPmod.exe $TESTAVS

			;;

			n|N|no|NO|"") # do nothing
			
			;;

			*)

			echo "stupid, that's neither yes or no :-) "
			exit

			;;

		esac

		echo "set sar as fraction with a slash: /"
		read -e -p "sar > " SAR

		# keep cfg informed
		sed -i '/SAR/d' $CONFIG
		echo "SAR=$SAR" >> $CONFIG

		# find correct height, width and reframes for test encodes only
		# movie encoding may have different values

		DARHEIGHT0=$(mediainfo $SOURCE|grep Height|awk '{print $3$4}'|sed 's/[a-z]//g')
		# keep cfg informed
		sed -i '/DARHEIGHT0/d' $CONFIG
		echo "DARHEIGHT0=$DARHEIGHT0" >> $CONFIG

		DARWIDTH0=$(mediainfo $SOURCE|grep Width|awk '{print $3$4}'|sed 's/[a-z]//g')
		# keep cfg informed
		sed -i '/DARWIDTH0/d' $CONFIG
		echo "DARWIDTH0=$DARWIDTH0" >> $CONFIG

		REF0=$(echo "scale=0;32768/((($DARWIDTH0 * ($SAR) /16)+0.5)/1 * (($DARHEIGHT0/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i '/REF0/d' $CONFIG
		echo "REF0=$REF0" >> $CONFIG

		echo ""
		echo "set lowest CRF as integer, e.g. 15"
		echo ""
		read -e -p "crf > " CRFLOW

		echo ""
		echo "set highst CRF as integer, e.g. 20"
		echo ""
		read -e -p "crf > " CRFHIGH

		for ((CRF1=$CRFLOW; $CRF1<=$CRFHIGH; CRF1=$CRF1+1));do
			echo ""
			echo "encoding ${SOURCE%.*}.crf$CRF1.mkv"
			echo ""
			wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $TESTAVS - \
			| x264 --stdin y4m \
			--crf $CRF1 \
			--preset $PRESET \
			--tune $TUNE \
			--profile $PROFILE \
			--ref $REF0 \
			--sar $SAR \
			--rc-lookahead $LOOKAHEAD \
			--me $ME \
			--merange $MERANGE \
			--subme $SUBME \
			--deblock $DEBLOCK \
			--no-psy \
			-o ${SOURCE%.*}.crf$CRF1.mkv -;
		done

		if [ -e /usr/bin/beep ]; then beep $BEEP; fi
		
	echo ""
	echo "look at these first encodings. if you find any"
	echo "detail loss in still images, you have found"
	echo "your crf integer. go on to find fractionals around"
	echo "this integer and run the script with"
	echo "option 3"
	echo ""
	;;

	3)	# 3 - a second round for fractionals of crf

	echo ""	
	echo "set lowest CRF value as hundreds,"
	echo "e.g. 168 for 16.8"
	echo ""
	read -e -p "CRF > " CRFLOW2

	echo ""
	echo "set highst CRF value as hundreds,"
	echo "e.g. 176 for 17.6"
	echo ""
	read -e -p "CRF > " CRFHIGH2

	echo ""
	echo "set fractional steps, e.g. 1 for 0.1"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " CRFFRACTIONAL

	for ((CRF2=$CRFLOW2; $CRF2<=$CRFHIGH2; CRF2+=$CRFFRACTIONAL));do
		echo ""
		echo "encoding ${SOURCE%.*}.crf$CRF2.mkv"
		echo ""
		wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $TESTAVS - \
		| x264 --stdin y4m \
		--crf $(printf '%s.%s' "$(($CRF2/10))" "$(($CRF2%10))") \
		--preset $PRESET \
		--tune $TUNE \
		--profile $PROFILE \
		--ref $REF0 \
		--sar $SAR \
		--rc-lookahead $LOOKAHEAD \
		--me $ME \
		--merange $MERANGE \
		--subme $SUBME \
		--deblock $DEBLOCK \
		--no-psy \
		-o ${SOURCE%.*}.crf$CRF2.mkv -;
	done

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, which crf gave"
	echo "best results at acceptable file size."

	echo ""
	echo "set crf parameter"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " CRF
	# keep cfg informed
	sed -i '/CRF/d' $CONFIG
	echo "CRF=$CRF" >> $CONFIG

	echo ""
	echo "from here, run the script with"
	echo "option 4"
	echo ""

	;;

	4)	#4 - test variations in qcomp

	echo ""
	echo "qcomp: mostly values range from 0.6 to 0.8"
	echo "first, set lowest qcomp value"
	echo "e.g. 60 for 0.60"
	echo ""
	read -e -p "qcomp > " QCOMPLOW

	echo ""
	echo "set highst qcomp value"
	echo "e.g. 80 for 0.80"
	echo ""
	read -e -p "qcomp > " QCOMPHIGH

	echo ""
	echo "set fractional steps, e.g. 5 for 0.05"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " QCOMPFRACTIONAL

	for ((QCOMPNUMBER=$QCOMPLOW; $QCOMPNUMBER<=$QCOMPHIGH; QCOMPNUMBER+=$QCOMPFRACTIONAL));do
		echo ""
		echo "encoding ${SOURCE%.*}.crf$CRF.qc$QCOMPNUMBER.mkv"
		echo ""
		wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $TESTAVS - \
		| x264 --stdin y4m \
		--crf $CRF \
		--preset $PRESET \
		--tune $TUNE \
		--profile $PROFILE \
		--ref $REF0 \
		--sar $SAR \
		--rc-lookahead $LOOKAHEAD \
		--me $ME \
		--merange $MERANGE \
		--subme $SUBME \
		--aq-mode $AQMODE \
		--deblock $DEBLOCK \
		--qcomp $(echo "scale=1;$QCOMPNUMBER/100"|bc) \
		-o ${SOURCE%.*}.crf$CRF.qc$QCOMPNUMBER.mkv -;
	done

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi

	echo ""
	echo "thoroughly look through the encodings"
	echo "and decide, which qcomp parameters"
	echo "gave best results."
	echo ""
	echo "set qcomp parameter"
	echo "e.g. 0.75"
	echo ""
	read -e -p "qcomp > " QCOMP

	# keep cfg informed
	sed -i '/QCOMP/d' $CONFIG
	echo "QCOMP=$QCOMP" >> $CONFIG

	echo ""
	echo "from here, run the script with"
	echo "option 5"
	echo ""
	;;

	5)	# 5 - variations in aq strength and psy-rd

	echo ""
	echo "aq strength: values range 0.6 to 1.0, mostly"
	echo "set lower limit of aq strength, e.g. 60 for 0.6"
	echo ""
	read -e -p "aq strength, lower limit > " AQLOW

	echo ""
	echo "set upper limit of aq strength, e.g. 100 for 1.0"
	echo ""
	read -e -p "aq strength, upper limit > " AQHIGH

	echo ""
	echo "set fractional steps, e.g. 5 for 0.05 or 10 for 0.10"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " AQFRACTIONAL

	echo ""
	echo "psy-rd: mostly values range 0.9 to 1.2"
	echo "set lower limit of psy-rd, e.g. 90 for 0.9"
	echo ""
	read -e -p "psy-rd, lower limit > " PSY1LOW

	echo ""
	echo "upper limit of psy-rd, e.g. 120 for 1.2"
	echo ""
	read -e -p "psy-rd, upper limit> " PSY1HIGH

	echo ""
	echo "fractional steps for psy-rd values"
	echo "e.g. 5 for 0.05 or 10 for 0.1"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " PSY1FRACTIONAL

	echo ""
	echo "this will last some time…"
	echo ""

	for ((AQNUMBER=$AQLOW; $AQNUMBER<=$AQHIGH; AQNUMBER+=$AQFRACTIONAL));do
		for ((PSY1NUMBER=$PSY1LOW; $PSY1NUMBER<=$PSY1HIGH; PSY1NUMBER+=$PSY1FRACTIONAL));do
			echo ""
			echo "encoding ${SOURCE%.*}.crf$CRF.qc$QCOMP.aq$AQNUMBER.psy$PSY1NUMBER.mkv"
			echo ""
			wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $TESTAVS - \
			| x264 --stdin y4m \
			--crf $CRF \
			--qcomp $QCOMP \
			--preset $PRESET \
			--tune $TUNE \
			--profile $PROFILE \
			--ref $REF0 \
			--sar $SAR \
			--rc-lookahead $LOOKAHEAD \
			--me $ME \
			--merange $MERANGE \
			--subme $SUBME \
			--aq-mode $AQMODE \
			--deblock $DEBLOCK \
			--aq-strength $(echo "scale=1;$AQNUMBER/100"|bc) \
			--psy-rd $(echo "scale=1;$PSY1NUMBER/100"|bc):unset \
			-o ${SOURCE%.*}.crf$CRF.qc$QCOMP.aq$AQNUMBER.psy$PSY1NUMBER.mkv -;
		done
	done

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi

	echo ""
	echo "thoroughly look through all your test encodings"
	echo "and decide, which aq strength and which psy-rd"
	echo "parameters gave you best results."

	echo ""
	echo "set aq strength"
	echo "e.g. 0.85"
	echo ""
	read -e -p "aq strength > " AQS

	# keep cfg informed
	sed -i '/AQS/d' $CONFIG
	echo "AQS=$AQS" >> $CONFIG

	echo ""
	echo "set psy-rd"
	echo "e.g. 0.9"
	echo ""
	read -e -p "psy-rd > " PSYRD

	# keep cfg informed
	sed -i '/PSYRD/d' $CONFIG
	echo "PSYRD=$PSYRD" >> $CONFIG

	echo ""
	echo "run the script with option 6"
	echo "to set or unset psy-trellis"
	echo ""

	;;
	
	6)	# 6 - variations in psy-trellis

	echo "if you ended up with psy-rd ≥1"
	echo "you may (t)est for psy-trellis"
	echo "if you ended up with psy-rd <1"
	echo "you may (u)nset psy-trellis"
	read -e -p "psy-trellis > " ANSWER60

	case $ANSWER60 in

		t|T) # test for psy-trellis

			echo "psy-trellis: values range 0.0 to 0.1, in most cases"
			echo "set lower limit for psy-trellis, e.g. 0 for 0.0"
			echo ""
			read -e -p "psy-trellis, lower limit > " PSY2LOW

			echo ""
			echo "set upper limit for psy-trellis, e.g. 10 for 0.1"
			echo ""
			read -e -p "psy-trellis, upper limit > " PSY2HIGH

			echo ""
			echo "set fractional steps, e.g. 5 for 0.05"
			echo ""
			read -e -p "fractionals > " PSY2FRACTIONAL

			for ((PSY2NUMBER=$PSY2LOW; $PSY2NUMBER<=$PSY2HIGH; PSY2NUMBER+=$PSY2FRACTIONAL));do
				echo ""
				echo "encoding ${SOURCE%.*}.crf$CRF.qc$QCOMP.aq$AQS.psy$PSYRD.$PSY2NUMBER.mkv"
				echo ""
				wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $TESTAVS - \
				| x264 --stdin y4m \
				--crf $CRF \
				--qcomp $QCOMP \
				--aq-strength $AQS \
				--preset $PRESET \
				--tune $TUNE \
				--profile $PROFILE \
				--ref $REF0 \
				--sar $SAR \
				--rc-lookahead $LOOKAHEAD \
				--me $ME \
				--merange $MERANGE \
				--subme $SUBME \
				--aq-mode $AQMODE \
				--deblock $DEBLOCK \
				--psy-rd $PSYRD:$(echo "scale=1;$PSY2NUMBER/100"|bc) \
				-o ${SOURCE%.*}.crf$CRF.qc$QCOMP.aq$AQS.psy$PSYRD.$PSY2NUMBER.mkv -;
			done
			if [ -e /usr/bin/beep ]; then beep $BEEP; fi

			echo ""
			echo "thoroughly look through this last test encodings and"
			echo "decide, which one is your best encode."
			echo ""
			echo "set psy-trellis"
			echo "e.g. 0.05"
			echo ""
			read -e -p "psy-trellis > " PSYTR

			# keep cfg informed
			sed -i '/PSYTR/d' $CONFIG
			echo "PSYTR=$PSYTR" >> $CONFIG

		;;

		u|U) # unset psy-trellis

			# keep cfg informed
			sed -i '/PSYTR/d' $CONFIG
			echo "PSYTR=unset" >> $CONFIG

		;;

		*)

		echo "stupid, that's neither yes or no :-) "
		exit

		;;

	esac

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi

	echo "try another (maybe last) round"
	echo "for optimal crf"
	echo "option 7"
	echo ""
	;;

	7)	# 7 - another round of crf

	echo ""
	echo "once again, try a range of crf fractionals"
	echo "set lowest crf value as hundreds,"
	echo "e.g. 168 for 16.8"
	echo ""
	read -e -p "CRF > " CRFLOW2

	echo ""
	echo "set highst crf value as hundreds,"
	echo "e.g. 172 for 17.2"
	echo ""
	read -e -p "CRF > " CRFHIGH2

	echo ""
	echo "set fractional steps, e.g. 1 for 0.1"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " CRFFRACTIONAL2

	for ((CRFNUMBER2=$CRFLOW2; $CRFNUMBER2<=$CRFHIGH2; CRFNUMBER2+=$CRFFRACTIONAL2));do
		echo ""
		echo "encoding ${SOURCE%.*}.qc$QCOMP.aq$AQS.psy$PSYRD.$PSYTR.crf$CRFNUMBER2.mkv"
		echo ""
		wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $TESTAVS - \
		| x264 --stdin y4m \
		--qcomp $QCOMP \
		--aq-strength $AQS \
		--psy-rd $PSYRD:$PSYTR \
		--preset $PRESET \
		--tune $TUNE \
		--profile $PROFILE \
		--ref $REF0 \
		--rc-lookahead $LOOKAHEAD \
		--me $ME \
		--merange $MERANGE \
		--subme $SUBME \
		--deblock $DEBLOCK \
		--crf $(echo "scale=1;$CRFNUMBER2/10"|bc) \
		-o ${SOURCE%.*}.qc$QCOMP.aq$AQS.psy$PSYRD.$PSYTR.crf$CRFNUMBER2.mkv -;
	done

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, with which crf you"
	echo "get best results at considerable bitrate."
	echo ""
	echo "set crf parameter"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " CRF

	# keep cfg informed
	sed -i '/CRF/d' $CONFIG
	echo "CRF=$CRF" >> $CONFIG

	echo "now you may run the script"
	echo "to encode the whole movie with"
	echo "option 8"
	echo ""
	;;

	8)	# 8 - encode the whole movie

	# video filter cropping
	# --vf crop:{left},{top},{right},{bottom}
#TODONOTE: find a way to get all the numbers in one step

	echo ""
	echo "if no cropping is needed, just type 0 (zero)"
	echo "all numbers unsigned, must be even"
	echo "number of pixels to be cropped on the"
	echo ""
	read -e -p "left > " LEFT

	echo ""
	echo "number of pixels to be cropped on the"
	echo ""
	read -e -p "top > " TOP

	echo ""
	echo "number of pixels to be cropped on the"
	echo ""
	read -e -p "right > " RIGHT

	echo ""
	echo "number of pixels to be cropped on the"
	echo ""
	read -e -p "bottom > " BOTTOM

	# resizing
	echo "if you want to resize with or without cropping,"
	echo "better check for correct resolution!"
	echo ""
	echo "do you want to check with AvsPmod for correct"
	echo "destination file resolution?"
	echo "when checked, note values and close AvsPmod window"
	echo "do NOT press »apply«"
	read -e -p "check now (y|n) > " ANSWER70

	case "$ANSWER70" in

		y|Y|yes|YES)

		wine ~/$WINE/drive_c/Program\ Files/AvsPmod/AvsPmod.exe $AVS

		;;

		n|N|no|NO)

		;;

		*)

		echo "stupid, that's neither yes or no :-) "
		exit

		;;

	esac

	echo ""
	echo "do you want any resizing to e.g. (S)D, (7)20p,"
	echo "(1)080p or encode (a)ll three resolutions?"
	echo ""
	echo "(S|7|1|a)"
	read -e -p "> " ANSWER80

	case "$ANSWER80" in
	
	1|10|108|1080|1080p|"")

	# Get Reframes for 1080
	DARWIDTH1=$(echo "$DARWIDTH0-$LEFT-$RIGHT"|bc)
	DARHEIGHT1=$(echo "$DARHEIGHT0-$TOP-$BOTTOM"|bc)
	REF1=$(echo "scale=0;32768/((($DARWIDTH1 * ($SAR) /16)+0.5)/1 * (($DARHEIGHT1/16)+0.5)/1)"|bc)

	# keep cfg informed
	sed -i '/REF1/d' $CONFIG
	echo "REF1=$REF1" >> $CONFIG

	echo ""
	echo "encoding ${SOURCE%.*}.final.1080.mkv"
	echo "with $DARWIDTH1×$DARHEIGHT1"
	echo ""

	wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $AVS - \
	| x264 --stdin y4m \
	--crf $CRF \
	--sar $SAR \
	--qcomp $QCOMP \
	--aq-strength $AQS \
	--psy-rd $PSYRD:$PSYTR \
	--preset $PRESET \
	--tune $TUNE \
	--profile $PROFILE \
	--ref $REF1 \
	--rc-lookahead $LOOKAHEAD \
	--me $ME \
	--merange $MERANGE \
	--subme $SUBME \
	--aq-mode $AQMODE \
	--deblock $DEBLOCK \
	--vf crop:$LEFT,$TOP,$RIGHT,$BOTTOM \
	-o ${SOURCE%.*}.final.1080.mkv -;

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi
	;;

	7|72|720|720p)

	echo ""
	echo "final height for 720p"
	echo ""
	read -e -p "height > " HEIGHT7

	echo ""
	echo "final width for 720p"
	echo ""
	read -e -p "width > " WIDTH7

	echo ""
	echo "encoding ${SOURCE%.*}.final.720.mkv"
	echo "with $WIDTH7×$HEIGHT7"
	echo ""

	# Get Reframes for 720p
	REF7=$(echo "scale=0;32768/((($WIDTH7 * ($SAR) /16)+0.5)/1 * (($HEIGHT7/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/REF7/d' $CONFIG
	echo "REF7=$REF7" >> $CONFIG
	
	wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $AVS - \
	| x264 --stdin y4m \
	--crf $CRF \
	--qcomp $QCOMP \
	--aq-strength $AQS \
	--psy-rd $PSYRD:$PSYTR \
	--preset $PRESET \
	--tune $TUNE \
	--profile $PROFILE \
	--ref $REF7 \
	--rc-lookahead $LOOKAHEAD \
	--me $ME \
	--merange $MERANGE \
	--subme $SUBME \
	--aq-mode $AQMODE \
	--deblock $DEBLOCK \
	--vf crop:$LEFT,$TOP,$RIGHT,$BOTTOM/resize:$WIDTH7,$HEIGHT7 \
	-o ${SOURCE%.*}.final.720.mkv -;

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi
	;;

	s|S|sd|SD)

	echo ""
	echo "final height for SD"
	echo ""
	read -e -p "height > " HEIGHT5

	echo ""
	echo "final width for SD"
	echo ""
	read -e -p "width > " WIDTH5

	echo ""
	echo "encoding ${SOURCE%.*}.final.SD.mkv"
	echo "with $WIDTH5×$HEIGHT5"
	echo ""


	# Get Reframes for SD
	# though --preset Placebo sets Ref to 16, but 
	# 1- that may set level ≥ 4.1
	# 2- cropping may change reframes value
	REF5=$(echo "scale=0;32768/((($WIDTH5 * ($SAR) /16)+0.5)/1 * (($HEIGHT5/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/REF5/d' $CONFIG
	echo "REF5=$REF5" >> $CONFIG
	
	wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $AVS - \
	| x264 --stdin y4m \
	--crf $CRF \
	--sar $SAR \
	--ref $REF5 \
	--qcomp $QCOMP \
	--aq-strength $AQS \
	--psy-rd $PSYRD:$PSYTR \
	--preset $PRESET \
	--tune $TUNE \
	--profile $PROFILE \
	--rc-lookahead $LOOKAHEAD \
	--me $ME \
	--merange $MERANGE \
	--subme $SUBME \
	--aq-mode $AQMODE \
	--deblock $DEBLOCK \
	--vf crop:$LEFT,$TOP,$RIGHT,$BOTTOM/resize:$WIDTH5,$HEIGHT5 \
	-o ${SOURCE%.*}.final.SD.mkv -;

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi
	;;

	a|A)

	echo ""
	echo "encoding in all three resolutions"
	echo "THAT will last long!"
	echo ""

	echo ""
	echo "final height for SD"
	echo ""
	read -e -p "height > " HEIGHT5

	echo ""
	echo "final width for SD"
	echo ""
	read -e -p "width > " WIDTH5

	echo ""
	echo "final height for 720p"
	echo ""
	read -e -p "height > " HEIGHT7

	echo ""
	echo "final width for 720p"
	echo ""
	read -e -p "width > " WIDTH7

	echo ""
	echo "encoding ${SOURCE%.*}.final.SD.mkv"
	echo "with $HEIGHT5×$WIDTH5"
	echo ""

	# Get Reframes for SD
	REF5=$(echo "scale=0;32768/((($WIDTH5/16)+0.5)/1 * (($HEIGHT5/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/REF5/d' $CONFIG
	echo "REF5=$REF5" >> $CONFIG
	
	wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $AVS - \
	| x264 --stdin y4m \
	--crf $CRF \
	--sar $SAR \
	--ref $REF5 \
	--qcomp $QCOMP \
	--aq-strength $AQS \
	--psy-rd $PSYRD:$PSYTR \
	--preset $PRESET \
	--tune $TUNE \
	--profile $PROFILE \
	--rc-lookahead $LOOKAHEAD \
	--me $ME \
	--merange $MERANGE \
	--subme $SUBME \
	--aq-mode $AQMODE \
	--deblock $DEBLOCK \
	--vf crop:$LEFT,$TOP,$RIGHT,$BOTTOM/resize:$WIDTH5,$HEIGHT5 \
	-o ${SOURCE%.*}.final.SD.mkv -;

	echo ""
	echo "encoding ${SOURCE%.*}.final.720.mkv"
	echo "with $WIDTH7×$HEIGHT7"
	echo ""

	# Get Reframes for 720p
	REF7=$(echo "scale=0;32768/((($WIDTH7 * ($SAR) /16)+0.5)/1 * (($HEIGHT7/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/REF7/d' $CONFIG
	echo "REF7=$REF7" >> $CONFIG
	
	wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $AVS - \
	| x264 --stdin y4m \
	--crf $CRF \
	--sar $SAR \
	--qcomp $QCOMP \
	--aq-strength $AQS \
	--psy-rd $PSYRD:$PSYTR \
	--preset $PRESET \
	--tune $TUNE \
	--profile $PROFILE \
	--ref $REF7 \
	--rc-lookahead $LOOKAHEAD \
	--me $ME \
	--merange $MERANGE \
	--subme $SUBME \
	--aq-mode $AQMODE \
	--deblock $DEBLOCK \
	--vf crop:$LEFT,$TOP,$RIGHT,$BOTTOM/resize:$WIDTH7,$HEIGHT7 \
	-o ${SOURCE%.*}.final.720.mkv -;

	echo ""
	echo "encoding ${SOURCE%.*}.final.1080.mkv"
	echo "with $DARWIDTH1×$DARHEIGHT1"
	echo ""

	# Get Reframes for 1080
	DARWIDTH1=$(echo "$DARWIDTH0-$LEFT-$RIGHT"|bc)
	DARHEIGHT1=$(echo "$DARHEIGHT0-$TOP-$BOTTOM"|bc)
	REF1=$(echo "scale=0;32768/((($DARWIDTH1  * ($SAR) /16)+0.5)/1 * (($DARHEIGHT1/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/REF1/d' $CONFIG
	echo "REF1=$REF1" >> $CONFIG

	wine ~/$WINE/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $AVS - \
	| x264 --stdin y4m \
	--crf $CRF \
	--sar $SAR \
	--qcomp $QCOMP \
	--aq-strength $AQS \
	--psy-rd $PSYRD:$PSYTR \
	--preset $PRESET \
	--tune $TUNE \
	--profile $PROFILE \
	--ref $REF1 \
	--rc-lookahead $LOOKAHEAD \
	--me $ME \
	--merange $MERANGE \
	--subme $SUBME \
	--aq-mode $AQMODE \
	--deblock $DEBLOCK \
	--vf crop:$LEFT,$TOP,$RIGHT,$BOTTOM \
	-o ${SOURCE%.*}.final.1080.mkv -;

	if [ -e /usr/bin/beep ]; then beep $BEEP; fi
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
