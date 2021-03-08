#!/bin/sh
if [ -e /data/ip.txt ]
then
    OLD_IP=`cat /data/ip.txt`
else
    OLD_IP=''
fi
IP=`curl -s https://api.ipify.org`

if [ $OLD_IP == $IP ]
then
   echo "IP not changed"
else
    echo $IP > /data/ip.txt
    curl -X POST -H "Content-Type: application/json" \
        -d "{\"old_ip\": \"$OLD_IP\", \"new_ip\": \"$IP\"}" \
        $UPDATE_ENDPOINT
fi
