import { Schema } from "./schema"

html = ( schema, options ) ->
  instance = new Schema schema
  instance.html options

resolve = ( schema, options ) ->
  instance = new Schema schema
  instance.resolve options

markdown = ( schema, options ) ->
  instance = new Schema schema
  instance.markdown options

export { Schema, html, resolve, markdown }