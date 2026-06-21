import { Format } from "./formatting"

buildProperty = ( propertyName, property, isPattern, references ) ->
  description = property.value.description?.value || null
  if property.Ctype == "object" && property.value.$ref?
    referenceValue = property.value.$ref.value
    referenceSchema = references[ referenceValue[ 1.. ]]?.value
    description = description || referenceSchema?.description?.value || null
    
  tableRows = []
  if !( property.Ctype == "object" && property.value.$ref? )
    for subPropertyName, subProperty of property.value
      if subPropertyName not in [
        "title", "description", "properties", "patternProperties"
      ]
        if subPropertyName == "items" &&
        subProperty.Ctype == "object" &&
        subProperty.value.$ref?
          continue
        if subPropertyName == "$ref"
          continue
        
        label = Format.label subPropertyName
        value = ( Format.property subPropertyName, subProperty, references )
        if value != ""
          tableRows.push { label, value }
          
  referenceList = []
  if property.Ctype == "object" && property.value.$ref?
    referenceValue = property.value.$ref.value
    headingName =
      ( Format.heading referenceValue,
        references[ referenceValue[ 1.. ]]?.value )
    referenceList.push { href: "##{ Format.identifier headingName }", text: headingName }
    
  if property.value.items? && property.value.items.Ctype == "object" &&
  property.value.items.value.$ref?
    referenceValue = property.value.items.value.$ref.value
    headingName =
      ( Format.heading referenceValue,
        references[ referenceValue[ 1.. ]]?.value )
    referenceList.push { href: "##{ Format.identifier headingName }", text: headingName }

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

buildSection = ( key, iterable, isRoot, references ) ->
  heading = ( Format.heading key, iterable )
  id = ( Format.identifier heading )
  
  description = iterable.description?.value || null
  
  tableRows = []
  for propertyName, property of iterable
    if propertyName not in [
      "title", "description", "properties", "patternProperties"
    ]
      if propertyName == "items" &&
      property.Ctype == "object" &&
      property.value.$ref?
        continue
      if propertyName == "$ref"
        continue
      
      label = Format.label propertyName
      value = ( Format.property propertyName, property, references )
      if value != ""
        tableRows.push { label, value }
        
  referenceList = []
  if iterable.$ref?
    referenceValue = iterable.$ref.value
    headingName =
      ( Format.heading referenceValue,
        references[ referenceValue[ 1.. ]]?.value )
    referenceList.push { href: "##{ Format.identifier headingName }", text: headingName }
    
  if iterable.items? && iterable.items.Ctype == "object" &&
  iterable.items.value.$ref?
    referenceValue = iterable.items.value.$ref.value
    headingName =
      ( Format.heading referenceValue,
        references[ referenceValue[ 1.. ]]?.value )
    referenceList.push { href: "##{ Format.identifier headingName }", text: headingName }

  properties = []
  if iterable.properties?
    for propertyName, property of iterable.properties.value
      properties.push(
        ( buildProperty propertyName, property, false, references )
      )
      
  if iterable.patternProperties?
    for pattern, patternSchema of iterable.patternProperties.value
      properties.push(
        ( buildProperty pattern, patternSchema, true, references )
      )
      
  id: id
  heading: heading
  isRoot: isRoot
  description: description
  tableRows: tableRows
  references: referenceList
  properties: properties

build = ( schema, references ) ->
  sections = []
  sections.push( ( buildSection "top-level", schema, true, references ))
  for key, reference of references
    sections.push( ( buildSection key, reference.value, false, references ))
  sections

Prose = {
  build
}

export { Prose }
