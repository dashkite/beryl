import { getHeadingName, slugify, getPropertyLabel } from "./helpers"
import { formatPropertyVal } from "./formatting"

buildPropertySection = ( propertyName, property, isPattern, references ) ->
  description = property.value.description?.value || null
  if property.Ctype == "object" && property.value.$ref?
    referenceValue = property.value.$ref.value
    referenceSchema = references[ referenceValue.slice( 1 ) ]?.value
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
        
        label = getPropertyLabel subPropertyName
        value = ( formatPropertyVal subPropertyName, subProperty, references )
        if value != ""
          tableRows.push { label, value }
          
  refList = []
  if property.Ctype == "object" && property.value.$ref?
    referenceValue = property.value.$ref.value
    headingName =
      ( getHeadingName referenceValue, references[ referenceValue.slice( 1 ) ]?.value )
    refList.push { href: "##{slugify headingName}", text: headingName }
    
  if property.value.items? && property.value.items.Ctype == "object" &&
  property.value.items.value.$ref?
    referenceValue = property.value.items.value.$ref.value
    headingName =
      ( getHeadingName referenceValue, references[ referenceValue.slice( 1 ) ]?.value )
    refList.push { href: "##{slugify headingName}", text: headingName }

  if isPattern
    heading = propertyName
    id = ( slugify ( "Properties matching " + propertyName ) )
  else
    heading = ( getHeadingName propertyName, property.value )
    id = ( slugify heading )

  id: id
  heading: heading
  isPattern: isPattern
  description: description
  tableRows: tableRows
  references: refList

buildSection = ( key, iterable, isRoot, references ) ->
  heading = ( getHeadingName key, iterable )
  id = ( slugify heading )
  
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
      
      label = getPropertyLabel propertyName
      value = ( formatPropertyVal propertyName, property, references )
      if value != ""
        tableRows.push { label, value }
        
  refList = []
  if iterable.$ref?
    referenceValue = iterable.$ref.value
    headingName =
      ( getHeadingName referenceValue, references[ referenceValue.slice( 1 ) ]?.value )
    refList.push { href: "##{slugify headingName}", text: headingName }
    
  if iterable.items? && iterable.items.Ctype == "object" &&
  iterable.items.value.$ref?
    referenceValue = iterable.items.value.$ref.value
    headingName =
      ( getHeadingName referenceValue, references[ referenceValue.slice( 1 ) ]?.value )
    refList.push { href: "##{slugify headingName}", text: headingName }

  properties = []
  if iterable.properties?
    for propertyName, property of iterable.properties.value
      properties.push(
        ( buildPropertySection propertyName, property, false, references )
      )
      
  if iterable.patternProperties?
    for pattern, patternSchema of iterable.patternProperties.value
      properties.push(
        ( buildPropertySection pattern, patternSchema, true, references )
      )
      
  id: id
  heading: heading
  isRoot: isRoot
  description: description
  tableRows: tableRows
  references: refList
  properties: properties

buildProseViewModel = ( schema, references ) ->
  sections = []
  sections.push( ( buildSection "top-level", schema, true, references ) )
  for key, reference of references
    sections.push( ( buildSection key, reference.value, false, references ) )
  sections

export {
  buildPropertySection
  buildSection
  buildProseViewModel
}
