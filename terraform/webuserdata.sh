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

# Init flask log file
touch /var/log/flask.log
chown flask /var/log/flask.log

# configure flask service
cat <<EOF > /lib/systemd/system/flask.service
[Unit]
Description=Flask Web Server
After=network.target
StartLimitIntervalSec=0
[Service]
User=flask
Type=simple
Restart=always
RestartSec=1
ExecStart=/bin/bash -c "cd /var/www/html; python run.py >> /var/log/flask.log 2>&1"
Wants=autossh.service
[Install]
WantedBy=multi-user.target
EOF

# Start the service
systemctl daemon-reload
systemctl enable flask
systemctl start flask
