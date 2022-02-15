variable "region" {
  default = "nyc3"
}
variable "vpc_cidr" {
  default = "10.0.0.0/24"
}
variable "image" {
  default = "ubuntu-20-04-x64"
}
variable "size" {
  default = "s-2vcpu-4gb"
}
variable "name" {
  default = "gala-node-main"
}

variable "subdomain" {
  default = "gala-player"
}
variable "domain" {
  default = "thinkorthogonal.com"
}

variable "godaddy_key" {}
variable "godaddy_secret" {}

variable "do_token" {}
