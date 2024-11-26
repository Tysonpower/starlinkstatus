#!/bin/bash
# This script makes Ping tests and sends them to the starlinkstatus.space API
VERSION=1.3
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

ping_server() {
  local server=$1
  if ping 127.0.0.1 -c 1 -i 0.2; then
    avg_ping=$(ping -4 -W 1 -c 3 -i 0.2 "$server" | awk -F '/' 'END {print $5}')
  else
    avg_ping=$(ping -c 3 "$server" | awk -F '/' 'END {print $5}')
  fi
  
  # on timeout use -1
  echo "${avg_ping:-"-1"}"
}
export -f ping_server

pingservers() {
    parallel --version >/dev/null && echo "getting servers to ping..." || { echo -e "\e[31mgnu parallel not found! please install it!\e[0m"; exit 1; }

    # get servers to ping
    SERVERS=($(curl -s ${SERVERSURL}))
    # Check if Servers to Ping are there, if not try again (could be caused by connection timeout)
    if [ ${#SERVERS[@]} -gt 0 ]; then
        SERVERS=($(curl -s ${SERVERSURL}))
    fi

    cnt=$((${#SERVERS[@]} - 1))
    echo "Starting Ping Test (Servers: ${#SERVERS[@]})..."
    
    # parallel ping of servers to save time
    results=$(printf "%s\n" "${SERVERS[@]}" | parallel --no-notice ping_server {})
    
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
    geojsn=$(curl -s http://ip-api.com/json/)
}

getdishy() {
    # Check if Dishy Telemetry Enabled and run it
    if [ $dishy == true ]; then
        grpcurl --version >/dev/null && echo "getting Dishy Data..." || { echo -e "\e[31mgrpcurl not found! please install it!\e[0m"; exit 1; }
        dishstatus=$(grpcurl -plaintext -emit-defaults -d '{"getStatus":{}}' 192.168.100.1:9200 SpaceX.API.Device.Device/Handle) || dishstatus="{}"
    else
        dishstatus="{}"
    fi
}

collect_lr() {
    echo "Collecting Low Res data... $(date)"
    pingservers
    getgeodata
    getdishy
    
    # Check if Speedtest Enabled and run it
    if [ $speedtest == true ]; then
        # Check if Servers to Ping are there, if not try again (could be caused by connection timeout)
        if [ ${#SERVERS[@]} -gt 0 ]
        then
            SERVERS=($(curl -s ${SERVERSURL}))
        fi

        speedtest -V --accept-license --accept-gdpr >/dev/null && echo "speedtest is running..." || { echo -e "\e[31mSpeedtest CLI not found!\e[0m"; exit 1; }
        st=$(speedtest --accept-license --accept-gdpr -f json)
    else
        st="{}"
    fi
    
    local jsndata='{"key":"'$apikey'","geo":'$geojsn',"ping":'$pingjsn',"speed":'$st',"dishyStatus":'$dishstatus',"version":'$VERSION'}'
    # Send data to API
    curl -d "$jsndata" -H "Content-Type: application/json" -X POST $APIURL/lowres
}

collect_hr() {
    echo "Collecting High Res data... $(date)"
    pingservers
    getdishy

    local jsndata='{"key":"'$apikey'","ping":'$pingjsn',"dishyStatus":'$dishstatus',"version":'$VERSION'}'
    # Send data to API
    curl -d "$jsndata" -H "Content-Type: application/json" -X POST $APIURL/highres
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