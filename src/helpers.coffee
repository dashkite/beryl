import { isArray } from "@dashkite/joy/type"
import { uncase, titleCase } from "@dashkite/joy/text"

areType = ( typeChecker, array ) ->
  ( isArray array ) && ( array.every typeChecker )

slugify = ( text ) ->
  text.toLowerCase()
    .replace( /[^a-z0-9\s-]/g, "" )
    .replace( /\s+/g, "-" )
    .replace( /-+/g, "-" )

getHeadingName = ( key, referenceSchema ) ->
  if referenceSchema?.title?.value?
    referenceSchema.title.value
  else
    parts = key.split( "/" )
    lastName = parts[ parts.length - 1 ]
    ( titleCase ( uncase lastName ) )

getRefLink = ( referenceValue, references ) ->
  referenceObject = references[ referenceValue.slice( 1 ) ]
  referenceSchema = referenceObject?.value
  headingName = ( getHeadingName referenceValue, referenceSchema )
  slug = ( slugify headingName )
  "<a href=\"##{ slug }\">#{ headingName }</a>"

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
    else ( titleCase ( uncase name ) )

export {
  areType
  slugify
  getHeadingName
  getRefLink
  getPropertyLabel
}
