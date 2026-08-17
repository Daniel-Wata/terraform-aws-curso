resource "aws_security_group" "alb" {
    name = "${local.name_prefix}-alb"
    description = "ponto de entrada public, libera HTTP da internet"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-alb"
    }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
    security_group_id = aws_security_group.alb.id 
    description = "HTTP da internet"

    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80 
    ip_protocol = "tcp"
}