terraform {
  required_version = "0.11.11"
}

provider "google" {
  version = "2.0.0"

  project = "${var.project}"

  region = "${var.region}"

}

resource "google_compute_project_metadata" "default" {
  metadata {
    # path to public key
    ssh-keys = "appuser1:${file("~/.ssh/appuser.pub")} \nappuser2:${file("~/.ssh/appuser.pub")}"
    #ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

}

module "app" {
  source	= "./modules/app"
  count		= "2"
}

module "vpc" {
  source	= "./modules/vpc"
}




