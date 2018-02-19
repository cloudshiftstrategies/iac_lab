#!/bin/env python
# __init__.py

from flask import Flask
from flask import render_template
app = Flask(__name__)

from os import environ
from auth import getDbCreds, dbLoginTest

app.config.from_object('config')

@app.route("/")
def index():
    """
    The Home Page for our app
    """

    return render_template('index.html')

@app.route("/vault")
def vault():
    """
    A Web Page to demonstrate vault credentials
    """
    # put the VAULT environment variables in the data dict so that we can
    # render them in the /vault web page
    data= {}
    
    # Get the host name
    import socket
    data['HOSTNAME'] = socket.gethostname()

    # VAULT_ADDR is the http address of the VAULT Server
    if environ.has_key('VAULT_ADDR'): data["VAULT_ADDR"] = environ['VAULT_ADDR']
    else: data["VAULT_ADDR"]='' # env var not set. write '' so tempalte will render

    # VAULT_NONCE is the authentication string (password)
    if environ.has_key('VAULT_NONCE'): data["VAULT_NONCE"] = environ['VAULT_NONCE']
    else: data["VAULT_NONCE"]='' # env var not set. write '' so tempalte will render

    # VAULT_STATUS is the error code of the initial autentication attempt
    if environ.has_key('VAULT_STATUS'): data["VAULT_STATUS"] = environ['VAULT_STATUS']
    else: data["VAULT_STATUS"]='' # env var not set. write '' so tempalte will render

    # Call the function to get db credentials (file: auth.py function: getDbCreds())
    dbCreds = getDbCreds()

    # Call the function to test db creds(file: auth.py function: dbLoginTest())
    testResult = dbLoginTest(dbCreds)

    return render_template('vault.html', data=data, creds=dbCreds, testResult=testResult)

@app.route("/database")
def database():
    """
    A Web Page to test database connectivity
    """
    creds = getDbCreds()
    if creds['db_host'] == "":
        return render_template('error.html')
    import MySQLdb
    db = MySQLdb.connect(
        host  =creds['db_host'],
        user  =creds['db_username'],
        passwd=creds['db_password'],
        db    =creds['db_name'])
    cursor = db.cursor()
    # see if we have a table called authors
    showQuery = "SHOW TABLES LIKE 'authors';"
    cursor.execute(showQuery)
    if cursor.rowcount == 0:
        cursor.close()
        cursor = db.cursor()
        # The authors table doesnt exist, load it with data so we have something to look at
        filename="dbload.sql"
        f = open(filename, 'r')
        loadQuery = " ".join(f.readlines())
        cursor.execute(loadQuery)
    # query the authors table
    cursor.close()
    cursor = db.cursor()
    selectQuery = "select * from authors;"
    cursor.execute(selectQuery)
    data = cursor.fetchall()
    # get the field names from the query
    num_fields = len(cursor.description)
    field_names = [i[0] for i in cursor.description]
    # Render the database page template
    return render_template('database.html', query=selectQuery, data=data, field_names=field_names)

@app.route("/loadgen")
def loadgen():
    """
    A Web Page that generates load for perf testing
    """

    from time import time
    # Params to set up the workload
    iterations = 300000
    i = 0
    x = 2
    # Ready Set go (capture start time)
    start = time()
    # do the useless work to generate CPU load
    while i < iterations:
        x = x * 2
        i += 1
    # We're done
    end = time()
    # Figure out the elapsed Seconds
    seconds = end - start
    # Pass it all to the template for presentation
    return render_template('loadgen.html', iters=iterations,
            duration = seconds)

if __name__ == "__main__":
    app.run()
