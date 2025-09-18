terraform {
  backend "s3" {
    # These values are set in state.config
    # terraform init -backend-config="./state.config"
    bucket     = ""
    region     = "RegionOne"
    access_key = ""
    secret_key = ""
    endpoints = {
      s3 = "https://s3.echo.stfc.ac.uk"
    }
    # Required for using with ceph s3
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    skip_region_validation      = true
  }
}
