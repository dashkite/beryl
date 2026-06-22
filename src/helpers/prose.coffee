import { Format } from "./format"

# Extracts external reference links ($ref) from properties or array items.
# Resolves the referenced definition schema to obtain its formatted header name.
getReferences = ( iterable, references ) ->
  list = []
  if iterable.$ref?
    refVal = iterable.$ref.value
    heading = ( Format.heading refVal, references[ refVal[ 1.. ]]?.value )
    ( list.push { href: "##{ Format.identifier heading }", text: heading } )
  if iterable.items? && iterable.items.Ctype == "object" && iterable.items.value.$ref?
    refVal = iterable.items.value.$ref.value
    heading = ( Format.heading refVal, references[ refVal[ 1.. ]]?.value )
    ( list.push { href: "##{ Format.identifier heading }", text: heading } )
  list

# Filters and extracts metadata constraints (such as type, minProperties, required, etc.)
# from a schema node to form rows of key-value definitions for the prose tables.
getTableRows = ( iterable, references ) ->
  rows = []
  for key, value of iterable
    if key not in [ "title", "description", "properties", "patternProperties" ]
      if key == "items" && value.Ctype == "object" && value.value.$ref?
        continue
      if key == "$ref"
        continue
      label = ( Format.label key )
      valStr = ( Format.property key, value, references )
      if valStr != ""
        ( rows.push { label, value: valStr } )
  rows

# Compiles the view-model representation for an individual schema property.
# Determines description fallback priorities, tables rows, and reference links.
buildProperty = ( propertyName, property, isPattern, references ) ->
  description = property.value.description?.value || null
  if property.Ctype == "object" && property.value.$ref?
    referenceValue = property.value.$ref.value
    referenceSchema = references[ referenceValue[ 1.. ]]?.value
    description = description || referenceSchema?.description?.value || null
    
  tableRows = []
  if !( property.Ctype == "object" && property.value.$ref? )
    tableRows = ( getTableRows property.value, references )
          
  referenceList = ( getReferences property.value, references )

  if isPattern
    heading = propertyName
    id = ( Format.identifier ( "Properties matching " + propertyName ))
  else
    heading = ( Format.heading propertyName, property.value )
    id = ( Format.identifier heading )

  id: id
  heading: heading
  isPattern: isPattern
  description: description
  tableRows: tableRows
  references: referenceList

# Compiles the view-model section for a schema definition (root or hoisted subschema).
# Gathers all direct child properties and pattern properties.
buildSection = ( key, iterable, isRoot, references ) ->
  heading = ( Format.heading key, iterable )
  id = ( Format.identifier heading )
  
  description = iterable.description?.value || null
  
  tableRows = ( getTableRows iterable, references )
  referenceList = ( getReferences iterable, references )

  properties = []
  if iterable.properties?
    for propertyName, property of iterable.properties.value
      if isRoot && propertyName == "$schema"
        continue
      ( properties.push ( buildProperty propertyName, property, false, references ))
      
  if iterable.patternProperties?
    for pattern, patternSchema of iterable.patternProperties.value
      ( properties.push ( buildProperty pattern, patternSchema, true, references ))
      
  id: id
  heading: heading
  isRoot: isRoot
  description: description
  tableRows: tableRows
  references: referenceList
  properties: properties

build = ( schema, references ) ->
  sections = []
  ( sections.push ( buildSection "top-level", schema, true, references ))
  for key, reference of references
    ( sections.push ( buildSection key, reference.value, false, references ))
  sections

Prose = {
  build
}

export { Prose }
