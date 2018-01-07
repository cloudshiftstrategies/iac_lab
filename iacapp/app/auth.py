#!/bin/env python

import hvac, requests, MySQLdb, boto3

nonce = "10933259-e424-d3b0-cb69-46d94a30ce4d"

# Get metadata about this instance
instance_id = requests.get("http://169.254.169.254/latest/meta-data/instance-id").text
region = requests.get(" http://169.254.169.254/latest/meta-data/placement/availability-zone").text[:-1]
pkcs7 = requests.get("http://169.254.169.254/latest/dynamic/instance-identity/pkcs7").text

# Get the IP aadress of the vault server, which should be stored in the VaultIP tag for this instance
ec2 = boto3.resource('ec2', region_name=region)
ec2instance = ec2.Instance(instance_id)
for tag in ec2instance.tags:
	if tag["Key"] == "VaultIP":
		VAULT_IP = tag["Value"]
VAULT_ADDR='http://%s:8200' %VAULT_IP

#VAULT_TOKEN=`vault write /auth/aws-ec2/login role=web-role pkcs7="$(curl http://169.254.169.254/latest/dynamic/instance-identity/pkcs7)" nonce="10933259-e424-d3b0-cb69-46d94a30ce4d" | egrep "^token " | awk '{print$2}'`

client = hvac.Client(url=VAULT_ADDR)
#client.token = '17f16284-cad1-1e30-025b-a4f5a0b80de6'

# Authenticate the client to vault
params = {
    'role': 'web-role',
    'pkcs7': pkcs7,
    'nonce': nonce,
}
result = client.auth('/v1/auth/aws-ec2/login', json=params)

# Get database information from vault
request = (client.read('secret/mysql'))
host = request['data']['host']
port = request['data']['port']
database = request['data']['database']

request = (client.read('mysql/creds/readwrite'))
username = request['data']['username']
password = request['data']['password']

# Connect to the mysql database
db = MySQLdb.connect(host=host, 
                     user=username,
                     passwd=password,
                     db=database)

# create a database cursor object
cur = db.cursor()

# execute a query
cur.execute("SHOW DATABASES;")

# print all the first cell of all the rows
for row in cur.fetchall():
    print row[0]

db.close()
