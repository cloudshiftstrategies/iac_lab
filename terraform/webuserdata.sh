#!/bin/bash -v

# Update all packages
yum -y update

# Configure CloudWatch Logging Agent
#CONF_BUCKET='m6connect-cloudwatch-log-config'
#CONF_FILE='m6connect-web-awslogs.conf'
#AZ=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
#REGION=${AZ::-1}
#AWS_LOGCONF="http://${CONF_BUCKET}.s3.amazonaws.com/${CONF_FILE}"
#curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
#python ./awslogs-agent-setup.py -n --region=$REGION --configfile=$AWS_LOGCONF
#systemctl daemon-reload
#service awslogs restart

# Install apache
yum -y install httpd php php-mysql

# Start apache
systemctl start httpd.service

# Enable apache to start on reboot
systemctl enable httpd.service

# drop a couple of file in the root of the site we can use to validate
hostname > /var/www/html/index.html
echo "<br><a href=phpinfo.php>phpinfo.php</a>" >> /var/www/html/index.html
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
