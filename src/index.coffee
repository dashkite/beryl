import generator from "./html"
import $RefParser from "@apidevtools/json-schema-ref-parser"
import { isString, isArray, isObject, isNumber, isBoolean } from "@dashkite/joy/type"
import { clone } from "@dashkite/joy/value"

import FS from "fs/promises"

ref_keys = []

areType = ( typeChecker, array ) ->
  return false unless isArray array
  for item in array
    return false unless typeChecker item
  true


typeDecorator = ( iterable ) ->
  for key, value of iterable
    if key == "$ref"
      ref_keys.push value
    if isString value
      iterable[key] = { Ctype: "string", value }
    else if isNumber value
      iterable[key] = { Ctype: "number", value }
    else if isBoolean value
      iterable[key] = { Ctype: "boolean", value }
    else if isObject value
      iterable[key] = { Ctype: "object", value }
      typeDecorator iterable[key].value
    else if isArray value
      if areType isString, value || areType isNumber, value || areType isBoolean, value
        iterable[key] = { Ctype: "string", value: value.toString() }
      else
        iterable[key] = { Ctype: "array", value }
        typeDecorator iterable[key].value


html = ( schema ) ->
  refs = {}
  $schema = clone schema
  resolved = await $RefParser.resolve $schema, external: false
  
  # TODO The following will be a cleaner approach once onDereference 
  # is added to an upcoming release of $RefParser.
  # dereferenced = await $RefParser.dereference schema, 
  #   dereference: onDereference: ( key, value ) -> refs[key] = value
  #   resolve: external: false

  typeDecorator schema
  for key in ref_keys
    clean_key = key.slice 1
    refs[clean_key] = resolved.get key
  typeDecorator refs
  delete schema["$schema"]
  delete schema["$defs"]
  generator { schema, refs }

export { html }