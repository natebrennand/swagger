
type datatype =
  | Integer32 | Integer64 | Float | Double
  | String | Byte | Password
  | Date | Datetime
  | Boolean

(* TODO: support more later *)
type default_value =
  | Int of int
  | Str of string

(* TODO: provided more type options for enum values *)
(* http://json-schema.org/latest/json-schema-validation.html#anchor76 *)
type enum = string

type web_resource = {
  description : string;
  url : string;
}


(* http://swagger.io/specification/#contactObject *)
type contact = {
  name: string;
  url: string;
  email: string;
}

(* http://swagger.io/specification/#licenseObject *)
type license = web_resource

(* http://swagger.io/specification/#infoObject *)
type info = {
  title : string;
  description: string;
  terms_of_service : string;
  contact : contact;
  license : license;
  version : string;
}

(* http://swagger.io/specification/#externalDocumentationObject *)
type external_doc = web_resource

type parameter_format = Query | Header | Path | FormData | Body

type item_datatype = String | Number | Integer | Boolean | Array

(*
Determines the format of the array if type array is used. Possible values are:
  csv - comma separated values foo,bar.
  ssv - space separated values foo bar.
  tsv - tab separated values foo\tbar.
  pipes - pipe separated values foo|bar.
  Default value is csv.
*)
type collection_format = | CSV | SSV | TSV | Pipes

type item = {
  datatype : item_datatype; (* 'type' *)
  items : item option; (* IFF datatype == Array *)
  collection_format : collection_format;
  default: default_value;
  enum_values : enum list; (* MUST be unique *)
  (* non-MVP options
    format': string;
    maximum : int option;
    exclusive_maximum : int option;
    minimum : int option;
    exclusive_minimum : int option;
    max_length : int option;
    min_length : int option;
    pattern : string option;
    max_items : int option;
    min_items : int option;
    unique_items : bool;
    multiple_of : int;
  *)
}

(* http://swagger.io/specification/#schemaObject *)
type data_schema = {
  (* JSON schema spec: http://json-schema.org/latest/json-schema-validation.html *)
  ref : data_schema option;
  format : datatype;
  title : string;
  description : string;
  default_value : default_value;
  required_attributes : string list;
  enum_values : enum list; (* MUST be unique *)
  type_options : string list;
  (* swagger modified spec (definitions altered from JSON schema) *)
  items: item;
  discriminator : string;
  read_only : bool;
  external_docs : external_doc;
  example : string;
  (* TODO: non-MVP options
    multiple_of : int option; (* http://json-schema.org/latest/json-schema-validation.html#anchor14 *)
    maximum : int option;
    exclusive_maximum : int option;
    minimum : int option;
    exclusive_minimum : int option;
    max_length : int option;
    min_length : int option;
    pattern : string option;
    max_items : int option;
    min_items : int option;
    unique_items : bool;
    max_properties : int option;
    min_properties : int option;
    all_of : string list;
    xml : XML;
  *)
}

(* http://swagger.io/specification/#parameterObject *)
type parameter = {
  name : string;
  in' : parameter_format;
  description : string;
  required : bool;
  schema : data_schema;
}

type parameters = parameter

(* http://swagger.io/specification/#operationObject *)
type operation = {
  tags : string list;
  summary : string;
  description : string;
  external_docs : web_resource;
  operation_id : string;
  consumes : string list;
  produces : string list;
  parameters :  parameters;
}

(* http://swagger.io/specification/#pathItemObject *)
type path = {
  ref : string;
  get : string option;
}

(* http://swagger.io/specification/#pathsObject *)
type paths = {
  pattern : string * path;
}

(* http://swagger.io/specification/#swaggerObject *)
type schema = {
  swagger : string;
  info : info;
  host : string;
  base_path : string;
  schemes : string list;
  consumes : string list;
  produces : string list;
  paths : paths;
}


