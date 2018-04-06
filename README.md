# Masternode Setup Script
Te bash scripts will go through the setup process to create the masternode coin daemon.

### git_setup.sh
###### Run this if you want to compile from source code
1. Asks for github link.
2. Asks for private key. Get this from your main wallet by running ```masternode genkey``` in your debug window or cli
3. Checks if 1.5GB of memory is available. If not, attempts to create a 2GB swapfile.
4. Updates and upgrades system.
5. Installs required packages.
6. Pulls from github and compiles coin.
7. Sets up the coin daemon conf file.

### wget_setup.sh - TODO
###### Run this if you already have the daemon files
1. Asks for zip or tar url. 
If the files are already extracted into the current directory, leave this blank.
2. Asks for private key. Get this from your main wallet by running ```masternode genkey``` in your debug window or cli
3. Checks if 0.5GB of memory is available. If not, attempts to create a 2GB swapfile.
4. Updates and upgrades system.
5. Installs required packages.
6. Wgets url and extracts.
7. Sets up the coin daemon conf file.

Example .conf
```
rpcuser=servepeaku
rpcpassword=servepeakp
rpcallowip=127.0.0.1

listen=1
server=1
daemon=1

logtimestamps=1
maxconnections=256

masternode=1
externalip=0.0.0.0
bind=0.0.0.0
masternodeprivkey=7rRc1kGaYkGeUNp2ZFPRaWqKxGd5hSDVTgqsPK9NPs8mcaAzZ4E
```

Donate via BTC: [35K33YaAjsq1trdynNeeQfisnQXXxjaSEF](bitcoin:35K33YaAjsq1trdynNeeQfisnQXXxjaSEF)