terraform {
  backend "s3" {
    bucket  = "rlustin-tfstate-storage"
    key     = "ovh-terraform.tfstate"
    profile = "personal"
    region  = "eu-west-3"
  }

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.16.0"
    }
  }
  required_version = ">= 0.16"
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = module.global_vars.ovh_application_key
  application_secret = module.global_vars.ovh_application_secret
  consumer_key       = module.global_vars.ovh_consumer_key
}

module "global_vars" {
  source = "../global_vars"
}

data "terraform_remote_state" "scaleway" {
  backend = "s3"

  config = {
    bucket  = "rlustin-tfstate-storage"
    key     = "scaleway-terraform.tfstate"
    profile = "personal"
    region  = "eu-west-3"
  }
}

resource "ovh_domain_zone_record" "email" {
  zone      = module.global_vars.root_domain
  subdomain = "email"
  fieldtype = "CNAME"
  ttl       = "300"
  target    = "ghs.googlehosted.com."
}

resource "ovh_domain_zone_record" "nas" {
  zone      = module.global_vars.root_domain
  subdomain = "nas"
  fieldtype = "A"
  ttl       = "300"
  target    = "82.65.111.219"
}

# lustin.fr

resource "ovh_domain_zone_record" "root" {
  zone      = module.global_vars.root_domain
  fieldtype = "A"
  ttl       = "300"
  target = data.terraform_remote_state.scaleway.outputs.main_domain_ip
}

resource "ovh_domain_zone_record" "subdomains" {
  zone       = module.global_vars.root_domain
  subdomain  = element(module.global_vars.default_subdomains, count.index)
  fieldtype  = "CNAME"
  ttl        = "300"
  target     = "${module.global_vars.root_domain}."
  count      = length(module.global_vars.default_subdomains)
  depends_on = [ovh_domain_zone_record.root]
}

resource "ovh_domain_zone_record" "mx1" {
  zone      = module.global_vars.root_domain
  fieldtype = "MX"
  ttl       = "300"
  target    = "1 aspmx.l.google.com."
}

resource "ovh_domain_zone_record" "mx2" {
  zone      = module.global_vars.root_domain
  fieldtype = "MX"
  ttl       = "300"
  target    = "5 alt1.aspmx.l.google.com."
}

resource "ovh_domain_zone_record" "mx3" {
  zone      = module.global_vars.root_domain
  fieldtype = "MX"
  ttl       = "300"
  target    = "5 alt2.aspmx.l.google.com."
}

resource "ovh_domain_zone_record" "mx4" {
  zone      = module.global_vars.root_domain
  fieldtype = "MX"
  ttl       = "300"
  target    = "10 aspmx2.googlemail.com."
}

resource "ovh_domain_zone_record" "mx5" {
  zone      = module.global_vars.root_domain
  fieldtype = "MX"
  ttl       = "300"
  target    = "10 aspmx3.googlemail.com."
}

resource "ovh_domain_zone_record" "mx6" {
  zone      = module.global_vars.root_domain
  fieldtype = "MX"
  ttl       = "300"
  target    = "10 aspmx4.googlemail.com."
}

resource "ovh_domain_zone_record" "mx7" {
  zone      = module.global_vars.root_domain
  fieldtype = "MX"
  ttl       = "300"
  target    = "10 aspmx5.googlemail.com."
}

resource "ovh_domain_zone_record" "fastmail_dkim_1" {
  zone      = module.global_vars.root_domain
  subdomain = "fm1._domainkey"
  fieldtype = "CNAME"
  ttl       = "300"
  target    = "fm1.lustin.fr.dkim.fmhosted.com."
}

resource "ovh_domain_zone_record" "fastmail_dkim_2" {
  zone      = module.global_vars.root_domain
  subdomain = "fm2._domainkey"
  fieldtype = "CNAME"
  ttl       = "300"
  target    = "fm2.lustin.fr.dkim.fmhosted.com."
}

resource "ovh_domain_zone_record" "fastmail_dkim_3" {
  zone      = module.global_vars.root_domain
  subdomain = "fm3._domainkey"
  fieldtype = "CNAME"
  ttl       = "300"
  target    = "fm3.lustin.fr.dkim.fmhosted.com."
}

resource "ovh_domain_zone_record" "fastmail_spf" {
  zone      = module.global_vars.root_domain
  fieldtype = "TXT"
  ttl       = "300"
  target    = "v=spf1 include:spf.messagingengine.com ?all"
}

resource "ovh_domain_zone_record" "dkim" {
  zone      = module.global_vars.root_domain
  subdomain = "lustinemails._domainkey"
  fieldtype = "TXT"
  ttl       = "300"
  target    = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQClLvZHTWIUaDrGD0mmjsUBueO4An68KN4JXnbF1cc2HXxe/IfjLG1V4sXAVHPzV69R15w/vwXDZup54/SIg7sKHUwF1TK3+RwpDthy704c6Tm9EKl5UBbv6ORLPoIWERvA+nuPZzIF4hf1vbPQ+DQdOMSFsbxVchVN3R3tiiL8rwIDAQAB"
}

resource "ovh_domain_zone_record" "google_site" {
  zone      = module.global_vars.root_domain
  fieldtype = "TXT"
  ttl       = "300"
  target    = "\"google-site-verification=dNordox3ih20SUXsw0B74G7HoLhMF8PfiR_KMohELvQ\""
}

# atrema.fr

resource "ovh_domain_zone_record" "atrema" {
  zone      = module.global_vars.atrema_fr_domain
  fieldtype = "A"
  ttl       = "300"
  target = data.terraform_remote_state.scaleway.outputs.main_domain_ip
}

resource "ovh_domain_zone_record" "atrema_subdomains" {
  zone       = module.global_vars.atrema_fr_domain
  subdomain  = element(module.global_vars.default_subdomains, count.index)
  fieldtype  = "CNAME"
  ttl        = "300"
  target     = "${module.global_vars.atrema_fr_domain}."
  count      = length(module.global_vars.default_subdomains)
  depends_on = [ovh_domain_zone_record.atrema]
}

resource "ovh_domain_zone_record" "atrema_google_site" {
  zone      = module.global_vars.atrema_fr_domain
  fieldtype = "TXT"
  ttl       = "300"
  target    = "google-site-verification=EVjxSHt_8COCzfbU8F-P7kMNEfOdRaNaBlu1Ygonhbw"
}
