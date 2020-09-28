#!/usr/bin/env bash
# Version         : 2.0
# Created date    : 12/09/2019
# Last update     : 09/27/2020
# Author          : bigb0ss
# Description     : Automated script to install gophish
# Note            : 
#                   09/20/20 - gophish admin password is not longer static. Added function to grab the temporary password for the initial login. You will be prompted to change the password as you login

### Colors
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 4`;
magenta=`tput setaf 5`;
cyan=`tput setaf 6`;
bold=`tput bold`;
clear=`tput sgr0`;

banner() {
cat <<EOF
${blue}${bold}
	                          _     _     _
                                 | |   (_)   | |
     __ _  ___   __ _  ___  _ __ | |__  _ ___| |__
    / _\` |/ _ \ / _\` |/ _ \| '_ \| '_ \| / __| '_ \\
   | (_| | (_) | (_| | (_) | |_) | | | | \__ \ | | |
    \__, |\___/ \__, |\___/| .__/|_| |_|_|___/_| |_|
     __/ |       __/ |     | |           [bigb0ss]
    |___/       |___/      |_|

        /|
       / |   /|
   <===  |=== | --------------------------------v2.0
       \ |   \|
        \|
${clear}
EOF

}

usage() {
  local ec=0

  if [ $# -ge 2 ] ; then
    ec="$1" ; shift
    printf "%s\n\n" "$*" >&2
  fi

  banner
  cat <<EOF

A quick Bash script to install GoPhish server. 

${bold}Usage: ${blue}./$(basename $0) [-r <rid name>] [-e] [-s] [-d <domain name> ] [-c] [-h]${clear}

One shot to set up:
  - Gophish Server (Email Phishing Ver.)
  - Gophish Server (SMS Phishing Ver.)
  - SSL Cert for Phishing Domain (LetsEncrypt)

Options:
  -e 			Setup Email Phishing Gophish Server
  -s 			Setup SMS Phishing Gophish Server
  -r <rid name>		Configure custom "rid=" parameter for landing page (e.g., https://example.com?rid={{.RID}})
			If not specified, the default value would be "secure_id="
  -d <domain name>      SSL cert for phishing domain
			${red}[WARNING] Configure 'A' record before running the script${clear}
  -c 			Cleanup for a fresh install
  -h              	This help menu

Examples:
  ./$(basename $0) -e					Setup Email Phishing Gophish
  ./$(basename $0) -s					Setup SMS Phishing Gophish
  ./$(basename $0) -r <rid name> -e 			Setup Email Phishing Gophish + Your choice of rid
  ./$(basename $0) -r <rid name> -s			Setup SMS Phishing Gophish + Your choice of rid
  ./$(basename $0) -d <domain name>			Configure SSL cert for your phishing Domain
  ./$(basename $0) -e -d <domain name>			Email Phishing Gophish + SSL cert for Phishing Domain
  ./$(basename $0) -r <rid name> -e -d <domain name> 	Email Phishing Gophish + SSL cert + rid 

EOF

exit $ec
 
}

### Exit
exit_error() {
	usage
	exit 1
}

### Initial Update & Dependency Check
dependencyCheck() {
	### Update Sources
	echo "${blue}${bold}[*] Updating source lists...${clear}"
	apt-get update -y >/dev/null 2>&1	


	### Checking/Installing unzip
	unzip=$(which unzip)

	if [[ $unzip ]];
	then
		echo "${green}${bold}[+] Unzip already installed${clear}"
	else
		echo "${blue}${bold}[*] Installing unzip...${clear}"
		apt-get install unzip -y >/dev/null 2>&1
	fi

	### Checking/Installing go
        gocheck=$(which go)

        if [[ $gocheck ]];
        then
                echo "${green}${bold}[+] Golang already installed${clear}"
        else
                echo "${blue}${bold}[*] Installing Golang...${clear}"
                apt-get install golang -y >/dev/null 2>&1
        fi
	
	### Checking/Installing git
        gitcheck=$(which git)

        if [[ $gitcheck ]];
        then
                echo "${green}${bold}[+] Git already installed${clear}"
        else
                echo "${blue}${bold}[*] Installing Git...${clear}"
                apt-get install git -y >/dev/null 2>&1
        fi

	### Checking/Installing pip (*Needed to install Twilio lib)
        pipcheck=$(which pip)

	if [[ $pipcheck ]];
        then
                echo "${green}${bold}[+] Pip already installed${clear}"
        else
                echo "${blue}${bold}[*] Installing pip...${clear}"
                apt-get install python-pip -y >/dev/null 2>&1
		
        fi

}

### Setup Email Version Gophish
setupEmail() {
	### Cleaning Port 80
	fuser -k -s -n tcp 80

	### Deleting Previous Gophish Source (*Need to be removed to update new rid)
	rm -rf /root/go/src/github.com/gophish >/dev/null 2>&1 &&

	### Installing GoPhish v0.8.0
        echo "${blue}${bold}[*] Downloading gophish (x64)...${clear}"
        mkdir -p /root/go &&
	export GOPATH=/root/go &&
	go get github.com/gophish/gophish >/dev/null 2>&1 &&

	echo "${blue}${bold}[*] Creating a gophish folder: /opt/gophish${clear}"
        mkdir -p /opt/gophish &&

	if [ "$rid" != "" ]
	then
		echo "${blue}${bold}[*] Updating \"rid\" to \"$rid\"${clear}"
	        sed -i 's!rid!'$rid'!g' $GOPATH/src/github.com/gophish/gophish/models/campaign.go
		ridConfirm=$(cat $GOPATH/src/github.com/gophish/gophish/models/campaign.go | grep $rid)
		echo "${blue}${bold}[*] Confirmation: $ridConfirm (campaign.go)${clear}"
    fi

	go build $GOPATH/src/github.com/gophish/gophish &&
	mv ./gophish /opt/gophish/gophish &&
	cp -R $GOPATH/src/github.com/gophish/gophish/* /opt/gophish &&
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/gophish/config.json &&

        echo "${blue}${bold}[*] Creating a gophish log folder: /var/log/gophish${clear}"
        mkdir -p /var/log/gophish &&

	### Start Script Setup	
	cp gophish_start /etc/init.d/gophish &&
	chmod +x /etc/init.d/gophish &&
	update-rc.d gophish defaults
}

setupSMS() {
	### Cleaning Port 80
	fuser -k -s -n tcp 80

	### Deleting Previous Gophish Source (*Need to be removed to update new rid)
	rm -rf $GOPATH/src/github.com/gophish >/dev/null 2>&1 &&

	### Installing GoPhish v0.8.0
        echo "${blue}${bold}[*] Downloading gophish (x64)...${clear}"
        mkdir -p /root/go &&
	export GOPATH=/root/go &&
	go get github.com/gophish/gophish >/dev/null 2>&1 &&

	echo "${blue}${bold}[*] Creating a gophish folder: /opt/gophish${clear}"
        mkdir -p /opt/gophish &&

	if [ "$rid" != "" ]
	then
		echo "${blue}${bold}[*] Updating \"rid\" to \"$rid\"${clear}"
	        sed -i 's!rid!'$rid'!g' $GOPATH/src/github.com/gophish/gophish/models/campaign.go
		ridConfirm=$(cat $GOPATH/src/github.com/gophish/gophish/models/campaign.go | grep $rid)
		echo "${blue}${bold}[*] Confirmation: $ridConfirm (campaign.go)${clear}"
    fi

	go build $GOPATH/src/github.com/gophish/gophish &&
	mv ./gophish /opt/gophish/gophish &&
	cp -R $GOPATH/src/github.com/gophish/gophish/* /opt/gophish &&
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/gophish/config.json &&

        echo "${blue}${bold}[*] Creating a gophish log folder: /var/log/gophish${clear}"
        mkdir -p /var/log/gophish &&

	### Getting gosmish.py (Author: fals3s3t)
	echo "${blue}${bold}[*] Pulling gosmish.py (Author: fals3s3t) to: /opt/gophish...${clear}"
	wget https://raw.githubusercontent.com/fals3s3t/gosmish/master/gosmish.py -P /opt/gophish/gosmish.py 2>/dev/null &&
	chmod +x /opt/gophish/gosmish.py

	### Installing Twilio
	echo "${blue}${bold}[*] Installing Twilio...${clear}"
	pip install -q  twilio >/dev/null 2>&1 &&

	echo "${blue}${bold}[*] Installing and configuring Postfix for SMS SMTP blackhole...${clear}"
	name=$(hostname)
	echo "postfix    postfix/mailname string sms.sms " | debconf-set-selections
	echo "postfix postfix/main_mailer_type string 'Local Only'" | debconf-set-selections
	apt-get -y  install postfix >/dev/null 2>&1
	apt-get -y  install postfix-pcre >/dev/null 2>&1

	sed -i  "/myhostname/c\myhostname = $name" /etc/postfix/main.cf >/dev/null 2>&1 &&
	echo 'virtual_alias_maps = pcre:/etc/postfix/virtual' >> /etc/postfix/main.cf
	echo '/.*/                        nonexist' > /etc/postfix/virtual
	service postfix stop &&
	service postfix start &&

	### Start Script Setup	
	cp gophish_start /etc/init.d/gophish &&
	chmod +x /etc/init.d/gophish &&
	update-rc.d gophish defaults
}


### Setup SSL Cert
letsEncrypt() {
	### Clearning Port 80
	fuser -k -s -n tcp 80 
	service gophish stop 2>/dev/null
	
	### Installing certbot-auto
	echo "${blue}${bold}[*] Installing certbot...${clear}" 
	#wget https://dl.eff.org/certbot-auto -qq
	#chmod a+x certbot-auto
	apt-get install certbot -y >/dev/null 2>&1

	### Installing SSL Cert	
	echo "${blue}${bold}[*] Installing SSL Cert for $domain...${clear}"

	### Manual
	#./certbot-auto certonly -d $domain --manual --preferred-challenges dns -m example@gmail.com --agree-tos && 
	### Auto
	certbot certonly --non-interactive --agree-tos --email example@gmail.com --standalone --preferred-challenges http -d $domain &&

	echo "${blue}${bold}[*] Configuring New SSL cert for $domain...${clear}" &&
	cp /etc/letsencrypt/live/$domain/privkey.pem /opt/gophish/domain.key &&
	cp /etc/letsencrypt/live/$domain/fullchain.pem /opt/gophish/domain.crt &&
	sed -i 's!false!true!g' /opt/gophish/config.json &&
	sed -i 's!:80!:443!g' /opt/gophish/config.json &&
	sed -i 's!example.crt!domain.crt!g' /opt/gophish/config.json &&
	sed -i 's!example.key!domain.key!g' /opt/gophish/config.json &&
	mkdir -p /opt/gophish/static/endpoint &&
	printf "User-agent: *\nDisallow: /" > /opt/gophish/static/endpoint/robots.txt &&
	echo "${green}${bold}[+] Check if the cert is correctly installed: https://$domain/robots.txt${clear}"
}

gophishStart() {
	service=$(ls /etc/init.d/gophish 2>/dev/null)

	if [[ $service ]];
	then
		sleep 1
		service gophish restart &&
		#ipAddr=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)
		ipAddr=$(curl ifconfig.io 2>/dev/null)
		pass=$(cat /var/log/gophish/gophish.error | grep 'Please login with' | cut -d '"' -f 4 | cut -d ' ' -f 10 | tail -n 1)
		echo "${green}${bold}[+] Gophish Started: https://$ipAddr:3333 - [Login] Username: admin, Temporary Password: $pass${clear}"
	else
		exit 1
	fi
}

cleanUp() {
	echo "${green}${bold}Cleaning...1...2...3...${clear}"
	service gophish stop 2>/dev/null
	rm -rf /root/go/src/github.com/gophish 2>/dev/null
	rm certbot-auto* 2>/dev/null
	rm -rf /opt/gophish 2>/dev/null
	rm /etc/init.d/gophish 2>/dev/null
	rm /etc/letsencrypt/keys/* 2>/dev/null
	rm /etc/letsencrypt/csr/* 2>/dev/null
	rm -rf /etc/letsencrypt/archive/* 2>/dev/null
	rm -rf /etc/letsencrypt/live/* 2>/dev/null
	rm -rf /etc/letsencrypt/renewal/* 2>/dev/null
	echo "${green}${bold}[+] Done!${clear}"
}

domain=''
rid=''

while getopts ":r:esd:ch" opt; do
	case "${opt}" in
		r)
			rid=$OPTARG ;;
		e)
			banner
			dependencyCheck
			setupEmail
			gophishStart ;;
		s)
			banner
			dependencyCheck
			setupSMS
			gophishStart ;;
		d) 
			domain=${OPTARG} 
			letsEncrypt && 
			gophishStart ;;
		c)
			cleanUp ;;
		h | * ) 
			exit_error ;;
		:) 
			echo "${red}${bold}[-] Error: -${OPTARG} requires an argument (e.g., -r page_id or -d gogophish.com)${clear}" 1>&2
			exit 1;;
	esac
done

if [[ $# -eq 0 ]];
then
	exit_error
fi
