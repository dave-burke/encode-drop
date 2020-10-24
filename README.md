# encode-drop

This is a wrapper that transcodes everything in an input directory to an output
directory with the same parameters for each. Great for seasons of TV shows.

It expects an executable named `transcode` to be on the PATH. For me that's a
[different
script](https://github.com/dave-burke/ansible-playbook/blob/master/roles/video_transcoding/files/transcode.sh)
that itself wraps Don Melton's [video
transcoding](https://github.com/donmelton/video_transcoding) script.

`encode-drop.sh [input dir] [output dir] [flags]`

