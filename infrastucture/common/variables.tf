variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# compute / scaling
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 1
}

# networking
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_cidrs" {
  type    = list(string)
  default = [
    "10.20.1.0/24",
    "10.20.2.0/24",
  ]
}

variable "private_cidrs" {
  type    = list(string)
  default = [
    "10.20.11.0/24",
    "10.20.12.0/24",
  ]
}

# e‑mail for SNS notifications
variable "alert_email" {
  type    = string
  default = ""
}

# optional key paira
variable "key_name" {
  type    = string
  default = ""
}

variable "aws_profile" {
  description = "AWS CLI profile to use for provider"
  type        = string
  default     = "demo-task"
}

