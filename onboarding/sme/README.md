<div align="center">
  <h1>XYO Financial &mdash; SME & Fintech Cloud SaaS Onboarding Guide</h1>
  <p><b>Institutional-Grade AI Payment Transaction Enrichment Platform</b></p>
  <p>
    <a href="https://api.xyo.financial"><img src="https://img.shields.io/badge/Endpoint-https%3A%2F%2Fapi.xyo.financial-0A84FF.svg?style=flat-square" alt="API Endpoint" /></a>
    <a href="https://github.com/xyo-financial/specs"><img src="https://img.shields.io/badge/OpenAPI-3.0.3-34C759.svg?style=flat-square" alt="OpenAPI 3.0.3" /></a>
    <a href="https://tools.ietf.org/html/rfc7807"><img src="https://img.shields.io/badge/RFC%207807-Problem%20Details-5856D6.svg?style=flat-square" alt="RFC 7807" /></a>
    <a href="https://api.xyo.financial"><img src="https://img.shields.io/badge/Latency-Sub--15ms-FF9500.svg?style=flat-square" alt="Latency" /></a>
    <a href="https://api.xyo.financial"><img src="https://img.shields.io/badge/Security-TLS%201.3%20%7C%20Bearer%20Auth-007AFF.svg?style=flat-square" alt="Security" /></a>
    <a href="https://api.xyo.financial"><img src="https://img.shields.io/badge/Architecture-Multi--Tenant%20Global%20Edge-AF52DE.svg?style=flat-square" alt="Multi-Tenant" /></a>
  </p>
</div>

---

## 1. Executive & Architectural Overview

Welcome to the **XYO Financial Cloud SaaS Onboarding Guide** for Small and Medium Enterprises (SMEs), Challenger Banks, Neobanks, and Fintech Platforms. 

XYO Financial operates a high-throughput, multi-tenant global edge platform engineered specifically for ultra-low latency transaction enrichment. Raw bank narratives (such as `COSTA PICKUP LONDON`, `STARBUCKS STORE #10423 SEATTLE WA`, or `UBER *TRIP 12345 HELP.UBER.COM`) are resolved in real time into clean merchant identities, deep hierarchical classifications, geolocated store locations, and high-resolution base64 brand logos.

```
+---------------------------------------------------------------------------------------------------+
|                                 XYO FINANCIAL MULTI-TENANT CLOUD SAAS                             |
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|  [ Fintech / SME App ]                                                                            |
|         │                                                                                         |
|         │ HTTPS / TLS 1.3 (Bearer Auth)                                                           |
|         ▼                                                                                         |
|  [ Anycast Global Edge Network ] <── (Sub-15ms Edge Routing & Caching)                             |
|         │                                                                                         |
|         ▼                                                                                         |
|  [ Multi-Tenant API Gateway (https://api.xyo.financial) ]                                         |
|         │                                                                                         |
|         ├── Tenant Rate Limiter (Token Bucket + Jitter Protection)                                |
|         ├── RFC 7807 Problem Details Interceptor                                                  |
|         └── Cryptographic Tenant Boundary Isolation                                               |
|         │                                                                                         |
|         ▼                                                                                         |
|  [ Real-Time AI Inference Engine ]                                                                |
|         │                                                                                         |
|         ├── Single Stream (Sub-15ms Synchronous Enrichment: enrichTransaction)                    |
|         └── Asynchronous Batch Queue (Settlement Files: enrichTransactions)                       |
|         │                                                                                         |
|         ▼                                                                                         |
|  [ Structured Intelligence Response ]                                                             |
|         ├── Clean Merchant Entity (e.g., "Costa Coffee", "Starbucks", "Uber")                     |
|         ├── Hierarchical Taxonomy (e.g., ["Food & Beverage", "Cafes & Coffee Shops"])             |
|         ├── Exact Store Geolocation & Normalized Address                                          |
|         └── Embedded Base64 Logo (Zero external CDN dependency)                                   |
|                                                                                                   |
+---------------------------------------------------------------------------------------------------+
```

### Key Architectural Tenets for SMEs
* **Global Edge Deployment**: All requests resolve via Anycast DNS to the nearest regional edge node targeting `https://api.xyo.financial`.
* **Sub-15ms Real-Time SLA**: Optimized inference and memory-mapped entity databases enable synchronous enrichment directly within the critical payment authorization path (ISO 8583 / ISO 20022 message cycles).
* **Cryptographic Multi-Tenancy**: Complete logical and cryptographic isolation between tenant environments. Request contexts are ephemeral, stateless, and audited.
* **Zero PII Footprint**: XYO requires only the raw counterparty narrative string (`content`) and the ISO 3166-1 alpha-2 country code (`countryCode`). No Primary Account Numbers (PANs), Card Verification Values (CVVs), or customer names are ever accepted or processed.

---

## 2. Getting Started & Authentication

### 2.1 API Key Provisioning
Every SME tenant is issued an API key during workspace registration via the [XYO Developer Portal](https://api.xyo.financial). 

* **Test Environment**: Use your sandbox API key (`xyo_test_...`) to test mock transactions with zero credit consumption.
* **Production Environment**: Use your production API key (`xyo_live_...`) targeting `https://api.xyo.financial`.

> [!IMPORTANT]
> API keys grant programmatic access to your tenant credit balance and enrichment quotas. Store keys securely using secret management solutions (e.g., AWS Secrets Manager, HashiCorp Vault, Kubernetes Secrets, or Doppler). **Never hardcode API keys into version control or client-side web/mobile apps.**

### 2.2 Bearer Authentication
All HTTP requests to the XYO API must include the API key in the `Authorization` header formatted as a standard HTTP Bearer token:

```http
Authorization: Bearer <YOUR_XYO_API_KEY>
Content-Type: application/json
Accept: application/json
```

### 2.3 Transport Layer Security (TLS 1.3)
All connections must be established over HTTPS with **TLS 1.3** (or TLS 1.2 with strong modern cipher suites). Cleartext HTTP requests to port 80 are rejected immediately with an HTTP `301 Moved Permanently` or connection termination.

---

## 3. Official v2 SDK Integrations

XYO publishes official, type-safe client libraries with native support for real-time synchronous enrichment, asynchronous bulk batches, and automatic RFC 7807 error parsing.

### 3.1 Node.js / TypeScript Integration

#### Installation
```bash
npm install xyo-sdk
# or
yarn add xyo-sdk
# or
pnpm add xyo-sdk
```

#### Complete Implementation (`enrichment-service.ts`)
```typescript
import { XYOClient, EnrichmentRequest, EnrichmentResponse } from 'xyo-sdk';

// 1. Initialize the XYO Client with your API Key
const xyo = new XYOClient({
  apiKey: process.env.XYO_API_KEY ?? 'xyo_live_your_api_key_here',
  baseUrl: 'https://api.xyo.financial', // Default production endpoint
});

/**
 * Enriches a single card transaction narrative in real time.
 */
async function processCardTransaction(rawDescription: string, country: string): Promise<void> {
  const request: EnrichmentRequest = {
    content: rawDescription,
    countryCode: country,
  };

  try {
    const startTime = performance.now();
    const result: EnrichmentResponse = await xyo.enrichTransaction(request);
    const duration = (performance.now() - startTime).toFixed(2);

    console.log(`[XYO] Enriched in ${duration}ms:`);
    console.log(`- Merchant:    ${result.merchant}`);
    console.log(`- Description: ${result.description}`);
    console.log(`- Categories:  ${result.categories.join(' > ')}`);
    console.log(`- Location:    ${result.location}`);
    console.log(`- Address:     ${result.address}`);
    console.log(`- Logo Data:   ${result.logo.substring(0, 32)}... (Base64 Data URI)`);
  } catch (error: any) {
    console.error('[XYO Error]', error.message);
  }
}

// Execute sample
processCardTransaction('COSTA PICKUP LONDON', 'GB');
```

---

### 3.2 Go (Golang) Integration

#### Installation
```bash
go get github.com/xyo-financial/sdk-go/v2
```

#### Complete Implementation (`main.go`)
```go
package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	xyo "github.com/xyo-financial/sdk-go/v2"
)

func main() {
	apiKey := os.Getenv("XYO_API_KEY")
	if apiKey == "" {
		apiKey = "xyo_live_your_api_key_here"
	}

	// 1. Initialize Client Configuration
	client, err := xyo.NewClient(&xyo.ClientConfig{
		APIKey:  apiKey,
		BaseURL: "https://api.xyo.financial",
	})
	if err != nil {
		log.Fatalf("Failed to initialize XYO client: %v", err)
	}

	// 2. Prepare Context with strict timeout (e.g., 50ms for payment auth)
	ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
	defer cancel()

	// 3. Execute Real-Time Enrichment
	req := &xyo.EnrichmentRequest{
		Content:     "STARBUCKS STORE #10423 SEATTLE WA",
		CountryCode: "US",
	}

	resp, err := client.EnrichTransaction(ctx, req)
	if err != nil {
		log.Fatalf("Enrichment failed: %v", err)
	}

	// 4. Inspect Structured Merchant Intelligence
	fmt.Printf("Merchant:    %s\n", resp.Merchant)
	fmt.Printf("Description: %s\n", resp.Description)
	fmt.Printf("Categories:  %v\n", resp.Categories)
	fmt.Printf("Location:    %s\n", resp.Location)
	fmt.Printf("Address:     %s\n", resp.Address)
	fmt.Printf("Logo (b64):  %s...\n", resp.Logo[:30])
}
```

---

### 3.3 Python Integration (Modern Async / Sync)

```python
import os
import httpx

XYO_API_KEY = os.getenv("XYO_API_KEY", "xyo_live_your_api_key_here")
XYO_BASE_URL = "https://api.xyo.financial"

def enrich_transaction(content: str, country_code: str) -> dict:
    headers = {
        "Authorization": f"Bearer {XYO_API_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    payload = {
        "content": content,
        "countryCode": country_code,
    }

    with httpx.Client(base_url=XYO_BASE_URL, timeout=5.0) as client:
        response = client.post("/v1/ai/finance/enrichment/transaction", json=payload, headers=headers)
        response.raise_for_status()
        return response.json()

if __name__ == "__main__":
    result = enrich_transaction("UBER *TRIP 12345 HELP.UBER.COM", "GB")
    print(f"Merchant: {result['merchant']}")
    print(f"Categories: {', '.join(result['categories'])}")
    print(f"Location: {result['location']}")
```

---

### 3.4 Java (Java 17+) Integration

#### Dependency (`pom.xml`)
```xml
<dependency>
    <groupId>com.xyo</groupId>
    <artifactId>xyo-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

#### Code Snippet
```java
package com.fintech.enrichment;

import com.xyo.financial.ClientConfig;
import com.xyo.financial.XyoClient;
import com.xyo.financial.model.EnrichmentRequest;
import com.xyo.financial.model.EnrichmentResponse;

public class PaymentEnrichmentService {

    private final XyoClient xyoClient;

    public PaymentEnrichmentService() {
        ClientConfig config = new ClientConfig.Builder(System.getenv("XYO_API_KEY"))
                .apiBaseUrl("https://api.xyo.financial")
                .connectTimeoutMs(3000)
                .requestTimeoutMs(5000)
                .build();
        this.xyoClient = new XyoClient(config);
    }

    public EnrichmentResponse enrich(String narrative, String countryCode) {
        EnrichmentRequest request = new EnrichmentRequest(narrative, countryCode);
        return xyoClient.enrichTransaction(request);
    }
}
```

---

### 3.5 Direct cURL Snippet

```bash
curl -X POST "https://api.xyo.financial/v1/ai/finance/enrichment/transaction" \
  -H "Authorization: Bearer xyo_live_your_api_key_here" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "content": "TfL Travel Charge tfl.gov.uk",
    "countryCode": "GB"
  }'
```

---

## 4. Core Real-Time Workflow: `enrichTransaction`

### 4.1 Payment Authorization Stream Integration
In real-time banking pipelines, when a cardholder taps their physical card, smartphone, or executes an online checkout, the core card issuing switch receives an ISO 8583 authorization message containing a truncated, noisy transaction narrative (e.g. `COSTA PICKUP LONDON`). 

The SME gateway triggers `enrichTransaction` to resolve counterparty intelligence before storing the ledger entry or pushing push notifications to the cardholder mobile application.

```
[ POS Terminal / Card Swiped ]
       │
       ▼
[ Payment Processor / Core Banking ]
       │
       │ 1. ISO 8583 Auth Stream
       ▼
[ SME Payment Gateway Hook ]
       │
       │ 2. POST /v1/ai/finance/enrichment/transaction (Sub-15ms)
       ▼
[ XYO Multi-Tenant Edge Engine ]
       │
       │ 3. Returns Enriched Merchant + Base64 Logo + Geocoding
       ▼
[ SME Mobile Notification Service ]
       │
       │ 4. "You spent £3.40 at Costa Coffee, 40-42 Great Portland St"
       ▼
[ Cardholder Mobile Device (Clean Logo + Map Pin Displayed) ]
```

---

### 4.2 Request Specification

* **Endpoint**: `POST /v1/ai/finance/enrichment/transaction`
* **Content-Type**: `application/json`

| Field | Type | Required | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `content` | `string` | **Yes** | Min 1, Max 128 chars | Raw counterparty description from card narrative or bank feed. |
| `countryCode` | `string` | **Yes** | Exact 2 chars (ISO 3166-1 alpha-2) | Two-letter country code where transaction originated (e.g., `GB`, `US`, `DE`). |

#### Example Request Payload
```json
{
  "content": "COSTA PICKUP LONDON",
  "countryCode": "GB"
}
```

---

### 4.3 Response Specification

* **Status Code**: `200 OK`
* **Content-Type**: `application/json`

| Field | Type | Description |
| :--- | :--- | :--- |
| `merchant` | `string` | Standardized, human-readable merchant name (e.g. `Costa Coffee`). |
| `description` | `string` | Concise institutional corporate and business summary of the merchant. |
| `categories` | `string[]` | Hierarchical taxonomy tags suitable for budgeting and categorization. |
| `logo` | `string` | Base64-encoded Data URI (`data:image/png;base64,...`) for instant rendering without CDN roundtrips. |
| `location` | `string` | Resolved country and municipality (e.g. `United Kingdom, London`). |
| `address` | `string` | Normalized street address of the merchant venue (e.g. `40-42 Great Portland St, Marylebone, London W1W 7LZ`). |

#### Example Enriched Response
```json
{
  "merchant": "Costa Coffee",
  "description": "Costa Coffee is a British coffeehouse chain and a subsidiary of The Coca-Cola Company.",
  "categories": [
    "Food & Beverage",
    "Cafes & Coffee Shops",
    "Dining Out"
  ],
  "logo": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
  "location": "United Kingdom, London",
  "address": "40-42 Great Portland St, Marylebone, London W1W 7LZ"
}
```

---

### 4.4 Canonical Production Fixtures

| Raw Input (`content`) | Country (`countryCode`) | Resolved Merchant | Primary Category | Geolocation |
| :--- | :--- | :--- | :--- | :--- |
| `COSTA PICKUP LONDON` | `GB` | **Costa Coffee** | Food & Beverage | London, United Kingdom |
| `STARBUCKS STORE #10423 SEATTLE WA` | `US` | **Starbucks** | Food & Beverage | Seattle, United States |
| `UBER *TRIP 12345 HELP.UBER.COM` | `GB` | **Uber** | Transportation | London, United Kingdom |
| `TfL Travel Charge tfl.gov.uk` | `GB` | **Transport for London** | Public Transportation | London, United Kingdom |

---

## 5. Rate Limits, Quotas & Backoff Strategies

### 5.1 Standard SME Quota Allocations
XYO enforces deterministic rate limits at the API Gateway level to ensure quality of service across multi-tenant clusters:

| Tier | Sustained RPS | Burst Allowance | Monthly Quota |
| :--- | :--- | :--- | :--- |
| **SME Starter** | 50 req/sec | 100 requests | 250,000 requests |
| **SME Growth** | 200 req/sec | 400 requests | 2,500,000 requests |
| **Fintech Scale** | 500 req/sec | 1,000 requests | 10,000,000 requests |

### 5.2 Rate Limit Headers
Every response includes standard rate limit tracking headers:

```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 200
X-RateLimit-Remaining: 184
X-RateLimit-Reset: 1770508800
```

When rate limits are exceeded, the server returns an **HTTP 429 (Too Many Requests)** status with a `Retry-After` header indicating seconds until requests will be accepted:

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 2
Content-Type: application/problem+json
```

### 5.3 Exponential Backoff with Jitter (Recommended Pattern)
To prevent the "thundering herd" problem, client applications must implement exponential backoff with full jitter when handling `429` or transient `503` responses.

#### TypeScript Full Jitter Implementation
```typescript
/**
 * Executes an operation with full jitter exponential backoff.
 */
async function executeWithRetry<T>(
  operation: () => Promise<T>,
  maxRetries = 4,
  baseDelayMs = 100,
  maxDelayMs = 2000
): Promise<T> {
  let attempt = 0;

  while (true) {
    try {
      return await operation();
    } catch (error: any) {
      attempt++;
      if (attempt > maxRetries || (error.status !== 429 && error.status < 500)) {
        throw error;
      }

      // Calculate exponential ceiling: base * 2^(attempt - 1)
      const ceiling = Math.min(maxDelayMs, baseDelayMs * Math.pow(2, attempt - 1));
      // Apply full random jitter: uniform(0, ceiling)
      const jitterDelay = Math.random() * ceiling;

      console.warn(`[XYO] HTTP ${error.status}. Retrying attempt ${attempt}/${maxRetries} in ${jitterDelay.toFixed(0)}ms...`);
      await new Promise((resolve) => setTimeout(resolve, jitterDelay));
    }
  }
}
```

---

## 6. RFC 7807 Problem Details & Error Handling

XYO strictly adheres to the **IETF RFC 7807 (Problem Details for HTTP APIs)** standard across all error responses (`application/problem+json`).

### 6.1 Schema Specification

An RFC 7807 error object comprises:

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `string` (URI) | A URI reference identifying the specific error classification. |
| `title` | `string` | A short, human-readable summary of the problem type. |
| `status` | `integer` | The HTTP status code generated by the origin server. |
| `detail` | `string` | A human-readable explanation specific to this occurrence of the problem. |
| `instance` | `string` (URI) | A URI reference identifying the specific request occurrence (useful for support correlation). |

### 6.2 Standard Error Catalog

| Status Code | RFC 7807 Type URI | Title | Typical Scenario |
| :--- | :--- | :--- | :--- |
| **`400 Bad Request`** | `https://api.xyo.financial/errors/bad-request` | `Bad Request` | Missing required `countryCode` or `content` length exceeds 128 characters. |
| **`401 Unauthorized`** | `https://api.xyo.financial/errors/unauthorized` | `Unauthorized` | Missing or invalid API key in `Authorization: Bearer <key>`. |
| **`403 Forbidden`** | `https://api.xyo.financial/errors/forbidden` | `Forbidden` | IP allowlist violation or tenant account suspended due to depleted credits. |
| **`404 Not Found`** | `https://api.xyo.financial/errors/not-found` | `Not Found` | Resource or batch job ID does not exist. |
| **`429 Too Many Requests`** | `https://api.xyo.financial/errors/rate-limit-exceeded` | `Rate Limit Exceeded` | Tenant quota exhausted. Client must back off. |
| **`500 Internal Server Error`** | `https://api.xyo.financial/errors/internal-server-error` | `Internal Server Error` | Transient server error during enrichment execution. |
| **`503 Service Unavailable`** | `https://api.xyo.financial/errors/service-unavailable` | `Service Unavailable` | Edge node scaling or maintenance window in progress. |

### 6.3 Example RFC 7807 Problem Details Payload

#### 400 Bad Request (Missing `countryCode`)
```json
{
  "errors": [
    {
      "type": "https://api.xyo.financial/errors/bad-request",
      "title": "Bad Request",
      "status": 400,
      "detail": "Request body is missing required field 'countryCode'.",
      "instance": "/v1/ai/finance/enrichment/transaction#req-a72f8832-1b19-482f-8501-9c87d461ba10"
    }
  ]
}
```

#### 401 Unauthorized (Invalid Bearer Token)
```json
{
  "errors": [
    {
      "type": "https://api.xyo.financial/errors/unauthorized",
      "title": "Unauthorized",
      "status": 401,
      "detail": "Invalid or expired Bearer authentication token provided.",
      "instance": "/v1/ai/finance/enrichment/transaction#req-9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d"
    }
  ]
}
```

---

## 7. Production Readiness Checklist for SMEs & Fintechs

Before deploying your XYO integration to live customer traffic, ensure your engineering team has verified the following operational criteria:

- [ ] **Secrets Management**: API keys are loaded via environment variables or secret vaults—never committed to git.
- [ ] **HTTP Connection Pooling**: Enabled TCP Keep-Alive and connection pooling in your HTTP client to eliminate TLS handshake overhead on every request (crucial for sub-15ms performance).
- [ ] **Timeout Budgeting**: Configured a strict timeout of `50ms - 100ms` for real-time payment authorization webhooks to prevent card network timeouts.
- [ ] **Circuit Breaker Fallback**: Implemented a graceful fallback that renders the raw un-enriched narrative to the customer in the unlikely event of an enrichment timeout.
- [ ] **Jittered Retries**: Ensured retry logic only fires on `429` and `5xx` status codes with randomized jitter. Never retry `400` or `401` errors.
- [ ] **Error Logging Correlation**: Capturing the `instance` URI from RFC 7807 problem details in your logging infrastructure (Datadog, Splunk, Elastic) for instant support escalations.

---

## 8. Support & SLA Escalations

* **Developer Portal & Documentation**: [https://api.xyo.financial](https://api.xyo.financial)
* **Technical Support & Onboarding**: `support@syniol.com`
* **Status Page**: [https://status.xyo.financial](https://status.xyo.financial)
* **API Specifications**: [OpenAPI 3.0.3 YAML](https://github.com/xyo-financial/specs/blob/main/openapi.yml)

---

### 🔐 License & Governance
Copyright &copy; 2026 <a href='https://syniol.com' target='_blank'>Syniol Limited</a>. All rights reserved.  
Distributed under the **BSD-3-Clause License**.
