terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

locals {
  cluster_name = "finops-spot-demo"
  cluster_zone = "${var.region}-b"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

resource "google_compute_network" "demo" {
  name                    = "${local.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "demo" {
  name          = "${local.cluster_name}-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.demo.id

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

resource "google_container_cluster" "demo" {
  name                     = local.cluster_name
  location                 = local.cluster_zone
  network                  = google_compute_network.demo.id
  subnetwork               = google_compute_subnetwork.demo.id
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }
}

resource "google_container_node_pool" "on_demand" {
  name       = "on-demand-pool"
  location   = google_container_cluster.demo.location
  cluster    = google_container_cluster.demo.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "e2-medium"
    spot         = false

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      workload_tier = "on-demand"
    }

    tags = ["gke-finops-demo", "on-demand"]
  }
}

resource "google_container_node_pool" "spot" {
  name       = "spot-pool"
  location   = google_container_cluster.demo.location
  cluster    = google_container_cluster.demo.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "e2-medium"
    spot         = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      workload_tier = "spot"
    }

    tags = ["gke-finops-demo", "spot"]
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.demo.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.demo.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }

  depends_on = [google_container_node_pool.on_demand]
}

resource "kubernetes_namespace" "job_processing" {
  metadata {
    name = "job-processing"
  }

  depends_on = [google_container_node_pool.spot]
}

resource "kubernetes_deployment" "production_app" {
  metadata {
    name      = "critical-app"
    namespace = kubernetes_namespace.production.metadata[0].name
    labels = {
      app = "critical-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "critical-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "critical-app"
        }
      }

      spec {
        node_selector = {
          workload_tier = "on-demand"
        }

        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [google_container_node_pool.on_demand]
}

resource "kubernetes_deployment" "job_app" {
  metadata {
    name      = "batch-app"
    namespace = kubernetes_namespace.job_processing.metadata[0].name
    labels = {
      app = "batch-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "batch-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "batch-app"
        }
      }

      spec {
        node_selector = {
          workload_tier                 = "spot"
          "cloud.google.com/gke-spot" = "true"
        }

        toleration {
          key      = "cloud.google.com/gke-spot"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        }

        container {
          name    = "worker"
          image   = "busybox:1.36"
          command = ["/bin/sh", "-c", "sleep 3600"]

          resources {
            requests = {
              cpu    = "50m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "50m"
              memory = "32Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [google_container_node_pool.spot]
}