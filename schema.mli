
(* http://swagger.io/specification/#dataTypeFormat *)
type data_type = Integer | Number | String | Boolean
  | Array | File (* these are added to work with other datatypes *)
  | Object
type data_format =
  | Integer32 | Integer64 | Float | Double
  | Byte | Password
  | Date | Datetime

(* TODO: support more later *)
type default_value =
  | Int of int
  | Str of string

type parameter_format = Query | Header | Path | FormData | Body

type parameter_collection_format = (* default is CSV *)
  | CSV (* comma separated values *)
  | SSV (* space separated values *)
  | TSV (* tab separated values *)
  | Pipes (* pipe separated values *)
  | Multi (* multiple parametern instances, must be Query||FormData *)

type transfer_protocol = HTTP | HTTPS | WS | WSS

(*
Determines the format of the array if type array is used. Possible values are:
  csv - comma separated values foo,bar.
  ssv - space separated values foo bar.
  tsv - tab separated values foo\tbar.
  pipes - pipe separated values foo|bar.
  Default value is csv.
*)
type collection_format = CSV | SSV | TSV | Pipes

(* TODO: provided more type options for enum values *)
(* http://json-schema.org/latest/json-schema-validation.html#anchor76 *)
type enum = string

(* http://swagger.io/specification/#mimeTypes *)
(* TODO: support additional mime types *)
type mime_types =
  | JSON (* 'application/json *)
  | Text (* 'text/plain; charset=utf-8' *)

(* http://swagger.io/specification/#contactObject *)
type contact = {
  name: string option;
  url: string option;
  email: string option;
}

(* http://swagger.io/specification/#licenseObject *)
type license = {
  name : string;
  url : string option;
}

(* http://swagger.io/specification/#infoObject *)
type info = {
  title : string;
  description: string option;
  terms_of_service : string option;
  contact : contact option;
  license : license option;
  version : string;
}

(* http://swagger.io/specification/#externalDocumentationObject *)
type external_doc = {
  description : string option;
  url : string;
}


(* http://swagger.io/specification/#itemsObject *)
type item = {
  datatype : data_type; (* 'type' *)
  items : item option; (* IFF datatype == Array *)
  collection_format : collection_format option;
  default: default_value option;
  enum_values : (enum list) option; (* MUST be unique *)
  data_format : data_format option;
  (* non-MVP options
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
  ref : string option;
  format : data_format option;
  type_options : data_type; (* TODO: type can have multiiple options, for now we only allow 1 *)
  title : string option;
  description : string option;
  default_value : default_value option;
  required_attributes : string list;
  enum_values : enum list option;
  (* swagger modified spec (definitions altered from JSON schema) *)
  items: item option;
  properties : (string * item) list;
  (* swagger specific fixed fields *)
  external_docs : external_doc option;
  example : string option;
  (* TODO: non-MVP options
    discriminator : string option;
    read_only : bool option;
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
  description : string option;
  required : bool option; (* required if in' == Path *)
  (* if in' == "body" *)
  schema : data_schema;
  (* else *)
  type' : data_type;
  format' : data_format option;
  allow_empty_value : bool option;
  items : item option; (* required if type' == Array *)
  collection_format : parameter_collection_format option;
  default : default_value;
  enum_values : enum list option; (* MUST be unique *)
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

(* http://swagger.io/specification/#headerObject *)
type header = {
  description : string option;
  type' : data_type;
  format : data_format option;
  items : item option option; (* IFF datatype == Array *)
  collection_format : collection_format option;
  default : default_value option;
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

(* http://swagger.io/specification/#headersObject *)
type headers = (string * header) list

(* http://swagger.io/specification/#exampleObject *)
(* mime-type -> value *)
type example = (string * default_value) list

(* http://swagger.io/specification/#responseObject *)
type response = {
  description : string;
  schema : data_schema option;
  headers : headers option;
  examples : example option;
}

type reference = {
  ref : string;
}

(* response object or reference *)
type default_object =
  | Resp of response
  | Ref of reference

(* http://swagger.io/specification/#responsesObject *)
type responses = {
  default_obj : default_object option;
  default_ref : string option;
}

type parameters =
  | Parameter of parameter
  | Reference of reference

(* http://swagger.io/specification/#securityRequirementObject *)
(* security name scheme --> array of scopes if oauth2 otherwise empty array  *)
type security_requirements = (string * string list) list

(* http://swagger.io/specification/#operationObject *)
type operation = {
  tags : string list option;
  summary : string option;
  description : string option;
  external_docs : external_doc option;
  operation_id : string option;
  consumes : mime_types list option;
  produces : mime_types list option;
  parameters : parameters list;
  responses : responses;
  schemes : transfer_protocol list option;
  deprecated : bool option;
  (* non-MVP options
    security : security_requirements list option;
  *)
}

(* http://swagger.io/specification/#pathItemObject *)
type path = {
  ref : string option;
  get : operation option;
  put : operation option;
  post : operation option;
  delete : operation option;
  options : operation option;
  head : operation option;
  patch : operation option;
  parameters : parameters option;
}

(* http://swagger.io/specification/#securitySchemeObject *)
(* non-MVP options
type security_scheme_type = Basic | ApiKey | Oauth2
type security_api_key_location = Query | Header
type security_flow = Implicit | Password | Application | AccessCode

type security_scheme = {
  type' : security_scheme_type;
  description : string option;
  name : string;
  in' : security_api_key_location;
}
*)

(* http://swagger.io/specification/#pathsObject *)
(* relative path to endpoint -> path *)
type paths = (string * path) list

(* http://swagger.io/specification/#definitionsObject *)
type definitions = (string * data_schema) list

(* http://swagger.io/specification/#parametersDefinitionsObject *)
type parameter_definitions = (string * parameter) list

(* http://swagger.io/specification/#responsesDefinitionsObject *)
type response_definitions = (string * response) list

(* non-MVP options
(* http://swagger.io/specification/#securityDefinitionsObject *)
*)

(* http://swagger.io/specification/#tagObject *)
type tag = {
  name : string;
  description : string option;
  external_docs : external_doc;
}

(* http://swagger.io/specification/#swaggerObject *)
type schema = {
  swagger : string;
  info : info;
  paths : paths;
  host : string option;
  base_path : string option;
  schemes : string list option;
  consumes : string list option;
  produces : string list option;
  definitions : definitions option;
  responses : response_definitions option;
  tags : tag list option;
  external_docs : external_doc option;
  (* non-MVP options
    security_definitions :
    security
  *)
}
