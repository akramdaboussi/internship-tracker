resource "aws_db_instance" "rds" {
  allocated_storage           = 20
  db_name                     = "internship_tracker"
  engine                      = "postgres"
  engine_version              = "18.6"
  instance_class              = "db.t4g.micro"
  username                    = "internship_tracker_user"
  identifier                  = "internship-tracker-db"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  skip_final_snapshot         = true
  publicly_accessible         = false
  storage_encrypted           = true
  tags = {
    Name = "internship-tracker-db"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "internship-tracker-db"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name = "internship-tracker-db"
  }
}

resource "aws_security_group" "rds" {
  name        = "internship-tracker-db-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "ecs_tasks" {
  name        = "internship-tracker-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres" {
  security_group_id            = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ecs_tasks.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

