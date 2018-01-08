# vpcpeering.tf - vpc peering connection between default VPC and app vpc for bastion host access

###############################################################
# Queries

# get the default vpc for this account/region
data "aws_vpc" "dflt_vpc" { 
    default = true
} 

# Get the route table that serves the default subnet
# TODO: Will probably break of default VPC has multiple route tables
data "aws_route_table" "dflt_subnet_rt" {
	vpc_id = "${data.aws_vpc.dflt_vpc.id}"
}

###############################################################
# Peering connection

# create the peering connection
resource "aws_vpc_peering_connection" "vpx" {
    peer_vpc_id   = "${data.aws_vpc.dflt_vpc.id}"
    vpc_id        = "${aws_vpc.vpc.id}"
    auto_accept   = true

    tags {
        Name = "VPC Peering default VPC and the ${var.projectName}-${var.stageName}-vpc"
        Project     = "${var.projectName}",
        Stage       = "${var.stageName}"
        CostCenter  = "${var.costCenter}"
    }   
}

###############################################################
# Routes between VPCs

# create route in the default (bastion) subnet to our web vpc
resource "aws_route" "dflt_to_web_rte" {
	route_table_id            = "${data.aws_route_table.dflt_subnet_rt.id}"
	destination_cidr_block    = "${var.vpcCidr}"
	vpc_peering_connection_id = "${aws_vpc_peering_connection.vpx.id}"
}

# create a route in each of the web private route tables (one per AZ) to the default vpc
resource "aws_route" "web_to_dflt_rte" {
	count   = "${length(var.availZones)}"
	route_table_id = "${element(aws_route_table.privateRouteTable.*.id, count.index)}"
	destination_cidr_block    = "${data.aws_vpc.dflt_vpc.cidr_block}"
	vpc_peering_connection_id = "${aws_vpc_peering_connection.vpx.id}"
}
