{
    "terraform": {
        "backend": {
            "s3": {
                "bucket": "tfstate-iaclab-dev", 
                "key": "tfStateFile-iaclab-dev", 
                "region": "us-east-2"
            }
        }
    }
}