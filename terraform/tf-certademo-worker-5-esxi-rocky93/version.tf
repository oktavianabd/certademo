terraform {
  required_providers {
	vsphere = {
		source = "hashicorp/vsphere"
		version = ">=2.5.1"
	}
  }
  required_version = ">=1.6.0"
}