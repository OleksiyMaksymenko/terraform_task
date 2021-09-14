resource "aws_vpc" "vpc_a" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "a_public_a"{
    vpc_id = aws_vpc.vpc_a.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "eu-west-3a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "a_private_a"{
    vpc_id = aws_vpc.vpc_a.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-3b"
    map_public_ip_on_launch = false
}

resource "aws_route_table" "rt_a" {
    vpc_id = aws_vpc.vpc_a.id
}

##############################################

resource "aws_internet_gateway" "inet_gateway_a" {
  vpc_id = aws_vpc.vpc_a.id
}

resource "aws_route" "public-internet_gateway_a" {
  route_table_id = aws_route_table.rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.inet_gateway_a.id
}

##############################################

resource "aws_instance" "Bastion" {
  key_name = "bastion_connect_key"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.a_public_a.id
}