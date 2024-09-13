variable "vm_name" {
  type    = string
  default = "worker"
}

variable "domain" {
  type    = string
  default = "certa.systems"
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "ipaddress" {
  type    = string
  default = "10"
}

variable "ci_user" {
  type = string
}

variable "ci_password" {
  type      = string
  sensitive = true
}

variable "ci_ssh_public_key" {
  type = string
}

variable "ci_ssh_private_key" {
  type = string
}