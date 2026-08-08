<div align="center">
  <h1>XYO Developer Center</h1>
  <p><b>Enterprise-Grade AI Payment Transaction Enrichment</b></p>
</div>

Welcome to the central portal for XYO Financial's developer documentation, API specifications, and SDK libraries. Our infrastructure is designed to process, enrich, and categorize high-volume transaction streams with sub-millisecond latency.

## 🚀 Architecture & Integration

We offer flexible deployment topologies tailored to your regulatory and throughput requirements:

* [**Basic SaaS Plan (SMEs)**](https://github.com/xyo-financial/xyo-financial/tree/main/onboarding/sme)
  Multi-tenant cloud infrastructure suitable for rapid integration.
* [**Partial On-Premises (Large Business)**](https://github.com/xyo-financial/xyo-financial/tree/main/onboarding/large)
  Hybrid deployment utilizing local caching and private secure tunnels.
* [**Complete On-Premises (Enterprise & Government)**](https://github.com/xyo-financial/xyo-financial/tree/main/onboarding/enterprise-gov)
  Fully air-gapped deployment within your VPC for absolute data sovereignty (GDPR, PCI-DSS compliant).

---

## 🛠 Official SDKs

Our machine-generated SDKs ensure deterministic type-safety and 100% parity with our OpenAPI specification. We provide native clients for the following environments:

| Language | Repository | Status | 
| :--- | :--- | :--- |
| **Node.js / TypeScript** | [xyo-financial/sdk-node](https://github.com/xyo-financial/sdk-node) | Stable |
| **Go (Golang)** | [xyo-financial/sdk-go](https://github.com/xyo-financial/sdk-go) | Stable |
| **Java** | [xyo-financial/sdk-java](https://github.com/xyo-financial/sdk-java) | Stable |
| **Rust** | [xyo-financial/sdk-rust](https://github.com/xyo-financial/sdk-rust) | Beta |
| **C++** | [xyo-financial/sdk-cpp](https://github.com/xyo-financial/sdk-cpp) | Beta |
| **PHP** | [xyo-financial/sdk-php](https://github.com/xyo-financial/sdk-php) | Stable |

---

## 📖 API Specification

For engineers building custom integrations or leveraging our REST API directly, our specifications are the absolute source of truth:

* [**OpenAPI 3.0 Specification**](https://github.com/xyo-financial/specs/blob/main/openapi.yml) - The core schema powering our network.
* [**Postman Collection**](https://github.com/xyo-financial/specs/blob/main/postman.json) - Ready-to-use requests for interactive testing.

---

## 🔒 Security & Compliance

At XYO Financial, data security is our foundational layer. 
* **Encryption**: All data in transit is secured via TLS 1.3, and at rest using AES-256.
* **Compliance**: We adhere strictly to GDPR data processing agreements. SOC 2 Type II certification is currently in progress.
* **Authentication**: All endpoints require Bearer Token authentication via securely provisioned API keys.

## 📄 License & Legal

Copyright &copy; 2026 <a href='https://syniol.com' target='_blank'>Syniol Limited</a>. All rights reserved. 
Use of these SDKs is subject to the XYO Financial Master Services Agreement.
