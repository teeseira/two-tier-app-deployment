provider "aws" {
  region = var.region
}

resource "aws_security_group" "db_sg" {
  name        = var.db_sg_name

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = var.app_sg_name

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "jenkins_sg" {
  name        = var.jenkins_sg_name
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "db_instance" {
  ami           = var.ami_db
  instance_type = var.instance_type
  associate_public_ip_address = true
  key_name      = var.key_name
  security_groups = [aws_security_group.db_sg.name] 

  tags = {
    Name = "my-db-instance" 
  }

}

resource "aws_instance" "app_instance" {
  ami           = var.ami_app
  instance_type = var.instance_type
  associate_public_ip_address = true
  key_name      = var.key_name
  security_groups = [aws_security_group.app_sg.name] 

  tags = {
    Name = "my-app-instance" 
  }

  user_data = <<-EOF
    #!/bin/bash
    cd /home/ubuntu/repo/app
    export DB_CONNECTION_URI="mysql+pymysql://admin:password@${aws_instance.db_instance.private_ip}/northwind"
    waitress-serve --port=5000 northwind_web:app > waitress.log 2>&1 &
EOF

}

resource "aws_instance" "jenkins_server" {
  ami           = var.ami_jenkins
  instance_type = var.instance_type
  key_name      = var.key_name
  
  security_groups = [aws_security_group.jenkins_sg.name]
  
  tags = {
    Name = "jenkins-server"
  }
  depends_on = [aws_instance.db_instance]

}


