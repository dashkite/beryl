# Implementation Details

This document explains the key implementation choices, structural layouts, and logic blocks that drive Beryl.

## Codebase Modules

Beryl's helper logic is divided into four main source files:

- `src/schema.coffee`: The primary entry point. Manages the parsing, dereferencing, and coordinates the hoisting, view-model compilation, and templating.
- `src/helpers/hoist.coffee`: Recursively scans the schema to hoist nested subschemas and resolve naming conflicts.
- `src/helpers/prose.coffee`: Compiles the intermediate view-model sections, table rows, and cross-references.
- `src/helpers/format.coffee`: Formats constraints, types, required keys, and reference links into HTML or Markdown fragments.

---

## Detailed Component Walkthrough

### 1. Hoisting Traversal (`hoist.coffee`)
The `Hoister` class encapsulates the hoisting execution state:
- `@schema`: The mutable root schema object where `$defs` are registered.
- `@definitionsToTitle`: A mapping tracking the mapping of definition keys to original schema descriptors.

The `traverse` method walks the following object structures:
- `properties` and `patternProperties`
- `items` (supporting both single-object items and tuple item arrays)
- Combinators (`anyOf`, `allOf`, `oneOf`)

When a nested subschema is eligible for hoisting (verified by the `check` helper), Beryl registers it in `@schema.$defs` and returns a `{ hoistedName, refObj }` structure. The traversal loop updates the original container with `refObj` and continues traversing the original schema node.

### 2. Naming Collision Resolution
At the end of traversal, `assignTitles` performs a frequency analysis on the base names of all hoisted schemas:
- Unique titles are left as-is (e.g., `Domain`).
- Colliding titles (e.g., `resolvers` defined in both `Grant` and `RuneDescription`) are renamed to append parenthetical context: `Resolvers (Grant)` and `Resolvers (Rune Description)`.

### 3. Property Formatting (`format.coffee`)
Instead of using complex generic dispatch patterns, property formatting delegates to specialized helper functions:
- `formatString`: Handles `type` strings, `pattern` expressions, `required` fields (generating anchor links), and `$ref` pointers.
- `formatObject` and `formatArray`: Format nested schemas and combinator blocks recursively.
- `Format.identifier`: Builds valid URL slugs/anchor IDs by composing `@dashkite/joy/text`'s `dash` and `replace` helpers. Multiple hyphens caused by stripped punctuation are collapsed to keep identifiers clean.

---

## Structural Implementation Decisions

### switch/case vs. Generic Dispatch
We originally refactored `format.coffee` to use `@dashkite/generic` for polymorphic property formatting. However, we chose to replace it with a clean, helper-delegated `switch/case` statement for the following reasons:
- **No LIFO Fragility**: Generic rules match in LIFO order (last defined takes precedence). This made the order of definitions extremely fragile and prone to subtle bugs. A native `switch` block is top-to-bottom readable.
- **Lower Overhead**: The switch block eliminated the need for external package dependencies and syntax wrappers, reducing source code length by ~35 lines.

### Pre-calculated Subschemas in CoffeeScript
Pug templates are kept simple by doing all logic slicing inside CoffeeScript. Rather than performing array slicing inside the rendering templates, Beryl pre-calculates the subschemas range in `schema.coffee`:

```coffeescript
sections = ( Prose.build @schema, @references )
subschemas = sections[ 1.. ]
```

This ensures templates remain purely presentational.
