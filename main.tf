resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags,
    {Name = "${var.env}-vpc"}
  )
}

## Public subnets
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {Name = "${var.env}-${each.value["name"]}"}
  )
  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

}