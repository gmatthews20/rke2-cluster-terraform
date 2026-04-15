resource "tls_private_key" "leaf_ca_key" {
  for_each  = toset(["client", "server", "request-header", "etcd/peer", "etcd/server"])
  algorithm = "RSA"
}

resource "tls_cert_request" "leaf_ca_csr" {
  for_each        = toset(["client", "server", "request-header", "etcd/peer", "etcd/server"])
  private_key_pem = tls_private_key.leaf_ca_key[each.key].private_key_pem

  subject {
    common_name = format("%s-%s-ca", "rke2", each.key)
  }
}

resource "tls_locally_signed_cert" "leaf_ca_cert" {
  for_each           = toset(["client", "server", "request-header", "etcd/peer", "etcd/server"])
  cert_request_pem   = tls_cert_request.leaf_ca_csr[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.intermediate_ca_key.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.intermediate_ca_cert.cert_pem

  validity_period_hours = 88800
  is_ca_certificate     = true

  early_renewal_hours = 8760

  allowed_uses = [
    "cert_signing",
  ]
}