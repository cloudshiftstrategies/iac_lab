#!/bin/env python
import sys, os

# required to run application inside apache
sys.path.append('/var/www/html')
from app import app as application

# This function is required to import Apache EnvVars set in httpd.conf
def application(environ, start_response):
    os.environ['VAULT_ADDR'] = environ['VAULT_ADDR']
    os.environ['VAULT_NONCE'] = environ['VAULT_NONCE']
    from app import app as _application
    return _application(environ, start_response)
