#!/bin/bash

MAIN_URL="https://yhdm.nl"
DETAIL_URL="$1"
PLAY_URL="$(echo "$DETAIL_URL" | sed 's/detail/play/')"
TARGET_SOURCE="$2"
OUT="$3"
clear
echo "正在初始化..."
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
TARGET_NAME="$(curl -sL "$DETAIL_URL" | grep 'age-anime-title d-inline-block mt-1 mb-0' | cut -d '>' -f 2 | sed 's#</h5##')"
PART1=$(curl -sL $DETAIL_URL | grep "第*话" | awk '{print $5}' | sort | sed "s/'//g" | sed "s/title=//g")
PART2=$(echo "$PART1" | wc -l)
mkdir -p "$OUT/$TARGET_NAME"
echo "番剧名：$TARGET_NAME"
echo "番剧总集数：$PART2"
echo "线路源：$TARGET_SOURCE"
for get in $(seq 1 $(echo "$PART1" | wc -l)); do
    if [ "$PART2" -ge "1000" ]; then
        PLAY_ID=""
    elif [[ "$PART2" -ge "100" && "$PART2" -lt "1000" ]]; then
        PLAY_ID="1"
    elif [[ "$PART2" -ge "10" && "$PART2" -lt "100" ]]; then
        PLAY_ID="10"
    elif [[ "$PART2" -gt "1" && "$PART2" -lt "10" ]]; then
        PLAY_ID="100"
    elif [ "$PART2" -eq "1" ]; then
        PLAY_ID="quan-ji"
    fi
    if [[ "$PART2" -ge "100" && "$PART2" -lt "1000" ]]; then
        if [ "$get" -lt "10" ]; then
            PLAY_ID+="00"
        elif [[ "$get" -ge "10" && "$get" -lt "100" ]]; then
            PLAY_ID+="0"
        fi
    elif [[ "$PART2" -ge "10" && "$PART2" -lt "100" ]]; then
        if [ "$get" -lt "10" ]; then
            PLAY_ID+="00"
        elif [[ "$get" -ge "10" && "$get" -lt "100" ]]; then
            PLAY_ID+="0"
        fi
    fi
    if [ "$PLAY_ID" != "quan-ji" ]; then
        PART1_GET=$(echo "$PART1" | sed -n "${get}p")
        PLAY_ID+="${get}000"
    else
        PART1_GET="全集"
    fi
    SOURCE_URL="$(curl -sL "${PLAY_URL}?playid=$PLAY_ID" | grep "target=\"p-frame\">$TARGET_SOURCE</a>" | sed -n '1p' | awk '{print $8}' | sed "s/'//g" | sed "s/href=//g")"
    CFG_TYPE="$(curl -sL "${PLAY_URL}?playid=$PLAY_ID" | grep "target=\"p-frame\">$TARGET_SOURCE</a>" | sed -n '1p' | awk '{print $7}' | sed 's/"//g' | sed "s/cfg=//g")"
    VIDEO_URL="$(curl -sL "${MAIN_URL}$SOURCE_URL" | grep "$CFG_TYPE" | awk '{print $2}' | sed 's/"//g' | sed "s/src=//g")"
    axel -a -n "8" -o "$OUT/$TARGET_NAME/${PART1_GET}.${CFG_TYPE}" "$VIDEO_URL"
done
END_TIME=`date +'%Y-%m-%d %H:%M:%S'`
START_SECONDS=$(date --date="$START_TIME" +%s);
END_SECONDS=$(date --date="$END_TIME" +%s);
echo "总用时： "$((END_SECONDS-START_SECONDS))"s"
