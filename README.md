# Beryl

*A JSON schema documentation generator.*

```coffeescript
import Beryl from "@dashkite/beryl"
import schema from "./schema"

do ->
  # Generate HTML documentation
  html = await Beryl.html schema

  # Generate Markdown documentation
  markdown = await Beryl.markdown schema
```

