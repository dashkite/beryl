import { isArray } from "@dashkite/joy/type"
import { pipe } from "@dashkite/joy/function"
import {
  titleCase
  uncase
  startsWith
  dash
  replace
} from "@dashkite/joy/text"

import labels from "./labels"

# Convert schema titles to valid URL slugs / anchor IDs.
# Joy's `dash` strips non-alphanumeric characters, but due to pipeline ordering
# in `gloss`, this can leave adjacent spaces that result in double hyphens.
# We explicitly collapse consecutive hyphens to ensure clean output.
toIdentifier = pipe [
  dash
  replace( /-+/g, "-" )
]

getHeadingName = ( key, referenceSchema ) ->
  if referenceSchema?.title?.value?
    referenceSchema.title.value
  else
    parts = ( key.split "/" )
    lastName = parts[ parts.length - 1 ]
    ( titleCase ( uncase lastName ))

getRefLink = ( referenceValue, references ) ->
  referenceObject = references[ referenceValue[ 1.. ]]
  referenceSchema = referenceObject?.value
  headingName = ( getHeadingName referenceValue, referenceSchema )
  id = ( toIdentifier headingName )
  "<a href=\"##{ id }\">#{ headingName }</a>"

# Formats string-type schema properties.
# Dispatches on the property name to produce direct type mappings, code blocks 
# for regex patterns, links for required arrays, or standard links for $refs.
formatString = ( name, property, references ) ->
  if name == "type"
    ( Format.direct property.value )
  else if name == "pattern"
    "<code>#{ property.value }</code>"
  else if name == "required"
    propertyNames = ( property.value.split ", " )
    links = []
    for propertyName in propertyNames
      title = ( titleCase ( uncase propertyName ))
      id = ( Format.identifier title )
      ( links.push "<a href=\"##{ id }\">#{ title }</a>" )
    ( links.join ", " )
  else if name == "$ref" || ( startsWith "#", property.value )
    ( Format.reference property.value, references )
  else
    property.value

formatNumberOrBoolean = ( property ) ->
  ( String property.value )

formatObject = ( property, references ) ->
  if property.value.$ref?
    ( Format.reference property.value.$ref.value, references )
  else
    ( Format.subschema property.value, references )

formatArray = ( name, property, references ) ->
  if name in [ "anyOf", "allOf", "oneOf" ]
    ( Format.combinator name, property.value, references )
  else
    options = []
    for item in property.value
      if item.Ctype == "object"
        if item.value.$ref?
          ( options.push ( Format.reference item.value.$ref.value, references ))
        else
          ( options.push ( Format.subschema item.value, references ))
      else if item.Ctype == "string"
        ( options.push item.value )
      else
        ( options.push ( String item.value ))
    ( options.join ", " )

Format =
  identifier: toIdentifier
  heading: getHeadingName
  reference: getRefLink
  label: ( name ) -> labels[ name ] || ( titleCase ( uncase name ))

  # Formats raw type names into a grammatically correct natural language list.
  # For example, "string, object, array" -> "String, Object, or Array".
  direct: ( typeValue ) ->
    if !typeValue
      "Object"
    else
      types = ( typeValue.split ", " )
      capitalized = ( titleCase t for t in types )
      if capitalized.length == 1
        capitalized[ 0 ]
      else if capitalized.length == 2
        ( capitalized.join " or " )
      else
        last = ( capitalized.pop() )
        "#{ ( capitalized.join ", " ) }, or #{ last }"

  type: ( propertySchema, referenceSchema ) ->
    type = propertySchema.type?.value || referenceSchema?.type?.value
    ( Format.direct type )

  # Formats nested inline object structures.
  # If the schema is just a single $ref, formats as a direct reference link.
  # Otherwise, builds a semicolon-separated string of key-value property descriptions.
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
          ( parts.push "#{ Format.label key }: #{ formattedValue }" )
      ( parts.join "; " )

  # Formats logical combinator arrays (allOf, anyOf, oneOf) into a conjunction-joined list.
  # For example, allOf -> "A and B", anyOf -> "A, B, or C".
  combinator: ( name, arrayValue, references ) ->
    conjunction = if name == "allOf" then "and" else "or"
    options = []
    for item in arrayValue
      ( options.push ( Format.subschema item.value, references ))
    if options.length == 1
      options[ 0 ]
    else if options.length == 2
      ( options.join " #{ conjunction } " )
    else
      last = ( options.pop() )
      "#{ ( options.join ", " ) }, #{ conjunction } #{ last }"

  property: ( name, property, references ) ->
    if !property? then ""
    else
      switch property.Ctype
        when "string" then ( formatString name, property, references )
        when "number", "boolean" then ( formatNumberOrBoolean property )
        when "object" then ( formatObject property, references )
        when "array" then ( formatArray name, property, references )
        else ""

export { Format }
