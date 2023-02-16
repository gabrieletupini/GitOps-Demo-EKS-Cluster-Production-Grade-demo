#used in private subnets to allow services to connect to the internet


#allocate public IP address first
resource "aws_eip" "nat" {
  vpc      = true

  tags = {
    Name = "nat"
  }
}




resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id #place it in the public subnet, that subnet must have internal gateway as default route

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}