#!/bin/bash

user=${1}
key=${2}
serverlist=${3}

rm ~/.ssh/known_hosts
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
sudo chmod -R 700 .ssh
sudo chmod -R 640 .ssh/authorized_keys 
scripts/scpWorkers.sh ${user} ${key} ${serverlist} ~/.ssh/id_rsa.pub ~/id_rsa.pub
scripts/sshWorkers.sh ${user} ${key} ${serverlist} "cat ~/id_rsa.pub >> ~/.ssh/authorized_keys"
scripts/sshWorkers.sh ${user} ${key} ${serverlist} "chmod -R 700 .ssh"
scripts/sshWorkers.sh ${user} ${key} ${serverlist} "chmod -R 640 .ssh/authorized_keys"
