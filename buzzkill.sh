#!/bin/bash

if [[ `whoami` != "root" ]]; then
	echo "Rerun as root"
	exit 1
fi

echo " ___            _   _ _ _ 
| _ )_  _ _____| |_(_) | |
| _ \ || |_ /_ / / / | | |
|___/\_,_/__/__|_\_\_|_|_|
                          
"
echo "         .' '.            __
.        .   .           (__\_
 .         .         . -{{_(|8)
   ' .  . ' ' .  . '     (__/
"

# remove hacking tools/games 
apt --purge -y remove netcat p0f iodine bind9 nfs-kernel-server wireshark fcrackzip squid icecast2 zangband zmap nmapsi4 amule qbot nmap postfix john ophcrack medusa

# update apt
apt update
apt full-upgrade -y
apt autoremove -y 

# ufw
apt install ufw -y

ufw enable
ufw status verbose
ufw default deny
ufw logging on

# media files

echo "░█▀▀░█▀▀░█▀█░█▀▄░█▀▀░█░█░▀█▀░█▀█░█▀▀░░░█▀▀░█▀█░█▀▄░░░█▄█░█▀▀░█▀▄░▀█▀░█▀█░░░
░▀▀█░█▀▀░█▀█░█▀▄░█░░░█▀█░░█░░█░█░█░█░░░█▀▀░█░█░█▀▄░░░█░█░█▀▀░█░█░░█░░█▀█░░░
░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀░░░▀░░░▀▀▀░▀░▀░░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀░▀░▀░
░█▀▀░█░█░█▀▀░█▀▀░█░█░░░█▀▀░▀█▀░█░░░█▀▀░█▀▀░░░░▀█▀░█░█░▀█▀
░█░░░█▀█░█▀▀░█░░░█▀▄░░░█▀▀░░█░░█░░░█▀▀░▀▀█░░░░░█░░▄▀▄░░█░
░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀░▀░░░▀░░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░░░▀░░▀░▀░░▀░
"

# music
find /home -name "*.mp3" >> files.txt
find /home -name "*.wav" >> files.txt
find /home -name "*.ogg" >> files.txt
find /home -name "*.wma" >> files.txt

# videos
find /home -name "*.mp4" >> files.txt
find /home -name "*.mov" >> files.txt
find /home -name "*.mkv" >> files.txt
find /home -name "*.wmv" >> files.txt

# pictures
find /home -name "*.jpeg" >> files.txt
find /home -name "*.png" >> files.txt
find /home -name "*.jpg" >> files.txt
find /home -name "*.svg" >> files.txt
find /home -name "*.tif" >> files.txt
find /home -name "*.webp" >> files.txt
find /home -name "*.gif" >> files.txt
find /home -name "*.ico" >> files.txt

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
		userdel $line
		echo -e "\t$line removed"
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
		gpasswd --delete $line adm
		echo -e "\t$line removed from admin"
	fi
done < /tmp/admins.tmp
rm admins.txt
rm /tmp/admins.tmp

echo "░█▀▀░█░█░█▀█░█░█░▀█▀░█▀█░█▀▀░░░█▀▄░█░█░█▀█░█▀█░▀█▀░█▀█░█▀▀
░▀▀█░█▀█░█░█░█▄█░░█░░█░█░█░█░░░█▀▄░█░█░█░█░█░█░░█░░█░█░█░█
░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀░░░▀░▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░▀▀▀
░█▀▀░█▀▀░█▀▄░█░█░█▀▀░█▀▄░█▀▀░░░░░░█▀▀░█░█░█▀▀░█▀▀░█░█
░▀▀█░█▀▀░█▀▄░▀▄▀░█▀▀░█▀▄░▀▀█░░░░░░█░░░█▀█░█▀▀░█░░░█▀▄
░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀░░░░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀░▀
░█▀▀░█▀▀░█▀▄░█░█░█▀▀░█▀▄░█▀▀░░░░▀█▀░█░█░▀█▀
░▀▀█░█▀▀░█▀▄░▀▄▀░█▀▀░█▀▄░▀▀█░░░░░█░░▄▀▄░░█░
░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀░░░▀░░▀░▀░░▀░
"

# print some servers
netstat -tulpn | grep "sshd" >> servers.txt
netstat -tulpn | grep "samba" >> servers.txt
netstat -tulpn | grep "apache" >> servers.txt
netstat -tulpn | grep "nginx" >> servers.txt
netstat -tulpn | grep "ftp" >> servers.txt

# auto updates
sudo cp apt-config /etc/apt/apt.conf.d/10periodic

# no permit root
sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
