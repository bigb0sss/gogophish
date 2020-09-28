<p align="center">
  <img src="https://github.com/bigb0sss/gogophish/blob/master/gogophish_img.png">
</p>

# Gogophish

A quick Bash script to automate the [Gophish](https://github.com/gophish/gophish) installation + LetsEncrypt your phishing domain.

Gophish is an open-source phishing toolkit designed for businesses and penetration testers. It provides the ability to quickly and easily setup and execute phishing engagements and security awareness training.

Table of contents
=================

<!--ts-->
   * [Installation](#installation)
   * [Usage](#usage)
   * [Example](#example)
   * [Phishing Server](#phishing-server-vps)
       * [AWS](#aws)
   * [Wildcard SSL Certificate Setup](#wildcard-ssl-certificate-setup)
<!--te-->

## Installation

```
git clone https://github.com/bigb0sss/gogophish.git
cd gogophish
chmod +x gogophish.sh
```

## Usage & Example

This script will help you automate installing + configuring your phishing domain with SSL certificate using [Certbot](https://github.com/certbot/certbot).

### Usage
```
./gogophish.sh -h
	                          _     _     _
                                 | |   (_)   | |
     __ _  ___   __ _  ___  _ __ | |__  _ ___| |__
    / _` |/ _ \ / _` |/ _ \| '_ \| '_ \| / __| '_ \
   | (_| | (_) | (_| | (_) | |_) | | | | \__ \ | | |
    \__, |\___/ \__, |\___/| .__/|_| |_|_|___/_| |_|
     __/ |       __/ |     | |           [bigb0ss]
    |___/       |___/      |_|

        /|
       / |   /|
   <===  |=== | --------------------------------v2.0
       \ |   \|
        \|


A quick Bash script to install GoPhish server.

Usage: ./gogophish.sh [-r <rid name>] [-e] [-s] [-d <domain name> ] [-c] [-h]

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
			[WARNING] Configure 'A' record before running the script
  -c 			Cleanup for a fresh install
  -h              	This help menu

Examples:
  ./gogophish.sh -e					Setup Email Phishing Gophish
  ./gogophish.sh -s					Setup SMS Phishing Gophish
  ./gogophish.sh -r <rid name> -e 			Setup Email Phishing Gophish + Your choice of rid
  ./gogophish.sh -r <rid name> -s			Setup SMS Phishing Gophish + Your choice of rid
  ./gogophish.sh -d <domain name>			Configure SSL cert for your phishing Domain
  ./gogophish.sh -e -d <domain name>			Email Phishing Gophish + SSL cert for Phishing Domain
  ./gogophish.sh -r <rid name> -e -d <domain name> 	Email Phishing Gophish + SSL cert + rid

```

### Example

```
./gogophish.sh -e -d phish-me.com

	                          _     _     _
                                 | |   (_)   | |
     __ _  ___   __ _  ___  _ __ | |__  _ ___| |__
    / _` |/ _ \ / _` |/ _ \| '_ \| '_ \| / __| '_ \
   | (_| | (_) | (_| | (_) | |_) | | | | \__ \ | | |
    \__, |\___/ \__, |\___/| .__/|_| |_|_|___/_| |_|
     __/ |       __/ |     | |           [bigb0ss]
    |___/       |___/      |_|

        /|
       / |   /|
   <===  |=== | --------------------------------v2.0
       \ |   \|
        \|

[*] Updating source lists...
[+] Unzip already installed
[+] Golang already installed
[+] Git already installed
[*] Installing pip...
[*] Downloading gophish (x64)...
[*] Creating a gophish folder: /opt/gophish
[*] Creating a gophish log folder: /var/log/gophish
[+] Gophish Started: https://18.188.242.148:3333 - [Login] Username: admin, Temporary Password: 9b1463f87a726fd0
[*] Installing certbot...
[*] Installing SSL Cert for phish-me.com...
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Obtaining a new certificate

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/phish-me.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/phish-me.com/privkey.pem
   Your cert will expire on 2020-12-27. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

[*] Configuring New SSL cert for phish-me.com...
[+] Check if the cert is correctly installed: https://phish-me.com/robots.txt
[+] Gophish Started: https://18.188.242.148:3333 - [Login] Username: admin, Temporary Password: 08dc04c93066b242

```

## Phishing Server (VPS)
### AWS

```
1) Install aws-cli - https://github.com/aws/aws-cli
* MacOS
$ wget https://awscli.amazonaws.com/AWSCLIV2.pkg
$ installer -pkg AWSCLIV2.pkg -target

2) AWS Configure
$ aws configure
	AWS Access Key ID [None]: <Your Access Key>
	AWS Secret Access Key [None]: <Your Secret Access Key>
	Default region name [None]: us-east-2
	Default output format [None]: json

3) SSH Key Pairs
First, 'ssh-keygen' to create a SSH key pair
Second, import the .pub key to AWS EC2 Key Pair

$ aws ec2 import-key-pair \
	--key-name gogophish-ssh \
	--public-key-material file:///Users/bigb0ss/tools/aws-cli/.ssh/gogophish_id_rsa.pub \
	--region us-east-2
	
4) Create AWS EC2
$ ./ec2_create.sh - https://github.com/bigb0sss/gogophish/blob/master/aws/ec2_create.sh

5) Terminate AWS EC2
$ ./ec2_termination.sh - https://github.com/bigb0sss/gogophish/blob/master/aws/ec2_termination.sh
```

### Vultr
coming soon...

## Wildcard SSL Certificate Setup

If you are planning to use subdomains with your phishing domain, do the following to add the wildcard SSL certificate. 

```
1) Run the following Certbot command:
$ certbot certonly -d *.phish-me.com --manual --preferred-challenges dns

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for phish-me.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.phish-me.com with the following value:

yunoNuR-DxwUpypvTGYtWpysYslnAFutagi7swXoi6k

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue

2) Configure the above _acme-challege to your domain's DNS TXT record. Use the following command to confirm:
$ dig -t TXT _acme-challenge.phish-me.com

; <<>> DiG 9.10.6 <<>> -t TXT _acme-challenge.phish-me.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39714
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;_acme-challenge.phish-me.com. IN	TXT

;; ANSWER SECTION:
_acme-challenge.phish-me.com. 3600 IN TXT	"yunoNuR-DxwUpypvTGYtWpysYslnAFutagi7swXoi6k"

3) Run the following Bash script:

#!/usr/bin/bash
domain="<Your Domain>"

cp /etc/letsencrypt/live/$domain-0001/privkey.pem /opt/gophish/domain.key &&
cp /etc/letsencrypt/live/$domain-0001/fullchain.pem /opt/gophish/domain.crt 
service gophish restart
```

## Work In-Progress
* SMS Phishing Server Config is not 100% integrated to gogophish. And disclaimer to using fals3s3t python script.

## Change Log
* 09/26/20 - gogophish BETA is decommissioned
* 09/27/20 - gogophish v1.0 is decommissioned
* 09/27/20 - gogophish v2.0 is uploaded
