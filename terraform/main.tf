# main.tf – tells terraform which provider to use (AWS)

provider "aws" {
  region = "${var.region}"
}

#################################################
# ssh key 
# Use a public keypair we specify
resource "aws_key_pair" "public_key" {
    key_name   = "${var.projectName}-${var.stageName}-key"
    public_key = "${file(var.publicSshKey)}"
}

