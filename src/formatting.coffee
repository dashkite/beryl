import { titleCase, uncase } from "@dashkite/joy/text"
import { getRefLink, slugify, getPropertyLabel } from "./helpers"

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

export {
  formatTypeDirect
  formatType
  formatSubschema
  formatCombinator
  formatPropertyVal
}
