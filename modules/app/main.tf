resource "google_compute_instance" "app" {
#  name         = "ruby-app"
  name         = "ruby-app-${count.index + 1}"
#  count	       = "${var.count}"	
#  machine_type = "g1-small"
  machine_type = "f1-micro"

  #  zone		= "us-central1-a"
  zone = "${var.zone}"
  tags = ["ruby-app"]

  boot_disk {
    initialize_params {
      #      image = "ruby-base"
      image = "${var.disk_image}"
    }
  }

  scheduling {
    preemptible = "True"
    automatic_restart = "False"
  }

  network_interface {
    network = "default"

    # use ethemeral ip for access from outside
    access_config {
#      nat_ip = "${google_compute_address.app_ip.address}"
    }
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

#resource "google_compute_address" "app_ip" {
#  name = "ruby-app-ip"
#}

