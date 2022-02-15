terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.8.0"
    }
    godaddy = {
      source = "n3integration/godaddy"
      version = "1.8.7"
    }
  }
}

provider "godaddy" {
  key = var.godaddy_key
  secret = var.godaddy_secret
}

provider "digitalocean" {
  token = var.do_token
}

resource "tls_private_key" "terraform" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "id_terraform" {
  filename = "id_terraform"
  content  = tls_private_key.terraform.private_key_pem

  file_permission = "0600"
}

resource "local_file" "id_terraform_pub" {
  filename = "id_terraform.pub"
  content  = tls_private_key.terraform.public_key_openssh

  file_permission = "0600"
}


# Droplet ---------------------------------------------------------------------

resource "digitalocean_vpc" "gala_player" {
  name     = "${var.name}-vpc"
  region   = var.region
  ip_range = var.vpc_cidr
}

resource "digitalocean_ssh_key" "terraform" {
  name       = "${var.name}-terraform"
  public_key = tls_private_key.terraform.public_key_openssh
}

resource "digitalocean_droplet" "gala_player_main" {
  image  = var.image
  name   = var.name
  region = var.region
  size   = var.size

  ssh_keys = [digitalocean_ssh_key.terraform.fingerprint]

  private_networking = true
  vpc_uuid           = digitalocean_vpc.gala_player.id

  backups    = true
  monitoring = true
  ipv6       = true

  user_data = templatefile(
    "${path.module}/gala-node.yaml",
    {
      name = "${var.name}"
      fqdn = "${var.subdomain}.${var.domain}"
    },
  )
}

resource "godaddy_domain_record" "gala_player_main" {
  domain = var.domain

  record {
    name = var.subdomain
    type = "A"
    data = digitalocean_droplet.gala_player_main.ipv4_address
    ttl  = 600
  }
}
