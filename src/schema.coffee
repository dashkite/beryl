import $RefParser from "@apidevtools/json-schema-ref-parser"
import {
  isString
  isArray
  isObject
  isNumber
  isBoolean
} from "@dashkite/joy/type"
import TurndownService from "turndown"

import fullHtml from "./html"
import resolveHtml from "./templates/resolve"

import { Format } from "./helpers/format"
import { Hoist } from "./helpers/hoist"
import { Prose } from "./helpers/prose"
import { Tabular } from "./helpers/tabular"

areType = ( typeChecker, array ) ->
  ( isArray array ) && ( array.every typeChecker )

class Schema

  constructor: ( @source ) ->
    @referenceKeys = []

  decode: ->
    @referenceKeys = []
    @schema = ( structuredClone @source )
    ( Hoist.nested @schema )
    
    resolvedSchema = ( structuredClone @source )
    ( Hoist.nested resolvedSchema )
    
    resolved = await ( $RefParser.resolve resolvedSchema, external: false )
    ( @decorator @schema )
    @references = {}
    for key in @referenceKeys
      cleanKey = key[ 1.. ]
      @references[ cleanKey ] = ( resolved.get key )
    ( @decorator @references )
    delete @schema[ "$schema" ]
    delete @schema[ "$defs" ]

  decorator: ( iterable ) ->
    for key, value of iterable
      if key == "$ref"
        ( @referenceKeys.push value )
      if isString value
        iterable[ key ] = { Ctype: "string", value }
      else if isNumber value
        iterable[ key ] = { Ctype: "number", value }
      else if isBoolean value
        iterable[ key ] = { Ctype: "boolean", value }
      else if isObject value
        iterable[ key ] = { Ctype: "object", value }
        ( @decorator iterable[ key ].value )
      else if isArray value
        if ( areType isString, value ) ||
        ( areType isNumber, value ) ||
        ( areType isBoolean, value )
          iterable[ key ] = { Ctype: "string", value: ( value.join ", " ) }
        else
          iterable[ key ] = { Ctype: "array", value }
          ( @decorator iterable[ key ].value )

  html: ( options = { tabular: true } ) ->
    await @decode()
    if !options.tabular
      sections = ( Prose.build @schema, @references )
      subschemas = sections[ 1.. ]
      
      title = if @schema.title?.value?
        "#{ @schema.title.value } — Schema Reference"
      else if sections[ 0 ]?
        "#{ sections[ 0 ].heading } — Schema Reference"
      else
        "Untitled Schema Reference"
        
      navigation = if sections[ 0 ]?
        sublist =
          ( { href: "##{ sec.id }", text: sec.heading } for sec in subschemas )
        root: { href: "##{ sections[ 0 ].id }", text: sections[ 0 ].heading }
        subschemas: sublist
      else
        null
        
      ( fullHtml { @schema, sections, subschemas, options, title, navigation } )
    else
      tabular = ( Tabular.build @schema, @references )
      
      title = if @schema.title?.value?
        "#{ @schema.title.value } — Schema Reference"
      else
        "Untitled Schema Reference"
        
      sublist =
        for key, ref of @references
          { href: "##{ key }", text: ref.value.title?.value || "Untitled" }
          
      navigation =
        root: { href: "#top-level", text: @schema.title?.value || "Untitled" }
        subschemas: sublist
          
      ( fullHtml { @schema, tabular, options, title, navigation } )

  resolve: ( options = { tabular: true } ) ->
    await @decode()
    if !options.tabular
      sections = ( Prose.build @schema, @references )
      subschemas = sections[ 1.. ]
      ( resolveHtml { @schema, sections, subschemas, options } )
    else
      tabular = ( Tabular.build @schema, @references )
      ( resolveHtml { @schema, tabular, options } )

  markdown: ( options = {} ) ->
    mergedOptions = ( Object.assign { tabular: false }, options )
    htmlContent = await ( @html mergedOptions )
    turndown = ( new TurndownService emDelimiter: "_" )
    ( turndown.remove [ "title", "nav" ] )
    ( turndown.addRule 'table',
      filter: 'table'
      replacement: ( content, node ) ->
        rows = ( Array.from ( node.querySelectorAll "tr" ))
        mdRows = []
        for row in rows
          cells = ( Array.from ( row.querySelectorAll "th, td" ))
          mdCells = []
          for cell in cells
            html = ( cell.innerHTML.replace /<br\s*\/?>/gi, '^^BR^^' )
            text =
              ( turndown.turndown html )
                .trim()
            text = ( text.replace /\^\^BR\^\^/g, '<br>' )
            text = ( text.replace /\|/g, '\\|' )
            text = ( text.replace /\r?\n/g, ' ' )
            ( mdCells.push text )
          ( mdRows.push "| " + ( mdCells.join " | " ) + " |" )
        if mdRows.length > 0
          headerRow = mdRows[ 0 ]
          cellsCount =
            ( Array.from ( rows[ 0 ].querySelectorAll "th, td" )).length
          separatorCells = ( "---" for i in [ 1..cellsCount ] )
          separatorRow = "| " + ( separatorCells.join " | " ) + " |"
          ( mdRows.splice 1, 0, separatorRow )
        "\n\n" + ( mdRows.join "\n" ) + "\n\n" )
    ( turndown.turndown htmlContent )

export { Schema }
