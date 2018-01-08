# network.tf – creates VPC, subnets, route tables, internet gateways and nat gateways

###############################################################
# VPC

# Create a new VPC for this project
resource "aws_vpc" "vpc" {
	cidr_block = "${var.vpcCidr}"
	enable_dns_hostnames = true
	tags {
		Name    = "${var.projectName}-${var.stageName}-vpc",
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
	}
}

# Create an Internet Gateway for the public subnets
resource "aws_internet_gateway" "igw" {
	vpc_id = "${aws_vpc.vpc.id}"
	tags {
		Name    = "${var.projectName}-${var.stageName}-igw",
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
	}
}

###############################################################
# Public Subnets

# Create one public subnet for each publicCidr specified
resource "aws_subnet" "public_subnet" {
	count	= "${length(var.publicCidrs)}"
	vpc_id  = "${aws_vpc.vpc.id}"
	cidr_block = "${element(var.publicCidrs, count.index)}"
	availability_zone = "${element(var.availZones, count.index)}"
	map_public_ip_on_launch = true
	tags {
		Name = "${var.projectName}-${var.stageName}-public-${element(var.availZones, count.index)}-sn"
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
  }
}

# Create a singe route table for all the public subnets
resource "aws_route_table" "publicRouteTable" {
	vpc_id = "${aws_vpc.vpc.id}"
	tags {
		Name = "${var.projectName}-${var.stageName}-public-routeTable"
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
	}
}

# Add a rule to the public route table, making the Internet GW the default route
resource "aws_route" "publicIgwRoute" {
  route_table_id         = "${aws_route_table.publicRouteTable.id}"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

# Associate all public Subnets with the igw Route Table
resource "aws_route_table_association" "publicRteTblAssoc" {
	count          = "${length(var.publicCidrs)}"
	subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
	route_table_id = "${aws_route_table.publicRouteTable.id}"
}

# Create one elastic IP for each public subnet to be used by the NAT gateway
resource "aws_eip" "natEip" {
	count = "${length(var.publicCidrs)}"
	vpc   = true
	# tags arent allowed on this TF resource (but they are in AWS console)
}

# Create a NAT gateway in each public subnet (to be used by private subnets for internet access)
resource "aws_nat_gateway" "natGw" {
	count         = "${length(var.publicCidrs)}"
	allocation_id = "${element(aws_eip.natEip.*.id, count.index)}"
	subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
	tags {
		Name = "${var.projectName}-${var.stageName}-${element(var.availZones, count.index)}-natgw"
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
  }
}

###############################################################
# Private Subnets

# Create a private subnet for each appCidr specified
resource "aws_subnet" "app_subnet" {
	count	= "${length(var.appCidrs)}"
	vpc_id  = "${aws_vpc.vpc.id}"
	cidr_block = "${element(var.appCidrs, count.index)}"
	availability_zone = "${element(var.availZones, count.index)}"
	tags {
		Name = "${var.projectName}-${var.stageName}-private-${element(var.availZones, count.index)}-sn"
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
  }
}

# Associate each private Route Table to the private subnet
resource "aws_route_table_association" "privateRteTblAssoc" {
	count          = "${length(var.appCidrs)}"
	subnet_id      = "${element(aws_subnet.app_subnet.*.id, count.index)}"
	route_table_id = "${element(aws_route_table.privateRouteTable.*.id, count.index)}"
}

		
###############################################################
# Database Subnets

# Create one database subnet for each databaseCidrs specified
resource "aws_subnet" "database_subnet" {
	count	= "${length(var.databaseCidrs)}"
	vpc_id  = "${aws_vpc.vpc.id}"
	cidr_block = "${element(var.databaseCidrs, count.index)}"
	availability_zone = "${element(var.availZones, count.index)}"
	tags {
		Name = "${var.projectName}-${var.stageName}-database-${element(var.availZones, count.index)}-sn"
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
  }
}

# Associate the private Route Tables to the database subnets
resource "aws_route_table_association" "databaseRteTblAssoc" {
	count          = "${length(var.databaseCidrs)}"
	subnet_id      = "${element(aws_subnet.database_subnet.*.id, count.index)}"
	route_table_id = "${element(aws_route_table.privateRouteTable.*.id, count.index)}"
}

###############################################################
# Private Routes

# Create a private route table for each AZ (to be assoicated w/ app and database subnets)
resource "aws_route_table" "privateRouteTable" {
	count	= "${length(var.availZones)}"
	vpc_id = "${aws_vpc.vpc.id}"
	tags {
		Name = "${var.projectName}-${var.stageName}-private-${element(var.availZones, count.index)}-routeTable"
		Project = "${var.projectName}",
		Stage   = "${var.stageName}"
		CostCenter = "${var.costCenter}"
	}
}

# Add a rule to each private subent route table, making the NAT GW in public subnet the default route
resource "aws_route" "privateNatRoute" {
	count = "${length(var.appCidrs)}"
	route_table_id = "${element(aws_route_table.privateRouteTable.*.id, count.index)}"
	nat_gateway_id = "${element(aws_nat_gateway.natGw.*.id, count.index)}"
	destination_cidr_block = "0.0.0.0/0"
}
