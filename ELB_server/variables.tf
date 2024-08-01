variable "aws_region" {
  description = "AWS region to create resources in"
  default     = "eu-central-1"
}

variable "server_port" {
  description = "Port for the web server"
  default     = 80
}

variable "my_address" {
    description = "My address IP"
    type = string
    default = "178.235.242.60/32"
}

variable "instance_count" {
  description = "Number of instances"
  default     = 2
}