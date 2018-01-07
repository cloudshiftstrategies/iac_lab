#!/bin/env python
import sys
# required to run application inside apache
sys.path.append('/var/www/html')
from app import app as application
