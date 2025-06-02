locals {
  docdb_username = "appuser"
  docdb_pwd_ssm  = "/demoapp/dev/docdb/master-pwd"
}

resource "aws_secretsmanager_secret" "docdb_pwd" {
  name = local.docdb_pwd_ssm              
}

resource "random_password" "docdb" {
  length              = 16
  special = false
}

resource "aws_secretsmanager_secret_version" "docdb_pwd_v" {
  secret_id     = aws_secretsmanager_secret.docdb_pwd.id
  secret_string = random_password.docdb.result
}

resource "aws_security_group" "docdb" {
  name        = "${var.project_name}-${var.environment}-docdb-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 27017
    to_port         = 27017
    security_groups = [aws_security_group.ec2.id]   
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_docdb_cluster" "main" {
  cluster_identifier = "${var.project_name}-${var.environment}-docdb"
  master_username    = local.docdb_username
  master_password    = random_password.docdb.result
  engine_version     = "5.0"           
  vpc_security_group_ids = [aws_security_group.docdb.id]
  db_subnet_group_name   = aws_docdb_subnet_group.main.name
  #skip_final_snapshot = true 
}

resource "aws_docdb_cluster_instance" "this" {
  count              = 1
  identifier         = "${var.project_name}-${var.environment}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = "db.t3.medium"
  auto_minor_version_upgrade = true
}

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-docdb-sng"
  subnet_ids = module.vpc.private_subnets
}
