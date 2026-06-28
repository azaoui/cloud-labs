variable "project_id" {
  description = "GCP project ID for the demo resources."
  type        = string
}

variable "region" {
  description = "GCP region used for the VPC and to derive the cluster zone."
  type        = string
  default     = "europe-west1"
}