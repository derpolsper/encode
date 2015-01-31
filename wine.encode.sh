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
config="${HOME}/.config/wine.encode.cfg"

while IFS='= ' read lhs rhs
do
    if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"		# delete in line right comments
        rhs="${rhs%"${rhs##*[^ ]}"}"	# delete trailing spaces
        rhs="${rhs%\"*}"		# delete opening string quotes
        rhs="${rhs#\"*}"		# delete closing string quotes
        declare $lhs="$rhs"
    fi
done < $config


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
read -p "> " answer10

case "$answer10" in

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

	if [ -e ~/$wine/drive_c/Program\ Files/eac3to/eac3to.exe ]
		then wine ~/$wine/drive_c/Program\ Files/eac3to/eac3to.exe|grep 'eac3to v'; echo ""
		else echo ""
		echo "***"
		echo "*** eac3to seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$wine/drive_c/windows/system32/avisynth.dll ]
		then echo "avisynth seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** avisynth seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$wine/drive_c/Program\ Files/AvsPmod/AvsPmod.exe ]
		then echo "AvsPmod seems to be installed"
		echo ""
		else echo ""
		echo "***"
		echo "*** AvsPmod seems not to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe ]
		then echo "avs2yuv seems to be installed"
		echo ""
		else
		echo ""
		echo "***"
		echo "*** avs2yuv seems NOT to be installed"
		echo "***"
		echo "" ;
	fi

	if [ -e ~/$wine/drive_c/Program\ Files/Haali/MatroskaSplitter/uninstall.exe ]
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
	echo -e "TUNE:\t\t "$tune
	echo -e "PROFILE:\t "$profile
	echo -e "PRESET:\t\t "$preset
	echo ""
	echo -e "*** more specific settings ***"
	echo ""
	echo -e "ME:\t\t "$me
	echo -e "MERANGE:\t "$merange
	echo -e "SUBME:\t\t "$subme
	echo -e "AQMODE:\t\t "$aqmode
	echo -e "DEBLOCK:\t "$deblock
	echo -e "lookahead:\t "$lookahead
	echo ""
	echo "please note, parameters for reframes are"
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
	read -e -p "> " source0

# TODONOTE dirty: if dir then dvd, if file then bluray
	if [ -d $source0 ];
	then

		cd $source0
		echo "choose out of these VOB containers:"
		echo ""
		ls -l $source0|grep VOB$ |grep -v _0.VOB|grep -v VIDEO|awk '{print $9, $5}'
		echo ""
		echo "which group(s) of VOB containers do you"
		echo "want to encode? add them like this:"
		echo "VTS_02_1.VOB+VTS_02_2.VOB+VTS_02_3.VOB(+…)"
		echo ""
		read -e -p "> " param0

		wine ~/$wine/drive_c/Program\ Files/eac3to/eac3to.exe $param0

		echo ""
		echo "extract all wanted tracks following this name pattern:"
		echo "[1-n]:name.extension, e.g. 2:name.h264 3:name.flac 4:name.ac3 5:name.sup etc"
		echo "the video stream MUST be given mpeg2 as file extension"
		echo ""
		read -e -p "> " param1

		wine ~/$wine/drive_c/Program\ Files/eac3to/eac3to.exe $param0 $param1

		echo ""
		echo "where you want to place the demuxed file?"
		echo "absolute path and name with file extension"
		echo ""
		read -e -p "> " source

		# keep cfg informed
		sed -i '/source/d' $config
		echo "source=$source" >> $config

#TODONOTE dirty. problems when >1 mpeg2 file
		mkvmerge -v -o $source $(ls $source0|grep .mpeg2)

		# eac3to's Log file names contain spaces
		for i in *.txt; do mv -v "$i" $(echo $i | sed 's/ /_/g') &>/dev/null; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in *.mpeg* *.h264 *.dts* *.pcm *.flac *.ac3 *.aac *.wav *.w64 *.sup *.txt; do mv $file ${source%/*}/ &>/dev/null; done

		echo ""
		echo "you find the demuxed files in"
		echo "${source%/*}"
		echo ""

	elif [ -f $source0 ];
	then

		cd ${source0%/*}

		wine ~/$wine/drive_c/Program\ Files/eac3to/eac3to.exe ${source0##*/}

		echo ""
		echo "extract all wanted tracks following this name pattern:"
		echo "[1-n]:name.extension, e.g. 2:name.h264 3:name.flac 4:name.ac3 5:name.sup etc"
		echo "the video stream MUST be given h264 as file extension"
		echo ""
		read -e -p "> " param1

		wine ~/$wine/drive_c/Program\ Files/eac3to/eac3to.exe ${source0##*/} $param1

		echo ""
		echo "where you want to place the demuxed file?"
		echo "absolute path and name with file extension"
		echo ""
		read -e -p "> " source

		# keep cfg informed
		sed -i '/source/d' $config
		echo "source=$source" >> $config

		
#TODONOTE: dirty. problems when >1 h264 file
		mkvmerge -v -o $source $(ls ${source0%/*}|grep .h264)

		# eac3to's Log file names contain spaces
		for i in *.txt; do mv -v "$i" $(echo $i | sed 's/ /_/g') &>/dev/null; done

# TODONOTE move ALL eac3to associated files to directory for demuxed files. does it?
		for file in *.mpeg* *.h264 *.dts* *.pcm *.flac *.ac3 *.aac *.wav *.w64 *.sup *.txt; do mv $file ${source%/*}/ &>/dev/null; done

		echo ""
		echo "you find the demuxed files in"
		echo "${source%/*}"
		echo ""

	else
		echo "something went wrong"
		echo ""

	fi

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	;;

	2)	# 2 - create a avs file for first test and test encode with suitable integer crf

	echo ""
	echo "your movie source is"
	echo "$source, right?"

	echo ""
	echo "do you have a suitable test avs file already? (y|n)"
	read -e -p "> " answer20
	echo ""

	case "$answer20" in

		y|Y|yes|YES) # do nothing

		echo ""
		echo "full path to your test avs file with .avs file extension"
		echo ""
		read -e -p "> " testavs

		# keep cfg informed
		sed -i '/testavs/d' $config
		echo "testavs=$testavs" >> $config

		;;

		n|N|No|NO) # write a .avs

		echo ""
		echo "create your test avs file"
		echo "full path to your test avs file with .avs file extension"
		echo ""
		read -e -p "> " testavs

		# keep cfg informed
		sed -i '/testavs/d' $config
		echo "testavs=$testavs" >> $config

		echo "FFVideosource(\"$source\")" > $testavs

		echo ""
		echo "check, if your movie is interlaced"
		echo ""
		echo "mediainfo says:"

		mediainfo $source|grep 'Scan type'|awk '{print $4}'

		echo ""
		read -p "press enter to continue"

		echo ""
		echo "do you want to check with AvsPmod frame by frame,"
		echo "if your movie is interlaced and/or telecined?"
		echo "after this, close AvsPmod window"
		echo ""
		read -e -p "check now? (y|n) > " answer30

		case "$answer30" in

			y|Y|yes|YES)

			wine ~/$wine/drive_c/Program\ Files/AvsPmod/AvsPmod.exe $testavs

			;;

			n|N|no|NO)

			;;
		esac

		echo ""
		echo "qualities of your video source:"
		echo "(i)nterlaced? (t)elecined? (b)oth? (n)either nor?"
		echo ""
		read -e -p "> " answer40

		case "$answer40" in

			i|I) # interlaced

			echo "QTGMC().SelectEven()" >> $testavs
			echo "SelectRangeEvery(20000, 500, 10000)" >> $testavs

			;;

			t|T) # telecined
# TODONOTE: how to integrate de-telecine?
			echo "# placeholder de-telecine >> $testavs"
			echo "SelectRangeEvery(20000, 500, 10000)" >> $testavs

			;;

			b|B) # interlaced and telecined
# TODONOTE: how to integrate de-telecine?
			echo "QTGMC().SelectEven()" >> $testavs
			echo "# placeholder de-telecine >> $testavs"
			echo "SelectRangeEvery(20000, 500, 10000)" >> $testavs

			;;

			n|N) # neither interlaced nor telecined

			echo "SelectRangeEvery(20000, 500, 10000)" >> $testavs

			;;

		esac

		;;

		*)
		echo "stupid, that's neither yes or no :-) "
		exit

		;;

	esac
		# copy content of $testavs into final.avs in same direct
		# write path to final.avs to CFG and delete line Select…
		# from final.avs
#TODONOTE: thats quite circumstantial, can be done by ${testavs%/*}/final.avs only
		cat  $testavs > ${testavs%/*}/final.avs
		# keep cfg informed
		sed -i '/^avs/d' $config
		echo "avs=${testavs%/*}/final.avs" >> $config
		sleep 1
		sed -i '/SelectRangeEvery/d' ${testavs%/*}/final.avs

	

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
		read -e -p "check now? (y|n) > " answer50

		case $answer50 in 

			y|Y|yes|YES) # check sar with AvsPmod

			wine ~/$wine/drive_c/Program\ Files/AvsPmod/AvsPmod.exe $testavs

			;;

			n|N|no|NO|"") # do nothing
			
			;;

			*)

			echo "stupid, that's neither yes or no :-) "
			exit

			;;

		esac

		echo "set sar as fraction with a slash: /"
		read -e -p "sar > " sar

		# keep cfg informed
		sed -i '/sar/d' $config
		echo "sar=$sar" >> $config

		# find correct height, width and reframes for test encodes only
		# final movie encoding may have different values

		darheight0=$(mediainfo $source|grep Height|awk '{print $3$4}'|sed 's/[a-z]//g')
		# keep cfg informed
		sed -i '/darheight0/d' $config
		echo "darheight0=$darheight0" >> $config

		darwidth0=$(mediainfo $source|grep Width|awk '{print $3$4}'|sed 's/[a-z]//g')
		# keep cfg informed
		sed -i '/darwidth0/d' $config
		echo "darwidth0=$darwidth0" >> $config

		ref0=$(echo "scale=0;32768/((($darwidth0 * ($sar) /16)+0.5)/1 * (($darheight0/16)+0.5)/1)"|bc)
		# keep cfg informed
		sed -i '/ref0/d' $config
		echo "ref0=$ref0" >> $config

		# isolate the source file name without file extension
		# bash parameter expansion does not allow nesting, so do it in two steps
		sourc2=${source##*/}
		sed -i '/sourc2/d' $config
		echo "sourc2=$sourc2" >> $config

		echo ""
		echo "set lowest crf as integer, e.g. 15"
		echo ""
		read -e -p "crf > " crflow

		echo ""
		echo "set highst crf as integer, e.g. 20"
		echo ""
		read -e -p "crf > " crfhigh

		start0=$(date +%s)

		for ((crf1=$crflow; $crf1<=$crfhigh; crf1=$crf1+1));do
			echo ""
			echo "encoding ${sourc2%.*}.crf$crf1.mkv"
			echo ""

			start1=$(date +%s)

			wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $testavs - \
			| x264 --stdin y4m \
			--crf $crf1 \
			--preset $preset \
			--tune $tune \
			--profile $profile \
			--ref $ref0 \
			--sar $sar \
			--rc-lookahead $lookahead \
			--me $me \
			--merange $merange \
			--subme $subme \
			--deblock $deblock \
			--no-psy \
			-o ${source%.*}.crf$crf1.mkv -;

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${sourc2%.*}.crf$crf1.mkv lasted $time"

		done

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
		echo "test encodings for integer crf lasted $time"

		if [ -e /usr/bin/beep ]; then beep $beep; fi
		
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

	start0=$(date +%s)

	for ((crf2=$crflow2; $crf2<=$crfhigh2; crf2+=$crffractional));do
		echo ""
		echo "encoding ${sourc2%.*}.crf$crf2.mkv"
		echo ""

		start1=$(date +%s)

		wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $testavs - \
		| x264 --stdin y4m \
		--crf $(printf '%s.%s' "$(($crf2/10))" "$(($crf2%10))") \
		--preset $preset \
		--tune $tune \
		--profile $profile \
		--ref $ref0 \
		--sar $sar \
		--rc-lookahead $lookahead \
		--me $me \
		--merange $merange \
		--subme $subme \
		--deblock $deblock \
		--no-psy \
		-o ${source%.*}.crf$crf2.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${sourc2%.*}.crf$crf2.mkv lasted $time"

	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for fractional crf lasted $time"

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, which crf gave"
	echo "best results at acceptable file size."

	echo ""
	echo "set crf parameter"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " crf
	# keep cfg informed
	sed -i '/crf/d' $config
	echo "crf=$crf" >> $config

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
	read -e -p "qcomp > " qcomplow

	echo ""
	echo "set highst qcomp value"
	echo "e.g. 80 for 0.80"
	echo ""
	read -e -p "qcomp > " qcomphigh

	echo ""
	echo "set fractional steps, e.g. 5 for 0.05"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " qcompfractional

	start0=$(date +%s)

	for ((qcompnumber=$qcomplow; $qcompnumber<=$qcomphigh; qcompnumber+=$qcompfractional));do
		echo ""
		echo "encoding ${sourc2%.*}.crf$crf.qc$qcompnumber.mkv"
		echo ""

		start1=$(date +%s)

		wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $testavs - \
		| x264 --stdin y4m \
		--crf $crf \
		--preset $preset \
		--tune $tune \
		--profile $profile \
		--ref $ref0 \
		--sar $sar \
		--rc-lookahead $lookahead \
		--me $me \
		--merange $merange \
		--subme $subme \
		--aq-mode $aqmode \
		--deblock $deblock \
		--qcomp $(echo "scale=1;$qcompnumber/100"|bc) \
		-o ${source%.*}.crf$crf.qc$qcompnumber.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${sourc2%.*}.crf$crf.qc$qcompnumber.mkv lasted $time"

	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for qcomp lasted $time"

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through the encodings"
	echo "and decide, which qcomp parameters"
	echo "gave best results."
	echo ""
	echo "set qcomp parameter"
	echo "e.g. 0.75"
	echo ""
	read -e -p "qcomp > " qcomp

	# keep cfg informed
	sed -i '/qcomp/d' $config
	echo "qcomp=$qcomp" >> $config

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
	read -e -p "aq strength, lower limit > " aqlow

	echo ""
	echo "set upper limit of aq strength, e.g. 100 for 1.0"
	echo ""
	read -e -p "aq strength, upper limit > " aqhigh

	echo ""
	echo "set fractional steps, e.g. 5 for 0.05 or 10 for 0.10"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " aqfractional

	echo ""
	echo "psy-rd: mostly values range 0.9 to 1.2"
	echo "set lower limit of psy-rd, e.g. 90 for 0.9"
	echo ""
	read -e -p "psy-rd, lower limit > " psy1low

	echo ""
	echo "upper limit of psy-rd, e.g. 120 for 1.2"
	echo ""
	read -e -p "psy-rd, upper limit> " psy1high

	echo ""
	echo "fractional steps for psy-rd values"
	echo "e.g. 5 for 0.05 or 10 for 0.1"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " psy1fractional

	echo ""
	echo "this will last some time…"
	echo ""

	start0=$(date +%s)

	for ((aqnumber=$aqlow; $aqnumber<=$aqhigh; aqnumber+=$aqfractional));do
		for ((psy1number=$psy1low; $psy1number<=$psy1high; psy1number+=$psy1fractional));do
			echo ""
			echo "encoding ${sourc2%.*}.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv"
			echo ""

			start1=$(date +%s)

			wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $testavs - \
			| x264 --stdin y4m \
			--crf $crf \
			--qcomp $qcomp \
			--preset $preset \
			--tune $tune \
			--profile $profile \
			--ref $ref0 \
			--sar $sar \
			--rc-lookahead $lookahead \
			--me $me \
			--merange $merange \
			--subme $subme \
			--aq-mode $aqmode \
			--deblock $deblock \
			--aq-strength $(echo "scale=1;$aqnumber/100"|bc) \
			--psy-rd $(echo "scale=1;$psy1number/100"|bc):unset \
			-o ${source%.*}.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv -;

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
			echo "encoding ${sourc2%.*}.crf$crf.qc$qcomp.aq$aqnumber.psy$psy1number.mkv lasted $time"

	
		done
	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")

	echo " test encodings for aq strength and psy-rd lasted $time"

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test encodings"
	echo "and decide, which aq strength and which psy-rd"
	echo "parameters gave you best results."

	echo ""
	echo "set aq strength"
	echo "e.g. 0.85"
	echo ""
	read -e -p "aq strength > " aqs

	# keep cfg informed
	sed -i '/aqs/d' $config
	echo "aqs=$aqs" >> $config

	echo ""
	echo "set psy-rd"
	echo "e.g. 0.9"
	echo ""
	read -e -p "psy-rd > " psyrd

	# keep cfg informed
	sed -i '/psyrd/d' $config
	echo "psyrd=$psyrd" >> $config

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
	read -e -p "psy-trellis > " answer60

	case $answer60 in

		t|T) # test for psy-trellis

			echo "psy-trellis: values range 0.0 to 0.1, in most cases"
			echo "set lower limit for psy-trellis, e.g. 0 for 0.0"
			echo ""
			read -e -p "psy-trellis, lower limit > " psy2low

			echo ""
			echo "set upper limit for psy-trellis, e.g. 10 for 0.1"
			echo ""
			read -e -p "psy-trellis, upper limit > " psy2high

			echo ""
			echo "set fractional steps, e.g. 5 for 0.05"
			echo ""
			read -e -p "fractionals > " psy2fractional

			start0=$(date +%s)

			for ((psy2number=$psy2low; $psy2number<=$psy2high; psy2number+=$psy2fractional));do
				echo ""
				echo "encoding ${sourc2%.*}.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv"
				echo ""

				start1=$(date +%s)

				wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $testavs - \
				| x264 --stdin y4m \
				--crf $crf \
				--qcomp $qcomp \
				--aq-strength $aqs \
				--preset $preset \
				--tune $tune \
				--profile $profile \
				--ref $ref0 \
				--sar $sar \
				--rc-lookahead $lookahead \
				--me $me \
				--merange $merange \
				--subme $subme \
				--aq-mode $aqmode \
				--deblock $deblock \
				--psy-rd $psyrd:$(echo "scale=1;$psy2number/100"|bc) \
				-o ${source%.*}.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv -;

				stop=$(date +%s);
				time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
				echo "encoding ${sourc2%.*}.crf$crf.qc$qcomp.aq$aqs.psy$psyrd.$psy2number.mkv lasted $time"

			done

			stop=$(date +%s);
			time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
			echo "test encodings for psy-trellis lasted $time"

			if [ -e /usr/bin/beep ]; then beep $beep; fi

			echo ""
			echo "thoroughly look through this last test encodings and"
			echo "decide, which one is your best encode."
			echo ""
			echo "set psy-trellis"
			echo "e.g. 0.05"
			echo ""
			read -e -p "psy-trellis > " psytr

			# keep cfg informed
			sed -i '/psytr/d' $config
			echo "psytr=$psytr" >> $config

		;;

		u|U) # unset psy-trellis

			# keep cfg informed
			sed -i '/psytr/d' $config
			echo "psytr=unset" >> $config

		;;

		*)

		echo "stupid, that's neither yes or no :-) "
		exit

		;;

	esac

	if [ -e /usr/bin/beep ]; then beep $beep; fi

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
	read -e -p "crf > " crflow2

	echo ""
	echo "set highst crf value as hundreds,"
	echo "e.g. 172 for 17.2"
	echo ""
	read -e -p "crf > " crfhigh2

	echo ""
	echo "set fractional steps, e.g. 1 for 0.1"
	echo "≠0"
	echo ""
	read -e -p "fractionals > " crffractional2

	start0=$(date +%s)

	for ((crfnumber2=$crflow2; $crfnumber2<=$crfhigh2; crfnumber2+=$crffractional2));do
		echo ""
		echo "encoding ${sourc2%.*}.qc$qcomp.aq$aqs.psy$psyrd.$psytr.crf$crfnumber2.mkv"
		echo ""

		start1=$(date +%s)

		wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $testavs - \
		| x264 --stdin y4m \
		--qcomp $qcomp \
		--aq-strength $aqs \
		--psy-rd $psyrd:$psytr \
		--preset $preset \
		--tune $tune \
		--profile $profile \
		--ref $ref0 \
		--rc-lookahead $lookahead \
		--me $me \
		--merange $merange \
		--subme $subme \
		--deblock $deblock \
		--crf $(echo "scale=1;$crfnumber2/10"|bc) \
		-o ${source%.*}.qc$qcomp.aq$aqs.psy$psyrd.$psytr.crf$crfnumber2.mkv -;

		stop=$(date +%s);
		time=$(date -u -d "0 $stop seconds - $start1 seconds" +"%H:%M:%S")
		echo "encoding ${sourc2%.*}.qc$qcomp.aq$aqs.psy$psyrd.$psytr.crf$crfnumber2.mkv lasted $time"

	done

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start0 seconds" +"%H:%M:%S")
	echo "test encodings for a second round of crf lasted $time"

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	echo ""
	echo "thoroughly look through all your test"
	echo "encodings and decide, with which crf you"
	echo "get best results at considerable bitrate."
	echo ""
	echo "set crf parameter"
	echo "e.g. 17.3"
	echo ""
	read -e -p "crf > " crf

	# keep cfg informed
	sed -i '/crf/d' $config
	echo "crf=$crf" >> $config

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
	read -e -p "left > " left

	echo ""
	echo "number of pixels to be cropped on the"
	echo ""
	read -e -p "top > " top

	echo ""
	echo "number of pixels to be cropped on the"
	echo ""
	read -e -p "right > " right

	echo ""
	echo "number of pixels to be cropped on the"
	echo ""
	read -e -p "bottom > " bottom

	# resizing
	echo "if you want to resize with or without cropping,"
	echo "better check for correct resolution!"
	echo ""
	echo "do you want to check with AvsPmod for correct"
	echo "destination file resolution?"
	echo "when checked, note values and close AvsPmod window"
	echo "do NOT press »apply«"
	read -e -p "check now (y|n) > " answer70

	case "$answer70" in

		y|Y|yes|YES)

		wine ~/$wine/drive_c/Program\ Files/AvsPmod/AvsPmod.exe $avs

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
	read -e -p "> " answer80

	case "$answer80" in
	
	1|10|108|1080|1080p|"")

	# Get reframes for 1080
	darwidth1=$(echo "$darwidth0-$left-$right"|bc)
	darheight1=$(echo "$darheight0-$top-$bottom"|bc)
	ref1=$(echo "scale=0;32768/((($darwidth1 * ($sar) /16)+0.5)/1 * (($darheight1/16)+0.5)/1)"|bc)

	# keep cfg informed
	sed -i '/ref1/d' $config
	echo "ref1=$ref1" >> $config

	echo ""
	echo "now encoding ${sourc2%.*}.final.1080.mkv"
	echo "with $darwidth1×$darheight1…"
	echo ""

	start=$(date +%s)

	wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $avs - \
	| x264 --stdin y4m \
	--crf $crf \
	--sar $sar \
	--qcomp $qcomp \
	--aq-strength $aqs \
	--psy-rd $psyrd:$psytr \
	--preset $preset \
	--tune $tune \
	--profile $profile \
	--ref $ref1 \
	--rc-lookahead $lookahead \
	--me $me \
	--merange $merange \
	--subme $subme \
	--aq-mode $aqmode \
	--deblock $deblock \
	--vf crop:$left,$top,$right,$bottom \
	-o ${source%.*}.final.1080.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${sourc2%.*}.final.1080.mkv"
	echo "with $darwidth1×$darheight1 lasted $time"

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	;;

	7|72|720|720p)

	echo ""
	echo "final height for 720p"
	echo ""
	read -e -p "height > " height7

	echo ""
	echo "final width for 720p"
	echo ""
	read -e -p "width > " width7

	echo ""
	echo "now encoding ${sourc2%.*}.final.720.mkv"
	echo "with $width7×$height7…"
	echo ""

	# Get reframes for 720p
	ref7=$(echo "scale=0;32768/((($width7 * ($sar) /16)+0.5)/1 * (($height7/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref7/d' $config
	echo "ref7=$ref7" >> $config

	start=$(date +%s)

	wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $avs - \
	| x264 --stdin y4m \
	--crf $crf \
	--qcomp $qcomp \
	--aq-strength $aqs \
	--psy-rd $psyrd:$psytr \
	--preset $preset \
	--tune $tune \
	--profile $profile \
	--ref $ref7 \
	--rc-lookahead $lookahead \
	--me $me \
	--merange $merange \
	--subme $subme \
	--aq-mode $aqmode \
	--deblock $deblock \
	--vf crop:$left,$top,$right,$bottom/resize:$width7,$height7 \
	-o ${source%.*}.final.720.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${sourc2%.*}.final.720.mkv"
	echo "with $width7×$height7 lasted $time"

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	;;

	s|S|sd|SD)

	echo ""
	echo "final height for SD"
	echo ""
	read -e -p "height > " height5

	echo ""
	echo "final width for SD"
	echo ""
	read -e -p "width > " width5

	echo ""
	echo "now encoding ${sourc2%.*}.final.SD.mkv"
	echo "with $width5×$height5…"
	echo ""


	# Get reframes for SD
	# though --preset Placebo sets reframes to 16, but 
	# 1- that may set level ≥ 4.1
	# 2- cropping may change reframes value
	ref5=$(echo "scale=0;32768/((($width5 * ($sar) /16)+0.5)/1 * (($height5/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref5/d' $config
	echo "ref5=$ref5" >> $config

	start=$(date +%s)

	wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $avs - \
	| x264 --stdin y4m \
	--crf $crf \
	--sar $sar \
	--ref $ref5 \
	--qcomp $qcomp \
	--aq-strength $aqs \
	--psy-rd $psyrd:$psytr \
	--preset $preset \
	--tune $tune \
	--profile $profile \
	--rc-lookahead $lookahead \
	--me $me \
	--merange $merange \
	--subme $subme \
	--aq-mode $aqmode \
	--deblock $deblock \
	--vf crop:$left,$top,$right,$bottom/resize:$width5,$height5 \
	-o ${source%.*}.final.SD.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${sourc2%.*}.final.SD.mkv"
	echo "with $width5×$height5 lasted $time"

	if [ -e /usr/bin/beep ]; then beep $beep; fi

	;;

	a|A)

	echo ""
	echo "encoding in all three resolutions"
	echo "THAT will last long!"
	echo ""

	echo ""
	echo "final height for SD"
	echo ""
	read -e -p "height > " height5

	echo ""
	echo "final width for SD"
	echo ""
	read -e -p "width > " width5

	echo ""
	echo "final height for 720p"
	echo ""
	read -e -p "height > " height7

	echo ""
	echo "final width for 720p"
	echo ""
	read -e -p "width > " width7

	echo ""
	echo "now encoding ${sourc2%.*}.final.SD.mkv"
	echo "with $height5×$width5…"
	echo ""

	# Get reframes for SD
	ref5=$(echo "scale=0;32768/((($width5/16)+0.5)/1 * (($height5/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref5/d' $config
	echo "ref5=$ref5" >> $config

	start=$(date +%s)

	wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $avs - \
	| x264 --stdin y4m \
	--crf $crf \
	--sar $sar \
	--ref $ref5 \
	--qcomp $qcomp \
	--aq-strength $aqs \
	--psy-rd $psyrd:$psytr \
	--preset $preset \
	--tune $tune \
	--profile $profile \
	--rc-lookahead $lookahead \
	--me $me \
	--merange $merange \
	--subme $subme \
	--aq-mode $aqmode \
	--deblock $deblock \
	--vf crop:$left,$top,$right,$bottom/resize:$width5,$height5 \
	-o ${source%.*}.final.SD.mkv -;

	stop=$(date +%s)

	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo "encoding ${sourc2%.*}.final.SD.mkv"
	echo "with $height5×$width5 lasted $time"

	echo ""
	echo "now encoding ${sourc2%.*}.final.720.mkv"
	echo "with $width7×$height7…"
	echo ""

	# Get reframes for 720p
	ref7=$(echo "scale=0;32768/((($width7 * ($sar) /16)+0.5)/1 * (($height7/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref7/d' $config
	echo "ref7=$ref7" >> $config
	
	start=$(date +%s)

	wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $avs - \
	| x264 --stdin y4m \
	--crf $crf \
	--sar $sar \
	--qcomp $qcomp \
	--aq-strength $aqs \
	--psy-rd $psyrd:$psytr \
	--preset $preset \
	--tune $tune \
	--profile $profile \
	--ref $ref7 \
	--rc-lookahead $lookahead \
	--me $me \
	--merange $merange \
	--subme $subme \
	--aq-mode $aqmode \
	--deblock $deblock \
	--vf crop:$left,$top,$right,$bottom/resize:$width7,$height7 \
	-o ${source%.*}.final.720.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo ""
	echo "encoding ${sourc2%.*}.final.720.mkv"
	echo "with $width7×$height7 lasted $time"
	echo ""

	# Get reframes for 1080
	darwidth1=$(echo "$darwidth0-$left-$right"|bc)
	darheight1=$(echo "$darheight0-$top-$bottom"|bc)
	ref1=$(echo "scale=0;32768/((($darwidth1  * ($sar) /16)+0.5)/1 * (($darheight1/16)+0.5)/1)"|bc)
	# keep cfg informed
	sed -i '/ref1/d' $config
	echo "ref1=$ref1" >> $config

	echo ""
	echo "now encoding ${sourc2%.*}.final.1080.mkv"
	echo "with $darwidth1×$darheight1…"
	echo ""

	start=$(date +%s)

	wine ~/$wine/drive_c/Program\ Files/avs2yuv/avs2yuv.exe $avs - \
	| x264 --stdin y4m \
	--crf $crf \
	--sar $sar \
	--qcomp $qcomp \
	--aq-strength $aqs \
	--psy-rd $psyrd:$psytr \
	--preset $preset \
	--tune $tune \
	--profile $profile \
	--ref $ref1 \
	--rc-lookahead $lookahead \
	--me $me \
	--merange $merange \
	--subme $subme \
	--aq-mode $aqmode \
	--deblock $deblock \
	--vf crop:$left,$top,$right,$bottom \
	-o ${source%.*}.final.1080.mkv -;

	stop=$(date +%s);
	time=$(date -u -d "0 $stop seconds - $start seconds" +"%H:%M:%S")
	echo ""
	echo "encoding ${sourc2%.*}.final.1080.mkv"
	echo "with $darwidth1×$darheight1 lasted $time"
	echo ""

	if [ -e /usr/bin/beep ]; then beep $beep; fi
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
