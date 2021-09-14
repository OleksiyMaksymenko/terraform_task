resource "aws_vpc_peering_connection" "peer_connection"{
  vpc_id = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_b.id
}

resource "aws_vpc_peering_connection_accepter" "accepter_b"{
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
  auto_accept = true
}

resource "aws_route" "route_from_a_to_b" {
    route_table_id = aws_route_table.rt_a.id
    destination_cidr_block = aws_vpc.vpc_b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}

resource "aws_route" "route_from_b_to_a" {
    route_table_id = aws_route_table.rt_b.id
    destination_cidr_block = aws_vpc.vpc_a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}


resource "aws_route" "route_from_b_to_a_private" {
    route_table_id = aws_route_table.rt_private.id
    destination_cidr_block = aws_vpc.vpc_a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}

resource "aws_route" "route_from_b_to_a_public" {
    route_table_id = aws_route_table.rt_public.id
    destination_cidr_block = aws_vpc.vpc_a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}
