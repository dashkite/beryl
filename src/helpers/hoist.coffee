import { isObject, isArray } from "@dashkite/joy/type"
import { titleCase, uncase } from "@dashkite/joy/text"

check = ( object ) ->
  if ( isObject object ) && !object.$ref?
    hasOtherKeys = false
    for key of object
      if key not in [ "type", "title", "description" ]
        hasOtherKeys = true
    hasOtherKeys
  else
    false

parseHoistedName = ( hoistedName ) ->
  match = ( hoistedName.match /(.*)(Item\d+|Items|Variation\d+)$/ )
  
  if match
    prefix = match[ 1 ]
    suffix = match[ 2 ]
    formattedSuffix = ( suffix.replace /(\d+)/, " $1" )
    prefixWords = ( prefix.match /[A-Z][a-z0-9]*/g ) || []
    
    if prefixWords.length > 0
      baseWord = prefixWords[ prefixWords.length - 1 ]
      parentWords = prefixWords[ 0..( prefixWords.length - 2 ) ]
      baseTitle = "#{ baseWord } #{ formattedSuffix }"
      parentTitle = if parentWords.length > 0
        ( titleCase ( uncase ( parentWords.join " " )))
      else
        ""
    else
      baseTitle = formattedSuffix
      parentTitle = ""
  else
    words = ( hoistedName.match /[A-Z][a-z0-9]*/g ) || [ hoistedName ]
    len = words.length
    if len >= 2
      baseWords = [ words[ len - 1 ] ]
      parentWords = words[ 0..( len - 2 ) ]
    else
      baseWords = words
      parentWords = []
      
    baseTitle = ( titleCase ( uncase ( baseWords.join " " )))
    parentTitle = if parentWords.length > 0
      ( titleCase ( uncase ( parentWords.join " " )))
    else
      ""
      
  { baseTitle, parentTitle }

class Hoister
  constructor: ( @schema ) ->
    @schema.$defs ?= {}
    @definitionsToTitle = {}

  run: ->
    rootName = if @schema.title?
      ( titleCase ( uncase @schema.title ))
    else
      "Root"
    rootName = ( rootName.replace /\s+/g, "" )
    ( @traverse rootName, @schema )
    ( @assignTitles() )

  hoist: ( name, propName, schemaObj ) ->
    if ( check schemaObj )
      hoistedName = ( titleCase name ) + ( titleCase propName )
      @schema.$defs[ hoistedName ] = schemaObj
      if !schemaObj.title?
        @definitionsToTitle[ hoistedName ] = { definition: schemaObj }
      refObj = { $ref: "#/$defs/#{ hoistedName }" }
      if schemaObj.description?
        refObj.description = schemaObj.description
      { hoistedName, refObj }
    else
      null

  traverse: ( name, object ) ->
    if isObject object
      if object.properties?
        for propertyName, property of object.properties
          if hoisted = ( @hoist name, propertyName, property )
            object.properties[ propertyName ] = hoisted.refObj
            ( @traverse hoisted.hoistedName, property )
          else
            ( @traverse propertyName, property )

      if object.patternProperties?
        for pattern, patternSchema of object.patternProperties
          cleanPattern = ( pattern.replace /[^A-Za-z0-9]/g, "" )
          if hoisted = ( @hoist name, cleanPattern, patternSchema )
            object.patternProperties[ pattern ] = hoisted.refObj
            ( @traverse hoisted.hoistedName, patternSchema )
          else
            ( @traverse "#{ name }Pattern", patternSchema )
 
      if object.items?
        if isArray object.items
          for item, index in object.items
            if hoisted = ( @hoist name, "Item#{ index + 1 }", item )
              object.items[ index ] = hoisted.refObj
              ( @traverse hoisted.hoistedName, item )
            else
              ( @traverse "#{ name }Item#{ index + 1 }", item )
        else if isObject object.items
          if hoisted = ( @hoist name, "Items", object.items )
            object.items = hoisted.refObj
            ( @traverse hoisted.hoistedName, @schema.$defs[ hoisted.hoistedName ] )
          else
            ( @traverse "#{ name }Items", object.items )
 
      for key in [ "anyOf", "allOf", "oneOf" ]
        if object[ key ]? && isArray object[ key ]
          for item, index in object[ key ]
            if hoisted = ( @hoist name, "Variation#{ index + 1 }", item )
              object[ key ][ index ] = hoisted.refObj
              ( @traverse hoisted.hoistedName, item )
            else
              ( @traverse "#{ name }Variation#{ index + 1 }", item )
 
      if object.$defs?
        for definitionName, definition of object.$defs
          ( @traverse definitionName, definition )

  assignTitles: ->
    frequencies = {}
    for definitionName, definition of @schema.$defs
      if @definitionsToTitle[ definitionName ]?
        info = @definitionsToTitle[ definitionName ]
        { baseTitle, parentTitle } = ( parseHoistedName definitionName )
        info.baseTitle = baseTitle
        info.parentTitle = parentTitle
      else
        baseTitle = if definition.title?
          definition.title
        else
          ( titleCase ( uncase definitionName ))
          
      frequencies[ baseTitle ] = ( frequencies[ baseTitle ] || 0 ) + 1
 
    for definitionName, info of @definitionsToTitle
      if frequencies[ info.baseTitle ] > 1 && info.parentTitle != ""
        info.definition.title = "#{ info.baseTitle } (#{ info.parentTitle })"
      else
        info.definition.title = info.baseTitle

nested = ( schema ) ->
  hoister = ( new Hoister schema )
  ( hoister.run() )

Hoist = {
  check
  nested
}

export { Hoist }
