# Security Policy & Vulnerability Disclosure

## 🛡️ Enterprise Security Commitment

Syniol Limited and the **XYO Financial** engineering team take the security, integrity, and confidentiality of our financial transaction enrichment software with the utmost seriousness. Our infrastructure processes mission-critical payment streams for Tier-1 financial institutions, central banks, and fintech platforms worldwide.

---

## 🔒 Supported Versions

Only the latest active major/minor release tracks of the **XYO Enrichment Platform Appliance** and **Official SDK Libraries** receive security patches and vulnerability remediation:

| Component | Version Track | Security Support Status |
| :--- | :--- | :--- |
| **XYO Appliance (Core / Helm)** | `v2.x.x` | :white_check_mark: Actively Supported |
| **Official v2 SDKs (C++, Rust, Go, Java, .NET, Python, Node.js)** | `v2.x.x` | :white_check_mark: Actively Supported |
| **Legacy v1 SDKs** | `v1.x.x` | :x: End of Life (Upgrade Recommended) |

---

## 🚨 Reporting a Vulnerability

If you discover a potential security vulnerability, zero-day threat, or cryptographic implementation flaw within XYO Financial software, containers, or SDKs:

### ⚠️ DO NOT FILE A PUBLIC GITHUB ISSUE

Please report all security vulnerabilities privately to our dedicated Product Security Incident Response Team (PSIRT):

* **Direct Security Contact:** `security@syniol.com`
* **Compliance & Legal Officer:** `compliance@syniol.com`
* **Emergency Escalation (24/7/365):** Tier-1 enterprise customers should contact their designated Technical Account Manager (TAM) or use the dedicated institutional hotline provided in [SUPPORT.md](.github/SUPPORT.md).

### 📋 What to Include in Your Report
To accelerate triage and remediation, please provide:
1. **Description:** Clear summary of the vulnerability, potential impact, and affected components (e.g., specific SDK version, container image tag, or API endpoint).
2. **Proof of Concept (PoC):** Step-by-step reproduction instructions or code snippets.
3. **Exploitability Assessment:** CVSS v3.1 vector or severity estimation (if available).
4. **Disclosure Preferences:** PGP key details if you prefer encrypted correspondence.

---

## ⏱️ Response Time & SLA Commitments

Our PSIRT operates under strict institutional SLAs:

* **Initial Acknowledgement:** Within **24 hours** of receipt.
* **Triage & Severity Assessment:** Within **48 hours**.
* **Remediation & Patch Deployment:** Critical vulnerabilities (CVSS $\ge$ 9.0) are patched and distributed via signed container digests within **72 hours**.
* **Public Advisory:** Coordinated vulnerability disclosure (CVD) upon patch availability and customer notification.

---

## 🔐 Cryptographic Provenance & Supply Chain Verification

All official container images are cryptographically signed with **Sigstore Cosign**. To verify build integrity before deployment:

```bash
# Download official public key
curl -s https://downloads.syniol.com/xyo/cosign.pub -o cosign.pub

# Verify signature
cosign verify --key cosign.pub cr.syniol.com/xyo/gateway:v2.0.0
```

---

## 📜 Compliance & Data Sovereignty

As a tier-1 data infrastructure provider, XYO Financial adheres to strict zero-egress architecture patterns to satisfy global regulatory frameworks.

For exhaustive documentation regarding our jurisdiction-specific compliance mappings (SAMA, BaFin, GDPR, PCI-DSS), air-gapped guarantees, and cryptographic controls, please refer to our dedicated governance document:

👉 **[XYO Global Regulatory Compliance & Governance Manual (COMPLIANCE.md)](COMPLIANCE.md)**

---
Copyright &copy; 2026 <a href="https://syniol.com" target="_blank">Syniol Limited</a>. All rights reserved.
