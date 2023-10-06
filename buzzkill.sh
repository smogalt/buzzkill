#!/bin/bash

if [[ $1 == "--help" ]]; then
	echo -e "Usage: buzzkill [OPTION]"
	echo -e "buzzkill is a tool for administrative functions such as \nsystem 
		updates, user audits, security configs and more.\n"
	echo -e "options: "
	echo -e "\t--help            display this help message"
	echo -e "\tadmin-audit       compares list of athorized admins against 
		members of adm group"
	echo -e "\tauto-update       sets up daily updates. don't mess with the
		config file under 'apt-config'"
	echo -e "\tfirewall          set up ufw"
	echo -e "\tget-servers       show all running web servers"
	echo -e "\tmedia-search      finds all media files in /home directory"
	echo -e "\tpackage-search    search for games installed with apt"
	echo -e "\tupdate            update via apt"
	echo -e "\tuser-audit        compares list of allowed users against 
		system users"

	exit 0
fi

if [[ $1 == "update" ]]; then
	# system updates
	echo "updating sources..."
	sudo apt-get update >> buzzkill.log

	echo "upgrading packages..."
	sudo apt-get full-upgrade -y >> buzzkill.log

	sudo apt-get autoremove -y >> buzzkill.log
	sudo apt-get clean -y >> buzzkill.log
	echo -e "\n\n" >> buzzkill.log
	exit 0
fi

if [[ $1 == "firewall" ]]; then
	# firewall
	echo "installing firewall..."
	sudo apt install ufw >> buzzkill.log
	echo "turning firewall on..."
	sudo ufw enable >> buzzkill.log
	sudo ufw status verbose >> buzzkill.log
	sudo ufw default deny >> buzzkill.log
	sudo ufw logging on >> buzzkill.log
	exit 0
fi

if [[ $1 == "package-search" ]]; then
	# find games
	apt list --installed > /tmp/pkgs.tmp
	echo "packages: " >> buzzkill.log

	package="$2"

	if [[ $2 == "" ]]; then
		package="game"
	fi

	while IFS= read -r line; do
		line=${line%%/*}
		buffer=`apt-cache show "$line"`
		if [[ $buffer == *"$package"* ]]; then
			echo "$line";
			echo "$line" >> buzzkill.log;
		fi
	done < /tmp/pkgs.tmp
	rm /tmp/pkgs.tmp
	exit 0
fi

# search for media files in /home
if [[ $1 == "media-search" ]]; then
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
	exit 0
fi

if [[ $1 == "user-audit" ]]; then
	# user-audit
	if test -f "users.txt"; then
		echo > /dev/null
	else
		echo "list of users is needed. put list in \"users.txt\""
	fi

	grep -E '10[0-9][0-9]' /etc/passwd | cut -d: -f1 > /tmp/users.tmp

	while IFS= read -r line; do
		if grep "$line" users.txt >> /dev/null; then
			echo > /dev/null
		else
			echo $line
		fi
	done < /tmp/users.tmp

	rm /tmp/users.tmp
	exit 0
fi

if [[ $1 == "admin-audit" ]]; then
	if test -f "admins.txt"; then
		echo > /dev/null
	else
		echo "list of users is needed. put list in \"users.txt\""
	fi

	grep "sudo" /etc/group | cut -d: -f4 | sed -e $'s/,/\\\n/g' > /tmp/admins.tmp

	while IFS= read -r line; do
		if grep "$line" admins.txt > /dev/null; then
			echo > /dev/null
		else
			echo "$line"
		fi
	done < /tmp/admins.tmp

	rm /tmp/admins.tmp
	exit 0
fi

if [[ $1 = "get-servers" ]]; then
	netstat -tulpn | grep "sshd"
	netstat -tulpn | grep "samba"
	netstat -tulpn | grep "apache"
	netstat -tulpn | grep "nginx"
	netstat -tulpn | grep "ftp"
	exit 0
fi

if [[ $1 = "auto-update" ]]; then
	sudo cp apt-config /etc/apt/apt.conf.d/10periodic
fi

if [[ $1 = "ssh-config" ]]; then
	sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
fi

echo "Invalid argument:"
echo "Try 'buzzkill --help' for more information."

exit 0
