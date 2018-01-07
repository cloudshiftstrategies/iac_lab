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
yum -y install httpd jq php php-mysql

# drop a couple of files in the root of the site we can use to validate
echo `hostname` > /var/www/html/index.php
echo "<br><a href=phpinfo.php>phpinfo.php</a>" >> /var/www/html/index.php
echo "<br><?php print getenv('VAULT_NONCE')?>" >> /var/www/html/index.php
echo "<br><?php print getenv('VAULT_ADDR')?>" >> /var/www/html/index.php
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# Install Vault
wget https://releases.hashicorp.com/vault/0.9.1/vault_0.9.1_linux_amd64.zip
unzip -j vault_*_linux_amd64.zip -d /usr/local/bin

# Log the server into vault 
export AWS_DEFAULT_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//'`
export INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
export VAULT_IP=`aws ec2 describe-tags --filters Name=resource-id,Values="${INSTANCE_ID}" Name=key,Values=VaultIP | jq '.Tags[0].Value' | sed s/\"//g`
export VAULT_ADDR="http://${VAULT_IP}:8200"
export VAULT_NONCE=`vault write /auth/aws-ec2/login role=web-role pkcs7="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7)" | grep token_meta_nonce | awk '{print$2}' | sed s/\"//g`

# Set VAULT env variables in the apache 
cat <<EOF > /etc/httpd/conf.d/host.conf 
<VirtualHost *:80>
	SetEnv VAULT_NONCE ${VAULT_NONCE}
	SetEnv VAULT_ADDR ${VAULT_ADDR}
</VirtualHost>
EOF

# Start apache
systemctl start httpd.service

# Enable apache to start on reboot
systemctl enable httpd.service
