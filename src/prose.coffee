import { getHeadingName, slugify, getPropertyLabel } from "./helpers"
import { formatPropertyVal } from "./formatting"

buildPropertySection = ( propName, prop, isPattern, refs ) ->
  desc = prop.value.description?.value || null
  if prop.Ctype == "object" && prop.value.$ref?
    refVal = prop.value.$ref.value
    refSchema = refs[refVal.slice 1]?.value
    desc = desc || refSchema?.description?.value || null
    
  tableRows = []
  if !(prop.Ctype == "object" && prop.value.$ref?)
    for subPropName, subProp of prop.value
      if subPropName not in [
        "title", "description", "properties", "patternProperties"
      ]
        if subPropName == "items" && subProp.Ctype == "object" &&
        subProp.value.$ref?
          continue
        if subPropName == "$ref"
          continue
        
        label = getPropertyLabel subPropName
        value = formatPropertyVal subPropName, subProp, refs
        if value != ""
          tableRows.push { label, value }
          
  references = []
  if prop.Ctype == "object" && prop.value.$ref?
    refVal = prop.value.$ref.value
    hName = getHeadingName refVal, refs[refVal.slice 1]?.value
    references.push { href: "##{slugify hName}", text: hName }
    
  if prop.value.items? && prop.value.items.Ctype == "object" &&
  prop.value.items.value.$ref?
    refVal = prop.value.items.value.$ref.value
    hName = getHeadingName refVal, refs[refVal.slice 1]?.value
    references.push { href: "##{slugify hName}", text: hName }

  if isPattern
    heading = propName
    id = slugify "Properties matching " + propName
  else
    heading = getHeadingName propName, prop.value
    id = slugify heading

  return {
    id
    heading
    isPattern
    description: desc
    tableRows
    references
  }

buildSection = ( key, iterable, isRoot, refs ) ->
  heading = getHeadingName key, iterable
  id = slugify heading
  
  description = iterable.description?.value || null
  
  tableRows = []
  for propName, prop of iterable
    if propName not in [
      "title", "description", "properties", "patternProperties"
    ]
      if propName == "items" && prop.Ctype == "object" && prop.value.$ref?
        continue
      if propName == "$ref"
        continue
      
      label = getPropertyLabel propName
      value = formatPropertyVal propName, prop, refs
      if value != ""
        tableRows.push { label, value }
        
  references = []
  if iterable.$ref?
    refVal = iterable.$ref.value
    hName = getHeadingName refVal, refs[refVal.slice 1]?.value
    references.push { href: "##{slugify hName}", text: hName }
    
  if iterable.items? && iterable.items.Ctype == "object" &&
  iterable.items.value.$ref?
    refVal = iterable.items.value.$ref.value
    hName = getHeadingName refVal, refs[refVal.slice 1]?.value
    references.push { href: "##{slugify hName}", text: hName }

  properties = []
  if iterable.properties?
    for propName, prop of iterable.properties.value
      properties.push buildPropertySection propName, prop, false, refs
      
  if iterable.patternProperties?
    for pattern, patternSchema of iterable.patternProperties.value
      properties.push buildPropertySection pattern, patternSchema, true, refs
      
  return {
    id
    heading
    isRoot
    description
    tableRows
    references
    properties
  }

buildProseViewModel = ( schema, refs ) ->
  sections = []
  sections.push buildSection "top-level", schema, true, refs
  for key, ref of refs
    sections.push buildSection key, ref.value, false, refs
  sections

export {
  buildPropertySection
  buildSection
  buildProseViewModel
}
