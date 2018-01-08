#!/bin/env python
# auth.py

from app import app
from requests import get
from os import environ

def getDbCreds(VAULT_ROLE="web-role"):

    VAULT_ADDR=""
    VAULT_NONCE=""

    # Get the VAULT_NONCE ENV variable (should be set in apache SetEnv for us
    # during server build in userdata.sh)
    if environ.has_key('VAULT_NONCE'): VAULT_NONCE = environ['VAULT_NONCE']
    if environ.has_key('VAULT_ADDR'): VAULT_ADDR = environ['VAULT_ADDR']

    print "VAULT_NONCE: %s" %VAULT_NONCE
    print "VAULT_ADDR: %s" %VAULT_ADDR

    # If the vault server wasnt set in the EnvVars, go try to get it from the Ec2
    # tag VAULT_IP
    if VAULT_ADDR == "":
        META_ADDR="http://169.254.169.254/latest/meta-data"
        instance_id = get(META_ADDR + "/instance-id").text
        region = get(META_ADDR + "/placement/availability-zone").text[:-1]
        from boto3 import resource
        ec2 = resource('ec2', region_name=region)
        ec2instance = ec2.Instance(instance_id)
        for tag in ec2instance.tags:
            if tag["Key"] == "VaultIP":
                    VAULT_IP = tag["Value"]
        VAULT_ADDR='http://%s:8200' %VAULT_IP

    # Initiate a vault client
    import hvac
    vaultClient = hvac.Client(url=VAULT_ADDR)

    # Get the PKCS7 signature from this EC2 instance's metadata
    PKCS7 = get("http://169.254.169.254/latest/dynamic/instance-identity/pkcs7").text


    # Authenticate the client to vault
    auth_params = {
        'role' : VAULT_ROLE,
        'pkcs7': PKCS7,
        'nonce': VAULT_NONCE,
    }
    try:
        result = vaultClient.auth('/v1/auth/aws-ec2/login', json=auth_params)
    except:
        return 1

    creds = {}
    # Get database information from vault
    request = (vaultClient.read('secret/mysql'))
    creds['db_host'] = request['data']['host']
    creds['db_port'] = request['data']['port']
    creds['db_name'] = request['data']['database']

    request = (vaultClient.read('mysql/creds/readwrite'))
    creds['db_username'] = request['data']['username']
    creds['db_password'] = request['data']['password']
    creds['lease_id'] = request['lease_id']
    creds['lease_duration'] = request['lease_duration']

    return creds

def dbLoginTest(creds):    
    # Connect to the mysql database
    import MySQLdb
    if creds == 1:
        return 1
    db = MySQLdb.connect(
        host   = creds['db_host'],
        user   = creds['db_username'],
        passwd = creds['db_password'],
        db     = creds['db_name'])

    # create a database cursor object
    cur = db.cursor()

    # execute a query return 1 if it works
    try:
        cur.execute("SHOW DATABASES;")
        db.close()
        return 0
    except:
        db.close()
        return 1
