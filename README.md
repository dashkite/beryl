# Beryl

Beryl is a schema documentation generator that transforms complex JSON Schema files into clean, readable Markdown and HTML documentation.

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

## Purpose

Understanding complex nested JSON Schema trees can be challenging for developers. Beryl addresses this by:
- Automatically hoisting deeply nested inline objects to a global definitions section to keep document layouts flat and readable.
- Automatically parsing and resolving naming collisions dynamically with parenthetical names (e.g., `Resolvers (Grant)`).
- Generating both narrative prose documents and tabular reference layouts.

## Installation

Install Beryl using your favorite package manager:

```bash
pnpm add @dashkite/beryl
```

## Usage

You can use Beryl to generate HTML or Markdown documentation directly from your CoffeeScript code:

```coffeescript
import Beryl from "@dashkite/beryl"
import schema from "./schema"

do ->
  # Generate tabular HTML documentation (default layout)
  html = await Beryl.html schema

  # Generate markdown narrative documentation
  markdown = await Beryl.markdown schema, tabular: false
```

## Other Resources

- [Reference Guide](docs/reference.md)
- [Design Overview](docs/design.md)
- [Implementation Details](docs/implementation.md)

## Status

Beryl is currently in active development and not suitable for general production usage. 

If you encounter bugs or want to suggest improvements, please file an issue in our [GitHub Issue Tracker](https://github.com/dashkite/joy/issues).
