#!/bin/bash
# This script makes Ping tests and sends them to the starlinkstatus.space API
VERSION=1.31
APIURL="https://starlinkstatus.space/api/v1"
SERVERSURL="https://starlinkstatus.space/api/v1/getservers"

# interval in seconds for low res data (default 900 / 15 minutes)
lr_interval=900

speedtest=false
only_once=false
dishy=false
apikey=""

help() {
    echo "Usage: starlinkstatus.sh -k APIKEY";
    echo "-k | --key        API Key for starlinkstatus.space"
    echo "-s | --speedtest  Enable Speedtest Data, requires speedtest.net cli"
    echo "-d | --dishy      Enable Dishy Data, requires gprcurl"
    echo "-i | --interval   Interval for speedtest in seconds (default 15 min / 900s)"
    echo "-o | --once       Run only once (simulates old version)"
    echo "-h | --help       Show this Message"
}

retrive_ping_servers() {
    if ! SERVERS=($(curl -s -m 5 ${SERVERSURL})); then
        echo "Error: Could not retrieve server list"
        return 1
    fi
    echo "Server list successfully retrieved"
}

extract_avg_ping() {
  local output="$1"
  local avg

  # GNU/Linux (GNU ping): "rtt min/avg/max/mdev = 10.123/20.456/30.789/1.234 ms"
  if echo "$output" | grep -q "rtt"; then
    avg=$(echo "$output" | awk -F'/' '/rtt/ {print $5}')
  fi

  # macOS/BSD: "round-trip min/avg/max/stddev = 10.123/20.456/30.789/1.234 ms"
  if echo "$output" | grep -q "round-trip"; then
    avg=$(echo "$output" | awk -F'/' '/round-trip/ {print $5}')
  fi

  # Alpine Linux (BusyBox): "round-trip min/avg/max = 10.123/20.456/30.789 ms"
  if echo "$output" | grep -q "round-trip min/avg/max"; then
    avg=$(echo "$output" | awk -F'/' '/round-trip/ {print $4}')
  fi

  # if mothing found use -1
  echo "${avg:-"-1"}"
}

ping_server() {
  local server=$1
  if ping 127.0.0.1 -c 1 -i 0.2 >/dev/null; then
    ping_output=$(ping -4 -W 1 -c 3 -i 0.2 "$server" 2>/dev/null)
  else
    ping_output=$(ping -c 3 "$server" 2>/dev/null)
  fi

  avg_ping=$(extract_avg_ping "$ping_output")
  # on timeout use -1
  echo "${avg_ping:-"-1"}"
}
export -f extract_avg_ping
export -f ping_server

pingservers() {
    parallel --version >/dev/null && echo "Starting ping tests..." || { echo -e "\e[31mError: gnu parallel not found! please install it!\e[0m"; exit 1; }

    # get servers to ping
    retrive_ping_servers

    # Check if Servers to Ping are there, if not try again (could be caused by connection timeout)
    if [ ${#SERVERS[@]} -gt 0 ]; then
        retrive_ping_servers
    fi

    echo "Starting Ping Test (Servers: ${#SERVERS[@]})..."
    
    # parallel ping of servers to save time
    if ! results=$(printf "%s\n" "${SERVERS[@]}" | timeout 30 parallel --no-notice ping_server {}); then
        echo -e "\e[31mError: Could not collect ping data\e[0m"
        return 1
    fi
    
    i=0
    pingjsn="{"
    for server in "${SERVERS[@]}"
    do
        avg=$(echo "$results" | sed -n "$((i+1))p")
        pingjsn+="\"$server\": $avg"
        echo "Ping to $server: $avg"
        if (( i < ${#SERVERS[@]} - 1 )); then
            pingjsn+=", "
        fi
        ((i++))
    done
    pingjsn+="}"
}

getgeodata() {
    geojsn="{}"
    if ! geojsn=$(curl -s -m 5 http://ip-api.com/json/); then
        echo -e "\e[31mError: Could not retrieve geo data\e[0m"
        return 1
    fi
    echo "Geo data successfully retrieved"
}

getdishy() {
    dishstatus="{}"
    # Check if Dishy Telemetry Enabled and run it
    if [ $dishy == true ]; then
        grpcurl --version >/dev/null && echo "Collecting dishy data..." || { echo -e "\e[31mError: grpcurl not found! please install it!\e[0m"; exit 1; }
        if ! dishstatus=$(timeout 5 grpcurl -plaintext -emit-defaults -d '{"getStatus":{}}' 192.168.100.1:9200 SpaceX.API.Device.Device/Handle); then
            echo -e "\e[31mError: Could not retrieve dishy data\e[0m"
            return 1
        fi
    fi
}

collect_lr() {
    echo "$(date) Starting low-res data collection..."
    if ! pingservers; then
        echo "Ping tests failed - skipping"
    fi

    if ! getgeodata; then
        echo "Collecting geo data failed - skipping"
    fi

    if ! getdishy; then
        echo "Collecting dishy data failed - skipping"
    fi
    
    st="{}"
    # Check if Speedtest Enabled and run it
    if [ $speedtest == true ]; then
        speedtest -V --accept-license --accept-gdpr >/dev/null && echo "Starting speedtest..." || { echo -e "\e[31mError: Speedtest CLI not found!\e[0m"; exit 1; }
        if ! st=$(timeout 60 speedtest --accept-license --accept-gdpr -f json); then
            echo -e "\e[31mError: Speedtest failed or timed out after 60 seconds\e[0m"
        fi
    fi
    
    local jsndata='{"key":"'$apikey'","geo":'$geojsn',"ping":'$pingjsn',"speed":'$st',"dishyStatus":'$dishstatus',"version":'$VERSION'}'
    # Send data to API
    if ! timeout 5 curl -d "$jsndata" -H "Content-Type: application/json" -X POST $APIURL/lowres; then
        echo "Uploading data to api failed"
    fi
}

collect_hr() {
    echo "$(date) Starting high-res data collection..."
    if ! pingservers; then
        echo "Ping tests failed - skipping"
    fi

    if ! getdishy; then
        echo "Collecting dishy data failed - skipping"
    fi

    local jsndata='{"key":"'$apikey'","ping":'$pingjsn',"dishyStatus":'$dishstatus',"version":'$VERSION'}'
    # Send data to API
    if ! timeout 5 curl -d "$jsndata" -H "Content-Type: application/json" -X POST $APIURL/highres; then
        echo "Uploading data to api failed"
    fi
}

checkifrunning() {
    #check if the script is already running, if so stop it
    PIDFILE="/tmp/$(basename "$0").pid"
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        echo "The script is already running with PID $(cat "$PIDFILE")."
        exit 1
    fi
    # function to cleanup PID file
    cleanup() {
        rm -f "$PIDFILE"
    }
    trap cleanup EXIT
    # save current PID
    echo $$ > "$PIDFILE"
}

while [ "$1" != "" ]; do
    case $1 in
        -k | --key )            shift
                                apikey="$1"
                                ;;
        -s | --speedtest )      speedtest=true
                                ;;
        -d | --dishy )          dishy=true
                                ;;
        -i | --interval )       shift
                                lr_interval=$1
                                ;;
        -o | --once )           only_once=true
                                ;;
        -h | --help )           help
                                exit
                                ;;
        * )                     help
                                exit 1
    esac
    shift
done

# Main Script ----------------------------------------------------------------------------------
echo "starlinkstatus.space Client - Version $VERSION"
echo "Inteval for speedtests: $lr_interval"

if [ "$apikey" == "" ]; then
    exit
fi
echo "API Key: $apikey"

# check if this script is already running, fix if user doesen't change cron from 1.2x version
checkifrunning

# if user runs only once mode don't start the loop for timing
if [ $only_once == false ]; then
    while true; do
        echo "$(date) Status check:"
        current_time=$(date +%s)

        # check if seconds interval (default is 15s)
        if (( current_time % 15 == 0 )); then
            collect_hr
        fi

        # check if minute interval is reached
        if (( current_time % lr_interval == 0 )); then
            collect_lr
        fi

        # wait to reduce cpu load
        sleep 1
    done
else
    echo "Running in 'only once' mode"
    collect_lr
fi