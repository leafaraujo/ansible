#!/bin/bash
sudo docker stop open5gs_5gc
sudo docker rm open5gs_5gc
sudo docker image rm docker-5gc
sudo docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml up -d 5gc

