#!/bin/bash

# system updates
echo "updating sources..."
sudo apt-get update >> buzzkill.log

echo "upgrading packages..."
sudo apt-get full-upgrade -y >> buzzkill.log

sudo apt-get autoremove -y >> buzzkill.log
sudo apt-get clean -y >> buzzkill.log

# find games
echo "searching for games..."
apt list --installed > /tmp/pkgs.tmp
echo "games: " >> buzzkill.log
while IFS= read -r line; do
	line=${line%%/*}
	buffer=`apt-cache show "$line"`
	if [[ $buffer == *"game"* ]]; then
		echo "$line";
        echo "$line" >> buzzkill.log;
	fi
done < /tmp/pkgs.tmp
rm /tmp/pkgs.tmp

# search for media files in /home

echo "searching for media files..."
# audio files
sudo find /home -name "*.mp3"  
sudo find /home -name "*.wav" 
sudo find /home -name "*.ogg" 
sudo find /home -name "*.wma" 

# video files
sudo find /home -name "*.mp4" 
sudo find /home -name "*.mov" 
sudo find /home -name "*.mkv" 
sudo find /home -name "*.wmv" 

# pictures
sudo find /home -name "*.jpeg" 
sudo find /home -name "*.png" 
sudo find /home -name "*.jpg" 
sudo find /home -name "*.svg" 
sudo find /home -name "*.tif" 
sudo find /home -name "*.webp"
sudo find /home -name "*.gif"
sudo find /home -name "*.ico"
