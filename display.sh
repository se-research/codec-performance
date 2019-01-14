#!/bin/bash

REC=$1
ODVD=$2

# Display the last frame.
xhost +

cat <<EOF > script.sh
rm -fr opendlv.proxy.* last-frame.*
cluon-rec2csv --rec=$REC --odvd=$ODVD
cat opendlv.proxy.ImageReading-0.csv | tail -1 | cut -f10 -d";" | cut -f2 -d"\"" | base64 -d > last-frame.h264
WIDTH=\$(cat opendlv.proxy.ImageReading-0.csv | tail -1 | cut -f8 -d";")
HEIGHT=\$(cat opendlv.proxy.ImageReading-0.csv | tail -1 | cut -f9 -d";")
ffmpeg -f h264 -i last-frame.h264 last-frame.yuv
display -size \${WIDTH}x\${HEIGHT} -depth 8 -sampling-factor 4:2:0 -colorspace RGB last-frame.yuv
EOF
chmod 755 script.sh

docker run --rm -ti --init -v $PWD:/data -v /tmp:/tmp -e DISPLAY=$DISPLAY -w /data codec-performance:latest ./script.sh

rm -f script.sh
