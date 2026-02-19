#!/bin/bash
wget -P {{ ansible_env.HOME }}/ https://download.blender.org/demo/movies/BBB/bbb_sunflower_2160p_60fps_normal.mp4.zip
unzip /tmp/bbb_sunflower_2160p_60fps_normal.mp4.zip -d {{ ansible_env.HOME }}/open5gs/docker/4k-video/
mv {{ ansible_env.HOME }}/bbb_sunflower_2160p_60fps_normal.mp4 {{ ansible_env.HOME }}/video.mp4
