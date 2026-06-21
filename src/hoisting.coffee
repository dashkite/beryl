import { isObject, isArray } from "@dashkite/joy/type"
import { titleCase, uncase } from "@dashkite/joy/text"

shouldHoist = ( object ) ->
  if ( isObject object ) && !object.$ref?
    hasOtherKeys = false
    for key of object
      if key not in [ "type", "title", "description" ]
        hasOtherKeys = true
    hasOtherKeys
  else
    false

hoistNested = ( schema ) ->
  schema.$defs = schema.$defs || {}
  
  traverse = ( name, object ) ->
    if isObject object
      if object.properties?
        for propertyName, property of object.properties
          if ( shouldHoist property )
            hoistedName = ( titleCase name ) + ( titleCase propertyName )
            schema.$defs[ hoistedName ] = property
            if !property.title?
              property.title = ( titleCase ( uncase hoistedName ) )
            
            referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
            if property.description?
              referenceObject.description = property.description
            object.properties[ propertyName ] = referenceObject
            
            traverse hoistedName, property
          else
            traverse propertyName, property
            
      if object.patternProperties?
        for pattern, patternSchema of object.patternProperties
          if ( shouldHoist patternSchema )
            cleanPattern = pattern.replace( /[^A-Za-z0-9]/g, "" )
            hoistedName = ( titleCase name ) + ( titleCase cleanPattern )
            schema.$defs[ hoistedName ] = patternSchema
            if !patternSchema.title?
              patternSchema.title = ( titleCase ( uncase hoistedName ) )
            
            referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
            if patternSchema.description?
              referenceObject.description = patternSchema.description
            object.patternProperties[ pattern ] = referenceObject
            
            traverse hoistedName, patternSchema
          else
            traverse "#{ name }Pattern", patternSchema

      if object.items?
        if isArray object.items
          for item, index in object.items
            if ( shouldHoist item )
              hoistedName = ( titleCase name ) + "Item" + ( index + 1 )
              schema.$defs[ hoistedName ] = item
              if !item.title?
                item.title =
                  ( titleCase ( uncase name ) ) + " Item " + ( index + 1 )
              referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
              if item.description?
                referenceObject.description = item.description
              object.items[ index ] = referenceObject
              traverse hoistedName, item
            else
              traverse "#{ name }Item#{ index + 1 }", item
        else if isObject object.items
          if ( shouldHoist object.items )
            hoistedName = ( titleCase name ) + "Items"
            schema.$defs[ hoistedName ] = object.items
            if !object.items.title?
              object.items.title =
                ( titleCase ( uncase name ) ) + " Items"
            referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
            if object.items.description?
              referenceObject.description = object.items.description
            object.items = referenceObject
            traverse hoistedName, schema.$defs[ hoistedName ]
          else
            traverse "#{ name }Items", object.items

      for key in [ "anyOf", "allOf", "oneOf" ]
        if object[ key ]? && isArray object[ key ]
          for item, index in object[ key ]
            if ( shouldHoist item )
              hoistedName = ( titleCase name ) + "Variation" + ( index + 1 )
              schema.$defs[ hoistedName ] = item
              if !item.title?
                item.title =
                  ( titleCase ( uncase name ) ) + " Variation " + ( index + 1 )
              referenceObject = { $ref: "#/$defs/#{ hoistedName }" }
              if item.description?
                referenceObject.description = item.description
              object[ key ][ index ] = referenceObject
              traverse hoistedName, item
            else
              traverse "#{ name }Variation#{ index + 1 }", item

      if object.$defs?
        for definitionName, definition of object.$defs
          traverse definitionName, definition

  rootName = if schema.title?
    ( titleCase ( uncase schema.title ) )
  else
    "Root"
  rootName = rootName.replace( /\s+/g, "" )
  traverse rootName, schema

export {
  shouldHoist
  hoistNested
}
