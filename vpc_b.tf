resource "aws_vpc" "vpc_b" {
    cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "b_public_a"{
    vpc_id = aws_vpc.vpc_b.id
    cidr_block = "10.1.0.0/24"
    availability_zone = "eu-west-3a"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "b_private_a"{
    vpc_id = aws_vpc.vpc_b.id
    cidr_block = "10.1.2.0/24"
    availability_zone = "eu-west-3a"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "b_private_b"{
    vpc_id = aws_vpc.vpc_b.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "eu-west-3b"
    map_public_ip_on_launch = false
}

#######################################

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc_b.id
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_b.id
}

resource "aws_route_table" "rt_b" {
    vpc_id = aws_vpc.vpc_b.id
}

#######################################

resource "aws_internet_gateway" "inet_gateway_b" {
  vpc_id = aws_vpc.vpc_b.id
}
 
#######################################
 
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.inet_gateway_b] # this resource will be created after ig is created
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.b_public_a.id
  depends_on = [aws_eip.nat_eip]
}

#######################################

resource "aws_route" "public-internet_gateway" {
  route_table_id = aws_route_table.rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.inet_gateway_b.id
}

resource "aws_route" "private-nat_gateway" {
  route_table_id = aws_route_table.rt_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
} 

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.b_public_a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.b_private_a.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.b_private_b.id
  route_table_id = aws_route_table.rt_private.id
}
