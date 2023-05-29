provider "aws" {
  region = "eu-west-1"
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "new-vpc"
  cidr = local.vpc_cidr

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

################################################################################
# Local Variables
################################################################################
locals {
  region = "eu-west-1"
  name   = "devops-practise"
  vpc_cidr = "10.0.0.0/16"
  
  instances = [
    {
      name      = "jenkins-server"
      user_data = <<-EOT
      #!/bin/bash
      sudo yum update –y
      sudo amazon-linux-extras install epel -y
      sudo amazon-linux-extras install java-openjdk11 -y
      sudo wget -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
      sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
      sudo yum upgrade -y 
      sudo yum install git -y
      sudo yum install jenkins -y
      sudo sudo service jenkins start
      echo "jenkins-server" > /etc/hostname && hostnamectl set-hostname "jenkins-server"
      sudo sudo service jenkins restart
      sudo yum install git -y
      sudo mkdir /opt/maven
      sudo wget -O /opt/maven/apache-maven-3.9.2-bin.tar.gz https://dlcdn.apache.org/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz
      sudo tar -xvzf /opt/maven/apache-maven-3.9.2-bin.tar.gz -C /opt/maven
      sudo mv /opt/maven/apache-maven-3.9.2 /opt/maven/apache-maven      
      sudo rm /opt/maven/apache-maven-3.9.2-bin.tar.gz
      existing_path=$(grep -oP '(?<=^PATH=).+' ~/.bash_profile)
      echo "M2_HOME=/opt/maven/apache-maven" | sudo tee -a ~/.bash_profile >/dev/null
      echo "M2=\$M2_HOME/bin" | sudo tee -a ~/.bash_profile >/dev/null
      echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.18.0.10-1.amzn2.0.1.x86_64" | sudo tee -a ~/.bash_profile >/dev/null
      new_path="PATH=$PATH:$HOME/.local/bin:$HOME/bin:\$M2_HOME:\$M2:\$JAVA_HOME"
      updated_path="\$PATH:$HOME/bin:$new_path"
      sed -i "s#^PATH=.*#PATH=$updated_path#" ~/.bash_profile

      sudo yum update -y
      sudo yum install -y docker
      sudo service docker start
      sudo usermod -aG docker $(whoami)
      sudo chkconfig docker on
      sudo useradd dockeradmin
      sudo passwd dockeradmin
      sudo usermod -aG docker dockeradmin
      echo "docker-server" > /etc/hostname && hostnamectl set-hostname "docker-server"
      sudo yum update -y
      sudo yum install -y docker
      sudo service docker start
      sudo usermod -aG docker $(whoami)
      sudo chkconfig docker on
      sudo useradd dockeradmin
      sudo passwd dockeradmin
      sudo usermod -aG docker dockeradmin
      echo "docker-server" > /etc/hostname && hostnamectl set-hostname "docker-server"
      EOT
    }
  ]

  tags = {
    for instance in local.instances :
    instance.name => {
      Name    = instance.name
      Project = local.name
    }
  }
}


################################################################################
# EC2 Module
################################################################################
module "ec2_instances" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  count                       = length(local.instances)
  name                        = local.instances[count.index].name
  ami                         = "ami-0e23c576dacf2e3df"
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  key_name                    = "newInstance"
  user_data_base64            = base64encode(local.instances[count.index].user_data)
  user_data_replace_on_change = true
  tags                        = local.tags[local.instances[count.index].name]
}

################################################################################
# SG GROUP
################################################################################
module "security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 4.0"
  name                = local.name
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "ssh-tcp", "all-icmp", "http-8080-tcp"]
  egress_rules        = ["all-all"]
}