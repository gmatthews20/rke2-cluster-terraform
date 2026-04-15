resource "tls_private_key" "intermediate_ca_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "intermediate_ca_csr" {
  private_key_pem = tls_private_key.intermediate_ca_key.private_key_pem

  subject {
    common_name = "rke2-intermediate-ca"
  }
}

resource "tls_locally_signed_cert" "intermediate_ca_cert" {
  cert_request_pem   = tls_cert_request.intermediate_ca_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca_cert.cert_pem

  validity_period_hours = 88800
  is_ca_certificate     = true

  early_renewal_hours = 8760

  allowed_uses = [
    "cert_signing",
  ]
}