# web.tf

#################################################
# Web Load Balancer

# The load balancer
resource "aws_alb" "alb" {
	name			= "${var.projectName}-${var.stageName}-alb"
	internal		= false
	security_groups	= ["${aws_security_group.alb_sg.id}"]
	subnets			= ["${aws_subnet.public_subnet.*.id}"]
	tags {
		Project		= "${var.projectName}",
		Stage		= "${var.stageName}"
		CostCenter	= "${var.costCenter}"
	}
}

# The load balancer target group
resource "aws_lb_target_group" "alb_tg" {
	name			= "${var.projectName}-${var.stageName}-tg"
	port			= 80
	protocol		= "HTTP"
	vpc_id			= "${aws_vpc.vpc.id}"
	tags {
		Project		= "${var.projectName}",
		Stage		= "${var.stageName}"
		CostCenter	= "${var.costCenter}"
	}
}

# The load balancer listener
resource "aws_lb_listener" "alb_listener" {
	load_balancer_arn = "${aws_alb.alb.arn}"
	port              = "80"
	protocol          = "HTTP"
	# In production, provide certificate ARN for https
	#port              = "443"
	#protocol          = "HTTPS"
	#ssl_policy        = "ELBSecurityPolicy-2015-05"
	#certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

	default_action {
		target_group_arn = "${aws_lb_target_group.alb_tg.arn}"
		type             = "forward"
	}
}

# Security Group for ALB web access
resource "aws_security_group" "alb_sg" {
	name			= "${var.projectName}-${var.stageName}-alb-sg"
	vpc_id			= "${aws_vpc.vpc.id}"
	ingress {
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
    egress {
    	from_port	= 0
	    to_port		= 0
	    protocol	= "-1"
	    cidr_blocks = ["0.0.0.0/0"]
    }
	tags {
		Name		= "${var.projectName}-${var.stageName}-alb-sg"
		Project		= "${var.projectName}",
		Stage		= "${var.stageName}"
		CostCenter	= "${var.costCenter}"
	}
}

#################################################
# Autoscaling Group

# Create a launch configuration 
resource "aws_launch_configuration" "web_lc" {
	name_prefix			= "${var.projectName}-${var.stageName}-lc-"
	image_id			= "${var.webAmi}"
	security_groups		= ["${aws_security_group.web_sg.id}"]
	instance_type		= "${var.webInstanceType}"
	iam_instance_profile = "${aws_iam_instance_profile.web_profile.name}"
	user_data			= "${file("webuserdata.sh")}"
	key_name			= "${aws_key_pair.public_key.key_name}"
	lifecycle {
		create_before_destroy = true
	}
}

# Create an autoscaling group
resource "aws_autoscaling_group" "web_asg" {
	name                 = "${var.projectName}-${var.stageName}-web-asg"
	vpc_zone_identifier  = ["${aws_subnet.app_subnet.*.id}"]
	launch_configuration = "${aws_launch_configuration.web_lc.name}"
	target_group_arns	 = ["${aws_lb_target_group.alb_tg.arn}"]
	min_size             = "${var.tgtGrpMinSize}"
	max_size             = "${var.tgtGrpMaxSize}"
	desired_capacity     = "${var.tgtGrpDesiredSize}"
	health_check_grace_period = "${var.healthCheckGracePeriod}"
	lifecycle {
		create_before_destroy = true
	}
	# Tags that should be added to spawned instances
	tag {
		key                 = "Name"
		value               = "${var.projectName}-${var.stageName}-webinst"
		propagate_at_launch = true
	}
	tag {
		key                 = "Project"
		value               = "${var.projectName}"
		propagate_at_launch = true
	}
	tag {
		key                 = "Stage"
		value               = "${var.stageName}"
		propagate_at_launch = true
	}
	tag {
		key                 = "CostCenter"
		value               = "${var.costCenter}"
		propagate_at_launch = true
	}
	tag {
		key                 = "VaultIP"
		value               = "${aws_instance.vault.private_ip}"
		propagate_at_launch = true
	}

}

# Create a scaling policy
# Note: terraform only supports simple and step policies. Not the newer "Target Tracking"
#       policies. 
resource "aws_autoscaling_policy" "web_asg_policy" {
	name                 = "${var.projectName}-${var.stageName}-web-asg-policy"
	scaling_adjustment     = 2
	adjustment_type        = "ChangeInCapacity"
	cooldown               = 300
	autoscaling_group_name = "${aws_autoscaling_group.web_asg.name}"
}

# Create a cloud watch alarm that will trigger the autoscaling policy
resource "aws_cloudwatch_metric_alarm" "bat" {
	alarm_name          = "${var.projectName}-${var.stageName}-alarm-cpu"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods  = "2"
	metric_name         = "CPUUtilization"
	namespace           = "AWS/EC2"
	period              = "120"
	statistic           = "Average"
	threshold           = "80"

	dimensions {
		AutoScalingGroupName = "${aws_autoscaling_group.web_asg.name}"
	}

	alarm_description = "This metric monitors ec2 cpu utilization"
	alarm_actions     = ["${aws_autoscaling_policy.web_asg_policy.arn}"]
}

###########################################################
# Web Instance IAM role

# Create an IAM role we can attach to an EC2 instance
resource "aws_iam_role" "web_role" {
    name = "${var.projectName}-${var.stageName}-webinst-role"
	description = "Role that allows EC2 instance to write to cloudwatch logs and read tags"
	assume_role_policy = <<EOF
{
	"Version":"2012-10-17",
	"Statement":[
		{
			"Sid":"",
			"Effect":"Allow",
			"Principal":{"Service":"ec2.amazonaws.com"},
			"Action":"sts:AssumeRole"
		}
	]
}
EOF
}

# Attach a policy to the web role that allows it to write logs
resource "aws_iam_role_policy" "web_policy" {
    name = "${var.projectName}-${var.stageName}-webinst-policy"
	role = "${aws_iam_role.web_role.id}"
	policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
		"Effect": "Allow",
		"Action": [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:PutLogEvents",
			"logs:DescribeLogStreams"
		],
		"Resource": [ "arn:aws:logs:*:*:*" ]
	},{
		"Effect": "Allow",
		"Action": [
			"ec2:DescribeTags",
			"ec2:DescribeInstances"
		],
		"Resource": ["*"]
	}
 ]
}
EOF
}

# Create an IAM instance profile that allows us to attach IAM role to EC2 instance
resource "aws_iam_instance_profile" "web_profile" {
    name = "${var.projectName}-${var.stageName}-web-profile"
	role = "${aws_iam_role.web_role.name}"
}

###########################################################
# App Layer Security Group

# Security Group that allows ssh access from the bastion host and www load balancer
# Note: using a security group definition where rules are defined seperately, so that
#       if we are using a bastion.tf file, we can add the bastion host rule there.
resource "aws_security_group" "web_sg" {
	name = "${var.projectName}-${var.stageName}-web-sg"
	vpc_id = "${aws_vpc.vpc.id}"
	tags {
		Name		= "${var.projectName}-${var.stageName}-web-sg"
		Project		= "${var.projectName}",
		Stage		= "${var.stageName}"
		CostCenter	= "${var.costCenter}"
	}
}

# Rule to allow web servers to talk via port 80 to public (load balancer) subnet only
resource "aws_security_group_rule" "web_sg_80in" {
	type            = "ingress"
	from_port       = 80 
	to_port         = 80
	protocol        = "tcp"
	cidr_blocks		= ["${var.publicCidrs}"]
	security_group_id = "${aws_security_group.web_sg.id}"
}

# Rule to allow web servers to talk out to the world
resource "aws_security_group_rule" "web_sg_ALLout" {
	type            = "egress"
	from_port       = 0 
	to_port         = 0
	protocol        = "-1"
	cidr_blocks		= ["0.0.0.0/0"]
	security_group_id = "${aws_security_group.web_sg.id}"
}

# Note: if bastion.tf host is defined, the rule to allow it's ssh access is
#       in the bastion.tf file

