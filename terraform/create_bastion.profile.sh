#!/bin/bash
VARS="
	BASTION_IP
	LOADBALANCER_DNS
	MYSQL_DB
	MYSQL_HOST 
	MYSQL_PASS 
	MYSQL_PORT 
	MYSQL_USER 
	VAULT_IP 
	WEB_PROFILE_ARN" 

OUTFILE=./bastion.profile
echo "Copying terraform vars to ${OUTFILE}"
cat /dev/null > ${OUTFILE}
for VAR in ${VARS}; do
	echo -n "   terraform output ${VAR} = "
	VALUE=`terraform output ${VAR}`
	echo $VALUE
	echo "export ${VAR}=${VALUE}" >> ${OUTFILE}
done

echo "export MYSQL_VAULT_PASS=\${MYSQL_PASS}" >> $OUTFILE
echo "export MYSQL_VAULT_USER=vault" >> $OUTFILE

export BASTION_IP=`terraform output BASTION_IP`
export KEYFILE=`terraform output KEYFILE | sed s/.pub//`

echo "Adding ${KEYFILE} to local ssh agent"
ssh-add $KEYFILE

echo "Copying ${OUTFILE} to bastion host ec2-user@${BASTION_IP}:~/"
scp -qoStrictHostKeyChecking=no ${OUTFILE} ec2-user@${BASTION_IP}:~/

echo "You should now be able to ssh into the bastion host with the command:"
echo "  ssh -A ec2-user@${BASTION_IP}"
