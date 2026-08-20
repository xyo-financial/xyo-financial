<h1 align="center">XYO Financial Onboarding & Integration Portal</h1>

<p align="center">
  <strong>Enterprise-Grade Routing & Integration Documentation</strong><br>
  Select the deployment tier that matches your institution's compliance, throughput, and infrastructure requirements.
</p>

---

## 🏢 Institutional Deployment Tiers

The XYO Enrichment Platform supports three distinct integration tiers tailored to your organization's scale, security posture, and hosting preferences.

| Tier | Target Profile | Topology & Hosting | Throughput SLA | Core Focus |
| :--- | :--- | :--- | :--- | :--- |
| [**SME / Fintech Startups**](./sme/) | Fast-growth fintechs, neobanks, and SaaS platforms. | Public Cloud (SaaS API) | Standard (Rate Limited) | Speed to market, REST APIs, simple SDK usage, webhooks. |
| [**Large Enterprise**](./large/) | Global acquirers, payment processors, and Tier-2 banks. | Dedicated Ingress (mTLS) / VPC | High-Throughput Batch (100k+ TPS) | Asynchronous batch processing, tenant partitioning (`x-api-user`), private network tunnels (PrivateLink). |
| [**Enterprise & Sovereign Gov**](./enterprise-gov/) | Tier-1 Core Banking, Sovereign entities, Defense. | Self-Hosted Air-Gapped Appliance | Dedicated On-Premises / Private K8s | Zero-trust networks, air-gapped container mirroring, PSS Restricted K8s, dedicated Helm deployments. |

---

## 🧭 1. SME / Fintech Startups (`/sme`)
Designed for agile development teams seeking instant API access to XYO's enrichment pipelines.
* ⚡ **Zero Infrastructure**: Connect directly to `api.xyo.financial` via public internet.
* 🛠️ **Developer Experience**: Leverage official SDKs for C++, Rust, Go, Java, .NET, Python, and Node.js.
* 🔗 **[Explore SME Onboarding &rarr;](./sme/)**

## 🏗️ 2. Large Enterprise (`/large`)
Tailored for organizations requiring high-volume asynchronous processing and strict network perimeters.
* 🔒 **Network Hardening**: Mutual TLS (mTLS), AWS PrivateLink, Azure ExpressRoute, GCP Cloud Interconnect.
* 📦 **Batch Pipelines**: Orchestrate payload chunks exceeding 100,000+ transactions with encrypted `.tar.gz` delivery.
* 🔗 **[Explore Large Enterprise Onboarding &rarr;](./large/)**

## 🏛️ 3. Enterprise & Sovereign Government (`/enterprise-gov`)
Built for institutions operating under the most rigorous regulatory frameworks (PCI-DSS Level 1, GDPR, SOC 2 Type II, ISO 27001).
* 🛡️ **Air-Gapped Deployments**: Host the complete XYO AI inference engine entirely within your own private subnets with zero outbound connectivity.
* ☸️ **Container Native**: Kubernetes (Helm / Static Manifests) and Hardened Docker environments with dropped capabilities and Read-Only root filesystems.
* 🔗 **[Explore Enterprise & Gov Onboarding &rarr;](./enterprise-gov/)**

---

### 🔐 Compliance & Governance
Copyright &copy; 2026 Syniol Limited. All rights reserved.  
Distributed under the **Apache License, Version 2.0** (Client SDKs) and **XYO Financial Enterprise Master Services Agreement (MSA)**.
