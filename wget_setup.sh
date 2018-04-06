#!/bin/bash

output() {
    printf "\E[0;33;40m"
    echo $1
    printf "\E[0m"
}

displayErr() {
    echo
    echo $1;
    echo
    exit 1;
}

output "Created by ServePeak. Used to automatically setup masternodes on daemon end."
output "Let's begin the install process."

read -e -p "What is the URL for the coin daemon files?: " wget
zip="$(echo $wget | rev | cut -d'/' -f1 | cut -d'.' -f1 | rev)"
file="$(echo $wget | rev | cut -d'/' -f1 | rev)"
read -e -p "What is your private key?: " privkey
initial=$PWD

output "Checking total system memory."
    output ""
    sleep 3
    ram="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    swap="$(awk '/SwapTotal/ {print $2}' /proc/meminfo)"
    total="$(expr $ram + $swap)"
    if [ "$total" -le "524288" ]; then
        output "Not enough memory, making swapfile."
            output ""
            sleep 3
            dd if=/dev/zero of=/swapfile count=2048 bs=1M
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            swap="$(awk '/SwapTotal/ {print $2}' /proc/meminfo)"
            total="$(expr $ram + $swap)"
            if [ "$total" -le "524288" ]; then
                read -e -p "Could not allocate swap. Do you want to try and continue anyways? Y/n: " swapcon
                if [[ ("$swapcon" == "n" || "$swapcon" == "N") ]]; then
                    free -m
                    output "Requirement: 500 MB of Mem + Swap."
                    exit 1
                fi
            else
                echo "/swapfile   none    swap    sw    0   0" > /etc/fstab
            fi
    fi

if [ -z "$(dpkg -l | grep libdb4.8++-dev)" ]; then


output "Updating and upgrading system."
    output ""
	sleep 3
    
    sudo apt-get -y update 
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove

output "Installing required packages for daemons."
    output ""
    sleep 3  

    sudo apt install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev libdb4.8-dev libdb4.8++-dev python-virtualenv nano git unzip tar

fi 

output "Downloading and extracting files"
    output ""
	sleep 3
    sudo wget $wget
    if [[ "$zip" == "gz" ]]; then
        folder="${file%.tar.gz}"
        mkdir $folder
        tar -xzf $file -C $folder
        cd $folder
    elif [[ "$zip" == "zip" ]]; then
        folder="${file%.zip}"
        mkdir $folder
        unzip $file -d $folder
        cd $folder
    fi
    sudo chmod -R 777 *
    
output "Setting Up Masternode"
    output ""
	sleep 3
    coin="$(find . -name *d ! -name *.*d)"
    location=$PWD
    ./$coin
    pid="pgrep $coin"
    sleep 30
    kill -9 $pid
    cd 
    datadir="$(find -type d -name .${coin::-1})"
    cd $datadir
    config="$(find *.conf ! -name masternode.conf)"
    ip="$(curl ipecho.net/plain)"
    echo "rpcuser=servepeaku" >> $config
	echo "rpcpassword=servepeakp" >> $config
    echo "rpcallowip=127.0.0.1" >> $config
    echo "" >> $config
    echo "listen=1" >> $config
    echo "server=1" >> $config
    echo "daemon=1" >> $config
    echo "" >> $config
	echo "logtimestamps=1" >> $config
	echo "maxconnections=256" >> $config
    echo "" >> $config
	echo "masternode=1" >> $config
	echo "externalip=${ip}" >> $config
    echo "bind=${ip}" >> $config
    echo "masternodeprivkey=${privkey}" >> $config
    cd $location
    ./$coin
    cd $initial

output "Done! If your daemon does not sync you need to addnode= in your .{coinname}/{coinname}.conf"
output " "