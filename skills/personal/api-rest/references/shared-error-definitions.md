# Shared Error Definitions

Rules for using JFrog shared error definitions (`errors.yml`) for consistent, standards-compliant error responses across all APIs.

---

## Core Rule

`ALWAYS` use JFrog shared error definitions for all `4xx` and `5xx` error responses. Do NOT define custom inline error schemas.

**Base URL**:
```
https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml
```

---

## Available Shared Error Definitions

| Schema Ref | HTTP Code | Use When |
|---|---|---|
| `#/BadRequest400` | 400 | Invalid request format or data |
| `#/Unauthorized401` | 401 | Authentication issues |
| `#/Forbidden403` | 403 | Authorization issues |
| `#/NotFound404` | 404 | Resource not found |
| `#/Conflict409` | 409 | Conflicts (e.g., deletion blocked by dependencies) |
| `#/InternalServerError500` | 500 | General system errors |
| `#/ServiceUnavailable503` | 503 | Server unavailability |
| `#/GatewayTimeout504` | 504 | Timeout errors |
| `#/UnexpectedStatusCode` | — | General unexpected status codes |

---

## Defining Shared Responses in `components`

Define all error responses once in `components.responses`, then reference them with `$ref`:

```yaml
components:
  responses:
    BadRequest:
      description: Bad Request
      content:
        application/json:
          schema:
            $ref: "https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml#/BadRequest400"

    Unauthorized:
      description: Unauthorized
      content:
        application/json:
          schema:
            $ref: "https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml#/Unauthorized401"

    Forbidden:
      description: Forbidden
      content:
        application/json:
          schema:
            $ref: "https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml#/Forbidden403"

    NotFound:
      description: Not Found
      content:
        application/json:
          schema:
            $ref: "https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml#/NotFound404"

    Conflict:
      description: Conflict
      content:
        application/json:
          schema:
            $ref: "https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml#/Conflict409"

    InternalServerError:
      description: Internal Server Error
      content:
        application/json:
          schema:
            $ref: "https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml#/InternalServerError500"
```

---

## Using Shared Responses in Paths

Reference `components.responses` entries in paths:

✅ **Good**:
```yaml
paths:
  /books/{bookId}:
    get:
      responses:
        '200':
          description: Successfully retrieved book
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Book'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
```

---

## Inline Reference (Alternative)

If not using `components.responses`, reference JFrog directly in `content`:

```yaml
responses:
  '400':
    description: Bad Request
    content:
      application/json:
        schema:
          $ref: "https://inditex.jfrog.io/artifactory/apischemas-public/apidsg/rest/default-error-utils/0.1.1/schemas/errors.yml#/BadRequest400"
```

---

## Error Response Format Requirements

All `4xx` and `5xx` responses must:
- Use `Content-Type: application/problem+json`
- Include at minimum: `status`, `title`, `detail`

Standard error fields:

| Field | Type | Description |
|---|---|---|
| `type` | string | URI identifying the problem type |
| `status` | integer | HTTP status code |
| `title` | string | Short, human-readable summary |
| `detail` | string | Human-readable explanation for this occurrence |
| `timestamp` | string | ISO 8601 timestamp of the error |

---

## 📝 Validation Prompts

> "Ensure that all error responses use the appropriate globally defined models corresponding to each use case."
> "Have all error responses been reviewed to ensure they use the appropriate globally defined models for each use case?"
