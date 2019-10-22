variable "gce_ssh_user" {}
variable "gce_ssh_pub_key_file" {}
variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  default = "europe-west1"
}
variable disk_image {
  description = "Disk image"
}
