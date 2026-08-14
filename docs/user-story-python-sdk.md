# Agile User Story: Python Client SDK (`sdk-python`)

**Story ID:** `US-SDK-001`  
**Epic:** `EPIC-001: Multi-Language SDK Ecosystem Expansion`  
**Status:** `Ready for Development`  
**Priority:** `P0 (Critical)`  
**Standard Compliance:** `INVEST Model & Gherkin BDD Acceptance Criteria`  

---

## 1. User Story Statement

> **As a** Data Engineer / Machine Learning Engineer / Fintech Python Developer,  
> **I want** an official, type-safe, and idiomatic Python SDK with both synchronous and asynchronous support,  
> **So that** I can enrich and categorize banking transaction narratives seamlessly within AI/ML pipelines, FastAPI/Django microservices, and high-throughput batch ETL jobs without writing boilerplate HTTP clients.

---

## 2. Business Value & Strategic Rationale

- **AI/ML & Risk Ingestion:** Enables data science, fraud detection, and AML/KYC teams to enrich real-time and historical payment streams directly in Jupyter, Pandas, PySpark, and Airflow pipelines.
- **Modern Fintech Backends:** Direct compatibility with modern asynchronous Python frameworks (FastAPI, Starlette, Tornado) via native `async`/`await`.
- **Ecosystem Parity:** Extends XYO's deterministic OpenAPI v3 architecture to the world's most popular data engineering and AI language.

---

## 3. Technical Requirements & Architecture

### 3.1 Two-Layer Architecture
1. **Low-Level Transport Layer (`xyo._generated` / `openapi_client`):**
   - Generated via `@openapitools/openapi-generator-cli` with generator target `python`.
   - Immutable machine-generated models and API stubs.
   - Linter configurations (`ruff`, `black`, `flake8`, `mypy`) must explicitly ignore the generated directory.
2. **High-Level Idiomatic Facade (`xyo`):**
   - Clean top-level entry point: `xyo.Client` (sync) and `xyo.AsyncClient` (async).
   - Pythonic parameter naming (`snake_case`), typed dataclasses/Pydantic models, and comprehensive PEP 484 type annotations.

### 3.2 Canonical API Operations
1. `enrich_transaction(request: EnrichmentRequest) -> EnrichmentResponse` (Sync & Async)
2. `enrich_transactions(requests: list[EnrichmentRequest]) -> EnrichTransactionCollectionResponse` (Sync & Async)
3. `get_enrichment_status(id: str) -> EnrichmentCollectionStatusResponse` (Sync & Async)
4. `download_enrichment_collection(download_url: str) -> list[EnrichmentResponse]` (Streaming `.tar.gz` in-memory decompression without disk I/O bottlenecks).

### 3.3 Reliability, Security & Errors
- **RFC 7807 Error Handling:** Typed custom exceptions (`xyo.exceptions.ErrorResponse`, `xyo.exceptions.APIError`) preserving HTTP status codes and detailed validation fields.
- **SSRF & Token Leakage Prevention:** Header sanitization ensuring Bearer tokens are never leaked to external S3/CDN presigned download URLs.
- **Licensing:** Distributed under the standard **Apache License, Version 2.0 (Apache-2.0)**.
- **Packaging:** Standard `pyproject.toml` supporting modern build backends (Poetry / Flit / Hatchling) for PyPI distribution (`pip install xyo-sdk`).

---

## 4. Acceptance Criteria (Gherkin BDD Format)

```gherkin
Feature: Python SDK for Payment Transaction Enrichment

  Background:
    Given the XYO Python SDK is installed in a Python 3.9+ environment
    And the developer initializes the client with a valid API key:
      """python
      from xyo import Client, AsyncClient
      client = Client(api_key="xyo_test_key_123")
      """

  Scenario: Real-Time Single Transaction Enrichment (Synchronous)
    Given a raw transaction narrative "SQ *COSTA COFFEE GREENWICH" with country code "GB"
    When the client invokes `client.enrich_transaction(content="SQ *COSTA COFFEE GREENWICH", country_code="GB")`
    Then the response must contain:
      | Field        | Expected Value |
      | name         | Costa Coffee   |
      | category     | Food & Dining  |
      | country_code | GB             |
    And the call must execute within sub-millisecond client parsing overhead

  Scenario: Asynchronous High-Throughput Bulk Enrichment (Async / FastAPI)
    Given an asynchronous client instance `async_client = AsyncClient(api_key="xyo_test_key_123")`
    And a batch of 500 transaction requests
    When the developer awaits `async_client.enrich_transactions(batch)`
    Then the API must return a batch job ID and download link
    And no thread blocking must occur on the event loop

  Scenario: Streaming Bulk Archive Download & In-Memory Decompression
    Given a completed bulk job with a valid download URL
    When the client invokes `client.download_enrichment_collection(download_url)`
    Then the SDK streams and decompresses the .tar.gz archive in memory
    And returns a typed list of `EnrichmentResponse` objects
    And no temporary files are written to disk

  Scenario: RFC 7807 Structured Error Handling
    Given an invalid enrichment request with missing mandatory fields
    When the API returns an HTTP 422 Problem Details payload
    Then the SDK must raise `xyo.exceptions.ErrorResponse`
    And the exception must expose typed access to `status_code`, `title`, `detail`, and `errors` list

  Scenario: Automated Spec Regeneration via GitHub Actions
    Given a `spec_tagged` dispatch event from `xyo-financial/specs`
    When `.github/workflows/generate.yml` executes on GitHub Actions
    Then the OpenAPI Python client is regenerated deterministically
    And noise files are stripped
    And unit tests and linter suites pass with zero manual code modifications
```

---

## 5. Definition of Done (DoD)

- [ ] **Codebase & Architecture:** Dual sync/async architecture implemented with 100% type hints (`py.typed` marker included).
- [ ] **Testing:** Comprehensive `pytest` suite achieving ≥ 90% code coverage including mock HTTP integration tests with `respx` / `responses`.
- [ ] **Linter Isolation:** `pyproject.toml` / `ruff` / `flake8` / `mypy` configured to strictly ignore auto-generated transport modules.
- [ ] **Quality Gates & Docker:** Containerized verification in `deploy/Dockerfile` and `Makefile` (`make check`, `make test`, `make lint`).
- [ ] **Automation:** `.github/workflows/generate.yml` configured for `repository_dispatch` from `xyo-financial/specs`.
- [ ] **Documentation:** Complete `README.md` (quickstart, async guide, badges), `CONTRIBUTING.md`, `SECURITY.md`, and Apache 2.0 `LICENSE`.
- [ ] **Distribution:** Package validated for publishing to PyPI (`pip install xyo-sdk`).
