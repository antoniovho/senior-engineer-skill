# Inheritance and Polymorphism (Discriminator)

Rules for modeling base entities with multiple subtypes using OpenAPI discriminators.

---

## When to Use a Discriminator

Use `discriminator` when:

- A schema represents a **base entity** with multiple subtypes.
- Each subtype has **different properties**.
- The subtype can be determined from a **specific field value**.

**Do NOT** use a discriminator if the schema variants differ only slightly or can be represented with optional fields.

---

## Base Schema Requirements

The base schema must:

- ✅ Define the discriminator property in `properties`
- ✅ Mark the discriminator property as `required`
- ✅ Define an `enum` with all allowed subtype values
- ✅ Define the `discriminator` object with `propertyName` and `mapping`

The base schema must NOT contain:

- ❌ `oneOf`
- ❌ `anyOf`
- ❌ Subtype-specific properties

### Base Schema Structure

```yaml
BaseEntity:
  required:
    - type
  type: object
  description: Base type with discriminator for subtypes.
  properties:
    type:
      type: string
      description: Identifies the subtype of the entity.
      enum:
        - VALUE_A
        - VALUE_B
      example: VALUE_A
  discriminator:
    propertyName: type
    mapping:
      VALUE_A: '#/components/schemas/SubtypeA'
      VALUE_B: '#/components/schemas/SubtypeB'
```

---

## Subtype Schema Requirements

Each subtype must:

- ✅ Use `allOf` composition
- ✅ Include the base schema via `$ref`
- ✅ Define only subtype-specific properties
- ✅ Include descriptions and examples for all properties
- ❌ NOT redefine the discriminator property differently

### Subtype Structure

```yaml
SubtypeA:
  type: object
  allOf:
    - $ref: '#/components/schemas/BaseEntity'
    - type: object
      properties:
        specificProperty:
          type: string
          description: Property specific to SubtypeA
          example: "some value"
```

---

## Complete Example

```yaml
components:
  schemas:
    # Base schema
    Vehicle:
      required:
        - vehicleType
      type: object
      description: Base vehicle schema with discriminator.
      properties:
        vehicleType:
          type: string
          enum: [CAR, MOTORCYCLE]
          example: CAR
      discriminator:
        propertyName: vehicleType
        mapping:
          CAR: '#/components/schemas/Car'
          MOTORCYCLE: '#/components/schemas/Motorcycle'

    # Subtype A
    Car:
      type: object
      allOf:
        - $ref: '#/components/schemas/Vehicle'
        - type: object
          properties:
            numberOfDoors:
              type: integer
              minimum: 2
              maximum: 5
              example: 4

    # Subtype B
    Motorcycle:
      type: object
      allOf:
        - $ref: '#/components/schemas/Vehicle'
        - type: object
          properties:
            hasSidecar:
              type: boolean
              example: false
```

---

## ❌ Common Mistakes

```yaml
# ❌ DO NOT put oneOf/anyOf in the base schema
Vehicle:
  oneOf:
    - $ref: '#/components/schemas/Car'
    - $ref: '#/components/schemas/Motorcycle'

# ❌ DO NOT redefine discriminator property in subtype
Car:
  allOf:
    - $ref: '#/components/schemas/Vehicle'
    - type: object
      properties:
        vehicleType:       # ❌ redefining discriminator property
          type: string
          enum: [CAR]
```
