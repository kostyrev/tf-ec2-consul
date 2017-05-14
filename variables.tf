variable "name" {
  description = "The cluster name, e.g cdn"
  type        = "string"
}

variable "image_id" {
  description = "AMI Image ID"
  type        = "string"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = "string"
}

variable "instance_type" {
  description = "The instance type to use, e.g t2.small"
  type        = "string"
}

variable "instance_profile" {
  description = "The instance profile to use"
  type        = "string"
}

variable "ebs_optimized" {
  description = "When set to true the instance will be launched with EBS optimized turned on"
  default     = false
}

variable "security_groups" {
  description = "Security groups for new instances"
  type        = "list"
  default     = []
}

variable "min_size" {
  description = "The minimum size of the cluter, e.g. 5"
}

variable "max_size" {
  description = "The maximum size of the cluter, e.g. 5"
}

variable "subnet_ids" {
  description = "list of subnet IDs"
  type        = "list"
}

variable "datacenter" {
  description = "The datacenter in which the agent is running"
  default     = "dc1"
}

variable "ec2_tag_key" {
  description = "The Amazon EC2 instance tag key to filter on"
  default     = "consul_join"
}

variable "ec2_tag_value" {
  description = "The Amazon EC2 instance tag value to filter on"
  default     = "consul-cluster"
}

variable "bootstrap_expect" {
  description = "The number of expected servers in the datacenter"
  default     = "3"
}
