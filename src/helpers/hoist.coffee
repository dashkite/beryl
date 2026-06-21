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

nested = ( schema ) ->
  schema.$defs = schema.$defs || {}
  definitionsToTitle = {}
  
  traverse = ( name, object ) ->
    if isObject object
      if object.properties?
        for propertyName, property of object.properties
          if ( check property )
            hoistedName = ( titleCase name ) + ( titleCase propertyName )
            schema.$defs[ hoistedName ] = property
            if !property.title?
              definitionsToTitle[ hoistedName ] = { definition: property }
            
            referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
            if property.description?
              referenceObject.description = property.description
            object.properties[ propertyName ] = referenceObject
            
            ( traverse hoistedName, property )
          else
            ( traverse propertyName, property )
            
      if object.patternProperties?
        for pattern, patternSchema of object.patternProperties
          if ( check patternSchema )
            cleanPattern = ( pattern.replace /[^A-Za-z0-9]/g, "" )
            hoistedName = ( titleCase name ) + ( titleCase cleanPattern )
            schema.$defs[ hoistedName ] = patternSchema
            if !patternSchema.title?
              definitionsToTitle[ hoistedName ] = { definition: patternSchema }
            
            referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
            if patternSchema.description?
              referenceObject.description = patternSchema.description
            object.patternProperties[ pattern ] = referenceObject
            
            ( traverse hoistedName, patternSchema )
          else
            ( traverse "#{ name }Pattern", patternSchema )
 
      if object.items?
        if isArray object.items
          for item, index in object.items
            if ( check item )
              hoistedName = ( titleCase name ) + "Item" + ( index + 1 )
              schema.$defs[ hoistedName ] = item
              if !item.title?
                definitionsToTitle[ hoistedName ] = { definition: item }
              referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
              if item.description?
                referenceObject.description = item.description
              object.items[ index ] = referenceObject
              ( traverse hoistedName, item )
            else
              ( traverse "#{ name }Item#{ index + 1 }", item )
        else if isObject object.items
          if ( check object.items )
            hoistedName = ( titleCase name ) + "Items"
            schema.$defs[ hoistedName ] = object.items
            if !object.items.title?
              definitionsToTitle[ hoistedName ] = { definition: object.items }
            referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
            if object.items.description?
              referenceObject.description = object.items.description
            object.items = referenceObject
            ( traverse hoistedName, schema.$defs[ hoistedName ] )
          else
            ( traverse "#{ name }Items", object.items )
 
      for key in [ "anyOf", "allOf", "oneOf" ]
        if object[ key ]? && isArray object[ key ]
          for item, index in object[ key ]
            if ( check item )
              hoistedName = ( titleCase name ) + "Variation" + ( index + 1 )
              schema.$defs[ hoistedName ] = item
              if !item.title?
                definitionsToTitle[ hoistedName ] = { definition: item }
              referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
              if item.description?
                referenceObject.description = item.description
              object[ key ][ index ] = referenceObject
              ( traverse hoistedName, item )
            else
              ( traverse "#{ name }Variation#{ index + 1 }", item )
 
      if object.$defs?
        for definitionName, definition of object.$defs
          ( traverse definitionName, definition )
 
  rootName = if schema.title?
    ( titleCase ( uncase schema.title ))
  else
    "Root"
  rootName = ( rootName.replace /\s+/g, "" )
  ( traverse rootName, schema )
 
  frequencies = {}
  for definitionName, definition of schema.$defs
    if definitionsToTitle[ definitionName ]?
      info = definitionsToTitle[ definitionName ]
      { baseTitle, parentTitle } = ( parseHoistedName definitionName )
      info.baseTitle = baseTitle
      info.parentTitle = parentTitle
    else
      baseTitle = if definition.title?
        definition.title
      else
        ( titleCase ( uncase definitionName ))
        
    frequencies[ baseTitle ] = ( frequencies[ baseTitle ] || 0 ) + 1
 
  for definitionName, info of definitionsToTitle
    if frequencies[ info.baseTitle ] > 1 && info.parentTitle != ""
      info.definition.title = "#{ info.baseTitle } (#{ info.parentTitle })"
    else
      info.definition.title = info.baseTitle

Hoist = {
  check
  nested
}

export { Hoist }
