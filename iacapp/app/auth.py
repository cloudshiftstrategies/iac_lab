#!/bin/env python
# auth.py

from app import app
from requests import get
from os import environ

def getDbCreds(VAULT_ROLE="web-role"):

    # Initilaize the return dict
    creds = {}
    creds['db_host'] = ""
    creds['db_port'] = ""
    creds['db_name'] = ""
    creds['db_username'] = ""
    creds['db_password'] = ""
    creds['lease_id'] = ""
    creds['lease_duration'] = 0

    # Get the PKCS7 signature from this EC2 instance's metadata
    try:
        PKCS7 = get("http://169.254.169.254/latest/dynamic/instance-identity/pkcs7").text
    except:
        return creds # we must not be running on an EC2 instance. Just exit

    # Get the VAULT_NONCE and VAULT_ADDR ENV variable (should be set for us)
    if environ.has_key('VAULT_ADDR'): VAULT_ADDR = environ['VAULT_ADDR']
    else: return creds # Without a VAULT_ADDR, we wont get far, just exit
    if environ.has_key('VAULT_NONCE'): VAULT_NONCE = environ['VAULT_NONCE']
    else: return creds # If the NONCE isnt set, there is no sense in proceding

    # print this debug info to the app server
    print "VAULT_NONCE: %s" %VAULT_NONCE
    print "VAULT_ADDR: %s" %VAULT_ADDR

    # Initiate a vault client
    import hvac
    vaultClient = hvac.Client(url=VAULT_ADDR)

    # Authenticate the client to vault with the nonce
    auth_params = {
        'role' : VAULT_ROLE,
        'pkcs7': PKCS7,
        'nonce': VAULT_NONCE,
    }
    try: result = vaultClient.auth('/v1/auth/aws-ec2/login', json=auth_params)
    except: return creds # we failed to authenticate to vault for some reason

    # Get database information from vault
    request = (vaultClient.read('secret/mysql'))
    creds['db_host'] = request['data']['host']
    creds['db_port'] = request['data']['port']
    creds['db_name'] = request['data']['database']

    # get a database username and password from vault
    request = (vaultClient.read('mysql/creds/readwrite'))
    creds['db_username'] = request['data']['username']
    creds['db_password'] = request['data']['password']
    creds['lease_id'] = request['lease_id']
    creds['lease_duration'] = request['lease_duration']

    return creds

def dbLoginTest(creds):
    # Connect to the mysql database
    import MySQLdb
    if creds['db_host'] == "":
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
