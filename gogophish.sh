#!/usr/bin/env bash
#
# gogophish       
#
# Author: bigb0ss 
#

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
                               _     _     _
                              | |   (_)   | |
  __ _  ___   __ _  ___  _ __ | |__  _ ___| |__
 / _\` |/ _ \ / _\` |/ _ \| '_ \| '_ \| / __| '_ \\
| (_| | (_) | (_| | (_) | |_) | | | | \__ \ | | |
 \__, |\___/ \__, |\___/| .__/|_| |_|_|___/_| |_|
  __/ |       __/ |     | |   [bigb0ss]
 |___/       |___/      |_|

     /|
    / |   /|
<===  |=== | ------------------------------------
    \ |   \|
     \|

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

Usage:
       $(basename $0) [-d <domain name> ]

One shot to set up gophish server. If domain added, 
it will create LetsEncrypt SSL cert and configure it 
to the gophish server.

Options:

  -d <domain name>      Your phishing domain
  -h              	This help message

EOF

exit $ec
 
}

### Setup GoPhish
setup() {
	### Checking/Installing unzip
	unzip=$(which unzip)

	if [[ $unzip ]];
	then
		echo "${green}${bold}[+] Unzip already installed${clear}"
	else
		echo "${green}${bold}[*] Installing unzip...${clear}"
		apt-get install unzip -qq
	fi

	### Installing certbot-auto
	echo "${green}${bold}[*] Downloading certbot-auto...${clear}" 
	wget https://dl.eff.org/certbot-auto -qq
	chmod a+x certbot-auto
	echo "${green}${bold}[*] Installing certbot-auto...${clear}"
	./certbot-auto --install-only --quiet

	### Installing GoPhish v0.7.0 (*Reliable as of 11/30/19)
	echo "${green}${bold}[*] Downloading gophish v0.7.0 (x64)...${clear}"
	wget https://github.com/gophish/gophish/releases/download/v0.7.0/gophish-v0.7.0-linux-64bit.zip -qq

	echo "${yellow}${bold}[*] Creating a gophish folder: /opt/gophish...${clear}"
	mkdir -p /opt/gophish

	echo "${yellow}${bold}[*] Extracting meat of gophish to /opt/gophish...${clear}"
	unzip -qq gophish-v0.7.0-linux-64bit.zip -d /opt/gophish

	echo "${yellow}${bold}[*] Creating a log folder: /var/log/gophish...${clear}"
	mkdir -p /var/log/gophish

	echo "${green}${bold}[*] Installing gophish...${clear}"
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/gophish/config.json
	cp gophish /etc/init.d/gophish
	chmod +x /etc/init.d/gophish
	update-rc.d gophish defaults

	ipAddr=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
	echo "${cyan}${bold}[+] Gophish started: https://$ipAddr:3333 (Login: admin:gophish)${clear}"
	service gophish start
}

### Setup SSL Cert
letsEncrypt() {
	echo "${green}${bold}[*] Installing SSL Cert for $domain...${clear}"
	./certbot-auto certonly -d $domain --manual --preferred-challenges dns && 
	
	echo "${green}${bold}[*] Configuring New SSL cert for $domain...${clear}" &&
	cp /etc/letsencrypt/live/$domain/privkey.pem /opt/gophish/domain.key &&
	cp /etc/letsencrypt/live/$domain/fullchain.pem /opt/gophish/domain.crt &&
	sed -i 's!false!true!g' /opt/gophish/config.json &&
	sed -i 's!:80!:443!g' /opt/gophish/config.json &&
	sed -i 's!example.crt!domain.crt!g' /opt/gophish/config.json &&
	sed -i 's!example.key!domain.key!g' /opt/gophish/config.json &&
	
	ipAddr=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
	echo "${cyan}${bold}[+] Gophish restarted: https://$ipAddr:3333 (Login: admin:gophish)${clear}" &&
	service gophish restart
}

domain=''

while getopts 'hd:' opt; do
	case "$opt" in
		d) domain=$OPTARG ;;
		h) usage ;;
	esac
done

args=( "$domain" 1 )

if [ -n "$domain" ]; then
	banner
	setup	
	letsEncrypt 
else
	banner
	setup
fi
