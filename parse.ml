open Yojson.Basic
open Schema

let member_map key fn json = Util.member key json |> fn
let member_opt_map key fn json = Util.member key json |> Util.to_option fn

let member_string key json = member_map key Util.to_string json
let member_opt_string key json = member_opt_map key Util.to_string json


let member_list key fn json = Util.member key json |> Util.to_list |> List.map fn
let member_string_list key json = member_list key Util.to_string json

let member_opt_list key fn json = Util.member key json |>
  Util.to_option (fun x -> x |> Util.to_list |> List.map fn)
let member_opt_string_list key json = member_opt_list key Util.to_string json

let member_assoc key fn json = json |> Util.member key
  |> Util.to_assoc |> List.map (fun (s, v) -> (s, fn v))
let member_opt_assoc key fn json =
  let foo j = j |> Util.to_assoc |> List.map (fun (s, v) -> (s, fn v)) in
  json |> Util.member key |> Util.to_option foo

exception InvalidDataType of string
exception InvalidDataFormat of string
exception InvalidParameterLocation of string
exception UnsupportedDefaultValueType of string
exception UnsupportedTransferProtocol of string
exception UnsupportedMimeType of string
exception UnsupportedCollectionFormat of string
exception UnsupportedEnumValues of string


let data_type_from_json json = match to_string json with
  | "integer" -> Integer
  | "number" -> Number
  | "string" -> String
  | "boolean" -> Boolean
  | "file" -> File
  | "array" -> Array
  | "object" -> Object
  | x -> raise(InvalidDataType(x))

let data_format_from_json json = match to_string json with
  | "integer32" -> Integer32
  | "integer64" -> Integer64
  | "float" -> Float
  | "double" -> Double
  | "byte" -> Byte
  | "password" -> Password
  | "date" -> Date
  | "datetime" -> Datetime
  | x -> raise(InvalidDataType x)

let default_value_from_json = function
  | `String s -> Str s
  | `Int i -> Int i
  | x -> raise(InvalidDataType(pretty_to_string x))

let transfer_protocol_from_json json = match to_string json with
  | "http"  -> HTTP
  | "https" -> HTTPS
  | "ws"    -> WS
  | "wss"   -> WSS
  | x -> raise(UnsupportedTransferProtocol x)

let mime_type_from_json json = match to_string json with
  | "application/json" -> JSON
  | "text/plain; charset=utf-8" -> Text
  | x -> raise(UnsupportedMimeType x)

let parameter_format_from_json json = match to_string json with
  | "query" -> Query
  | "heaader" -> Header
  | "path" -> Path
  | "formData" -> FormData
  | "body" -> Body
  | x -> raise(InvalidParameterLocation x)

let contact_from_json json =
  {
    name  = member_opt_string "name" json;
    url   = member_opt_string "url" json;
    email = member_opt_string "email" json;
  }

let license_from_json json =
  {
    name  = member_string "name" json;
    url   = member_opt_string "url" json;
  }

let info_from_json json =
  {
    title = member_string "title" json;
    version = member_string "version" json;
    description = member_opt_string "description"  json;
    terms_of_service = member_opt_string "termsOfService" json;
    contact = member_opt_map "contact" contact_from_json json;
    license = member_opt_map "license" license_from_json json;
  }

let external_doc_from_json json =
  {
    description = member_opt_string "description" json;
    url = member_string "url" json;
  }

let collection_format_from_json json =
  match Util.to_string json with
    | "ssv" -> SSV
    | "tsv" -> TSV
    | "pipes" -> Pipes
    | "csv" -> CSV (* default *)
    | x -> raise(UnsupportedCollectionFormat x)

let parameter_collection_format_from_json json : parameter_collection_format =
  match Util.to_string json with
    | "ssv" -> SSV
    | "tsv" -> TSV
    | "pipes" -> Pipes
    | "multi" -> Multi
    | "csv" -> CSV (* default *)
    | x -> raise(UnsupportedCollectionFormat x)

type parameter_collection_format = (* default is CSV *)
  | CSV (* comma separated values *)
  | SSV (* space separated values *)
  | TSV (* tab separated values *)
  | Pipes (* pipe separated values *)
  | Multi (* multiple parametern instances, must be Query||FormData *)

let rec item_from_json json =
  {
    enum_values = member_opt_string_list "enum" json;
    datatype = member_map "type" data_type_from_json json;
    items = member_opt_map "items" item_from_json json;
    collection_format = member_opt_map "collectionFormat" collection_format_from_json json;
    default = member_opt_map "default" default_value_from_json json;
    data_format = member_opt_map "format" data_format_from_json json;
  }

let rec data_schema_from_json json : data_schema =
  {
    ref =  member_opt_string "$ref" json;
    format = member_opt_map "format" data_format_from_json json;
    type_options = member_map "type" data_type_from_json json;
    title =  member_opt_string "title" json;
    description =  member_opt_string "description" json;
    default_value = member_opt_map "default" default_value_from_json json;
    required_attributes = member_string_list "required" json;
    enum_values = member_opt_string_list "enum" json;
    items = member_opt_map "items" item_from_json json;
    properties = member_assoc "properties" item_from_json json;
    external_docs = member_opt_map "externalDocs" external_doc_from_json json;
    example = member_opt_string "example" json;
  }


let parameter_from_json json : parameter =
  {
    name = member_string "name" json;
    location = member_map "in" parameter_format_from_json json;
    description = member_opt_string "description" json;
    required = member_opt_map "required" Util.to_bool json;
    schema = member_opt_map "schema" data_schema_from_json json;
    data_type = member_opt_map "type" data_type_from_json json;
    data_format = member_opt_map "formatt" data_format_from_json json;
    allow_empty_value = member_opt_map "allowEmptyValue" Util.to_bool json;
    items = member_opt_map "item" item_from_json json;
    collection_format = member_opt_map "collectionFormat" parameter_collection_format_from_json json;
    default = member_opt_map "default" default_value_from_json json;
    enum_values = member_opt_string_list "enum" json;
  }

let header_from_json json : header =
  {
    description = member_opt_string "description" json;
    data_type = member_map "type" data_type_from_json json;
    data_format = member_opt_map "formatt" data_format_from_json json;
    items = member_opt_map "item" item_from_json json;
    collection_format = member_opt_map "collectionFormat" collection_format_from_json json;
    default = member_opt_map "default" default_value_from_json json;
  }


let main () =
  let json = from_channel stdin in
  let data = Util.to_assoc json in
  List.iter (fun (s, v) -> print_endline (Format.sprintf "%s -> %s" s (Util.to_string v))) data
  (*
  Util.member "collection" json |> collection_format_from_json |> (function
    | CSV -> print_endline "hi"
  )
  Util.member "format" json |> data_type_from_json |> (function
    | Integer -> print_endline "hi"
  )
  *)


let () = main ()
