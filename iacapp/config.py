# config.py
import os

# Title of the site
SITE_TITLE = 'Infrastructure as Code Lab'
# The URL for static files/images
STATIC_URL = 'https://s3-us-west-2.amazonaws.com/flaskdockerlab-static/'
# The name of the
FAV_ICON = STATIC_URL + 'docker-icon.png'
FAV_ICON = 'https://chocolatey.org/content/packageimages/terraform.0.10.8.png'

# Pages to show on the nav menu (provide a url or route)
PAGES=[
    {'title':'Lab Blog',
        'url':'https://www.cloudshiftstrategies.com/iacLab.html'},
    {'title':'Load Gen','route':'loadgen'},
    {'title':'Vault Credentials','route':'vault'},
    {'title':'Database','route':'database'},
    ]

# Bootstrap CSS files to include in each page included in ./app/templates/base.html
CSS_INCLUDES=[
    'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css',
    'https://maxcdn.bootstrapcdn.com/bootswatch/3.3.7/flatly/bootstrap.min.css',
    'https://cdn.datatables.net/1.10.15/css/dataTables.bootstrap.min.css',
    ]

# Bootstrap JS files to include in each page included in ./app/templates/base.html
JS_INCLUDES=[
    'https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js',
    'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js',
    'https://cdn.datatables.net/1.10.15/js/jquery.dataTables.min.js',
    'https://cdn.datatables.net/1.10.15/js/dataTables.bootstrap.min.js',
    'https://cdnjs.cloudflare.com/ajax/libs/jquery.form/4.2.1/jquery.form.min.js',
    ]
