variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from the vpc module"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs from the vpc module"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from the vpc module"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "app_server_count" {
  description = "Number of app servers to create"
  type        = number
  default     = 4
}
variable "instance_profile_name" {
  description = "IAM instance profile name from IAM module"
  type        = string
  default     = ""
}

