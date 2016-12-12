#!/bin/bash
# This program detects a change in the amount of Bitcoin contained in a
# Bitcoin address and sends a notification containing the relevant values.
#
# This script creates persistent variable storage in a text file in the
# $HOME dir so the script will work when run as a cron job.  The file
# is created if it does not already exist.  Then name of the file is
# the Bitcoin address.
#
# The source of the Bitcoin address related data is https://blockchain.info
#
# This script has been tested only on Ubuntu 14.10 DESKTOP version.
#
#
# rex addiscentis  2016/12/11
# Apache 2.0 License
# https://github.com/addiscent


# must specify a "bitcoin address" on command line
if [ $# -lt 1 ]; then
  echo "Usage   :  alert-bitcoin-address-change.sh  address  [email-address]"
  echo "Example :  alert-bitcoin-address-change.sh  1GdK9UzpHBzqzX2A9JFP3Di4weBwqgmoQA  example@example.com"
  echo "Alert \"Bitcoin address\" value required, exiting, nothing done"
  exit 1
fi 

#set -x

# if the previous total bitcoin received file does not exist create it and
# set it to 0, after ensuring a directory exists for storing multiple
# Bitcoin addresses
bitcoin_addrs_dir="$HOME/bitcoin_addrs"
previous_total_filename="$bitcoin_addrs_dir/$1"
echo "previous_total_filename is :$previous_total_filename"
if [ ! -f "$previous_total_filename"  ] ; then
  if [ ! -d "$bitcoin_addrs_dir"  ] ; then
    $(mkdir "$bitcoin_addrs_dir")
  fi  
  echo "0" > "$previous_total_filename"
fi

# fetch the json block containing current Bitcoin address data and
# extract "total amount received" value
latest_total_received=$(curl https://blockchain.info/address/$1?format=json | grep "total_received" | awk -F ',' '{print $1}' | cut -c22-32)
echo "Fetched total_received Bitcoin amount is : $latest_total_received Satoshis"

# fetch the previous_total_bitcoin_received from the variable storage file
previous_total_bitcoin_received=$(cat "$previous_total_filename")
echo "Previous Bitcoin total_received amount is : $previous_total_bitcoin_received Satoshis"

# https://blockchain.info service could have been unavailable during fetch.
# Detect and exit if suspect
if [ "$latest_total_received" \< "$previous_total_bitcoin_received" ] ; then
  if [ $# = 2 ] ; then
  mail -s 'Bitcoin Total Received Change (Quasimodo)' "$2" << EOF
From Bitcoin Address Monitor - Notification :

   Suspect data received from :
     https://blockchain.info/address/$1?format=json
   Service may be unavailable.
   Bitcoin Total Received : $latest_total_received Satoshis
   Bitcoin Previous Total Received : $previous_total_bitcoin_received Satoshis
EOF
  fi
  echo "Suspect data received, service may be unavailable, exiting"
  #set +x
  exit 0
fi

# calc new Bitcoin amount difference.
# if no difference, i.e., no new Bitcoin received, exit script
let "new_difference = $latest_total_received - $previous_total_bitcoin_received"
if [ $new_difference \= "0" ] ; then
  echo "No New Bitcoin received, nothing to do"
  #set +x
  exit 0
fi

# trace values on STDOUT
echo "New Bitcoin difference amount is : $new_difference Satoshis"
echo "Bitcoin total_received amount is : $latest_total_received Satoshis"

# notify statistics using GUI alert
DISPLAY=:0 notify-send "Bitcoin Total Received Change" "Bitcoin Newly Received : $new_difference Satoshis,\nBitcoin Total Received : $latest_total_received Satoshis" 

# if email address provided, send email notificiation
if [ $# = 2 ] ; then
  mail -s 'Bitcoin Total Received Change (Quasimodo)' "$2" << EOF
From Bitcoin Address Monitor - Notification :

   Bitcoin Newly Received : $new_difference Satoshis
   Bitcoin Total Received : $latest_total_received Satoshis
EOF
fi

# store variable for next run by cron
echo "$latest_total_received" > "$previous_total_filename"

#set +x

