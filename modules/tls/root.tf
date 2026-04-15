resource "tls_private_key" "root_ca_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "root_ca_cert" {
  private_key_pem = tls_private_key.root_ca_key.private_key_pem

  validity_period_hours = 175200
  is_ca_certificate     = true

  early_renewal_hours = 8760

  allowed_uses = [
    "cert_signing",
  ]

  subject {
    common_name = "rke2-root-ca"
  }
}
