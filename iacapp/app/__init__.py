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
    data= {}
    data["VAULT_NONCE"]=''
    data["VAULT_ADDR"]=''
    if environ.has_key('VAULT_NONCE'): data["VAULT_NONCE"] = environ['VAULT_NONCE']
    if environ.has_key('VAULT_ADDR'): data["VAULT_ADDR"] = environ['VAULT_ADDR']
    creds = getDbCreds()
    testResult = dbLoginTest(creds)
    if creds == 1 or testResult ==1:
        return render_template('error.html')
    else:
        return render_template('vault.html', data=data, creds=creds, testResult=testResult)

@app.route("/database")
def database():
    """
    A Web Page to test database connectivity
    """
    creds = getDbCreds()
    if creds == 1 :
        return render_template('error.html')
    import MySQLdb
    db = MySQLdb.connect(
        host  =creds['db_host'],
        user  =creds['db_username'],
        passwd=creds['db_password'],
        db    =creds['db_name'])
    cursor = db.cursor()
    cursor.execute("SHOW DATABASES;")
    data = cursor.fetchall()
    return render_template('database.html', data=data)

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
