#!/bin/bash

if [[ `whoami` != "root" ]]; then
	echo "need to be root to run"
	exit 1
fi

# remove hacking games 
apt --purge -y remove netcat p0f iodine bind9 nfs-kernel-server wireshark fcrackzip squid icecast2 zangband zmap nmapsi4 amule qbot nmap postfix john ophcrack medusa

# update apt
apt update
apt full-upgrade
apt autoremove

# ufw
apt install ufw

ufw enable
ufw status verbose
ufw default deny
ufw logging on

# media files
# music
find /home -name "*.mp3"
find /home -name "*.wav"
find /home -name "*.ogg"
find /home -name "*.wma"

# videos
find /home -name "*.mp4"
find /home -name "*.mov"
find /home -name "*.mkv"
find /home -name "*.wmv"

# pictures
find /home -name "*.jpeg"
find /home -name "*.png"
find /home -name "*.jpg"
find /home -name "*.svg"
find /home -name "*.tif"
find /home -name "*.webp"
find /home -name "*.gif"
find /home -name "*.ico"

# user audit
address=$1

if [[ $1 = "" ]]; then
	echo "enter README address:"
	read -r address
fi

curl -s $address > /tmp/readme.tmp

# ADMINS
# get all admins
sed -i -n -e '/Authorized Administrators:/,/Authorized Users:/p' /tmp/readme.tmp

# remove password part
sed -i -e '/password/d' /tmp/readme.tmp

# remove tags
sed -i -e '/Authorized Users:/d' /tmp/readme.tmp
sed -i -e '/Authorized Administrators:/d' /tmp/readme.tmp

# remove 'you' mark
sed -i -e 's/(you)//g' /tmp/readme.tmp

# move to admins.txt
cat /tmp/readme.tmp > admins.txt

# get fresh file
curl -s $address > /tmp/readme.tmp

# USERS
# get list of users
sed -i -n -e '/Authorized Users:/,/pre/p' /tmp/readme.tmp

# remove tags
sed -i -e '/Authorized Users:/d' /tmp/readme.tmp
sed -i -e '/pre/d' /tmp/readme.tmp

# move to users.txt
cat /tmp/readme.tmp > users.txt

# add admins to file
cat admins.txt >> users.txt

rm /tmp/readme.tmp

# user-audit
if test -f "users.txt"; then
	echo > /dev/null
else
	echo "list of users is needed. put list in \"users.txt\""
fi

grep -E '10[0-9][0-9]' /etc/passwd | cut -d: -f1 > /tmp/users.tmp

echo "users:"
while IFS= read -r line; do
	if grep "$line" users.txt >> /dev/null; then
		echo > /dev/null
	else
		echo -e "\t$line"
	fi
done < /tmp/users.tmp
rm users.txt
rm /tmp/users.tmp

# admin audit
if test -f "admins.txt"; then
	echo > /dev/null
else
	echo "list of admins is needed. put list in \"admins.txt\""
fi

grep "sudo" /etc/group | cut -d: -f4 | sed -e $'s/,/\\\n/g' > /tmp/admins.tmp

echo "admins:"
while IFS= read -r line; do
	if grep "$line" admins.txt > /dev/null; then
		echo > /dev/null
	else
		echo -e "\t$line"
	fi
done < /tmp/admins.tmp
rm admins.txt
rm /tmp/admins.tmp

# print some servers
netstat -tulpn | grep "sshd"
netstat -tulpn | grep "samba"
netstat -tulpn | grep "apache"
netstat -tulpn | grep "nginx"
netstat -tulpn | grep "ftp"

# auto updates
sudo cp apt-config /etc/apt/apt.conf.d/10periodic

# no permit root
sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
