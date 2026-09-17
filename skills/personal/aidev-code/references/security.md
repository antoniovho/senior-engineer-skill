# Security Practices

This file establishes universal security principles for all code produced. These principles apply regardless of technology stack.

**MCP discovery**: stack-specific security libraries, middleware, and configuration patterns must be discovered at runtime by querying available MCP documentation tools for the detected stack. Search for the stack's authentication, authorization, input validation, and security header configurations using MCP before implementing any security-sensitive code.

## Input Validation

- **Validate all input at trust boundaries** — every value that crosses a trust boundary (user input, API parameters, file uploads, query strings, headers, message payloads) must be validated before processing.
- **Allowlist over blocklist** — validate against a known set of permitted values/patterns rather than trying to reject known-bad input. Blocklists are always incomplete.
- **Validate type, length, range, and format** — enforce expected data types, maximum lengths, numeric ranges, and format patterns at the entry point.
- **Reject invalid input early** — fail fast with clear error messages that do not leak internal implementation details.
- **Sanitize for the target context** — when input must be embedded in HTML, SQL, shell commands, or other interpreted contexts, apply context-appropriate encoding/escaping.
- **Never trust client-side validation alone** — all validation must be enforced server-side regardless of what the client does.

## Injection Prevention

**General principle**: never construct interpreted strings by concatenating untrusted input. Always use the parameterized/prepared mechanisms provided by the platform.

- **Database query injection** — use parameterized queries or prepared statements. Never build query strings by interpolating user input directly. Use the ORM or query builder provided by the framework when available.
- **Cross-site scripting (XSS)** — encode all untrusted data before rendering it in HTML, JavaScript, CSS, or URL contexts. Use the framework's built-in template escaping. Set appropriate response headers to instruct browsers to enforce content security policies.
- **Command injection** — avoid executing shell commands with user-supplied input. When shell execution is unavoidable, use parameterized command execution (array-form APIs, not string interpolation). Never pass user input directly to system shell interpreters.
- **Path traversal** — validate and canonicalize file paths. Reject input containing directory traversal sequences. Restrict file operations to expected directories.
- **Deserialization attacks** — avoid deserializing untrusted data with generic deserialization mechanisms. Use schema-validated, type-safe parsing formats.
- **Log injection** — sanitize data before writing to logs. Ensure log entries cannot be forged or used to inject false audit records.

## Authentication and Authorization

- **Use the corporate-standard authentication mechanism** — every service must authenticate users and service-to-service calls using the organization's designated authentication system. Discover the specific mechanism for your stack via MCP documentation tools.
- **Never implement custom authentication** — do not build login flows, token generation, or session management from scratch. Use the framework-provided authentication integration.
- **Never use deprecated authentication mechanisms** — if the organization has deprecated an authentication method, do not use it in new code regardless of whether it still functions.
- **Apply least privilege** — grant the minimum permissions necessary for the operation. Request only the scopes/roles required. Verify authorization on every request, not just at the entry point.
- **Authorize at the resource level** — check that the authenticated identity has permission to access the specific resource being requested, not just that they are authenticated.
- **Separate authentication from authorization** — authentication confirms identity; authorization determines what that identity is allowed to do. Both must be enforced.
- **Protect authentication tokens** — tokens, session identifiers, and credentials must be transmitted over encrypted channels, stored securely, and rotated/expired according to policy.

## Secrets Handling

- **Never hardcode secrets** — no credentials, API keys, tokens, passwords, or connection strings in source code, configuration files committed to version control, or log output.
- **Use configuration management** — secrets must be injected at runtime via the environment, a secrets manager, or a vault service. Discover the stack-specific mechanism via MCP.
- **No secrets in version control** — if a secret is accidentally committed, treat it as compromised: rotate immediately, then remove from history.
- **Audit secret access** — log when secrets are accessed (but never log the secret values themselves).
- **Minimize secret scope** — each service/component should have access only to the secrets it needs.
- **Rotate secrets regularly** — secrets should have defined lifetimes and be rotated according to corporate policy.

## Security Response Headers and Transport

- **Use encrypted transport** — all service communication must use encrypted channels. Never allow unencrypted transport for sensitive data.
- **Set security response headers** — use the framework's security header middleware to set content security policies, frame protection, content type enforcement, and strict transport policies. Discover the specific header configuration for your stack via MCP.
- **Disable unnecessary information exposure** — suppress server version headers, stack traces in production error responses, and debug endpoints in non-development environments.
