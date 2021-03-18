
# Instances vars
variable "number_of_instances" {
  description = "number of instance to create"
  type        = number
}

variable "instance_type" {
  description = "number of instance to create"
  type        = string
}

variable "ami_instance" {
  description = "number of instance to create"
  type        = string
}

variable "key_name" {
  type = string
}