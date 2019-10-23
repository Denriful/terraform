variable "gce_ssh_user" {
  default = "appuser"
}

variable "gce_ssh_pub_key_file" {
  default = "~/.ssh/appuser.pub"
}

variable zone {
  description = "Zone"
  default     = "us-central1-a"
}

variable disk_image {
  description = "Disk image"
  default = "reddit-base"
}

variable provision_private_key {
  description = "Private key for provisioners"
  default = "~/.ssh/appuser"
}

variable count {
  description = "Number of instances"
  default = "1"
}

