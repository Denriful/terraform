terraform {
  required_version = "0.12.12"
}

provider "google" {
  #  version = "2.0.0"
 # version = "~> 2.18.0"

  project = var.project

  region = var.region
}

resource "google_container_cluster" "primary" {
  name               = "cluster-3"
  location           = "us-central1-c"
  initial_node_count = 3

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
  }

  network_policy {
    enabled = true
  }

  node_config {
    disk_size_gb = 25
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    machine_type = "g1-small"

    metadata = {
      disable-legacy-endpoints = "true"
    }



#    labels = {
#      foo = "bar"
#    }

#    tags = ["foo", "bar"]
  }

  timeouts {
    create = "15m"
    update = "15m"
  }
}
