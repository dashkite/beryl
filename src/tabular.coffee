buildViewModel = ( iterable, isArray = false ) ->
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
        row.value = ( buildViewModel property.value, false )
      else if property.Ctype == "array"
        row.value = ( buildViewModel property.value, true )
      else
        row.type = "simple"
        row.value = property.value
      
      rows.push row
      
  isArray: isArray
  rows: rows

build = ( schema, references ) ->
  root = ( buildViewModel schema, false )
  subschemas = []
  for key, reference of references
    subschemas.push { id: key, model: ( buildViewModel reference.value, false ) }
  
  root: root
  subschemas: subschemas

Tabular = {
  build
}

export { Tabular }
