# Gogophish

A quick Bash script to automate the [Gophish](https://github.com/gophish/gophish) installation.

Gophish is an open-source phishing toolkit designed for businesses and penetration testers. It provides the ability to quickly and easily setup and execute phishing engagements and security awareness training.

## Usage & Example
### Usage
```
./gogophish.sh

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
</br>
### Example



### Work In-Progress
* SMS Phishing Server Config is not 100% integrated to gogophish. And disclaimer to using fals3s3t python script.

## Change Log
* 09/26/20 - gogophish BETA is decommissioned
* 09/27/20 - gogophish v1.0 is decommissioned
* 09/27/20 - gogophish v2.0 is uploaded
