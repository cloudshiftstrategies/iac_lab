#!/bin/bash -v
# webuserdata.sh - script used to initialize web servers

# Update all packages
yum -y update

# Install software
yum -qqy install gcc python-pip mysql-devel python-devel git

# Add a user for the vault daemon
useradd -r -g daemon -d /usr/local/flask -m -s /sbin/nologin -c "Flask user" flask

# create the directory where we'll run the web application
mkdir -p /var/www/html

# cleanup in case this script has been run before
rm -rf /var/www/html/* /tmp/iac_lab

# checkout our code from github
cd /tmp
git clone http://github.com/cloudshiftstrategies/iac_lab
cd iac_lab

# Move the web application into the web directory
mv iacapp/* /var/www/html
cd ~/ && rm -rf /tmp/iac_lab
chmod 755 -R /var/www/html

# INstall the python requirements for the web application
pip install -r /var/www/html/requirements.txt

# Remove the unnessesary (possibly insecure) libraries after the pip install done above
yum -qqy remove gcc python-pip mysql-devel python-devel git

# Start Flask server
cd /var/www/html
sudo -u flask python run.py &
