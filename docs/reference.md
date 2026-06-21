# Reference

This document describes the public interface of the Beryl module.

## Functions

### html

`$html: schema, options \dashrightarrow html\_content$`

Generates complete HTML document reference representing the given schema.

Options:
- `tabular`: boolean (default: `true`). If `true`, formats using tabular lists. If `false`, formats using narrative prose blocks.

```coffeescript
html = await Beryl.html schema, tabular: false
```

### resolve

`$resolve: schema, options \dashrightarrow resolved\_fragment$`

Generates a standalone resolved HTML fragment representing the given schema, suitable for embedding.

Options:
- `tabular`: boolean (default: `true`).

```coffeescript
fragment = await Beryl.resolve schema
```

### markdown

`$markdown: schema, options \dashrightarrow markdown\_content$`

Generates a Markdown document reference representing the given schema.

Options:
- `tabular`: boolean (default: `false`).

```coffeescript
markdown = await Beryl.markdown schema
```

## Schema Class

Represents a schema parser and formatter instance.

### constructor

`$\text{new Schema}: source \to schema\_instance$`

Creates a new Schema representation instance.

```coffeescript
schema = new Schema source
```

### decode

`$decode: \dashrightarrow \emptyset$`

Dereferences and hoists the schema definitions.

```coffeescript
await schema.decode()
```

### html

`$html: options \dashrightarrow html\_content$`

Generates a complete HTML reference.

```coffeescript
html = await schema.html tabular: true
```

### resolve

`$resolve: options \dashrightarrow resolved\_fragment$`

Generates a resolved HTML fragment.

```coffeescript
fragment = await schema.resolve()
```

### markdown

`$markdown: options \dashrightarrow markdown\_content$`

Generates a Markdown reference.

```coffeescript
markdown = await schema.markdown()
```
