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

read -e -p "What is the GitHub URL for the coin source code?: " github
folder="$(echo $github | rev | cut -d'/' -f1 | rev | cut -d'.' -f 1)"
read -e -p "What is your private key?: " privkey
initial=$PWD

output "Checking total system memory."
    output ""
    sleep 3
    ram="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    swap="$(awk '/SwapTotal/ {print $2}' /proc/meminfo)"
    total="$(expr $ram + $swap)"
    if [ "$total" -le "1572864" ]; then
        output "Not enough memory, making swapfile."
            output ""
            sleep 3
            dd if=/dev/zero of=/swapfile count=2048 bs=1M
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            swap="$(awk '/SwapTotal/ {print $2}' /proc/meminfo)"
            total="$(expr $ram + $swap)"
            if [ "$total" -le "1572864" ]; then
                read -e -p "Could not allocate swap. Do you want to try and continue anyways? Y/n: " swapcon
                if [[ ("$swapcon" == "n" || "$swapcon" == "N") ]]; then
                    free -m
                    output "Requirement: 1500 MB of Mem + Swap."
                    exit 1
                fi
            else
                echo "/swapfile   none    swap    sw    0   0" > /etc/fstab
            fi
    fi

if [ -z "$(dpkg -l | grep libgmp-dev)" ]; then


output "Updating and upgrading system."
    output ""
	sleep 3
    
    sudo apt-get -y update 
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove

output "Installing required packages for daemons."
    output ""
    sleep 3  

    sudo apt-get -y install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
    sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
    sudo apt-get -y install libboost-all-dev
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository -y ppa:bitcoin/bitcoin
    sudo apt-get update
    sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
    sudo apt-get -y install libminiupnpc-dev
    sudo apt-get -y install libzmq3-dev
    sudo apt-get -y install libgmp-dev

fi 

output "Compiling Coin"
    output ""
	sleep 3
    sudo git clone $github
    cd $folder
    sudo chmod -R 777 *
    cd src
    if [ -f "makefile.unix" ]; then
        sudo make -f makefile.unix
    else
        cd ..
        sudo ./autogen.sh
        sudo ./configure
        sudo make
        cd src
    fi
    
output "Setting Up Masternode"
    output ""
	sleep 3
    coin="$(find *d -prune -type f ! -name *.*d)"
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