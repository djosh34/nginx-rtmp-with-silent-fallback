#!/bin/sh

# This file contains functions required by other nginx-rtmp-backup scripts
echo "Utils script started"

die() { # Exit with the proper stderr output
	echo "Nginx Rtmp Server: $*" >&2
	exit 1
}

parse_argv() {	# Checks that the streamname for scripts is provided
				# and set the variable
	[ "$#" -ge 1 ] || die "too few arguments"
	STREAMNAME=$1
}

pid_for() { # Gets a pid, according to stream kind (main/backup) and streamname
	echo "$PIDS_FOLDER/$1_$STREAMNAME.pid"
}

is_running() {	# Checks if the process pushing stream
				# of provided kind (main/backup) is running
	pidfile="$(pid_for "$1")"
	echo $pidfile
  pidfile_contents="$(cat $pidfile)"
  /bin/kill -0 $pidfile_contents
}

get_var() { # Gets variable value by its name
	eval echo "$"$1""
}

kill() {	# Kills a process pushing stream of provided kind (main/backup)
			# if it is running and removes its pidfile
  echo "killing $1"
	if is_running "$1"; then
    pidfile="$(pid_for "$1")"
    echo $pidfile
    pidfile_contents="$(cat $pidfile)"
    echo "got pid: $pidfile_contents"
		/bin/kill -9 $pidfile_contents 
		rm -f "$pidfile"
	fi
}

assert_one_of() { # Checks that the value for a variable provided in config is rigth
	varname="$1"; shift # Get variable name and remove it from arguments list
	value="$(get_var $varname)"
	expected="$*" # Values left in arguments list are expected values

	while [ "$#" -gt 0 ]; do
		if [ "$value" = "$1" ]; then return; fi # If a value of the varibale is one of the expected, return
		shift
	done

	# If we are here, the variable value do not match any of expected, exit
	die "unexpected value \`$value' for \`$varname' (expected one of '$expected')"
}

push_stream() { # Starts pushing stream
	stream_kind="$1" # backup or main
	# Get a value of either $MAIN_STREAM_NAME or $BACKUP_STREAM_NAME
	appname="$(get_var "$(echo "${stream_kind}_STREAM_APPNAME" | tr '[:lower:]' '[:upper:]')")"
  echo "pushing stream appname $appname"

	LOGFILE="$LOGS_FOLDER/${appname}_${STREAMNAME}.log"

  if [ "$stream_kind" = "main" ]; then
    nohup $FFMPEG_PATH \
      -re -i "rtmp://127.0.0.1:1935/$appname/$STREAMNAME" \
      -vn -c:a copy -f flv \
      "rtmp://127.0.0.1:1936/$OUT_STREAM_APPNAME/$STREAMNAME" \
      \
      </dev/null \
      >"$LOGFILE" \
      2>&1 \
      &
  else
    nohup $FFMPEG_PATH \
      -re -f lavfi -i "anullsrc=r=44100:cl=stereo" \
      -c:a aac -b:a 256k -ar 44100 -ac 2 \
      -f flv \
      "rtmp://127.0.0.1:1936/$OUT_STREAM_APPNAME/$STREAMNAME" \
      \
      </dev/null \
      >"$LOGFILE" \
      2>&1 \
      &
  fi

  echo $! > "$(pid_for "$stream_kind")"
}
