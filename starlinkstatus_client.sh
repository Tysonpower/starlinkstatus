#!/bin/bash
# This script makes Ping tests and sends them to the starlinkstatus.space API
VERSION=1.21
APIURL="https://starlinkstatus.space/api/postresult"
SERVERSURL="https://starlinkstatus.space/api/getservers"

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

# Main Script ----------------------------------------------------------------------------------
main(){
    echo "starlinkstatus.space Client - Version $VERSION"
    if [ "$APIKEY" == "" ]
    then
        echo "APIKEY not set"
        exit
    fi
    echo "API Key: $APIKEY"

    # get servers to ping
    SERVERS=($(curl -s ${SERVERSURL}))
    # Check if Servers to Ping are there, if not try again (could be caused by connection timeout)
    if [ ${#SERVERS[@]} -gt 0 ]
    then
        SERVERS=($(curl -s ${SERVERSURL}))
    fi

    pingservers

    # Check if Dishy Telemetry Enabled and run it
    if [ $DISHY == true ]
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
    if [ $SPEEDTEST == true ]
    then
        speedtest -V --accept-license --accept-gdpr >/dev/null && echo "speedtest is running..." || { echo -e "\e[31mSpeedtest CLI not found!\e[0m"; exit 1; }
        st=$(speedtest --accept-license --accept-gdpr -f json)
    else
        st="{}"
    fi

    getgeodata

    jsndata='{"key":"'$APIKEY'","geo":'$geojsn',"ping":'$pingjsn',"speed":'$st',"dishyStatus":'$dishstatus',"dishyContext":'$dishcontext',"version":'$VERSION'}'
    
    # Send data to API
    curl -d "$jsndata" -H "Content-Type: application/json" -X POST $APIURL
    echo ""
    echo ""
    echo ""
    if [ $debug == true ]
    then 
        echo "jsndata"
        echo "$jsndata"
        echo 
    fi
}

if [[ -z "$CRONJOB" ]] || [[ $CRONJOB == false ]]; then
     
    echo "Scheduled to run every: $SCHEDULE seconds"
    while :
    do
        main
        echo 
        count=0 
        until false 
        do
            ((count++))
            if [[ $debug2 == true ]]
            then 
                echo "Counter = $count of $SCHEDULE"
            fi

            sleep 1
            if [[ "$count" -ge "$SCHEDULE" ]] 
            then 
                break
            fi
        done
    done
else
    echo "Running as CRONJOB"
    main
fi