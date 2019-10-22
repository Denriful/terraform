terraform {
  required_version = "0.11.11"
}

provider "google" {
  version = "2.0.0"

  #  project = "ruby-app-denriful"
  project = "${var.project}"

  #  region = "us-central1"
  region = "${var.region}"

}

resource "google_compute_project_metadata" "default" {
  metadata {
    # path to public key
    ssh-keys = "appuser1:${file("~/.ssh/appuser.pub")} \nappuser2:${file("~/.ssh/appuser.pub")}"
    #ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

}


resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"

  #  zone		= "us-central1-a"
  zone = "${var.zone}"
  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      #      image = "reddit-base"
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network = "default"

    # use ethemeral ip for access from outside
    access_config {}
  }

  metadata {
    # path to public key
    #  ssh-keys = "appuser:${file("/home/sulgin/.ssh/appuser.pub")}"
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  # connection settings for provisioners
  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.provision_private_key)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
