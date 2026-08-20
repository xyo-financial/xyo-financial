# 🛡️ XYO Financial Platform — Hardened Container Security & Deployment

This guide outlines the production deployment, container security posture, cryptographic supply chain verification, and air-gapped operations for the **XYO Financial Transaction Enrichment Service** using Docker and Docker Compose in Tier-1 banks, financial institutions, and sovereign government infrastructure.

---

## 📑 Table of Contents

1. [Architecture & Topology](#-architecture--topology)
2. [Tier-1 Bank Container Security Posture](#-tier-1-bank-container-security-posture)
3. [Sigstore / Cosign Cryptographic Verification](#-sigstore--cosign-cryptographic-verification)
   - [Public Key Verification](#1-public-key-verification)
   - [Verifying All Microservice Images](#2-verifying-all-microservice-images)
   - [Verifying SBOM & SLSA Provenance Attestations](#3-verifying-sbom--slsa-provenance-attestations)
   - [Enterprise KMS Verification (AWS, Azure, GCP, Vault)](#4-enterprise-kms-verification)
   - [Automated Admission Policy (Kyverno / Gatekeeper)](#5-automated-admission-policy)
4. [Air-Gapped & Sovereign Operations Workflow](#-air-gapped--sovereign-operations-workflow)
   - [Step 1: Bastion Image Ingestion & Integrity Audit](#step-1-bastion-image-ingestion--integrity-audit)
   - [Step 2: Tarball Generation (`docker save`)](#step-2-tarball-generation-docker-save)
   - [Step 3: Secure Diode / Media Transfer](#step-3-secure-diode--media-transfer)
   - [Step 4: Air-Gapped Registry Ingestion (`docker load`)](#step-4-air-gapped-registry-ingestion-docker-load)
   - [Step 5: Mirroring Cosign Signatures & Attestations](#step-5-mirroring-cosign-signatures--attestations)
5. [Docker Compose Hardened Specification](#-docker-compose-hardened-specification)
6. [Deployment & Verification Steps](#-deployment--verification-steps)
7. [Operational Runbook & Health Checks](#-operational-runbook--health-checks)

---

## 🏛️ Architecture & Topology

The containerized suite runs as an isolated microservice mesh inside a private bridge network:

```mermaid
flowchart TD
    subgraph Host Network Ingress
        Client["Bank Ingress / Core Banking Systems"]
    end

    subgraph "Docker Secure Network (xyo-network) [Non-Root UID 10001]"
        Gateway["xyo-gateway:v2.0.0<br/>• Read-Only Rootfs<br/>• Drop All Caps<br/>• Port 8080"]
        Enrichment["xyo-enrichment:v2.0.0<br/>• Read-Only Rootfs<br/>• Port 9091"]
        Oracle["xyo-oracle:v2.0.0<br/>• Deterministic Heuristics<br/>• Port 9092"]
        Yoda["xyo-yoda:v2.0.0<br/>• ML Categorizer<br/>• Port 9093"]
        DB[("xyo-postgres<br/>• Non-Root UID 70<br/>• Port 5432")]
    end

    subgraph Storage
        SSD[("Host NVMe SSD<br/>/var/lib/xyo/logos")]
    end

    Client -->|HTTP 8080| Gateway
    Gateway -->|gRPC 9091| Enrichment
    Gateway -->|TCP 5432| DB
    Enrichment -->|gRPC 9092| Oracle
    Enrichment -->|gRPC 9093| Yoda
    Enrichment -->|Read/Write| SSD
    Gateway -.->|Read-Only| SSD
```

---

## 🔒 Tier-1 Bank Container Security Posture

Every container image and compose specification is engineered to comply with **CIS Docker Benchmark**, **NIST SP 800-190** (Application Container Security Guide), **DISA STIG**, and **PCI-DSS v4.0 (Requirement 6.4)**.

| Security Control | Implementation Detail | Enterprise Compliance Impact |
|:---|:---|:---|
| **Non-Root Execution** | All processes run as explicit UID `10001` / GID `10001` (`xyo` user). | Prevents container-breakout privilege escalation to host `root`. |
| **Immutable Rootfs** | `read_only: true` applied across all service definitions. | Disallows disk modifications, binary patching, and unauthorized persistence. |
| **Linux Capabilities** | `cap_drop: ["ALL"]` drops all kernel capabilities (e.g. `CAP_NET_RAW`, `CAP_SYS_ADMIN`). | Mitigates raw network spoofing, kernel exploitation, and privilege changes. |
| **Privilege Escalation** | `security_opt: ["no-new-privileges:true"]`. | Prevents child processes from gaining higher privileges via `setuid`/`setgid` binaries. |
| **Distroless Runtime** | Multi-stage build targeting `gcr.io/distroless/static-debian12:nonroot` or Red Hat UBI Minimal. | Zero shell (`/bin/sh`), zero package managers (`apk`, `apt`, `yum`), zero glibc CVEs. |
| **Ephemeral Memory** | Memory-backed `tmpfs` mounts for `/tmp` and `/run` with `noexec, nosuid, nodev`. | Blocks in-memory exploit execution and payload staging. |
| **Resource Quotas** | Strict `deploy.resources.limits` and `reservations` on CPU & RAM. | Defends against Denial of Service (DoS) and memory exhaustion (OOM). |
| **Liveness & Readiness** | Dedicated static `/app/probe` executing `/healthz` & `/readyz` endpoints. | Real-time orchestrator state tracking without requiring external shell utilities. |

---

## 🔏 Sigstore / Cosign Cryptographic Verification

All official Syniol container images distributed from `cr.syniol.com` are cryptographically signed using **Sigstore Cosign** and accompanied by signed Software Bill of Materials (SBOM) and SLSA Level 3 build provenance.

```
       +-------------------------------------------------------------+
       |                  cr.syniol.com Registry                      |
       |  +---------------------------+  +------------------------+  |
       |  | cr.syniol.com/xyo/gateway |  | sha256-...sig (Cosign) |  |
       |  +---------------------------+  +------------------------+  |
       +-------------------------------------------------------------+
                                      |
                      1. Pull Signature & Attestation
                                      |
                                      v
       +-------------------------------------------------------------+
       |               Bank DevSecOps Verification Pipeline           |
       |                                                             |
       |   cosign verify --key cosign.pub cr.syniol.com/xyo/gateway   |
       |                                                             |
       |   [✓] Signature Valid                                       |
       |   [✓] Subject: release-engineering@syniol.com               |
       |   [✓] SBOM Attestation Valid (SPDX JSON)                    |
       |   [✓] Zero Critical/High CVEs                               |
       +-------------------------------------------------------------+
                                      |
                                      v
                     Approved for Deployment / Ingestion
```

### 1. Public Key Verification

Download Syniol’s enterprise release public key and verify its fingerprint:

```bash
# Retrieve public key from trusted key distribution channel
curl -sSL -o cosign.pub https://security.syniol.com/keys/cosign.pub

# (Optional) Verify public key SHA-256 fingerprint
sha256sum cosign.pub
```

### 2. Verifying All Microservice Images

Run `cosign verify` on each component before loading or running:

```bash
# Verify XYO Gateway
cosign verify --key cosign.pub cr.syniol.com/xyo/gateway:v2.0.0

# Verify XYO Enrichment
cosign verify --key cosign.pub cr.syniol.com/xyo/enrichment:v2.0.0

# Verify XYO Oracle
cosign verify --key cosign.pub cr.syniol.com/xyo/oracle:v2.0.0

# Verify XYO Yoda
cosign verify --key cosign.pub cr.syniol.com/xyo/yoda:v2.0.0
```

**Expected Successful Output:**
```json
Verification for cr.syniol.com/xyo/gateway:v2.0.0 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key
[{"critical":{"identity":{"docker-reference":"cr.syniol.com/xyo/gateway"},"image":{"docker-manifest-digest":"sha256:d5c21..."},"type":"cosign container image signature"},"optional":{"Bundle":{"SignedEntryTimestamp":"..."},"Issuer":"https://token.actions.githubusercontent.com","Subject":"release-engineering@syniol.com"}}]
```

### 3. Verifying SBOM & SLSA Provenance Attestations

Verify that the image contains a tamper-proof SPDX Software Bill of Materials (SBOM) and SLSA Provenance:

```bash
# 1. Verify and extract SPDX SBOM
cosign verify-attestation \
  --key cosign.pub \
  --type spdxjson \
  cr.syniol.com/xyo/gateway:v2.0.0 > gateway-sbom.spdx.json

# 2. Verify SLSA Provenance
cosign verify-attestation \
  --key cosign.pub \
  --type slsaprovenance \
  cr.syniol.com/xyo/gateway:v2.0.0
```

### 4. Enterprise KMS Verification

For institutions managing cryptographic verification keys in Hardware Security Modules (HSM) or Cloud KMS:

```bash
# AWS KMS
cosign verify --key awskms://arn:aws:kms:us-east-1:123456789012:key/mrk-abc12345 cr.syniol.com/xyo/gateway:v2.0.0

# Azure Key Vault
cosign verify --key azurekms://my-vault.vault.azure.net/xyo-cosign-key cr.syniol.com/xyo/gateway:v2.0.0

# Google Cloud KMS
cosign verify --key gcpkms://projects/bank-prod-sec/locations/global/keyRings/xyo-ring/cryptoKeys/xyo-key/cryptoKeyVersions/1 cr.syniol.com/xyo/gateway:v2.0.0

# HashiCorp Vault
cosign verify --key hashivault://xyo-transit-key cr.syniol.com/xyo/gateway:v2.0.0
```

### 5. Automated Admission Policy

For Kubernetes/OpenShift deployments running Gatekeeper or Kyverno, enforce signature verification prior to scheduling:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-xyo-image-signatures
spec:
  validationFailureAction: Enforce
  rules:
    - name: verify-signature
      match:
        resources:
          kinds:
            - Pod
      verifyImages:
        - imageReferences:
            - "cr.syniol.com/xyo/*"
            - "harbor.internal.bank.com/xyo/*"
          attestors:
            - entries:
                - keys:
                    publicKeys: |
                      -----BEGIN PUBLIC KEY-----
                      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...
                      -----END PUBLIC KEY-----
```

---

## 🛄 Air-Gapped & Sovereign Operations Workflow

For disconnected networks, sovereign government clouds, or high-security banking zones prohibiting outbound internet connectivity:

```
[ Connected Bastion Host ]                    [ Air-Gap Boundary ]                [ Sovereign Bank Zone ]
 1. docker pull (cr.syniol.com)                        |                            4. docker load
 2. cosign verify                                      |                            5. cosign copy (signatures)
 3. docker save -> xyo-bundle.tar                      |                            6. docker push (Internal Registry)
 4. sha256sum validation                               |                            7. Run with license.lic
            |                                          |                                        |
            +------------>[ Data Diode / Secure Media ]+----------------------------------------+
```

### Step 1: Bastion Image Ingestion & Integrity Audit

On an internet-connected security bastion:

```bash
# 1. Log in to Syniol Container Registry
docker login cr.syniol.com -u <your-client-id> -p <your-client-secret>

# 2. Pull official images
export XYO_VERSION="v2.0.0"
docker pull cr.syniol.com/xyo/gateway:${XYO_VERSION}
docker pull cr.syniol.com/xyo/enrichment:${XYO_VERSION}
docker pull cr.syniol.com/xyo/oracle:${XYO_VERSION}
docker pull cr.syniol.com/xyo/yoda:${XYO_VERSION}
docker pull postgres:15-alpine

# 3. Cryptographically verify each image using Cosign
for img in gateway enrichment oracle yoda; do
  cosign verify --key cosign.pub cr.syniol.com/xyo/${img}:${XYO_VERSION} || exit 1
done
```

### Step 2: Tarball Generation (`docker save`)

Package the verified images into a unified archive:

```bash
docker save \
  cr.syniol.com/xyo/gateway:${XYO_VERSION} \
  cr.syniol.com/xyo/enrichment:${XYO_VERSION} \
  cr.syniol.com/xyo/oracle:${XYO_VERSION} \
  cr.syniol.com/xyo/yoda:${XYO_VERSION} \
  postgres:15-alpine \
  -o xyo-stack-${XYO_VERSION}.tar

# Generate SHA-256 integrity checksum manifest
sha256sum xyo-stack-${XYO_VERSION}.tar > xyo-stack-${XYO_VERSION}.tar.sha256
```

### Step 3: Secure Diode / Media Transfer

Transfer `xyo-stack-v2.0.0.tar`, `xyo-stack-v2.0.0.tar.sha256`, and `cosign.pub` across your institutional security boundary (e.g. Data Diode, Optical Media, or Inspected Bastion).

### Step 4: Air-Gapped Registry Ingestion (`docker load`)

Inside the air-gapped environment:

```bash
# 1. Validate transfer integrity
sha256sum -c xyo-stack-v2.0.0.tar.sha256

# 2. Load images into the local Docker daemon
docker load -i xyo-stack-v2.0.0.tar

# 3. Tag images for your enterprise registry (e.g. Harbor, Artifactory, AWS ECR)
export INTERNAL_REGISTRY="harbor.internal.bank.com/xyo"

docker tag cr.syniol.com/xyo/gateway:${XYO_VERSION} ${INTERNAL_REGISTRY}/gateway:${XYO_VERSION}
docker tag cr.syniol.com/xyo/enrichment:${XYO_VERSION} ${INTERNAL_REGISTRY}/enrichment:${XYO_VERSION}
docker tag cr.syniol.com/xyo/oracle:${XYO_VERSION} ${INTERNAL_REGISTRY}/oracle:${XYO_VERSION}
docker tag cr.syniol.com/xyo/yoda:${XYO_VERSION} ${INTERNAL_REGISTRY}/yoda:${XYO_VERSION}
docker tag postgres:15-alpine ${INTERNAL_REGISTRY}/postgres:15-alpine

# 4. Push to enterprise registry
docker push ${INTERNAL_REGISTRY}/gateway:${XYO_VERSION}
docker push ${INTERNAL_REGISTRY}/enrichment:${XYO_VERSION}
docker push ${INTERNAL_REGISTRY}/oracle:${XYO_VERSION}
docker push ${INTERNAL_REGISTRY}/yoda:${XYO_VERSION}
docker push ${INTERNAL_REGISTRY}/postgres:15-alpine
```

### Step 5: Mirroring Cosign Signatures & Attestations

To maintain verification capability inside the air-gapped network:

```bash
# Re-copy signatures and SBOM attestations to your internal registry
cosign copy cr.syniol.com/xyo/gateway:${XYO_VERSION} ${INTERNAL_REGISTRY}/gateway:${XYO_VERSION}
cosign copy cr.syniol.com/xyo/enrichment:${XYO_VERSION} ${INTERNAL_REGISTRY}/enrichment:${XYO_VERSION}
cosign copy cr.syniol.com/xyo/oracle:${XYO_VERSION} ${INTERNAL_REGISTRY}/oracle:${XYO_VERSION}
cosign copy cr.syniol.com/xyo/yoda:${XYO_VERSION} ${INTERNAL_REGISTRY}/yoda:${XYO_VERSION}

# Internal teams verify against internal registry
cosign verify --key cosign.pub ${INTERNAL_REGISTRY}/gateway:${XYO_VERSION}
```

---

## ⚙️ Docker Compose Hardened Specification

The included [`docker-compose.yml`](./docker-compose.yml) enforces all security directives out of the box:

```yaml
# Sample extraction from docker-compose.yml showcasing hardening controls
services:
  xyo-gateway:
    image: cr.syniol.com/xyo/gateway:v2.0.0
    user: "10001:10001"
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    read_only: true
    tmpfs:
      - /tmp:size=128M,noexec,nosuid,nodev
      - /run:size=16M,noexec,nosuid,nodev
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: 1024M
        reservations:
          cpus: '0.25'
          memory: 256M
    healthcheck:
      test: ["CMD", "/app/probe", "-endpoint=http://127.0.0.1:8080/healthz"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s
```

---

## 🚀 Deployment & Verification Steps

### Step 1: Directory Setup & Host Permissions
Create the high-performance merchant logo volume with proper ownership for UID `10001`:

```bash
sudo mkdir -p /var/lib/xyo/logos
sudo chown -R 10001:10001 /var/lib/xyo/logos
sudo chmod 0750 /var/lib/xyo/logos
```

### Step 2: Environment Configuration
Define your Syniol License Key (or mount offline `license.lic`):

```bash
# Online activation mode:
export XYO_LICENSE_KEY="your-activation-license-key"

# Offline / Air-Gapped mode (mount digital certificate):
# Mount file to /etc/xyo/license.lic in docker-compose.yml
```

### Step 3: Launch Stack
Spin up the services in detached mode:

```bash
docker compose up -d
```

### Step 4: Validate Health & Service Readiness

```bash
# Inspect container health states
docker compose ps

# Tail gateway logs to confirm successful start
docker compose logs -f xyo-gateway
```

All five services should report `Up (healthy)`.

---

## 🧪 Operational Runbook & Verification Testing

### 1. Execute Test Transaction Enrichment

```bash
curl -i -X POST http://localhost:8080/v1/enrich \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key-if-configured" \
  -d '{
    "description": "AMZN Mktp US*Amzn.com/bill WA",
    "countryCode": "US"
  }'
```

**Expected JSON Response:**
```json
{
  "status": "success",
  "data": {
    "merchant": {
      "name": "Amazon",
      "domain": "amazon.com",
      "logoUrl": "http://localhost:8080/logos/amazon.png",
      "description": "Online retail marketplace and cloud services provider."
    },
    "category": {
      "name": "Shopping & E-Commerce",
      "mcc": "5942",
      "confidence": 0.998
    },
    "enrichmentConfidence": 0.99
  }
}
```

### 2. Verify Immutability & Non-Root Execution

Bank SecOps engineers can confirm container security constraints at runtime:

```bash
# Test 1: Confirm Non-Root UID
docker compose exec xyo-gateway id
# Output: uid=10001(xyo) gid=10001(xyo)

# Test 2: Confirm Read-Only Root Filesystem (Write attempts must fail)
docker compose exec xyo-gateway touch /test.txt
# Output: touch: cannot touch '/test.txt': Read-only file system

# Test 3: Confirm Cap Drop (Raw socket binding prohibited)
docker compose exec xyo-gateway ping -c 1 127.0.0.1
# Output: ping: permission denied (or executable not found)
```

---

## 🧹 Maintenance & Teardown

To gracefully stop the stack:

```bash
docker compose down
```

> [!WARNING]
> To purge persistent cache volumes, execute `docker compose down -v`. Do not run this in production without taking a PostgreSQL backup first.
