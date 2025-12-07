#!/bin/bash

# Fetch active torrents and their magnet links using qBittorrent Web API
curl -s -X GET "http://localhost:8080/api/v2/torrents/info" -d "filter=downloading" -d "category=" \
  --header "Referer: http://localhost:8080" \
  | jq -r '.[] | .magnet_uri' > /root/torrents/active_torrents.list
