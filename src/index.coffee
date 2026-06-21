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
  if refSchema?.title?.value?
    refSchema.title.value
  else
    parts = key.split "/"
    lastName = parts[parts.length - 1]
    titleCase uncase lastName

formatTypeDirect = ( typeVal ) ->
  if !typeVal
    "Object"
  else
    types = typeVal.split ", "
    capitalized = ( titleCase t for t in types )
    if capitalized.length == 1
      capitalized[0]
    else if capitalized.length == 2
      capitalized.join " or "
    else
      last = capitalized.pop()
      "#{capitalized.join ", "}, or #{last}"

formatType = ( propSchema, refSchema ) ->
  type = propSchema.type?.value || refSchema?.type?.value
  formatTypeDirect type

getPropertyLabel = ( name ) ->
  switch name
    when "type" then "Type"
    when "required" then "Required Properties"
    when "additionalProperties" then "Additional Properties"
    when "minProperties" then "Min Properties"
    when "maxProperties" then "Max Properties"
    when "pattern" then "Pattern"
    when "patternProperties" then "Pattern Properties"
    when "anyOf" then "Any Of"
    when "allOf" then "All Of"
    when "oneOf" then "One Of"
    when "$ref" then "Reference"
    else titleCase uncase name

formatSubschema = ( obj, refs ) ->
  keys = ( k for k, v of obj when k not in [
    "title", "description", "properties", "patternProperties"
  ] )
  if keys.length == 1 && keys[0] == "$ref"
    return formatPropertyVal "$ref", obj.$ref, refs
    
  parts = []
  for key in keys
    formattedVal = formatPropertyVal key, obj[key], refs
    if formattedVal
      parts.push "#{getPropertyLabel key}: #{formattedVal}"
  parts.join "; "

formatCombinator = ( name, arrayVal, refs ) ->
  prefix = switch name
    when "anyOf" then "Must match at least one of:"
    when "allOf" then "Must match all of:"
    when "oneOf" then "Must match exactly one of:"
    else "Must match:"
    
  options = []
  for item in arrayVal
    options.push formatSubschema item.value, refs
  
  result = prefix
  for opt in options
    result += "<br>• #{opt}"
  result

formatPropertyVal = ( name, property, refs ) ->
  if !property?
    return ""
    
  if property.Ctype == "string"
    if name == "type"
      formatTypeDirect property.value
    else if name == "pattern"
      "<code>#{property.value}</code>"
    else if name == "$ref" or property.value.startsWith? "#"
      refVal = property.value
      refObj = refs[refVal.slice 1]
      rSchema = refObj?.value
      "<a href=\"#{refVal}\">#{getHeadingName refVal, rSchema}</a>"
    else
      property.value
      
  else if property.Ctype == "number" or property.Ctype == "boolean"
    String property.value
    
  else if property.Ctype == "object"
    if property.value.$ref
      refVal = property.value.$ref.value
      refObj = refs[refVal.slice 1]
      rSchema = refObj?.value
      "<a href=\"#{refVal}\">#{getHeadingName refVal, rSchema}</a>"
    else
      formatSubschema property.value, refs
      
  else if property.Ctype == "array"
    if name in [ "anyOf", "allOf", "oneOf" ]
      formatCombinator name, property.value, refs
    else
      options = []
      for item in property.value
        if item.Ctype == "object"
          if item.value.$ref
            refVal = item.value.$ref.value
            refObj = refs[refVal.slice 1]
            rSchema = refObj?.value
            options.push "<a href=\"#{refVal}\">#{
              getHeadingName refVal, rSchema
            }</a>"
          else
            options.push formatSubschema item.value, refs
        else if item.Ctype == "string"
          options.push item.value
        else
          options.push String item.value
      options.join ", "
  else
    ""

hoistNested = ( schema ) ->
  schema.$defs = schema.$defs || {}
  
  traverse = ( name, obj ) ->
    if isObject obj
      if obj.properties?
        for propName, prop of obj.properties
          if isObject prop
            if prop.properties? || prop.patternProperties?
              hoistedName = ( titleCase name ) + ( titleCase propName )
              schema.$defs[hoistedName] = prop
              if !prop.title?
                prop.title = titleCase uncase hoistedName
              
              refObj = { $ref: "#/$defs/#{hoistedName}" }
              if prop.description?
                refObj.description = prop.description
              obj.properties[propName] = refObj
              
              traverse hoistedName, prop
            else
              traverse propName, prop
      
      if obj.$defs?
        for defName, def of obj.$defs
          traverse defName, def
      if obj.items?
        traverse "#{name}Items", obj.items
      if obj.anyOf?
        for item, index in obj.anyOf
          traverse "#{name}Option#{index}", item
      if obj.patternProperties?
        for pattern, patternSchema of obj.patternProperties
          traverse "#{name}Pattern", patternSchema

  rootName = if schema.title? then ( titleCase uncase schema.title ) else "Root"
  rootName = rootName.replace /\s+/g, ""
  traverse rootName, schema

class Schema

  constructor: ( @source ) ->
    @refKeys = []

  decode: ->
    @refKeys = []
    @schema = clone @source
    hoistNested @schema
    
    resolvedSchema = clone @source
    hoistNested resolvedSchema
    
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
    fullHtml {
      @schema
      @refs
      options
      getHeadingName
      formatType
      getPropertyLabel
      formatCombinator
      formatPropertyVal
    }

  resolve: ( options = { tabular: true } ) ->
    await @decode()
    resolveHtml {
      @schema
      @refs
      options
      getHeadingName
      formatType
      getPropertyLabel
      formatCombinator
      formatPropertyVal
    }

  markdown: ( options = {} ) ->
    opts = Object.assign { tabular: false }, options
    htmlContent = await @html opts
    turndown = new TurndownService emDelimiter: "_"
    turndown.remove [ "title", "nav" ]
    turndown.addRule 'table',
      filter: 'table'
      replacement: ( content, node ) ->
        rows = Array.from node.querySelectorAll 'tr'
        mdRows = []
        for row in rows
          cells = Array.from row.querySelectorAll 'th, td'
          mdCells = []
          for cell in cells
            html = cell.innerHTML.replace /<br\s*\/?>/gi, '^^BR^^'
            text = turndown.turndown( html ).trim()
            text = text.replace /\^\^BR\^\^/g, '<br>'
            text = text.replace /\|/g, '\\|'
            text = text.replace /\r?\n/g, ' '
            mdCells.push text
          mdRows.push "| " + mdCells.join( " | " ) + " |"
        if mdRows.length > 0
          headerRow = mdRows[0]
          cellsCount = Array.from( rows[0].querySelectorAll 'th, td' ).length
          separatorCells = ( "---" for i in [1..cellsCount] )
          separatorRow = "| " + separatorCells.join( " | " ) + " |"
          mdRows.splice 1, 0, separatorRow
        "\n\n" + mdRows.join( "\n" ) + "\n\n"
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