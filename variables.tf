variable "gce_ssh_user" {}
variable "gce_ssh_pub_key_file" {}
variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  default = "us-central1"
}
variable zone {
  description = "Zone"
  default = "us-central1-a"
}
variable disk_image {
  description = "Disk image"
}
variable provision_private_key {
  description = "Private key for provisioners"
}
