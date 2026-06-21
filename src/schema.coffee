import $RefParser from "@apidevtools/json-schema-ref-parser"
import {
  isString
  isArray
  isObject
  isNumber
  isBoolean
} from "@dashkite/joy/type"
import { clone } from "@dashkite/joy/value"
import TurndownService from "turndown"

import fullHtml from "./html"
import resolveHtml from "./templates/resolve"

import { areType } from "./helpers"
import { hoistNested } from "./hoisting"
import { buildProseViewModel } from "./prose"
import { buildTabularSections } from "./tabular"

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
        if ( areType isString, value ) ||
        ( areType isNumber, value ) ||
        ( areType isBoolean, value )
          iterable[key] = { Ctype: "string", value: value.join ", " }
        else
          iterable[key] = { Ctype: "array", value }
          @decorator iterable[key].value

  html: ( options = { tabular: true } ) ->
    await @decode()
    if !options.tabular
      sections = buildProseViewModel @schema, @refs
      
      title = if @schema.title?.value?
        "#{@schema.title.value} — Schema Reference"
      else if sections[0]?
        "#{sections[0].heading} — Schema Reference"
      else
        "Untitled Schema Reference"
        
      navigation = if sections[0]?
        root:
          href: "##{sections[0].id}"
          text: sections[0].heading
        subschemas:
          ( { href: "##{sec.id}", text: sec.heading } for sec in sections.slice 1 )
      else
        null
        
      fullHtml { @schema, sections, options, title, navigation }
    else
      tabular = buildTabularSections @schema, @refs
      
      title = if @schema.title?.value?
        "#{@schema.title.value} — Schema Reference"
      else
        "Untitled Schema Reference"
        
      navigation =
        root:
          href: "#top-level"
          text: @schema.title?.value || "Untitled"
        subschemas:
          ( { href: "##{key}", text: ref.value.title?.value || "Untitled" } for key, ref of @refs )
          
      fullHtml { @schema, tabular, options, title, navigation }

  resolve: ( options = { tabular: true } ) ->
    await @decode()
    if !options.tabular
      sections = buildProseViewModel @schema, @refs
      resolveHtml { @schema, sections, options }
    else
      tabular = buildTabularSections @schema, @refs
      resolveHtml { @schema, tabular, options }

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

export { Schema }
