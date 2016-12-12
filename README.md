# alert-bitcoin-address-change
This Bash script detects a change in the amount of Bitcoin contained in a Bitcoin address and sends a notification which contains the new "total amount received" at the address, and the amount of the increase from the previous check.  When run periodically as a _cron_ job, it may serve as a "new Bitcoin payment" alert.

This script creates persistent variable storage so the script will work when run as a cron job.  The variable storage file is created if it does not already exist.  The name of the file is the Bitcoin address.  Because there could be potentially many variable storage files, (one for each Bitcoin address), they are stored in a sub-directory of the user's _$HOME_ direcotry, named "bitcoin_addrs".

The source of the Bitcoin address related data is https://blockchain.info.

This script has been tested only on Ubuntu 14.10 DESKTOP version.

### Installation
After cloning this project or downloading/unzipping the project zip file, copy _alert-bitcoin-address-change.sh_ into a directory in which the user has permissions, and ensure the file permission is set as _executable_.

### Basic Command Line Syntax
The Bitcoin address in this example below is specified as _1GdK9UzpHBzqzX2A9JFP3Di4weBwqgmoQA_.  Change this value to set the Bitcoin address which is tested for notification.  If email notification is desired, set the user's email address in place of the email address in the example below.  If no email notification is desired, remove the email address "example@example.com".  If "example@example.com" is not removed from the example below, the host will waste CPU and IO cycles pointlessly attempting to send unnecessary email, and email notifications of delivery failures may arrive in the host admin's mailbox.

        alert-bitcoin-address-change.sh 1GdK9UzpHBzqzX2A9JFP3Di4weBwqgmoQA example@example.com

### Used As A Bitcoin Address Balance Change Alert
If the user wishes to regularly check by cron the amount of Bitcoin which the address has received, add the line of code shown below to the user's crontab .  The example line below causes the script to be executed once per minute.  Modify the example below accordingly if the script should be run less frequently.  The example code shown below assumes the user has _alert-bitcoin-address-change.sh_ stored in a directory named "bin", in the "user" home directory. If stored in some other path, adjust this example accordingly.  

        * * * * * /home/user/bin/alert-bitcoin-address-change.sh 1GdK9UzpHBzqzX2A9JFP3Di4weBwqgmoQA example@example.com >/dev/null 2>&1

#### Important
In order for email notifications to work correctly, the admin must ensure the _mail_ utility is installed and configured properly.

