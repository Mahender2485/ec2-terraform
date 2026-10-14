variable "aws_region" {
  description = "AWS region where the VPC and AMI exist"
  type        = string
}

variable "vpc_id" {
  description = "Existing default VPC ID"
  type        = string
  default     = "vpc-0d9fcd0433c9ec4e2"
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
  default     = "ami-0220d79f3f480ecf5"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "184.190.96.180"
  type        = string

  validation {
    condition     = can(cidrhost("${var.my_ip}/32", 0))
    error_message = "my_ip must be a valid IPv4 address."
  }
}