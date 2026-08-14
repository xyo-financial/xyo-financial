# Agile User Story: .NET / C# Client SDK (`sdk-dotnet`)

**Story ID:** `US-SDK-002`  
**Epic:** `EPIC-001: Multi-Language SDK Ecosystem Expansion`  
**Status:** `Ready for Development`  
**Priority:** `P0 (Critical)`  
**Standard Compliance:** `INVEST Model & Gherkin BDD Acceptance Criteria`  

---

## 1. User Story Statement

> **As a** .NET / C# Backend Engineer in a Tier-1 Bank or Fintech Institution,  
> **I want** an official, strongly typed .NET Client SDK targeting .NET 8+ and .NET Standard 2.1 with full `async`/`await` and `IHttpClientFactory` dependency injection integration,  
> **So that** I can integrate XYO's AI transaction enrichment engine directly into enterprise core-banking pipelines, ASP.NET Core web APIs, and Azure-hosted payment ledgers with zero memory leaks and high throughput.

---

## 2. Business Value & Strategic Rationale

- **Tier-1 Enterprise Banking Ingestion:** Unlocks adoption across traditional retail banks, credit unions, and legacy payment processors running on Microsoft .NET / Azure stacks.
- **Core Banking Integration:** Enables seamless integration with major banking ledger solutions (FIS, Fiserv, Temenos, Finastra) that communicate via C# enterprise middleware.
- **Idiomatic .NET Ergonomics:** First-class support for modern .NET Dependency Injection (`IServiceCollection.AddXyoClient()`), cancellation tokens, `System.Text.Json` source generation, and memory-safe streaming decompression.

---

## 3. Technical Requirements & Architecture

### 3.1 Two-Layer Architecture
1. **Low-Level Generated Transport (`Xyo.Generated` / `Xyo.OpenApi`):**
   - Generated via `@openapitools/openapi-generator-cli` with generator target `csharp-netcore`.
   - Immutable machine-generated models and API client stubs.
   - `.editorconfig` and Roslyn analyzers configured to ignore generated directories.
2. **High-Level Idiomatic Facade (`Xyo.Sdk`):**
   - Top-level interface: `IXyoClient` implemented by `XyoClient`.
   - Strong typing, nullable reference types (`#nullable enable`), immutable record types for requests/responses, and `CancellationToken` on every async signature.

### 3.2 Canonical API Operations
1. `Task<EnrichmentResponse> EnrichTransactionAsync(EnrichmentRequest request, CancellationToken cancellationToken = default)`
2. `Task<EnrichTransactionCollectionResponse> EnrichTransactionsAsync(IEnumerable<EnrichmentRequest> requests, CancellationToken cancellationToken = default)`
3. `Task<EnrichmentCollectionStatusResponse> GetEnrichmentStatusAsync(string id, CancellationToken cancellationToken = default)`
4. `Task<IReadOnlyList<EnrichmentResponse>> DownloadEnrichmentCollectionAsync(string downloadUrl, CancellationToken cancellationToken = default)` (Streaming `GZipStream` and `TarReader` decompression without buffering entire file to memory).

### 3.3 Reliability, Security & DI Support
- **Dependency Injection:** `services.AddXyoClient(options => options.ApiKey = "...");` supporting pooled `SocketsHttpHandler` / `IHttpClientFactory` to prevent socket exhaustion.
- **RFC 7807 Error Handling:** Custom `XyoException` and `XyoProblemDetailsException` with typed access to RFC 7807 problem details properties.
- **SSRF & Token Leakage Prevention:** Outbound authorization handler verifies host integrity before attaching Bearer headers to avoid leaking credentials to external CDN endpoints.
- **Licensing:** Distributed under the standard **Apache License, Version 2.0 (Apache-2.0)**.
- **Packaging:** Standard `.csproj` configured for NuGet packaging (`Xyo.Sdk`).

---

## 4. Acceptance Criteria (Gherkin BDD Format)

```gherkin
Feature: .NET C# SDK for Payment Transaction Enrichment

  Background:
    Given the XYO .NET SDK is referenced in a .NET 8.0+ project
    And the service is registered via Dependency Injection:
      """csharp
      services.AddXyoClient(options => 
      {
          options.ApiKey = "xyo_test_key_123";
      });
      """

  Scenario: Real-Time Single Transaction Enrichment (Task-based Async)
    Given a raw transaction narrative "SQ *COSTA COFFEE GREENWICH" with country code "GB"
    When the service awaits `xyoClient.EnrichTransactionAsync(new EnrichmentRequest("SQ *COSTA COFFEE GREENWICH", "GB"))`
    Then the returned `EnrichmentResponse` must have:
      | Property    | Expected Value |
      | Name        | Costa Coffee   |
      | Category    | Food & Dining  |
      | CountryCode | GB             |
    And the call must observe cancellation if the caller `CancellationToken` is cancelled

  Scenario: High-Throughput Bulk Enrichment Batch Submission
    Given a collection of 1,000 transaction requests
    When the service calls `xyoClient.EnrichTransactionsAsync(transactions)`
    Then the response must contain a non-empty `Id` and `Link`
    And request validation must fail fast if any item in the collection is null

  Scenario: Memory-Safe Streaming Batch Download Decompression
    Given a completed bulk job download URL
    When `xyoClient.DownloadEnrichmentCollectionAsync(downloadUrl)` is executed
    Then the SDK must stream and decompress the .tar.gz archive using System.IO.Compression
    And yield a strongly-typed list of `EnrichmentResponse` items
    And memory allocation must remain sub-megabyte regardless of archive size

  Scenario: RFC 7807 Problem Details Error Propagation
    Given an API call that returns HTTP 400 Bad Request with an RFC 7807 payload
    When the request fails
    Then the SDK must throw `XyoProblemDetailsException`
    And the exception must contain structured `Title`, `Status`, `Detail`, and `Errors` dictionary

  Scenario: Automated Spec Regeneration via GitHub Actions
    Given a `spec_tagged` dispatch event from `xyo-financial/specs`
    When `.github/workflows/generate.yml` executes on GitHub Actions
    Then the C# OpenAPI models and stubs are regenerated deterministically
    And `dotnet test` and `dotnet format --verify-no-changes` pass with zero manual edits
```

---

## 5. Definition of Done (DoD)

- [ ] **Codebase & Architecture:** Solution structure with `Xyo.Sdk` (facade), `Xyo.Generated` (transport), and `Xyo.Sdk.Tests`.
- [ ] **Modern Language Features:** Built for .NET 8 / .NET Standard 2.1 with Nullable Reference Types enabled (`<Nullable>enable</Nullable>`).
- [ ] **Testing:** `xUnit` test suite with ≥ 90% code coverage, utilizing `MockHttp` / `HttpMessageHandler` for deterministic HTTP simulation.
- [ ] **DI & Resilience:** `Microsoft.Extensions.DependencyInjection` integration package / extension methods tested for `HttpClientFactory` lifecycle.
- [ ] **Quality Gates & Docker:** Containerized build in `deploy/Dockerfile` and `Makefile` (`dotnet test`, `dotnet build`).
- [ ] **Automation:** `.github/workflows/generate.yml` configured for `repository_dispatch` from `xyo-financial/specs`.
- [ ] **Documentation:** Complete `README.md` (Quickstart, DI configuration, async patterns), `CONTRIBUTING.md`, `SECURITY.md`, and Apache 2.0 `LICENSE`.
- [ ] **NuGet Distribution:** Validated `.nupkg` package generation with symbol packages (`.snupkg`) and SourceLink support.
