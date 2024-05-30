#!/bin/bash
# This script makes Ping tests and sends them to the starlinkstatus.space API
VERSION=1.21
APIURL="https://starlinkstatus.space/api/postresult"
SERVERSURL="https://starlinkstatus.space/api/getservers"

speedtest=false
dishy=false
apikey=""

help() {
    echo "Usage: starlinkstatus.sh -k APIKEY";
    echo "-k | --key        API Key for starlinkstatus.space"
    echo "-s | --speedtest  Enable Speedtest Data, requires speedtest.net cli"
    echo "-d | --dishy      Enable Dishy Data, requires gprcurl"
    echo "-h | --help       Show this Message"
}

pingservers() {
    cnt=$((${#SERVERS[@]} - 1))

    echo "Starting Ping Test (Servers: ${#SERVERS[@]})..."
    pingjsn="{"

    for k in "${!SERVERS[@]}"
    do
        pingres=$(ping -c 4 ${SERVERS[$k]} | awk -F '/' 'END {print $5}')
        echo "Ping to ${SERVERS[$k]}: $pingres"
        pingjsn+="\"${SERVERS[$k]}\":\"$pingres\""
        if [ $k != $((${#SERVERS[@]} - 1))  ]
        then
            pingjsn+=","
        fi
    done

    pingjsn+="}"
}

getgeodata() {
    geojsn="{}"
    geojsn=$(curl -s http://ip-api.com/json/)
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

if [ "$apikey" == "" ]
then
    exit
fi
echo "API Key: $apikey"

# get servers to ping
SERVERS=($(curl -s ${SERVERSURL}))
# Check if Servers to Ping are there, if not try again (could be caused by connection timeout)
if [ ${#SERVERS[@]} -gt 0 ]
then
    SERVERS=($(curl -s ${SERVERSURL}))
fi

pingservers

# Check if Dishy Telemetry Enabled and run it
if [ $dishy == true ]
then
    grpcurl --version >/dev/null && echo "getting Dishy Data..." || { echo -e "\e[31mgrpcurl not found!\e[0m"; exit 1; }
    dishstatus=$(grpcurl -plaintext -emit-defaults -d '{"getStatus":{}}' 192.168.100.1:9200 SpaceX.API.Device.Device/Handle) || dishstatus="{}"
    # dishcontext=$(grpcurl -plaintext -emit-defaults -d '{"dishGetContext":{}}' 192.168.100.1:9200 SpaceX.API.Device.Device/Handle) || dishcontext="{}"
    dishcontext="{}"    #this APi is sadly not useable anymore
else
    dishstatus="{}"
    dishcontext="{}"
fi

# Check if Speedtest Enabled and run it
if [ $speedtest == true ]
then
    speedtest -V --accept-license --accept-gdpr >/dev/null && echo "speedtest is running..." || { echo -e "\e[31mSpeedtest CLI not found!\e[0m"; exit 1; }
    st=$(speedtest --accept-license --accept-gdpr -f json)
else
    st="{}"
fi

getgeodata
jsndata='{"key":"'$apikey'","geo":'$geojsn',"ping":'$pingjsn',"speed":'$st',"dishyStatus":'$dishstatus',"dishyContext":'$dishcontext',"version":'$VERSION'}'
# Send data to API
curl -d "$jsndata" -H "Content-Type: application/json" -X POST $APIURL
echo "\n"