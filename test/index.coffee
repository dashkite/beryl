import FS from "fs/promises"
import { test as _test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"

import { html, markdown } from "../src"
import schema from "./schema"

test = ( description, content ) ->
  _test {  description }, content

do ({ response } = {}) ->
  print await test "@dashkite/beryl", [

    await test "html", ->
      FS.writeFile "./test/output.html", await html schema

    await test "markdown", ->
      FS.writeFile "./test/output.md", await markdown schema
  ]