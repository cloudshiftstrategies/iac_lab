#!/bin/bash
# vaultInit.sh

# This script sets up the vault server from the bastion host
# it does everything described in http://localhost:8000/iacLab--lesson3.html

# Source the env vars
. ~/bastion.profile

# Install vault 
wget https://releases.hashicorp.com/vault/0.9.1/vault_0.9.1_linux_amd64.zip
sudo unzip -j vault_*_linux_amd64.zip -d /usr/local/bin

# Configure the vault address
export VAULT_ADDR=http://${VAULT_IP}:8200

# Unseal the vault
vault init 2>&1 | egrep '^Unseal Key|Initial Root Token' | tee ./vaultkeys.txt
chmod 600 ./vaultkeys.txt
egrep -m3 '^Unseal Key' vaultkeys.txt | cut -f2- -d: | tr -d ' ' | while read key; do vault unseal ${key}; echo; done
export VAULT_TOKEN=`egrep '^Initial Root Token:' ./vaultkeys.txt | awk -F':' '{print$2}' | sed s/' '//g`

# write the database connection info to the secret path
vault write secret/mysql host=${MYSQL_HOST} port=${MYSQL_PORT} database=${MYSQL_DB}

# create a vault user on the mysql database
sudo yum install -y mysql
MYSQL="mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASS -Bsse"
$MYSQL "CREATE USER ${MYSQL_VAULT_USER}@'%' IDENTIFIED BY '${MYSQL_VAULT_PASS}';"
$MYSQL "GRANT ALL ON ${MYSQL_DB}.* TO ${MYSQL_VAULT_USER}@'%' WITH GRANT OPTION;"
$MYSQL "GRANT CREATE USER ON *.* TO ${MYSQL_VAULT_USER}@'%';"
$MYSQL "FLUSH PRIVILEGES;"

# mount the mysql secrets engine in vault
vault mount mysql

# write the configuration to find the database
vault write mysql/config/connection \
		connection_url="vault:${MYSQL_VAULT_PASS}@tcp(${MYSQL_HOST}:${MYSQL_PORT})/" \
		allowed_roles="readwrite"

# Give the user accounts a 1 horu TTL
vault write mysql/config/lease lease=1h lease_max=12h

# Create a config that creates database users dynamically
vault write mysql/roles/readwrite \
		sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON ${MYSQL_DB}.* TO '{{name}}'@'%';"

# Create a policy for our web application that allows it to access these secrets
cat <<EOF > ./web-policy.hcl
path "sys/*" {
     policy = "deny"
	 }
	 path "secret/mysql*" {
	     capabilities = ["read"]
 }
 path "mysql/creds/readwrite" {
     capabilities = ["read"]
	 }
EOF

# write the policy
vault policy-write web-policy ./web-policy.hcl

# enable the AWS Ec2 authentication module
vault auth-enable aws-ec2

# configure the EC2 authentication module to allow authentication from any valid EC2 host
# that has a specific IAM policy attached $WEB_PROFILE_ARN
vault write auth/aws-ec2/role/web-role bound_iam_instance_profile_arn=${WEB_PROFILE_ARN} policies=web-policy
