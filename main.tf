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

## Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  for_each = var.public_subnets
  tags = merge(
    var.tags,
    {Name = "${var.env}-${each.value["name"]}"}
  )
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