#!/bin/sh

echo "Configuring nginx-rtmp"

# nginx rtmp application name for main stream
MAIN_STREAM_APPNAME="main"

FFMPEG_PATH="/usr/local/bin/ffmpeg"

# nginx rtmp application name for backup stream
BACKUP_STREAM_APPNAME="backup"

# nginx rtmp application name for final stream
OUT_STREAM_APPNAME="out"

# folder where pidfiles are stored
PIDS_FOLDER="/pids"

# folder where logfiles are stored
LOGS_FOLDER="/logs"

