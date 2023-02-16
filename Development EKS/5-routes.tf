resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route = [ 
    {
    cidr_block         = "0.0.0.0/0" #default route
    nat_gateway        = aws_internet_gateway.igw.id #is nat gateway

    #routing table with default route to internal gateway
    carrier_gateway_id = ""
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = ""
  },
]

  tags = {
    Name = "public"
  }
}

#associate subnets with routing tables
#create table association resources for all 4 subnets


resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private.id
}

#now public subnets


resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.public-us-east-1b.id
  route_table_id = aws_route_table.private.id
}