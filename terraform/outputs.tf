# output.tf
# These parameters will but spit out after each terraform apply

output "BASTION_IP" {
	value = "${aws_instance.bastion.public_ip}"
}

output "KEYFILE" {
	value = "${var.publicSshKey}"
}

output "VAULT_IP" {
	value = "${aws_instance.vault.private_ip}"
}

output "LOADBALANCER_DNS" {
	value = "${aws_alb.alb.dns_name}"
}

output "MYSQL_HOST" {
	value = "${aws_rds_cluster.rds_cluster.endpoint}"
}

output "MYSQL_USER" {
	value = "${aws_rds_cluster.rds_cluster.master_username}"
}

output "MYSQL_PASS" {
	value = "${aws_rds_cluster.rds_cluster.master_password}"
}

output "MYSQL_DB" {
	value = "${aws_rds_cluster.rds_cluster.database_name}"
}

output "MYSQL_PORT" {
	value = "${aws_rds_cluster.rds_cluster.port}"
}

output "WEB_PROFILE_ARN" {
	value = "${aws_iam_instance_profile.web_profile.arn}"
}
