#!/bin/bash

user=${1}
key=${2}
serverlist=${3}

arr=($(awk '{print $0}' $serverlist))
length=${#arr[@]}
echo "There are $length servers"
for (( i=0 ; i<$length ; i++ ))
do
        host=${arr[i]}
        echo -e "\n DNS sync on machine: $host"
        cat /etc/hosts | ssh -i $key $user@$host "sudo sh -c 'cat >/etc/hosts'"
done
