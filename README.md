<div align="center">
  <h1>XYO Developer Center</h1>
  <p><b>AI Payment Transaction Enrichment</b></p>
  <p>
    <a href="https://github.com/xyo-financial/specs"><img src="https://img.shields.io/badge/OpenAPI-3.0.3-green.svg" alt="OpenAPI 3.0.3" /></a>
    <a href="https://github.com/xyo-financial"><img src="https://img.shields.io/badge/Compliance-RFC%207807-blue.svg" alt="RFC 7807" /></a>
    <a href="./sdk/Architecture.md"><img src="https://img.shields.io/badge/Architecture-Deterministic%20SDKs-blueviolet.svg" alt="Deterministic SDKs" /></a>
    <a href="https://github.com/xyo-financial"><img src="https://img.shields.io/badge/Security-TLS%201.3%20%7C%20Bearer%20Auth-success.svg" alt="Security" /></a>
    <a href="https://www.apache.org/licenses/LICENSE-2.0"><img src="https://img.shields.io/badge/License-Apache--2.0-blue.svg" alt="License: Apache-2.0" /></a>
    <img src="https://img.shields.io/badge/SDK%20Version-v2.0.x-orange.svg" alt="SDK v2.0.x" />
  </p>
</div>

Welcome to the central developer portal for **XYO Financial**'s API specifications, SDK libraries, and integration guides. Our infrastructure is engineered 
to process, enrich, and categorize high-volume transaction narratives with sub-millisecond latency for Tier-1 financial institutions and fintechs.

---

## 🚀 Architecture & Deployment Topologies

We support flexible deployment topologies tailored to strict regulatory, compliance, and throughput requirements:

* [**Basic SaaS Plan (SMEs & Fintech)**](./onboarding/sme)  
  Multi-tenant cloud infrastructure with global edge routing for rapid integration.
* [**Partial On-Premises (High-Throughput)**](./onboarding/large)  
  Hybrid deployment utilizing local transaction caching, edge tokenization, and private secure tunnels.
* [**Complete On-Premises (Enterprise & Government)**](./onboarding/enterprise-gov)  
  Fully air-gapped deployment within your private VPC or on-prem hardware for absolute data sovereignty (GDPR, PCI-DSS, PSD2 compliant).

---

## 🛠 Official v2 Client SDKs

All XYO client libraries are generated deterministically from our central OpenAPI specification and paired with ergonomic, idiomatic wrappers. Each SDK includes full unit and mock HTTP integration test suites with zero drift.

| Language / Platform      | Repository                                                              | Installation                                | Version  | Status     |
|:-------------------------|:------------------------------------------------------------------------|:--------------------------------------------|:---------|:-----------|
| **C++ (C++17)**          | [xyo-financial/sdk-cpp](https://github.com/xyo-financial/sdk-cpp)       | `CMake / Conan / vcpkg`                     | `v2.0.0` | **Stable** |
| **Rust**                 | [xyo-financial/sdk-rust](https://github.com/xyo-financial/sdk-rust)     | `cargo add xyo-sdk`                         | `v2.0.0` | **Stable** |
| **Go (Golang)**          | [xyo-financial/sdk-go](https://github.com/xyo-financial/sdk-go)         | `go get github.com/xyo-financial/sdk-go/v2` | `v2.0.1` | **Stable** |
| **Java (Java 17+)**      | [xyo-financial/sdk-java](https://github.com/xyo-financial/sdk-java)     | `com.xyo.financial:xyo-sdk:2.0.0`           | `v2.0.0` | **Stable** |
| **.NET / C# (.NET 8+)**  | [xyo-financial/sdk-dotnet](https://github.com/xyo-financial/sdk-dotnet) | `dotnet add package Xyo.Sdk`                | `v2.0.0` | **Stable** |
| **Python (3.9+)**        | [xyo-financial/sdk-python](https://github.com/xyo-financial/sdk-python) | `pip install xyo-sdk`                       | `v2.0.1` | **Stable** |
| **Node.js / TypeScript** | [xyo-financial/sdk-node](https://github.com/xyo-financial/sdk-node)     | `npm install xyo-sdk`                       | `v2.0.0` | **Stable** |

> For architecture principles and generation mechanics, see the [**SDK Architecture Guide**](./sdk/Architecture.md).

---

## ⚡ Canonical API Operations

Every official SDK provides direct, type-safe access to XYO's core enrichment engine through three canonical operations:

1. **Real-Time Single Enrichment (`enrichTransaction`)**: Synchronous enrichment for real-time payment authorization streams. Returns merchant categorization, brand logo, confidence score, and geolocation.
2. **Asynchronous Bulk Enrichment (`enrichTransactions`)**: High-throughput batch submission for settlement files and nightly ledger processing. Returns a tracked batch ID and downloadable archive link.
3. **Batch Status Polling (`getEnrichmentStatus`)**: Deterministic job status tracking (`READY`, `PENDING`, `FAILED`) to retrieve completed bulk enrichment archives.

---

## 📖 API Specifications & Tooling

Our OpenAPI specifications serve as the single source of truth for the entire platform:

* [**Specs Home**](https://github.com/xyo-financial/specs)
  The home to all types of API specifications and tooling.
* [**OpenAPI 3.0.3 Specification**](https://github.com/xyo-financial/specs/blob/main/openapi.yml)
  Hardened schema with rich banking transaction fixtures (Costa, Starbucks, Uber, TfL) and strict RFC 7807 problem details.
* [**Postman Collection**](https://github.com/xyo-financial/specs/blob/main/postman.json)
  Production-ready collection with pre-configured Bearer auth and payload templates.

---

## 🔒 Security & Compliance

* **Encryption**

All data in transit is enforced via TLS 1.3; data at rest is encrypted using AES-256-GCM.
* **Authentication**

  Bearer Token authentication via cryptographically provisioned API keys (`Authorization: Bearer <token>`).
* **Error Semantics**

  Standardized RFC 7807 Problem Details (`application/problem+json`) across all 4xx/5xx status codes.
* **Compliance**

  Zero-log transaction policies are available for enterprise topologies to guarantee GDPR and banking privacy compliance.

---

## 📄 License & Legal

Copyright &copy; 2026 <a href='https://syniol.com' target='_blank'>Syniol Limited</a>. All rights reserved.  
Distributed under the **Apache License, Version 2.0**. Use of these SDKs is subject to the XYO Financial Master Services Agreement.
