resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags,
    {Name = "${var.env}-vpc"}
  )
}

## Public subnets
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {Name = "${var.env}-${each.value["name"]}"}
  )
  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

}

# Need one internet gatway for public subnets to route
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {Name = "${var.env}-igw"}
  )
}

# Create elastic ips for nat gateways
resource "aws_eip" "nat" {
  instance = var.public_subnets
  vpc      = true
}
#Creating nat gateways for each public subnets
resource "aws_nat_gateway" "nat_gateway" {
  for_each = var.public_subnets
  allocation_id = aws_eip.nat[each.value["name"]].id
  subnet_id     = aws_subnet.public_subnets[each.value["name"]].id

  tags = merge(
    var.tags,
    {Name = "${var.env}-${each.value["name"]}"}
  )

}

## Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  for_each = var.public_subnets
  tags = merge(
    var.tags,
    {Name = "${var.env}-${each.value["name"]}"}
  )
}

resource "aws_route_table_association" "public_association" {
  for_each = var.public_subnets
  subnet_id = lookup(lookup(aws_subnet.public_subnets, each.value["name"], null ), "id", null)
  route_table_id = aws_route_table.public_route_table[each.value["name"]].id
}

####private subnets
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {Name = "${var.env}-${each.value["name"]}"}
  )
  for_each = var.private_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

}

####private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  for_each = var.private_subnets
  tags = merge(
    var.tags,
    {Name = "${var.env}-${each.value["name"]}"}
  )
}

resource "aws_route_table_association" "private_association" {
  for_each = var.private_subnets
  subnet_id = lookup(lookup(aws_subnet.private_subnets, each.value["name"], null ), "id", null)
  route_table_id = aws_route_table.private_route_table[each.value["name"]].id
}