# s3state.tf – defines where terraform should store it’s very important state file (s3)

{
    "terraform": {
        "backend": {
            "s3": {
                "bucket": "terraform-tfstate-df270048", 
                "key": "tfstatefile", 
                "region": "us-east-2"
            }
        }
    }
}
