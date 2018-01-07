#!/usr/bin/env python
# Run the local devel web server
from app import app

app.run(debug=True,host="0.0.0.0")


