@{
from rosidl_generator_swift import get_field_name
from rosidl_generator_swift import get_swift_type
from rosidl_generator_swift import get_builtin_swift_type
from rosidl_generator_swift import get_default_for_type
from rosidl_generator_swift import constant_value_to_swift

from rosidl_parser.definition import AbstractNestedType
from rosidl_parser.definition import AbstractGenericString
from rosidl_parser.definition import AbstractString
from rosidl_parser.definition import AbstractWString
from rosidl_parser.definition import AbstractSequence
from rosidl_parser.definition import Array
from rosidl_parser.definition import BasicType
from rosidl_parser.definition import NamespacedType

type_name = message.structure.namespaced_type.name
msg_typename = '%s__%s' % ('__'.join(message.structure.namespaced_type.namespaces), type_name)
}

import RclSwiftCommon
@(empy.escape('@_implementationOnly'))
import @(package_name)_c

@[for member in message.structure.members]@
@[    if isinstance(member.type, NamespacedType) and member.type.namespaced_name()[0] != package_name]@
import class @(get_swift_type(member.type))
@[    end if]@
@[end for]@

@[for ns in message.structure.namespaced_type.namespaces]@
@[end for]@
public class @(type_name) : Message {

    public init()
    {
@[for member in message.structure.members]@
@[    if isinstance(member.type, Array)]@
// TODO: Array types are not supported
@[    elif isinstance(member.type, AbstractSequence)]@
// TODO: Sequence types are not supported
@[    elif isinstance(member.type, AbstractWString)]@
// TODO: Unicode types are not supported
@[    elif isinstance(member.type, BasicType)]@
        @(get_field_name(type_name, member.name)) = @(get_default_for_type(member.type.typename))
@[    elif isinstance(member.type, AbstractString)]@
        @(get_field_name(type_name, member.name)) = ""
@[    else]@
        @(get_field_name(type_name, member.name)) = @(get_swift_type(member.type, package_name))()
@[    end if]@
@[end for]@
    }

    public static func _GET_TYPE_SUPPORT() -> UnsafeRawPointer {
        return @(msg_typename)__get_typesupport()
    }

    public func _CREATE_NATIVE_MESSAGE() -> UnsafeMutableRawPointer{
        return @(msg_typename)__create_native_message()
    }

    public func _READ_HANDLE(messageHandle: UnsafeMutableRawPointer) -> Void {
@[for member in message.structure.members]@
@[    if isinstance(member.type, Array)]@
// TODO: Array types are not supported
@[    elif isinstance(member.type, AbstractSequence)]@
// TODO: Sequence types are not supported
@[    elif isinstance(member.type, AbstractWString)]@
// TODO: Unicode types are not supported
@[    elif isinstance(member.type, BasicType) or isinstance(member.type, AbstractString)]@
@[        if isinstance(member.type, AbstractString)]@
        let c_str_@(get_field_name(type_name, member.name)) = @(msg_typename)__read_field_@(member.name)(messageHandle)
        @(get_field_name(type_name, member.name)) = Swift.String(cString: c_str_@(get_field_name(type_name, member.name))!)
@[        else]@
        @(get_field_name(type_name, member.name)) = @(msg_typename)__read_field_@(member.name)(messageHandle)
@[        end if]@
@[    else]@
        @(get_field_name(type_name, member.name))._READ_HANDLE(messageHandle: @(msg_typename)__get_field_@(member.name)_HANDLE(messageHandle));
@[    end if]@
@[end for]@
    }

    public func _WRITE_HANDLE(messageHandle: UnsafeMutableRawPointer) {
@[for member in message.structure.members]@
@[    if isinstance(member.type, Array)]@
// TODO: Array types are not supported
@[    elif isinstance(member.type, AbstractSequence)]@
// TODO: Sequence types are not supported
@[    elif isinstance(member.type, AbstractWString)]@
// TODO: Unicode types are not supported
@[    elif isinstance(member.type, BasicType) or isinstance(member.type, AbstractString)]@
        @(msg_typename)__write_field_@(member.name)(messageHandle, @(get_field_name(type_name, member.name)));
@[    else]@
        @(get_field_name(type_name, member.name))._WRITE_HANDLE(messageHandle: @(msg_typename)__get_field_@(member.name)_HANDLE(messageHandle));
@[    end if]@
@[end for]@
    }

    public func _DESTROY_NATIVE_MESSAGE (messageHandle: UnsafeMutableRawPointer) {
        @(msg_typename)__destroy_native_message(messageHandle);
    }

@[for constant in message.constants]@
    static let @(constant.name) : @(get_swift_type(constant.type)) = @(constant_value_to_swift(constant.type, constant.value))
@[end for]@

@[for member in message.structure.members]@
@[    if isinstance(member.type, Array)]@
// TODO: Array types are not supported
@[    elif isinstance(member.type, AbstractSequence)]@
// TODO: Sequence types are not supported
@[    elif isinstance(member.type, AbstractWString)]@
// TODO: Unicode types are not supported
@[    else]@
    public var @(get_field_name(type_name, member.name)) : @(get_swift_type(member.type, package_name))
@[    end if]@
@[end for]@
}

@[for ns in reversed(message.structure.namespaced_type.namespaces)]@
@[end for]@