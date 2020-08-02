# Derived from .NET implementation, Copyright 2016-2018 Esteve Fernandez <esteve@apache.org>
# Swift Implementation Copyright 2020 Alex Tyshka <atyshka15@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import string
import pathlib

from rosidl_cmake import convert_camel_case_to_lower_case_underscore
from rosidl_cmake import expand_template
from rosidl_cmake import generate_files
from rosidl_cmake import get_newest_modification_time
from rosidl_cmake import read_generator_arguments
from rosidl_generator_c import BASIC_IDL_TYPES_TO_C
from rosidl_parser.definition import AbstractGenericString
from rosidl_parser.definition import AbstractString
from rosidl_parser.definition import AbstractWString
from rosidl_parser.definition import AbstractNestedType
from rosidl_parser.definition import AbstractSequence
from rosidl_parser.definition import Array
from rosidl_parser.definition import BasicType
from rosidl_parser.definition import IdlContent
from rosidl_parser.definition import IdlLocator
from rosidl_parser.definition import NamespacedType
from rosidl_parser.parser import parse_idl_file

class Underscorer(string.Formatter):
    def format_field(self, value, spec):
        if spec.endswith('underscore'):
            value = convert_camel_case_to_lower_case_underscore(value)
            spec = spec[:-(len('underscore'))] + 's'
        return super(Underscorer, self).format_field(value, spec)

def post_process(output):
    print("Post Process Output:")
    print(output)

def generate_swift(generator_arguments_file, typesupport_impls):
    mapping = {
        'idl.swift.em': '%s.swift',
        'idl.c.em': '%s.c',
        'idl.h.em': 'rclswift_%s.h',
    }
    
    generated_files = generate_files(generator_arguments_file, mapping)
    header_files = list(filter(lambda file: os.path.splitext(file)[1] == '.h', generated_files))
    args = read_generator_arguments(generator_arguments_file)
    data = {
        'package_name': args['package_name'],
        'headers': header_files,
    }
    template_basepath = pathlib.Path(args['template_dir'])
    generated_file = os.path.join(
                    args['output_dir'], 'module.modulemap')
    latest_target_timestamp = get_newest_modification_time(args['target_dependencies'])
    expand_template(os.path.basename('idl.modulemap.em'), data, generated_file, minimum_timestamp=latest_target_timestamp, template_basepath=template_basepath)
    return 0


def escape_string(s):
    s = s.replace('\\', '\\\\')
    s = s.replace("'", "\\'")
    return s


def constant_value_to_swift(type_, value):
    assert value is not None
    if isinstance(type_, BasicType):
        if type_.typename == 'boolean':
            return 'true' if value else 'false'

        if type_.typename in [
                'double',
                'long double',
                'float',
                'char',
                'wchar',
                'octet',
                'int8',
                'uint8',
                'int16',
                'uint16',
                'int32',
                'uint32',
                'int64',
                'uint64',
        ]:
            return str(value)

    if isinstance(type_, AbstractGenericString):
        return '"%s"' % escape_string(value)

    assert False, "unknown constant type '%s'" % type_.typename

def get_builtin_swift_type(type_):
    if type_ == 'boolean':
        return 'Swift.Bool'

    if type_ == 'byte':
        return 'Swift.UInt8'

    if type_ == 'char':
        return 'Swift.UInt8'

    if type_ == 'octet':
        return 'Swift.UInt8'

    if type_ == 'float':
        return 'Swift.Float'

    if type_ == 'double':
        return 'Swift.Double'

    if type_ == 'int8':
        return 'Swift.Int8'

    if type_ == 'uint8':
        return 'Swift.UInt8'

    if type_ == 'int16':
        return 'Swift.Int16'

    if type_ == 'uint16':
        return 'Swift.UInt16'

    if type_ == 'int32':
        return 'Swift.Int32'

    if type_ == 'uint32':
        return 'Swift.UInt32'

    if type_ == 'int64':
        return 'Swift.Int64'

    if type_ == 'uint64':
        return 'Swift.UInt64'

    assert False, "unknown type '%s'" % type_

def get_default_for_type(type_):
    if type_ == 'boolean':
        return 'false'

    if type_ == 'byte':
        return '0'

    if type_ == 'char':
        return '0'

    if type_ == 'octet':
        return '0'

    if type_ == 'float':
        return '0'

    if type_ == 'double':
        return '0'

    if type_ == 'int8':
        return '0'

    if type_ == 'uint8':
        return '0'

    if type_ == 'int16':
        return '0'

    if type_ == 'uint16':
        return '0'

    if type_ == 'int32':
        return '0'

    if type_ == 'uint32':
        return '0'

    if type_ == 'int64':
        return '0'

    if type_ == 'uint64':
        return '0'

    assert False, "unknown type '%s'" % type_

def get_swift_type(type_, current_package_=None):
    if isinstance(type_, AbstractGenericString):
        return 'Swift.String'
    if isinstance(type_, NamespacedType):
        if current_package_ is not None:
            if current_package_ == type_.namespaced_name()[0]:
                return type_.namespaced_name()[-1]
        return '.'.join((type_.namespaced_name()[0], type_.namespaced_name()[-1]))

    return get_builtin_swift_type(type_.typename)

def msg_type_to_c(type_):
    if isinstance(type_, AbstractString):
        return 'char *'
    if isinstance(type_, AbstractWString):
        assert False, "Unicode strings not supported"
    assert isinstance(type_, BasicType)
    return BASIC_IDL_TYPES_TO_C[type_.typename]

def upperfirst(s):
    return s[0].capitalize() + s[1:]


def get_field_name(type_name, field_name):
    return field_name.lower()
