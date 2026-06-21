import { isArray } from "@dashkite/joy/type"
import { titleCase, uncase } from "@dashkite/joy/text"
import { pipe } from "@dashkite/joy/function"
import {
  toLowerCase
  replace
  startsWith
} from "@dashkite/joy/text"

import labels from "./labels"

toIdentifier = pipe [
  toLowerCase
  replace( /[^a-z0-9\s-]/g, "" )
  replace( /\s+/g, "-" )
  replace( /-+/g, "-" )
]

getHeadingName = ( key, referenceSchema ) ->
  if referenceSchema?.title?.value?
    referenceSchema.title.value
  else
    parts = key.split( "/" )
    lastName = parts[ parts.length - 1 ]
    ( titleCase ( uncase lastName ))

getRefLink = ( referenceValue, references ) ->
  referenceObject = references[ referenceValue[ 1.. ]]
  referenceSchema = referenceObject?.value
  headingName = ( getHeadingName referenceValue, referenceSchema )
  slug = ( toIdentifier headingName )
  "<a href=\"##{ slug }\">#{ headingName }</a>"

Format =
  identifier: toIdentifier
  heading: getHeadingName
  reference: getRefLink
  label: ( name ) -> labels[ name ] || ( titleCase ( uncase name ))

  direct: ( typeValue ) ->
    if !typeValue
      "Object"
    else
      types = typeValue.split( ", " )
      capitalized = ( titleCase t for t in types )
      if capitalized.length == 1
        capitalized[ 0 ]
      else if capitalized.length == 2
        capitalized.join( " or " )
      else
        last = capitalized.pop()
        "#{ capitalized.join( ", " ) }, or #{ last }"

  type: ( propertySchema, referenceSchema ) ->
    type = propertySchema.type?.value || referenceSchema?.type?.value
    ( Format.direct type )

  subschema: ( object, references ) ->
    keys =
      ( key for key, value of object when key not in [
        "title", "description", "properties", "patternProperties"
      ] )
    if keys.length == 1 && keys[ 0 ] == "$ref"
      ( Format.property "$ref", object.$ref, references )
    else
      parts = []
      for key in keys
        formattedValue = ( Format.property key, object[ key ], references )
        if formattedValue
          parts.push "#{ Format.label key }: #{ formattedValue }"
      parts.join( "; " )

  combinator: ( name, arrayValue, references ) ->
    conjunction = if name == "allOf" then "and" else "or"
    options = []
    for item in arrayValue
      options.push( Format.subschema item.value, references )
    if options.length == 1
      options[ 0 ]
    else if options.length == 2
      options.join( " #{ conjunction } " )
    else
      last = options.pop()
      "#{ options.join( ", " ) }, #{ conjunction } #{ last }"

  property: ( name, property, references ) ->
    if !property?
      ""
    else
      if property.Ctype == "string"
        if name == "type"
          ( Format.direct property.value )
        else if name == "pattern"
          "<code>#{ property.value }</code>"
        else if name == "required"
          propertyNames = property.value.split( ", " )
          links = []
          for propertyName in propertyNames
            title = ( titleCase ( uncase propertyName ))
            slug = ( Format.identifier title )
            links.push( "<a href=\"##{ slug }\">#{ title }</a>" )
          links.join( ", " )
        else if name == "$ref" || ( startsWith "#", property.value )
          ( Format.reference property.value, references )
        else
          property.value
          
      else if property.Ctype == "number" || property.Ctype == "boolean"
        String property.value
        
      else if property.Ctype == "object"
        if property.value.$ref
          ( Format.reference property.value.$ref.value, references )
        else
          ( Format.subschema property.value, references )
          
      else if property.Ctype == "array"
        if name in [ "anyOf", "allOf", "oneOf" ]
          ( Format.combinator name, property.value, references )
        else
          options = []
          for item in property.value
            if item.Ctype == "object"
              if item.value.$ref
                options.push( Format.reference item.value.$ref.value, references )
              else
                options.push( Format.subschema item.value, references )
            else if item.Ctype == "string"
              options.push item.value
            else
              options.push( String item.value )
          options.join( ", " )
      else
        ""

export { Format }
