#!/bin/bash
# GoDaddy.shl
# Brian Snelgrove
# January 18, 2020
#
# update GoDaddy DNS records
# file to track old IP addresses is written
# must be executed in a location that can be written to!
# . ./GoDaddy.shl must be used to execute!
#
# this script uses ssmtp to send emails if the DNS updates failed
# it also updates/restores the configuration file for ssmtp - as such this should be run as root user

# !!!
# user defined variables, update them as needed
# !!!
# domain - TLD that is being targeted
DOMAIN="EXAMPLE.COM";
DNS="HOSTNAME";
CACHEFILE="${DNS}.${DOMAIN}";
# account key
KEY="MY_GODADDY_KEY";
# account key secret
SECRET="MY_GODADDY_SECRET";
# time to live for the DNS entry
# godaddy has a minimum of 600 seconds
TTL="600";
# email address (from and to)
EMAIL="MYEMAILADDRESS";
# email password - if 2fa is enabled you should be able 
#to get an app password to work here
EMAILPASSWORD="MYEMAILPASSWORD";
# !!!
# end user defined variables
# !!!

# make sure the script is being run as the root user
if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root!";
 echo "Exiting.";
 echo "";
 echo "In a HUFF!";
 echo "";
 echo "";
 return;
fi

# get the system OS
OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1);
# this process was developed on Ubuntu, alert the user if a different distro was found
if [[ $OS != *"Ubuntu"* ]]; then
 echo "Process developed on Ubuntu systems but may work with other distros, use at your own risk!";
fi

# touch the temp file and make sure the process has write access to it
# the script has to run as root, it should have access...
touch "${CACHEFILE}" || { echo "Process unable to write to cache file: ${CACHEFILE}, exiting."; return; }
echo "Able to access cache file (${CACHEFILE})";

# this script requires ssmpt to be installed, make sure it is there
command -v ssmtp >/dev/null 2>&1 || { echo >&2 "This process require ssmtp but it's not installed.  Exiting."; return; }

echo "ssmtp installation found, backing up config file";
# back up the ssmtp configuation
cp /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.bak;

# ssmtp configuation parameters, overwrite the existing file
cat >/etc/ssmtp/ssmtp.conf <<EOL
root=${EMAIL}
mailhub=smtp.gmail.com:465
FromLineOverride=YES
AuthUser=${EMAIL}
AuthPass=${EMAILPASSWORD}
UseTLS=YES
EOL

echo "Working with ${DNS}.${DOMAIN}";

# read the first line of the old IP file
OLDIP=$(head -n 1 "${CACHEFILE}");
echo "(${OLDIP}) found in ${CACHEFILE} as last known IP address - if blank ${CACHEFILE} does not contain an old IP address";

# get this machines external IP address
# dig would probably be better, but some networks (mine) block querying 
# external DNS servers so use curl
IP=$(curl -s http://whatismyip.akamai.com/);
echo "(${IP}) found as current IP address";

# make sure a valid IP address was returned - well, at lest validly formatted
if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
 echo "Valid IP address of $IP found, continuing";
else
 echo "Invalid IP address of $IP found, alerting user and exiting";
 {
  echo "To: ${EMAIL}";
  echo "From: ${EMAIL}";
  echo "Subject: GoDaddy.shl error on $HOSTNAME";
  echo "";
  echo "GoDaddy.shl, being executed on $HOSTNAME, experienced an error trying to get the systems ip address. ${IP} was found when attempting to look it up.";
 } | ssmtp ${EMAIL};
 # restore the ssmtp file
 mv /etc/ssmtp/ssmtp.conf.bak /etc/ssmtp/ssmtp.conf;
 # exit the script
 return;
fi

# see if our IP address has changed
# if its the same return out of the script
if [ "${IP}" = "${OLDIP}" ]; then
 echo "IP address matches cache value, exiting";
 return;
fi

echo "IP address does not match cache value, attempting to update DNS entries";
# json data to push to GoDaddy
JSON='[{"data": "'"${IP}"'","ttl": '"${TTL}"'}]';
echo "JSON built: ${JSON}";

# update the DNS using the GoDaddy API and a curl call
echo "Upating DNS with curl request";
RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X PUT -H 'Authorization: sso-key '"${KEY}"':'"${SECRET}" -H 'Content-Type: application/json' -d "${JSON}" 'https://api.godaddy.com/v1/domains/'"${DOMAIN}"'/records/A/'${DNS});

if [[ ${RESPONSE} -eq 200 ]] ; then
 # if a 200 code was returned the update was successul
 echo "DNS sucessfully updated, http reponse code ${RESPONSE}!";
 # update the cache file
 echo "${IP}" > "${CACHEFILE}";
 echo "Cache file updated";
else
 # if something other than a 200 code was returned the update failed, alert the user
 echo "Error saving DNS!";
 echo "Attempting to email user";
 {
  echo "To: ${EMAIL}";
  echo "From: ${EMAIL}";
  echo "Subject: GoDaddy.shl error on $HOSTNAME";
  echo "";
  echo "GoDaddy.shl, being executed on $HOSTNAME, experienced an error trying to update the DNS record for ${CACHEFILE} to ${IP}. HTTP return code of ${RESPONSE} was recieved from the GoDaddy servers.";
 } | ssmtp ${EMAIL};
fi

# restore the ssmtp file
mv /etc/ssmtp/ssmtp.conf.bak /etc/ssmtp/ssmtp.conf;

# final return - because programming
echo "Process commplete, exiting";
return;

