Over the years, much great software for advanced video encoding has been written, unfortunately advanced tools like avisynth for windows only. So linux users, who want to produce high quality encodings have to use a windows installation either natively or in a virtual machine. Both of which needs a windows license and often is disliked by those who never were at or went away from windows.  
Due to wine, many relevant windows tools do work at least sufficiently.

The script produces test encodes in a kind of methodical manner. Doing this manually is boring and sometimes tempting to be done unstructered. As testing each parameter may take fifteen, twenty minutes on average or even above average consumer hardware, you may have to operate your pc after every 20 minutes to prompt the next encode.  
This script provides test encodes with several parameters, and does some, gradually more complex encoding with crosswise parameters, and in the end encodes the whole movie. Most important, the script generates a simple .avs for each testing stage, so you don't have to tamper with avs files to get your comparison screens. Of course, they can be edited by $editor at any time as you like to.

It uses native linux cli tools as far as available (which is not much right now), all the rest is done using windows tools via wine.

It works for standard and high definition sources, getting along with Matroska containers, e.g. remuxes as well as m2ts streams (also mpls BluRay playlists).

If you encode a HD file in a SD resolution, the appropriate colormatrix is chosen.

It offers several options, (mostly) one prerequesite to another, largely corresponding to the methods recommended in advanced encoding guides:

+ 00 - check, if all necessary programs are installed
+ 0  - display and edit default settings and current encoding parameters
+ 1  - demux de-/ unencrypted m2ts|remux -> mpeg2|h264|vc1|m2v -> mkv,
+ 2  - create necessary avs files
+ 3  - test for crf
+ 4  - test for mbtree vs --no-mbtree
+ 5  - test for qcomp
+ 6  - test for aq strength in different aq modes
+ 7  - test for psy-rd
+ 8  - test for psy-trellis
+ 9  - do some more things: chroma-qp-offset
+ 10 - another round of crf
+ 11 - encoding the whole movie

The script consists of two parts:

The bash script itself: encode.sh and a configuration file default.cfg in a directory named encode.
You may place the script somewhere in your `$PATH`.

The config file I suggest to place to
`~/.config/encode/default.cfg`
but any other place may be suitable. In the latter case, you have to edit the script:
`config="${HOME}/.config/encode/default.cfg"`

Each movie gets its own config file derived from the default.cfg and stores all relevant parameters that occur during encoding.
If you want to change them manually, use your editor of choice or choose the edit-option in option 0.

Maybe you prefer not to mix your encoding environment with other installations of wine. If you do not have any wine-installation yet, you may leave the newly installed wine directory in place. If you do have a wine installation already, you may rename it or install your encoding environment someplace else. Edit the script:

`wine="${HOME}/.wine.encode"`

Start the script like this:

`$ ./encode.sh`

You can check, if all neccessary programs are available and check the default settings for encoding.
Start the script without parameters to begin the encoding process from an unencrypted remux file respectively m2ts file.
While going through option 1 and 2, an individual config file will be generated which stores your settings for each movie. The config file will be placed in the same ./encode directory as the default.cfg file and given the name of your test encode.

With this name as parameter, you go on from option 3 to option 11.

Let's say, you encode "The Fabulous Baker Boys". Choose a short name for practical reasons! Name your encoding tfbb, for example. From there on, start the script with
`$ ./encode.sh tfbb <resolution>`

with resolution = SD if you encode from a DVD or
with resolution = 480, 576, 720 or 1080 if you encode a HD file.

You want to work on another movie, before the baker boys are finished? No problem, that encoding also gets its individual config file, so your settings don't get confused.


### Requirements

Install some programs preferably from your distribution:

    # apt-get install bash bc beep libimage-exiftool-perl mediainfo mkvtoolnix sed unrar wine x264

If wine64 is installed, you should uninstall it to prevent windows applications from being installed there.

Download eac3to, AvsPmod, Avsresize, avs2yuv, Avisynth and the filters you want to use, like: FillBorders, BalanceBorders, FixBrightnessProtect3, etc.
You can find them linked [here](https://github.com/derpolsper/encode/tree/master/filtersetc.md) and put them to a custom place, but link to them in the encode.sh script.
Copying the desired filters to a place independent from the wine directories, e.g.:

    ~/.config/encode/.filters/

Unzip your eac3to.zip to "Program Files":

    $ unzip /path/to/eac3to.zip -d ~/.wine/drive_c/Program\ Files/eac3to

similar, with avs2yuv-0.24bm6.zip:

    $ unzip /path/to/avs2yuv-0.24bm6.zip -d ~/.wine/drive_c/Program\ Files/

Filters do not need to be in the wine directory. If stored somewhere else, they even survive reinstalls.

This script does not need more programs to work. You can use all kind of avisynth filters. There is no guarantee for them to work, though. Generally, most avisynth filters should work, however, I did not do much in the way of verification here.

I tested positive for
+ QTGMC()
+ SelectEven()
+ TFM()
+ TDecimate()
+ ColorMatrix
+ FillBorders
+ BalanceBorders
+ FixBrightnessProtect3

The script demuxes the source into h264, vc1, mpeg2 or m2v streams, which afterwards are muxed into a mkv file.

When using the resize calculator in AvsPmod, do not click »apply«, do not let the calculator work on your .avs, but set these parameters when the script asks for them.

### Limitations

The script does NOT do:

+ decrypt sources
+ handle DVDs or VOB containers
+ handle demuxed audio files
+ handle demuxed subtitles
+ handle chapter files
+ mux anything together

The maximum number of test encodings in one avs file is somewhat 154, which does not seem to set a concerning limit the number of combinations even in cross testing aq modes and aq strength.

Though some parameters can be set permanent, encoding needs a lot of trial and error to find the best possible result. There's lots of interaction. But hey, **encoding is fun!**
