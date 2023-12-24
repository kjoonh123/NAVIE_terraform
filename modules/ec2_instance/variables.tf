variable "ec2_name" {
  description = "ec2_name"
  type = string
}

variable "ec2_ami" {
  description = "ec2_ami"
  type = string
}

variable "ec2_type" {
  description = "ec2_type"
  type = string
}
variable "user_data" {
  description = "user_data_EOF"
  type = string
}

variable "ec2_keyname" {
  description = "ec2_keyname"
  type = string
}

variable "subnet_id" {
  description = "subnet_id"
  type = string
}

variable "ec2_security_group_ids" {
  description = "ec2_sg_id"
}
