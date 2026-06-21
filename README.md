# cloud-labs

A collection of hands-on labs and technical articles around cloud infrastructure, DevOps, and platform engineering.

Each lab is a self-contained guide covering a real-world scenario — architecture, step-by-step commands, gotchas, and cleanup.

---

## Labs

| # | Lab | Stack | Description |
|---|-----|-------|-------------|
| 01 | [Cloud Run behind a Regional HTTPS Load Balancer](./lab-cloud-run-regional-https-lb/) | GCP · Cloud Run · Certificate Manager | Expose a containerized API via an external regional HTTPS LB with a custom domain and auto-managed SSL certificate |

---

## Structure

```
cloud-labs/
└── lab-<topic>/
    └── README.md   # full lab guide (architecture, commands, pitfalls, cleanup)
```

---

## Licence

MIT
