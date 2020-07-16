
@{
from rosidl_generator_swift import msg_type_to_c

from rosidl_parser.definition import AbstractNestedType
from rosidl_parser.definition import AbstractGenericString
from rosidl_parser.definition import AbstractString
from rosidl_parser.definition import AbstractWString
from rosidl_parser.definition import AbstractSequence
from rosidl_parser.definition import Array
from rosidl_parser.definition import BasicType
from rosidl_parser.definition import NamespacedType

from rosidl_cmake import convert_camel_case_to_lower_case_underscore

header_filename = "{0}/rclswift_{1}.h".format('/'.join(message.structure.namespaced_type.namespaces), convert_camel_case_to_lower_case_underscore(type_name))
}@

module RclC [system] {
  header "@(header_filename)"
  export *
}
