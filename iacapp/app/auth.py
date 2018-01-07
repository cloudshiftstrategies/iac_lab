#!/bin/env python

from requests import get
from os import environ

def getDbCreds(VAULT_ROLE="web-role"):

    VAULT_ADDR=""
    VAULT_NONCE=""

    # Get the VAULT_NONCE ENV variable (should be set in apache SetEnv for us
    # during server build in userdata.sh)
    if os.environ.has_key('VAULT_NONCE'): VAULT_NONCE = os.environ['VAULT_NONCE']
    if os.environ.has_key('VAULT_ADDR'): VAULT_ADDR = os.environ['VAULT_ADDR']

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
    result = client.auth('/v1/auth/aws-ec2/login', json=auth_params)

    creds = {}
    # Get database information from vault
    request = (client.read('secret/mysql'))
    creds['db_host'] = request['data']['host']
    creds['db_port'] = request['data']['port']
    creds['db_name'] = request['data']['database']

    request = (client.read('mysql/creds/readwrite'))
    creds['db_username'] = request['data']['username']
    creds['db_password'] = request['data']['password']

    return creds

def dbLoginTest(creds):    
    # Connect to the mysql database
    import MySQLdb
    db = MySQLdb.connect(
        host   = creds['db_host'],
        user   = creds['db_username'],
        passwd = creds['db_password'],
        db     = creds['db_database'])

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
