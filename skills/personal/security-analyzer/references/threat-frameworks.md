# Threat Frameworks Reference

This file contains the frameworks used by the inditex-security-analyzer skill. It is read when building threat models and security audits.

---

## STRIDE-LM (Microsoft + Extended)

STRIDE-LM is the primary threat categorization framework. Apply it per component and per trust boundary.

| Letter | Threat | Property Violated | Key Question |
|---|---|---|---|
| **S** | Spoofing | Authentication | Can an attacker pretend to be someone/something else? |
| **T** | Tampering | Integrity | Can data or code be modified without detection? |
| **R** | Repudiation | Non-repudiation | Can a user deny having performed an action? |
| **I** | Information Disclosure | Confidentiality | Can sensitive data be read by unauthorized parties? |
| **D** | Denial of Service | Availability | Can the system be made unavailable? |
| **E** | Elevation of Privilege | Authorization | Can an attacker gain more access than intended? |
| **L** | Lateral Movement | Containment | If one component is compromised, what else is reachable? |

### Applying STRIDE in Practice

For each component or trust boundary crossing:
1. Ask each STRIDE-LM question
2. Identify if a threat exists
3. Rate likelihood (HIGH/MEDIUM/LOW) based on exploitability and attacker motivation
4. Rate impact (HIGH/MEDIUM/LOW) based on what's at stake
5. Define a mitigation control

---

## OWASP Top 10 (Web Applications — 2021)

| ID | Category | Key Concern |
|---|---|---|
| A01 | Broken Access Control | IDOR, privilege escalation, missing auth checks |
| A02 | Cryptographic Failures | Weak/missing encryption, sensitive data exposure |
| A03 | Injection | SQL, NoSQL, OS, LDAP, SSTI injection |
| A04 | Insecure Design | Missing security controls at design level |
| A05 | Security Misconfiguration | Default creds, open cloud storage, verbose errors |
| A06 | Vulnerable & Outdated Components | Dependencies with known CVEs |
| A07 | Identification & Authentication Failures | Broken session, weak passwords, missing MFA |
| A08 | Software & Data Integrity Failures | Insecure deserialization, CI/CD poisoning |
| A09 | Security Logging & Monitoring Failures | Missing audit logs, no alerting |
| A10 | SSRF | Server-Side Request Forgery |

---

## OWASP API Security Top 10 (2023)

| ID | Category | Key Concern |
|---|---|---|
| API1 | Broken Object Level Authorization | Access other users' objects via ID manipulation |
| API2 | Broken Authentication | Missing/weak token validation, credential stuffing |
| API3 | Broken Object Property Level Auth | Mass assignment, over-exposed properties |
| API4 | Unrestricted Resource Consumption | Missing rate limits on expensive operations |
| API5 | Broken Function Level Authorization | Admin endpoints accessible to regular users |
| API6 | Unrestricted Access to Sensitive Business Flows | Abuse of business logic (cart manipulation, etc.) |
| API7 | Server-Side Request Forgery | Via URL parameters in API calls |
| API8 | Security Misconfiguration | Permissive CORS, verbose stack traces |
| API9 | Improper Inventory Management | Undocumented/deprecated endpoints still active |
| API10 | Unsafe Consumption of APIs | Trusting third-party API responses without validation |

---

## OWASP LLM Top 10 (For AI/LLM-integrated apps — 2025)

Use this when the project integrates LLMs, AI models, or AI-powered APIs.

| ID | Category | Key Concern |
|---|---|---|
| LLM01 | Prompt Injection | Direct/indirect injection via user input or external data |
| LLM02 | Sensitive Information Disclosure | Model leaking training data, system prompts, PII |
| LLM03 | Supply Chain | Poisoned models, malicious plugins/extensions |
| LLM04 | Data and Model Poisoning | Training data manipulation |
| LLM05 | Improper Output Handling | Unsanitized LLM output fed to downstream systems |
| LLM06 | Excessive Agency | LLM with too many permissions, acting autonomously |
| LLM07 | System Prompt Leakage | Confidential system prompt exposed |
| LLM08 | Vector & Embedding Weaknesses | RAG data poisoning, embedding manipulation |
| LLM09 | Misinformation | Hallucinations leading to security decisions |
| LLM10 | Unbounded Consumption | DoS via resource-intensive LLM calls |

---

## CWE — Key Categories for Code Review

### Injection
- CWE-89: SQL Injection
- CWE-78: OS Command Injection
- CWE-79: XSS
- CWE-94: Code Injection
- CWE-917: Expression Language Injection
- CWE-611: XXE (XML External Entities)
- CWE-918: SSRF

### Authentication & Session
- CWE-287: Improper Authentication
- CWE-306: Missing Authentication for Critical Function
- CWE-384: Session Fixation
- CWE-613: Insufficient Session Expiration
- CWE-798: Use of Hard-coded Credentials
- CWE-522: Insufficiently Protected Credentials

### Authorization
- CWE-284: Improper Access Control
- CWE-285: Improper Authorization
- CWE-639: Authorization Bypass Through User-Controlled Key (IDOR)
- CWE-269: Improper Privilege Management

### Cryptography
- CWE-326: Inadequate Encryption Strength
- CWE-327: Use of Broken/Risky Cryptographic Algorithm
- CWE-330: Use of Insufficiently Random Values
- CWE-338: Use of Cryptographically Weak PRNG
- CWE-321: Use of Hard-coded Cryptographic Key
- CWE-311: Missing Encryption of Sensitive Data

### Memory & Logic
- CWE-787: Out-of-bounds Write
- CWE-125: Out-of-bounds Read
- CWE-416: Use After Free
- CWE-362: Race Condition (TOCTOU is CWE-367)
- CWE-502: Deserialization of Untrusted Data

### Data Exposure
- CWE-200: Information Exposure
- CWE-532: Insertion of Sensitive Information into Log File
- CWE-209: Generation of Error Message Containing Sensitive Information

---

## LINDDUN (Privacy Threat Model)

Use when the project processes personal data, health info, financial data, or operates under GDPR/CCPA.

| Letter | Threat | Description |
|---|---|---|
| **L** | Linkability | Linking data items about the same subject across contexts |
| **I** | Identifiability | Deriving an identity from pseudonymous data |
| **N** | Non-repudiation | User cannot deny actions — privacy violation |
| **D** | Detectability | Detecting that data about a subject exists |
| **D** | Disclosure | Exposing personal data to unauthorized parties |
| **U** | Unawareness | User unaware of data collection/processing |
| **N** | Non-compliance | Violations of privacy laws/regulations |

---

## Risk Rating Matrix

| Likelihood ↓ / Impact → | LOW | MEDIUM | HIGH |
|---|---|---|---|
| **HIGH** | MEDIUM | HIGH | CRITICAL |
| **MEDIUM** | LOW | MEDIUM | HIGH |
| **LOW** | INFO | LOW | MEDIUM |

**Likelihood factors**: ease of exploitation, attacker skill required, authentication required, network access needed
**Impact factors**: data sensitivity, number of users affected, business impact, reversibility
