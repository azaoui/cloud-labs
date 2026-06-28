# cloud-labs

A collection of hands-on labs and technical articles around cloud infrastructure, DevOps, and platform engineering.

Each lab is a self-contained guide covering a real-world scenario — architecture, step-by-step commands, gotchas, and cleanup.

---

## Labs

| # | Lab | Stack | Description |
|---|-----|-------|-------------|
| 01 | [Cloud Run behind a Regional HTTPS Load Balancer](./lab-cloud-run-regional-https-lb/) | GCP · Cloud Run · Certificate Manager | Expose a containerized API via an external regional HTTPS LB with a custom domain and auto-managed SSL certificate |
| 02 | [GKE Spot vs On-Demand Isolation](./lab-gke-finops-spot-isolation/) | GCP · GKE · Terraform · FinOps | Minimal GKE Standard demo with a dedicated VPC, separate on-demand and Spot node pools, and namespace-based workload placement |

---

## Structure

```
cloud-labs/
├── README.md
├── lab-cloud-run-regional-https-lb/
│   ├── README.md
│   ├── app-storage-reader.yaml
│   ├── app.py
│   ├── cloudbuild.yaml
│   ├── Dockerfile
│   ├── ksa-storage-reader.yaml
│   └── requirements.txt
├── lab-gke-finops-spot-isolation/
│   ├── infra/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── kube/
│   │   ├── job-processing-deployment.yaml
│   │   ├── namespaces.yaml
│   │   └── production-deployment.yaml
```

---

## Licence

MIT
