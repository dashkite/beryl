buildTabularViewModel = ( iterable, isArray = false ) ->
  rows = []
  for key, property of iterable
    if key == "$ref"
      rows.push { isRef: true, href: property.value }
    else
      row = { isRef: false, type: property.Ctype }
      
      if not isArray
        row.name = key
        
      if property.Ctype in [ "string", "number", "boolean" ]
        row.type = "simple"
        row.value = property.value
      else if property.Ctype == "object"
        row.value = ( buildTabularViewModel property.value, false )
      else if property.Ctype == "array"
        row.value = ( buildTabularViewModel property.value, true )
      else
        row.type = "simple"
        row.value = property.value
      
      rows.push row
      
  isArray: isArray
  rows: rows

buildTabularSections = ( schema, references ) ->
  root = ( buildTabularViewModel schema, false )
  subschemas = []
  for key, reference of references
    subschemas.push {
      id: key
      model: ( buildTabularViewModel reference.value, false )
    }
  
  root: root
  subschemas: subschemas

export {
  buildTabularViewModel
  buildTabularSections
}
