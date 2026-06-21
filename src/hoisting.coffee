import { isObject, isArray } from "@dashkite/joy/type"
import { titleCase, uncase } from "@dashkite/joy/text"

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

export {
  shouldHoist
  hoistNested
}
