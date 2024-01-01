variable "image_id" {
  type    = string
  default = "ami-0567f647e75c7bc05"
}

variable "instance_size" {
  type    = string
  default = "t3.nano"
}

variable "snapshot_id" {
  type    = string
}

variable "instance_dns" {
  type    = string
}

variable "instance_name" {
  type    = string
}

variable "volume_name" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "key_name" {
  type    = string
}

variable "subnet_id" {
  type    = string
}

variable "inbound" {
  type    = map
}

variable "policy_name" {
  type    = string
}

variable "mode" {
  type    = string
}

variable "volume_mount_id" {
  type    = string
}

variable "license_id" {
  type    = string
  default = ""
}

variable "route53_dns_tld" {
  type    = string
}

variable "tags" {
  type    = map
  default = {}
}