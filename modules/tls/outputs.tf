output "leaf_ca_key" {
  value = tls_private_key.leaf_ca_key
}

output "root_ca_cert" {
  value = tls_self_signed_cert.root_ca_cert
}
output "intermediate_ca_cert" {
  value = tls_locally_signed_cert.intermediate_ca_cert
}
output "leaf_ca_cert" {
  value = tls_locally_signed_cert.leaf_ca_cert
}

output "service_key" {
  value = tls_private_key.service_key
}