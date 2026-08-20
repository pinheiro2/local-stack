# 1. App Security Group (for compute resources in the public subnet)
resource "aws_security_group" "app_sg" {
  name        = "${var.environment}-app-sg"
  description = "Allow inbound web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Database Security Group (for RDS in the private subnet)
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-sg"
  description = "Allow Postgres inbound from App SG only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from App SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    # DevSecOps: Notice we reference the App SG, NOT an IP range!
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}