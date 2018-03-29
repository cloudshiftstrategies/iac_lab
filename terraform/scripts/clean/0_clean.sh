#!/bin/bash

# sudo yum install -y ruby
# gem install terraforming

#TYPES="alb asg dbpg dbsn ec2 eip elb iamp iamrp igw nat nif rds rt rta sg sn vpc"
TYPES="alb asg dbpg dbsn ec2 elb iamp iamrp igw nat nif rds rt rta sg sn vpc"
#TFTYPES="ec2 eip iamp iamrp igw nat nif rt rta sg sn vpc"
REGION="us-east-2"
TFSTATE="./terraform.tfstate"

# Create the main.tf
cat /dev/null > main.tf
cat <<EOF > main.tf
provider "aws" {
    region = "${REGION}"
}
EOF

cat /dev/null > clean.tf
COUNT=1
for TYPE in $TYPES; do
    if [ $COUNT -eq 1 ]; then
        terraforming $TYPE --tfstate --region="${REGION}" > $TFSTATE
    else
        terraforming $TYPE --tfstate --region="${REGION}" --merge=${TFSTATE} > ${TFSTATE}.tmp
        mv ${TFSTATE}.tmp $TFSTATE
    fi
    COUNT=$(( $COUNT + 1 ))
done

for TYPE in $TYPES; do
    terraforming $TYPE --region="${REGION}" >> clean.tf
done
