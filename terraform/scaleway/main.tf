terraform {
  backend "s3" {
    bucket  = "rlustin-tfstate-storage"
    key     = "scaleway-terraform.tfstate"
    profile = "personal"
    region  = "eu-west-3"
  }

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.1.0"
    }
  }
  required_version = ">= 0.13"
}

module "global_vars" {
  source = "../global_vars"
}

provider "scaleway" {
  region  = "fr-par"
  zone    = "fr-par-2"
}

resource "scaleway_account_ssh_key" "ssh_key" {
  name       = element(split("== ", element(module.global_vars.ssh_keys, count.index)), 1)
  public_key = element(module.global_vars.ssh_keys, count.index)
  count      = length(module.global_vars.ssh_keys)
}

resource "scaleway_instance_ip" "lustin_fr" {}

resource "scaleway_instance_server" "lustin_fr" {
  name  = module.global_vars.lustin_fr_scaleway_server_name
  image = "ubuntu_focal"
  type  = "DEV1-S"
  ip_id = scaleway_instance_ip.lustin_fr.id
  enable_ipv6 = false
  security_group_id = scaleway_instance_security_group.default_sg.id
  tags = []

  root_volume {
    size_in_gb = 20
  }

  depends_on = [
    scaleway_instance_ip.lustin_fr,
    scaleway_instance_security_group.default_sg
  ]
}

resource "scaleway_instance_ip_reverse_dns" "lustin_fr" {
  ip_id = scaleway_instance_ip.lustin_fr.id
  reverse = module.global_vars.root_domain

  depends_on = [scaleway_instance_ip.lustin_fr]
}

resource "scaleway_instance_security_group" "default_sg" {
  description = "Auto generated security group."
  stateful = false
}
