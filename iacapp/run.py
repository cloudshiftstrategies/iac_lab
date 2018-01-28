#!/usr/bin/env python
# Run the local web server
from app import app
import requests, boto3, os, hvac

# Get the vault address from the instance tags
if not os.environ.has_key('VAULT_ADDR'):
	# Get the instance ID of this EC2 instance
	instanceId = requests.get('http://169.254.169.254/latest/meta-data/instance-id').text
	print "EC2 instanceID: %s" %instanceId
	# Get region of this EC2 instance
	region = requests.get('http://169.254.169.254/latest/meta-data/placement/availability-zone').text[:-1]
	# Create a new boto3 ec2 client
	ec2client = boto3.client("ec2", region_name=region)
	# Pull the IP address of the vault server, should be set on instance tag name: VaultIP
	vaultIP = ec2client.describe_tags(Filters=[
			{'Name':'resource-id','Values':[instanceId]},
			{'Name':'key','Values':['VaultIP']}
		])['Tags'][0]['Value']
	# Set the environment variable with teh vault IP address
	os.environ['VAULT_ADDR'] = "http://%s:8200" %vaultIP
	print "Vault address: %s" %os.environ['VAULT_ADDR']
	
# Log into vault and set a nonce 
if not os.environ.has_key('VAULT_NONCE'):
	# get the PKCS7 key from the EC2 instance metadata
	pkcs7 = requests.get('http://169.254.169.254/latest/dynamic/instance-identity/pkcs7').text

	# Create a new vault client instance
	vaultClient = hvac.Client(url=os.environ['VAULT_ADDR'])

	# Define some params required for vault authentication
	params = {
		'role': 'web-role',
		'pkcs7': pkcs7,
		}
	try:
		# Attempt the login and get the nonce
		response = vaultClient.auth('/v1/auth/aws-ec2/login', json=params)
		# Extract the nonce from the api response (in json format)
		nonce = response['auth']['metadata']['nonce']
		# Write the env variables
		os.environ['VAULT_NONCE'] = nonce
		os.environ['VAULT_STATUS'] = 'authenticated'
	except Exception as error:
		# Something went wrong, write the error code to the env var VAULT_STATUS
		os.environ['VAULT_STATUS'] = '%s' %error
		os.environ['VAULT_NONCE'] = ''

	print "Vault nonce: %s" %os.environ['VAULT_NONCE']
	print "Vault status: %s" %os.environ['VAULT_STATUS']

# Start the web server
app.run(debug=True,host="0.0.0.0",port=8000)
