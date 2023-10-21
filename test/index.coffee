import FS from "fs/promises"
import { test as _test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"

import { html } from "../src"
import schema from "./schema"

test = ( description, content ) ->
  _test { wait: false, description }, content

do ({ response } = {}) ->
  print await test "@dashkite/beryl", [

    await test "html", ->
      console.log await html schema
      FS.writeFile "./test/output.html", await html schema
  ]