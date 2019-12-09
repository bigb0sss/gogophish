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
${blue}${bold}
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

${bold}Usage: ${blue}./$(basename $0) [-s] [-d <domain name> ] [-c] [-h]${clear}

One shot to set up gophish server and/or create 
LetsEncrypt SSL cert for your choice of domain.

Options:

  -s 			Set up gophish server
  -d <domain name>      SSL cert for phishing domain
			${red}[WARNING] Configure 'A' record
			before running the script${clear}
  -c 			Clean-up for a fresh install
  -h              	This help message

EOF

exit $ec
 
}

exit_error() {
	usage
	exit 1
}

### Setup GoPhish
setup() {
	### Cleaning Port 80
	fuser -k -s -n tcp 80

	### Checking/Installing unzip
	unzip=$(which unzip)

	if [[ $unzip ]];
	then
		echo "${cyan}${bold}[+] Unzip already installed${clear}"
	else
		echo "${blue}${bold}[*] Installing unzip...${clear}"
		apt-get install unzip 1>/dev/null
	fi

	### Installing GoPhish v0.7.0 (*Reliable as of 11/30/19)
	echo "${blue}${bold}[*] Downloading gophish v0.7.0 (x64)...${clear}"
	wget https://github.com/gophish/gophish/releases/download/v0.7.0/gophish-v0.7.0-linux-64bit.zip -qq &&

	echo "${yellow}${bold}[*] Creating a gophish folder: /opt/gophish...${clear}"
	mkdir -p /opt/gophish &&

	echo "${yellow}${bold}[*] Extracting 🍖(meat) of gophish to /opt/gophish...${clear}"
	unzip -qq gophish-v0.7.0-linux-64bit.zip -d /opt/gophish &&

	### Cleaning
	rm gophish-v0.7.0-linux-64bit.zip &&

	echo "${yellow}${bold}[*] Creating a log folder: /var/log/gophish...${clear}"
	mkdir -p /var/log/gophish &&

	echo "${blue}${bold}[*] Installing gophish...${clear}"
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/gophish/config.json &&
	
	### Start Script Setup	
	cp gophish_start /etc/init.d/gophish &&
	chmod +x /etc/init.d/gophish &&
	update-rc.d gophish defaults &&

	ipAddr=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)
	sleep 1
	echo "${green}${bold}[+] Gophish started: https://$ipAddr:3333 ([Login] Username:admin Password:gophish)${clear}"
	service gophish start
}

### Setup SSL Cert
letsEncrypt() {
	### Clearning Port 80
	fuser -k -s -n tcp 80 
	service gophish stop 2>/dev/null
	
	### Installing certbot-auto
	echo "${blue}${bold}[*] Downloading certbot-auto...${clear}" 
	wget https://dl.eff.org/certbot-auto -qq
	chmod a+x certbot-auto
	echo "${blue}${bold}[*] Installing certbot-auto...(This may take a few sec...)${clear}"
	./certbot-auto --install-only --quiet 1>/dev/null

	### Installing SSL Cert	
	echo "${blue}${bold}[*] Installing SSL Cert for $domain...${clear}"
	# Manual
	#./certbot-auto certonly -d $domain --manual --preferred-challenges dns -m example@gmail.com --agree-tos && 
	./certbot-auto certonly --non-interactive --agree-tos --email example@gmail.com --standalone --preferred-challenges http -d $domain &&

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

gophishRestart() {
	service=$(ls /etc/init.d/gophish 2>/dev/null)

	if [[ $service ]];
	then
		sleep 1
		ipAddr=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)
		echo "${green}${bold}[+] Gophish restarted: https://$ipAddr:3333 ([Login] Username:admin Password:gophish)${clear}" &&
		service gophish restart
	else
		exit 1
	fi
}

cleanUp() {
	service gophish stop 2>/dev/null
	rm certbot-auto* 2>/dev/null
	rm -rf /opt/gophish 2>/dev/null
	rm /etc/init.d/gophish 2>/dev/null
	rm /etc/letsencrypt/keys/* 2>/dev/null
	rm /etc/letsencrypt/csr/* 2>/dev/null
	rm -rf /etc/letsencrypt/archive/* 2>/dev/null
	rm -rf /etc/letsencrypt/live/* 2>/dev/null
	echo "${green}${bold}[+] Clean-up done!${clear}"
}

domain=''

while getopts ":scd:h" opt; do
	case "${opt}" in
		s)
			banner
			setup ;;
		d) 
			domain=${OPTARG} 
			letsEncrypt && 
			gophishRestart ;;
		c)
			cleanUp ;;
		h | * ) 
			exit_error ;;
		:) 
			echo "${red}${bold}[-] Error: -${OPTARG} requires an argument (e.g.) gogophish.com)${clear}" 1>&2
			exit 1;;
	esac
done

if [[ $# -eq 0 ]];
then
	exit_error
fi
