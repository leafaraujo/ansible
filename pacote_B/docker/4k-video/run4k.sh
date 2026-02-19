#!/bin/sh

service nginx start -s -t 5

ffmpeg -stream_loop -1 -re -nostdin \
       -i /opt/video.mp4 \
       -c copy \
       -hls_time 4 \
       -hls_list_size 6 \
       -hls_flags split_by_time+delete_segments \
       -hls_segment_filename "/var/www/html/hls_native/segment%03d.ts" \
       /var/www/html/hls_native/playlist.m3u8