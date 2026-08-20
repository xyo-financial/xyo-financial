# ☸️ XYO Financial Appliance Helm Chart

[![Helm Chart Version](https://img.shields.io/badge/Helm-v2.0.0-blue.svg?logo=helm)](https://helm.sh/)
[![App Version](https://img.shields.io/badge/AppVersion-v2.0.0-green.svg)](https://xyo.syniol.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.22+-326ce5.svg?logo=kubernetes)](https://kubernetes.io/)
[![OpenShift](https://img.shields.io/badge/OpenShift-4.10+-ee0000.svg?logo=redhatopenshift)](https://www.redhat.com/openshift)
[![License](https://img.shields.io/badge/License-Proprietary-orange.svg)](https://syniol.com)

Enterprise-grade Helm v3 chart for deploying the **XYO Payment Transaction Enrichment Appliance** on Kubernetes and Red Hat OpenShift. Designed for mission-critical banking infrastructure, ultra-low latency transaction enrichment, air-gapped deployments, and zero-trust compliance.

---

## 🏛️ Architecture Overview

The XYO Appliance consists of decoupled microservices orchestrated for sub-millisecond inference and high-availability scalability:

```mermaid
flowchart TD
    Client(["🏦 Core Banking / Card Processor / Mobile App"]) -->|"HTTP/HTTPS :8080"| Ingress["🌐 Ingress / Route (TLS)"]
    Ingress --> SvcGW["⚙️ xyo-gateway Service"]
    
    subgraph K8s ["☸️ Kubernetes / OpenShift Cluster (Namespace: xyo)"]
        SvcGW --> GW["🚀 xyo-gateway Pods (Replicas: 2+)"]
        
        GW -->|"gRPC :9091"| SvcEnrich["⚙️ xyo-enrichment Service"]
        GW -->|"SQL :5432"| DB[("🗄️ PostgreSQL (Appliance / External RDS)")]
        GW -.->|"Read-Only"| PVC[("💾 xyo-logos PVC (ReadWriteMany)")]
        
        SvcEnrich --> Enrich["🧠 xyo-enrichment Pods (Replicas: 2+)"]
        Enrich -.->|"Read-Write"| PVC
        
        SvcEnrich -->|"gRPC :9092"| SvcOracle["⚙️ xyo-oracle Service"]
        SvcEnrich -->|"gRPC :9093"| SvcYoda["⚙️ xyo-yoda Service"]
        
        SvcOracle --> Oracle["🔮 xyo-oracle (Neural NLP Engine)"]
        SvcYoda --> Yoda["⚡ xyo-yoda (Merchant Heuristics Engine)"]
    end
```

### Microservice Components

| Component | Port / Protocol | Replicas | Function |
| :--- | :--- | :--- | :--- |
| **`xyo-gateway`** | `8080` (HTTP) | 2+ (HPA) | High-performance public API endpoint, request routing, caching, and static logo delivery. |
| **`xyo-enrichment`** | `9091` (gRPC) | 2+ (HPA) | Core orchestration pipeline coordinating machine learning inference and logo resolution. |
| **`xyo-oracle`** | `9092` (gRPC) | 1+ | Deep neural transaction categorization and multi-lingual payment NLP model. |
| **`xyo-yoda`** | `9093` (gRPC) | 1+ | Deterministic merchant disambiguation, ISO 18245 MCC classification, and location normalization. |
| **`xyo-postgres`** | `5432` (TCP) | 1 (or External) | Caching backend and historical transaction intelligence storage. |
| **`xyo-logos-pvc`** | Shared FS | - | High-IOPS `ReadWriteMany` persistent volume storing enriched merchant brand assets. |

---

## 📋 Prerequisites

- **Kubernetes**: Version `1.22+` or **Red Hat OpenShift**: Version `4.10+`
- **Helm**: Version `3.8+`
- **Storage**: A `ReadWriteMany` (RWX) capable `StorageClass` (e.g. AWS EFS CSI, Azure Files NFS, GCP Filestore, CephFS / ODF, or NFS Provisioner).
- **Private Registry Access**: Credentials for `cr.syniol.com` (or mirrored images in your enterprise container registry).
- **Activation License**: Enterprise XYO activation key from Syniol Limited.

---

## 🚀 Quickstart Installation

### 1. Add Private Registry & License Secrets

Create the target namespace:
```bash
kubectl create namespace xyo
```

Create image pull secrets:
```bash
kubectl create secret docker-registry syniol-registry-secret \
  --docker-server=cr.syniol.com \
  --docker-username="<YOUR_CLIENT_ID>" \
  --docker-password="<YOUR_CLIENT_SECRET>" \
  --namespace=xyo
```

### 2. Install the Chart

Install using default embedded configuration:
```bash
helm install xyo-prod ./charts/xyo-appliance \
  --namespace xyo \
  --set global.licenseKey="YOUR-ENTERPRISE-LICENSE-KEY"
```

### 3. Verify Installation

```bash
kubectl get pods -n xyo -l app.kubernetes.io/part-of=xyo-appliance
```

---

## 🏢 Enterprise Production Deployments

### Scenario A: Air-Gapped / Internal Private Registry

For air-gapped banking infrastructure where public internet access is prohibited:

```bash
helm install xyo-prod ./charts/xyo-appliance \
  --namespace xyo \
  --set global.imageRegistry="registry.internal.bank.net/xyo" \
  --set global.licenseKey="YOUR-ENTERPRISE-LICENSE-KEY" \
  --set global.imagePullSecrets[0].name="bank-internal-registry-secret"
```

### Scenario B: External Managed Database (AWS RDS / Aurora / GCP Cloud SQL)

For production HA databases, point the appliance to your external PostgreSQL instance:

```yaml
# values-prod.yaml
postgresql:
  enabled: false
  external:
    enabled: true
    dsn: "postgres://xyo_user:SecureBankPass123!@aurora-pg.internal.bank.net:5432/xyo_prod?sslmode=require"

global:
  licenseKey: "YOUR-ENTERPRISE-LICENSE-KEY"

persistence:
  logos:
    storageClass: "gp3-efs-sc"
    size: 20Gi

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "bank-internal-ca"
  hosts:
    - host: "xyo-enrichment.internal.bank.net"
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: "xyo-tls-cert"
      hosts:
        - "xyo-enrichment.internal.bank.net"

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 75
```

Deploy with custom values:
```bash
helm install xyo-prod ./charts/xyo-appliance \
  --namespace xyo \
  -f values-prod.yaml
```

---

## 🔒 Security Hardening & Zero-Trust Compliance

This chart is pre-configured to comply with **NIST SP 800-190**, **CIS Kubernetes Benchmark**, and **OpenShift Restricted-V2 SCC**:

1. **Non-Root Execution**: Runs strictly under non-root UID `10001` and GID `10001`.
2. **Read-Only Root Filesystem**: `readOnlyRootFilesystem: true` enabled on all containers.
3. **Privilege Escalation Blocked**: `allowPrivilegeEscalation: false` prevents SUID exploits.
4. **Dropped Linux Capabilities**: `capabilities.drop: ["ALL"]` eliminates all kernel privileges.
5. **Seccomp Profile**: Defaulting to `RuntimeDefault`.
6. **Ephemeral Temp Storage**: Mounted `emptyDir` volumes at `/tmp` for scratch operations.

---

## 📊 Complete Values Parameter Reference

### Global Parameters

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `global.imageRegistry` | Global container registry hostname | `cr.syniol.com` |
| `global.imagePullSecrets` | Array of secret names for pulling private images | `[{name: syniol-registry-secret}]` |
| `global.licenseKey` | Enterprise appliance license key | `""` |
| `global.existingLicenseSecret` | Pre-existing secret name holding license key | `""` |
| `global.licenseSecretKey` | Key within existing license secret | `"license-key"` |

### Gateway Parameters

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `gateway.enabled` | Enable public gateway microservice | `true` |
| `gateway.replicaCount` | Replicas when HPA is disabled | `2` |
| `gateway.image.repository` | Container image repository | `"xyo/gateway"` |
| `gateway.image.tag` | Container image tag (defaults to `Chart.AppVersion`) | `"v2.0.0"` |
| `gateway.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `gateway.service.type` | Kubernetes Service type | `ClusterIP` |
| `gateway.service.port` | Service port | `8080` |
| `gateway.resources.requests.cpu` | CPU request | `250m` |
| `gateway.resources.requests.memory` | Memory request | `512Mi` |
| `gateway.resources.limits.cpu` | CPU limit | `500m` |
| `gateway.resources.limits.memory` | Memory limit | `1Gi` |
| `gateway.probes.liveness.path` | Liveness health check path | `/healthz` |
| `gateway.probes.readiness.path` | Readiness health check path | `/readyz` |
| `gateway.probes.startup.path` | Startup health check path | `/healthz` |

### Enrichment, Oracle, Yoda Parameters

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `enrichment.replicaCount` | Replicas for orchestration layer | `2` |
| `enrichment.service.port` | gRPC service port | `9091` |
| `enrichment.resources.requests` | CPU/Mem requests | `500m` / `1Gi` |
| `enrichment.resources.limits` | CPU/Mem limits | `1000m` / `2Gi` |
| `oracle.replicaCount` | Replicas for neural NLP engine | `1` |
| `oracle.service.port` | gRPC service port | `9092` |
| `oracle.resources.limits` | CPU/Mem limits | `1000m` / `2Gi` |
| `yoda.replicaCount` | Replicas for heuristic engine | `1` |
| `yoda.service.port` | gRPC service port | `9093` |
| `yoda.resources.limits` | CPU/Mem limits | `1000m` / `2Gi` |

### Persistence (Logos PVC)

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `persistence.logos.enabled` | Enable shared PVC for merchant logo persistence | `true` |
| `persistence.logos.mountPath` | Container directory path for logos | `/var/lib/xyo/logos` |
| `persistence.logos.accessModes` | PVC access modes (must support multi-pod write) | `[ReadWriteMany]` |
| `persistence.logos.size` | Storage capacity | `10Gi` |
| `persistence.logos.storageClass` | StorageClass name (leave empty for default) | `""` |
| `persistence.logos.existingClaim` | Name of pre-existing PVC to bind | `""` |

### Database & Ingress

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `postgresql.enabled` | Deploy embedded PostgreSQL instance | `true` |
| `postgresql.auth.database` | Database name | `"xyo"` |
| `postgresql.auth.username` | Database user | `"xyo_user"` |
| `postgresql.external.enabled` | Enable external PostgreSQL connection | `false` |
| `postgresql.external.dsn` | External PostgreSQL connection string (DSN) | `""` |
| `ingress.enabled` | Enable Ingress controller routing | `false` |
| `ingress.className` | IngressClass controller identifier | `"nginx"` |
| `ingress.hosts[0].host` | Hostname for Ingress routing | `"xyo-appliance.internal.bank.com"` |
| `ingress.tls` | TLS secret certificates and hostname mappings | `[]` |

### Autoscaling & Monitoring

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `autoscaling.enabled` | Enable Horizontal Pod Autoscaling (HPA v2) | `false` |
| `autoscaling.minReplicas` | Minimum replica threshold | `2` |
| `autoscaling.maxReplicas` | Maximum replica threshold | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization % | `75` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target Memory utilization % | `80` |
| `metrics.enabled` | Enable metrics endpoints | `false` |
| `metrics.serviceMonitor.enabled` | Deploy Prometheus Operator `ServiceMonitor` | `false` |

---

## 🧪 Testing & Validation

### 1. Port Forwarding

```bash
kubectl port-forward svc/xyo-prod-gateway 8080:8080 -n xyo
```

### 2. Send Sample Enrichment Request

```bash
curl -X POST http://localhost:8080/v1/enrich \
  -H "Content-Type: application/json" \
  -d '{
    "description": "AMZN Mktp US*Amzn.com/bill WA",
    "countryCode": "US"
  }'
```

### Expected JSON Response

```json
{
  "merchant": {
    "name": "Amazon",
    "cleanName": "Amazon Marketplace",
    "category": "Shopping & Retail",
    "mcc": "5399",
    "subCategory": "General Merchandise",
    "confidenceScore": 0.994,
    "logoUrl": "http://localhost:8080/logos/amazon.svg",
    "website": "https://www.amazon.com",
    "location": {
      "city": "Seattle",
      "state": "WA",
      "country": "US"
    }
  },
  "flags": {
    "isSubscription": false,
    "isRecurring": false,
    "isForeign": false
  },
  "timingMs": 0.42
}
```

---

## 🔄 Upgrading & Uninstalling

### Upgrading the Chart

```bash
helm upgrade xyo-prod ./charts/xyo-appliance \
  --namespace xyo \
  --reuse-values \
  --set gateway.image.tag="v2.1.0"
```

### Uninstalling the Chart

```bash
helm uninstall xyo-prod --namespace xyo
```

---

## 📞 Enterprise Support

For technical support, private registry onboarding, custom model training, or appliance SLA inquiries:
- **Email**: [support@syniol.com](mailto:support@syniol.com)
- **Portal**: [https://syniol.com](https://syniol.com)
- **Documentation**: [https://xyo.syniol.com](https://xyo.syniol.com)
