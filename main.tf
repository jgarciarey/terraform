provider "aws" {
	access_key = "<ACCESS_KEY_AWS>"
	secret_key = "<SECRET_KEY_AWS>"
	region = "${var.region_name}"
}

resource "aws_security_group" "wordpress_sg" {
	name = "wordpress_sg"
	description = "Security Group from Wordpress"


	# SSH ingress access for provisioning
	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Allow SSH access for provisioning"
	}

	ingress {
		from_port   = "80"
		to_port     = "80"
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Allow access to http servers"
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "wordpress" {
	ami = "${var.ami_id}"
	instance_type = "${var.server_instance_type}"
	key_name = "${var.key_pair_name}"
	security_groups = ["${aws_security_group.wordpress_sg.name}"]

	tags {
		Name = "wordpress-ec2"
    	}

    	provisioner "local-exec" {
		command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ./${var.key_pair_name}.pem -i ${aws_instance.wordpress.public_dns}, provisioning/playbook.yml"
	}
}






