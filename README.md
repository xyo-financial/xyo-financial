<div align="center">
  <h1>XYO Developer Center</h1>
  <p><b>Mission-Critical Financial Transaction Enrichment & AI Categorization Engine</b></p>
  <p>
    <a href="https://github.com/xyo-financial/specs"><img src="https://img.shields.io/badge/OpenAPI-3.0.3-green.svg" alt="OpenAPI 3.0.3" /></a>
    <a href="https://github.com/xyo-financial"><img src="https://img.shields.io/badge/Compliance-PCI--DSS%20v4.0%20%7C%20SOC%202-blue.svg" alt="Compliance" /></a>
    <a href="https://github.com/xyo-financial"><img src="https://img.shields.io/badge/Security-TLS%201.3%20%7C%20mTLS%20%7C%20FIPS%20140--3-success.svg" alt="Security" /></a>
    <a href="./sdk/Architecture.md"><img src="https://img.shields.io/badge/Architecture-Deterministic%20SDKs-blueviolet.svg" alt="Deterministic SDKs" /></a>
    <a href="https://www.apache.org/licenses/LICENSE-2.0"><img src="https://img.shields.io/badge/License-Apache--2.0-blue.svg" alt="License: Apache-2.0" /></a>
    <img src="https://img.shields.io/badge/SDK%20Version-v2.0.x-orange.svg" alt="SDK v2.0.x" />
  </p>
</div>

Welcome to the central developer portal for **XYO Financial**'s API specifications, SDK libraries, and enterprise integration guides. Engineered for Tier-1 financial institutions, national payment switches, and global card issuers, XYO provides deterministic, low-latency transaction narrative parsing, merchant disambiguation, geolocation resolution, and neural categorization.

---

## 🏛️ Architecture & Deployment Topologies

XYO supports flexible deployment architectures aligned with regional data residency, regulatory mandates (OCC 2023-17, PRA SS2/21, DORA, China PIPL), and high-throughput requirements:

* [**Basic SaaS Plan (SMEs & Fintechs)**](./onboarding/sme)  
  Multi-tenant cloud infrastructure with global edge routing and TLS 1.3 termination for rapid deployment.
* [**Partial On-Premises (High-Throughput Hybrid)**](./onboarding/large)  
  Hybrid topology combining localized transaction tokenization, caching proxies, and dedicated low-latency secure tunnels.
* [**Complete On-Premises & Air-Gapped (G-SIFIs, Central Banks & Sovereign Clouds)**](./onboarding/enterprise-gov)  
  Fully air-gapped, zero-telemetry deployment within your private VPC or bare-metal infrastructure (Kubernetes, OpenShift, Docker). Guarantees 100% data sovereignty with zero PII egress (compliant with GDPR, GLBA, PCI-DSS v4.0 Level 1, and HKMA/PIPL).

---

## 🛠 Official v2 Client SDKs

All XYO client libraries are generated deterministically from our canonical OpenAPI specification and wrapped in ergonomic, idiomatic interfaces. Each SDK provides thread-safe operations, connection pooling, automated retry logic with exponential backoff, and full mock integration test suites.

| Language / Platform      | Repository                                                              | Installation                                | Version  | Status     |
|:-------------------------|:------------------------------------------------------------------------|:--------------------------------------------|:---------|:-----------|
| **C++ (C++17)**          | [xyo-financial/sdk-cpp](https://github.com/xyo-financial/sdk-cpp)       | `CMake / Conan / vcpkg`                     | `v2.0.0` | **Stable** |
| **Rust**                 | [xyo-financial/sdk-rust](https://github.com/xyo-financial/sdk-rust)     | `cargo add xyo-sdk`                         | `v2.0.0` | **Stable** |
| **Go (Golang)**          | [xyo-financial/sdk-go](https://github.com/xyo-financial/sdk-go)         | `go get github.com/xyo-financial/sdk-go/v2` | `v2.0.1` | **Stable** |
| **Java (Java 17+)**      | [xyo-financial/sdk-java](https://github.com/xyo-financial/sdk-java)     | `com.xyo.financial:xyo-sdk:2.0.0`           | `v2.0.0` | **Stable** |
| **.NET / C# (.NET 8+)**  | [xyo-financial/sdk-dotnet](https://github.com/xyo-financial/sdk-dotnet) | `dotnet add package Xyo.Sdk`                | `v2.0.0` | **Stable** |
| **Python (3.9+)**        | [xyo-financial/sdk-python](https://github.com/xyo-financial/sdk-python) | `pip install xyo-sdk`                       | `v2.0.1` | **Stable** |
| **Node.js / TypeScript** | [xyo-financial/sdk-node](https://github.com/xyo-financial/sdk-node)     | `npm install xyo-sdk`                       | `v2.0.0` | **Stable** |

> For architectural standards, deterministic code generation mechanics, and benchmarking, refer to the [**SDK Architecture Guide**](./sdk/Architecture.md).

---

## ⚡ Canonical API Operations

Every official SDK provides type-safe access to XYO's core enrichment engine through three canonical operations:

1. **Real-Time Single Enrichment (`enrichTransaction`)**  
   Synchronous enrichment for authorization streams and real-time payment settlement (P99 < 10ms). Returns merchant name, normalized branding/logos, confidence scores, MCC codes, and geolocation.

2. **Asynchronous Bulk Enrichment (`enrichTransactions`)**  
   High-throughput asynchronous batch submission for settlement files, core banking feeds, and nightly ledger processing. Returns a cryptographically tracked batch ID and downloadable archive link.

3. **Batch Status Polling (`getEnrichmentStatus`)**  
   Deterministic job lifecycle tracking (`READY`, `PENDING`, `FAILED`) to retrieve completed enrichment archives with built-in checksum verification.

---

## 📖 API Specifications & Developer Tooling

Our OpenAPI specifications serve as the single source of truth across all platforms and integrations:

* [**Specs Repository**](https://github.com/xyo-financial/specs)  
  Central repository for API contracts, schema validation tools, and contract-testing fixtures.
* [**OpenAPI 3.0.3 Specification**](https://github.com/xyo-financial/specs/blob/main/openapi.yml)  
  Hardened schema featuring comprehensive banking fixtures (ISO 8583 / ISO 20022 transaction narratives) and strict RFC 7807 problem details.
* [**Postman Collection**](https://github.com/xyo-financial/specs/blob/main/postman.json)  
  Production-ready collection configured with Bearer and mTLS authentication profiles, parameter sets, and payload templates.

---

## 🔒 Security, Compliance & Governance

* 🔐 **Encryption & Cryptographic Standards**  
  All data in transit is enforced via TLS 1.3 with Perfect Forward Secrecy (PFS); data at rest is encrypted using AES-256-GCM under FIPS 140-3 validated key management.
* 🔑 **Authentication & Access Control**  
  Dual-mode enterprise authorization supporting Mutual TLS (mTLS x509 certificates) and cryptographically provisioned Bearer tokens (`Authorization: Bearer <token>`) with automated rotation policies.
* ⚠️ **Error Semantics & Resilience**  
  Standardized RFC 7807 Problem Details (`application/problem+json`) across all HTTP status codes, coupled with idempotent request handling (`X-Idempotency-Key`) and distributed trace correlation (`X-Correlation-ID`).
* 📜 **Regulatory Compliance & Data Sovereignty**  
  Full alignment with **PCI-DSS v4.0**, **SOC 2 Type II**, **ISO/IEC 27001**, **UK/EU GDPR & DORA**, **US GLBA / OCC 2023-17**, **Saudi SAMA CSF & PDPL**, and **China PIPL / DSL**. Zero-log transaction policies are standard for on-premises and sovereign deployments to prevent cross-border data leakage.

> For detailed regulatory frameworks across Saudi Arabia, China, UK, US, and Germany, see the [**Global Compliance & Data Sovereignty Guide**](./COMPLIANCE.md).

---

## 📄 Licensing & Legal Notice

* **Client SDKs**: Distributed under the open-source [**Apache License, Version 2.0**](https://www.apache.org/licenses/LICENSE-2.0).
* **Enterprise Appliance & Core Engine**: Proprietary software licensed under the XYO Financial Master Services Agreement (MSA) and Enterprise Evaluation Agreement.

Copyright &copy; 2026 <a href='https://syniol.com' target='_blank'>Syniol Limited</a>. All rights reserved.
