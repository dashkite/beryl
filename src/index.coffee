import $RefParser from "@apidevtools/json-schema-ref-parser"
import { isString, isArray, isObject, isNumber, isBoolean } from "@dashkite/joy/type"
import { clone } from "@dashkite/joy/value"
import { uncase, titleCase } from "@dashkite/joy/text"
import FS from "fs/promises"
import TurndownService from "turndown"

import fullHtml from "./html"
import resolveHtml from "./templates/resolve"

areType = ( typeChecker, array ) ->
  ( isArray array ) && ( array.every typeChecker )

getHeadingName = ( key, refSchema ) ->
  if refSchema.title?.value?
    refSchema.title.value
  else
    parts = key.split "/"
    lastName = parts[parts.length - 1]
    titleCase uncase lastName

class Schema

  constructor: ( @source ) ->
    @refKeys = []

  decode: ->
    @refKeys = []
    @schema = clone @source
    resolvedSchema = clone @source
    resolved = await $RefParser.resolve resolvedSchema, external: false
    @decorator @schema
    @refs = {}
    for key in @refKeys
      cleanKey = key.slice 1
      @refs[cleanKey] = resolved.get key
    @decorator @refs
    delete @schema["$schema"]
    delete @schema["$defs"]

  decorator: ( iterable ) ->
    for key, value of iterable
      if key == "$ref"
        @refKeys.push value
      if isString value
        iterable[key] = { Ctype: "string", value }
      else if isNumber value
        iterable[key] = { Ctype: "number", value }
      else if isBoolean value
        iterable[key] = { Ctype: "boolean", value }
      else if isObject value
        iterable[key] = { Ctype: "object", value }
        @decorator iterable[key].value
      else if isArray value
        if ( areType isString, value ) || ( areType isNumber, value ) || ( areType isBoolean, value )
          iterable[key] = { Ctype: "string", value: value.join ", " }
        else
          iterable[key] = { Ctype: "array", value }
          @decorator iterable[key].value

  html: ( options = { tabular: true } ) ->
    await @decode()
    fullHtml { @schema, @refs, options, getHeadingName }

  resolve: ( options = { tabular: true } ) ->
    await @decode()
    resolveHtml { @schema, @refs, options, getHeadingName }

  markdown: ( options = {} ) ->
    opts = Object.assign { tabular: false }, options
    htmlContent = await @html opts
    turndown = new TurndownService
    turndown.remove [ "title", "nav" ]
    turndown.turndown htmlContent

html = ( schema, options ) ->
  instance = new Schema schema
  instance.html options

resolve = ( schema, options ) ->
  instance = new Schema schema
  instance.resolve options

markdown = ( schema, options ) ->
  instance = new Schema schema
  instance.markdown options

export { Schema, html, resolve, markdown }