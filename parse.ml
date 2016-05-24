open Yojson.Basic

let sprintf = Format.sprintf

let member_string_option key json = Util.member key json |> Util.to_string_option
let member_string key json = Util.member key json |> Util.to_string
let member_opt_map key fn json = Util.member key json |> Util.to_option fn

exception InvalidDataType of string
exception InvalidDataFormat of string
exception UnsupportedDefaultValueType of string
exception UnsupportedTransferProtocol of string
exception UnsupportedMimeType of string


let data_type_from_json json = match to_string json with
  | "integer" -> Schema.Integer
  | "number" -> Schema.Number
  | "string" -> Schema.String
  | "boolean" -> Schema.Boolean
  | "file" -> Schema.File
  | "array" -> Schema.Array
  | x -> raise(InvalidDataType(x))

let data_format_from_json json =
  let value = to_string json in
  if value = "" then None else Some(
    match value with
    | "integer32" -> Schema.Integer32
    | "integer64" -> Schema.Integer64
    | "float" -> Schema.Float
    | "double" -> Schema.Double
    | "byte" -> Schema.Byte
    | "password" -> Schema.Password
    | "date" -> Schema.Date
    | "datetime" -> Schema.Datetime
    | x -> raise(InvalidDataType x))

let default_value_from_json = function
  | `String s -> Schema.Str s
  | `Int i -> Schema.Int i
  | x -> raise(InvalidDataType(pretty_to_string x))

let transfer_protocol_from_json json =
  let value = to_string json in
  if value = "" then None else Some(
    match value with
      | "http" -> Schema.HTTP
      | "https" -> Schema.HTTPS
      | "ws" -> Schema.WS
      | "wss" -> Schema.WSS
      | x -> raise(UnsupportedTransferProtocol x))

let mime_type_from_json json =
  let value = to_string json in
  if value = "" then None else Some(
    match value with
      | "text/plain; charset=utf-8" -> Schema.Text
      | "application/json" -> Schema.JSON
      | x -> raise(UnsupportedMimeType x))

let contact_from_json json : Schema.contact =
  {
    name  = member_string_option "name" json;
    url   = member_string_option "url" json;
    email = member_string_option "email" json;
  }

let license_from_json json : Schema.license =
  {
    name  = member_string "name" json;
    url   = member_string_option "url" json;
  }

let info_from_json json : Schema.info =
  {
    title = member_string "title" json;
    version = member_string "version" json;
    description = member_string_option "description"  json;
    terms_of_service = member_string_option "termsOfService" json;
    contact = member_opt_map "contact" contact_from_json json;
    license = member_opt_map "license" license_from_json json;
  }

let external_doc_from_json json : Schema.external_doc =
  {
    description = member_string_option "description" json;
    url = member_string "url" json;
  }


let main () =
  let json = from_channel stdin in
  Util.member "format" json |> data_type_from_json |> (function
    | Schema.Integer -> print_endline "hi"
  )


let () = main ()
