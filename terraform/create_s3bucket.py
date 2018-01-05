#!/usr/bin/env python

import boto3, uuid, sys, hcl
from botocore.exceptions import ClientError

# This is the file where we configure the online state
s3StateCfgFile='./s3state.tf'

bucket_prefix='terraformState_'
statekey='tfStateFile_'

# Open/parse the config file
with open(s3StateCfgFile) as datafile:
    data = hcl.load(datafile)
print data['terraform']['backend']['s3']['bucket']
bucketName=data['terraform']['backend']['s3']['bucket']
regionName=data['terraform']['backend']['s3']['region']
keyName=data['terraform']['backend']['s3']['key']

print "Reading Cfg File : %s" %s3StateCfgFile
print "       BucketName: %s" %bucketName
print "       Region    : %s" %regionName
print "       Key       : %s" %keyName

s3client = boto3.client('s3')

# See if the bucket name defined in the config file already exists
for bucket in s3client.list_buckets()['Buckets']:
    if bucketName  == bucket['Name']:
        if regionName == s3client.get_bucket_location(Bucket=bucketName)['LocationConstraint']:
            # Were done
            print "Bucket: %s already exists in AWS account & region" %bucketName
            print "        Enabling versioning on Bucket: %s" %bucketName
            s3client.put_bucket_versioning(
                    Bucket=bucketName,
                    VersioningConfiguration={ 'Status': 'Enabled' }
            )
            sys.exit(0)

# If we are still here, the bucket does not yet exist (in this account)
print "Bucket: %s does not exist in this AWS account & region." %bucketName

def createBucket(bucketName, regionName):
    print "Trying to create Bucket: %s in Region: %s" %(bucketName, regionName)
    try:
        # try to create a bucket with the name in the config file
        if regionName == 'us-east-1':
            s3client.create_bucket(Bucket=bucketName)
        else:
            s3client.create_bucket(Bucket=bucketName,
                CreateBucketConfiguration = {'LocationConstraint': regionName})
    except (ClientError) as e:
        # If it is BucketAlreadyExists error, handle it
        if e.response['Error']['Code'] == 'BucketAlreadyExists':
            print "    Bucket: %s exists in another AWS account" %bucketName
            return 1
        else:
            # We dont know what the error was, lets print error and exit
            print "Fatal Error:"
            print e
            sys.exit(1)
    print "    Successfully created Bucket: %s" %bucketName
    print "    Enabling versioning on Bucket: %s" %bucketName
    s3client.put_bucket_versioning(
        Bucket=bucketName,
        VersioningConfiguration={ 'Status': 'Enabled' }
    )
    return(0)

# Create a bucket. Try to use the bucket Name in the config file first
while createBucket(bucketName, regionName) != 0:
    # If we are still here, we need to try a new bucket name
    bucketName = "%s-%s" %(bucketName, str(uuid.uuid1())[:8])
    print "    Picking a different bucket name: %s" %bucketName

# Write out a new config file
print "Updating config file %s" %s3StateCfgFile
data['terraform']['backend']['s3']['bucket'] = bucketName
cfgFile = open(s3StateCfgFile, 'w')
cfgFile.write(hcl.dumps(data, indent=4, sort_keys=True))
