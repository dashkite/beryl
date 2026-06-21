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

slugify = ( text ) ->
  text.toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')

getHeadingName = ( key, refSchema ) ->
  if refSchema?.title?.value?
    refSchema.title.value
  else
    parts = key.split "/"
    lastName = parts[parts.length - 1]
    titleCase uncase lastName

getRefLink = ( refVal, refs ) ->
  refObj = refs[refVal.slice 1]
  rSchema = refObj?.value
  headingName = getHeadingName refVal, rSchema
  slug = slugify headingName
  "<a href=\"##{slug}\">#{headingName}</a>"

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
  conjunction = if name == "allOf" then "and" else "or"
  options = []
  for item in arrayVal
    options.push formatSubschema item.value, refs
  if options.length == 1
    options[0]
  else if options.length == 2
    options.join " #{conjunction} "
  else
    last = options.pop()
    "#{options.join ", "}, #{conjunction} #{last}"

formatPropertyVal = ( name, property, refs ) ->
  if !property?
    return ""
    
  if property.Ctype == "string"
    if name == "type"
      formatTypeDirect property.value
    else if name == "pattern"
      "<code>#{property.value}</code>"
    else if name == "required"
      propNames = property.value.split ", "
      links = []
      for p in propNames
        title = titleCase uncase p
        slug = slugify title
        links.push "<a href=\"##{slug}\">#{title}</a>"
      links.join ", "
    else if name == "$ref" or property.value.startsWith? "#"
      getRefLink property.value, refs
    else
      property.value
      
  else if property.Ctype == "number" or property.Ctype == "boolean"
    String property.value
    
  else if property.Ctype == "object"
    if property.value.$ref
      getRefLink property.value.$ref.value, refs
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
            options.push getRefLink item.value.$ref.value, refs
          else
            options.push formatSubschema item.value, refs
        else if item.Ctype == "string"
          options.push item.value
        else
          options.push String item.value
      options.join ", "
  else
    ""

shouldHoist = ( obj ) ->
  if !isObject obj
    return false
  if obj.$ref?
    return false
  for key of obj
    if key not in [ "type", "title", "description" ]
      return true
  false

hoistNested = ( schema ) ->
  schema.$defs = schema.$defs || {}
  
  traverse = ( name, obj ) ->
    if isObject obj
      if obj.properties?
        for propName, prop of obj.properties
          if shouldHoist prop
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
            
      if obj.patternProperties?
        for pattern, patternSchema of obj.patternProperties
          if shouldHoist patternSchema
            cleanPattern = pattern.replace /[^A-Za-z0-9]/g, ''
            hoistedName = ( titleCase name ) + ( titleCase cleanPattern )
            schema.$defs[hoistedName] = patternSchema
            if !patternSchema.title?
              patternSchema.title = titleCase uncase hoistedName
            
            refObj = { $ref: "#/$defs/#{hoistedName}" }
            if patternSchema.description?
              refObj.description = patternSchema.description
            obj.patternProperties[pattern] = refObj
            
            traverse hoistedName, patternSchema
          else
            traverse "#{name}Pattern", patternSchema

      if obj.items?
        if isArray obj.items
          for item, index in obj.items
            if shouldHoist item
              hoistedName = ( titleCase name ) + "Item" + ( index + 1 )
              schema.$defs[hoistedName] = item
              if !item.title?
                item.title = ( titleCase uncase name ) + " Item " + ( index + 1 )
              refObj = { $ref: "#/$defs/#{hoistedName}" }
              if item.description?
                refObj.description = item.description
              obj.items[index] = refObj
              traverse hoistedName, item
            else
              traverse "#{name}Item#{index + 1}", item
        else if isObject obj.items
          if shouldHoist obj.items
            hoistedName = ( titleCase name ) + "Items"
            schema.$defs[hoistedName] = obj.items
            if !obj.items.title?
              obj.items.title = ( titleCase uncase name ) + " Items"
            refObj = { $ref: "#/$defs/#{hoistedName}" }
            if obj.items.description?
              refObj.description = obj.items.description
            obj.items = refObj
            traverse hoistedName, schema.$defs[hoistedName]
          else
            traverse "#{name}Items", obj.items

      for key in [ "anyOf", "allOf", "oneOf" ]
        if obj[key]? && isArray obj[key]
          for item, index in obj[key]
            if shouldHoist item
              hoistedName = ( titleCase name ) + "Variation" + ( index + 1 )
              schema.$defs[hoistedName] = item
              if !item.title?
                item.title = ( titleCase uncase name ) + " Variation " + ( index + 1 )
              refObj = { $ref: "#/$defs/#{hoistedName}" }
              if item.description?
                refObj.description = item.description
              obj[key][index] = refObj
              traverse hoistedName, item
            else
              traverse "#{name}Variation#{index + 1}", item

      if obj.$defs?
        for defName, def of obj.$defs
          traverse defName, def

  rootName = if schema.title?
    titleCase uncase schema.title
  else
    "Root"
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
      slugify
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
      slugify
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