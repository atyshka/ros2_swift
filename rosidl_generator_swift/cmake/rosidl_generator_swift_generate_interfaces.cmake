# Copyright 2016-2018 Esteve Fernandez <esteve@apache.org>
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

find_package(rmw_implementation_cmake REQUIRED)
find_package(rmw REQUIRED)
find_package(rosidl_generator_c REQUIRED)
find_package(rosidl_typesupport_c REQUIRED)
find_package(rosidl_typesupport_interface REQUIRED)
find_package(rclswift_common REQUIRED)

enable_language(Swift)
set(CMAKE_Swift_LINKER_PREFERENCE 0)
# Get a list of typesupport implementations from valid rmw implementations.
rosidl_generator_swift_get_typesupports(_typesupport_impls)

if(_typesupport_impls STREQUAL "")
  message(WARNING "No valid typesupport for Swift generator. Swift messages will not be generated.")
  return()
endif()

set(_output_path
  "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_swift/${PROJECT_NAME}")
set(_generated_swift_files "")
set(_generated_modulemap_files "")
set(_generated_c_ts_files "")
set(_generated_h_files "")

foreach(_abs_idl_file ${rosidl_generate_interfaces_ABS_IDL_FILES})
  get_filename_component(_parent_folder "${_abs_idl_file}" DIRECTORY)
  get_filename_component(_parent_folder "${_parent_folder}" NAME)

  get_filename_component(_idl_name "${_abs_idl_file}" NAME_WE)
  string_camel_case_to_lower_case_underscore("${_idl_name}" _module_name)

  if(_parent_folder STREQUAL "msg")
    list(APPEND _generated_swift_files
      "${_output_path}/${_parent_folder}/${_module_name}.swift"
      )

    list(APPEND _generated_h_files
      "${_output_path}/${_parent_folder}/rclswift_${_module_name}.h"
      )

    list(APPEND _generated_c_ts_files
      "${_output_path}/${_parent_folder}/${_module_name}.c"
      )
  elseif(_parent_folder STREQUAL "srv")
  elseif(_parent_folder STREQUAL "action")
  else()
    message(FATAL_ERROR "Interface file with unknown parent folder: ${_idl_file}")
  endif()
endforeach()

list(APPEND _generated_modulemap_files
"${_output_path}/module.modulemap"
)

set(_dependency_files "")
set(_dependencies "")
foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
  foreach(_idl_file ${${_pkg_name}_IDL_FILES})
    set(_abs_idl_file "${${_pkg_name}_DIR}/../${_idl_file}")
    normalize_path(_abs_idl_file "${_abs_idl_file}")
    list(APPEND _dependency_files "${_abs_idl_file}")
    list(APPEND _dependencies "${_pkg_name}:${_abs_idl_file}")
  endforeach()
endforeach()

set(target_dependencies
  "${rosidl_generator_swift_BIN}"
  ${rosidl_generator_swift_GENERATOR_FILES}
  "${rosidl_generator_swift_TEMPLATE_DIR}/idl.h.em"
  "${rosidl_generator_swift_TEMPLATE_DIR}/idl.c.em"
  "${rosidl_generator_swift_TEMPLATE_DIR}/idl.swift.em"
  "${rosidl_generator_swift_TEMPLATE_DIR}/idl.modulemap.em"
  "${rosidl_generator_swift_TEMPLATE_DIR}/msg.h.em"
  "${rosidl_generator_swift_TEMPLATE_DIR}/msg.c.em"
  "${rosidl_generator_swift_TEMPLATE_DIR}/msg.swift.em"
  "${rosidl_generator_swift_TEMPLATE_DIR}/srv.swift.em"
  ${rosidl_generate_interfaces_ABS_IDL_FILES}
  ${_dependency_files})
foreach(dep ${target_dependencies})
  if(NOT EXISTS "${dep}")
    message(FATAL_ERROR "Target dependency '${dep}' does not exist")
  endif()
endforeach()

set(generator_arguments_file "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_swift__arguments.json")
rosidl_write_generator_arguments(
  "${generator_arguments_file}"
  PACKAGE_NAME "${PROJECT_NAME}"
  IDL_TUPLES "${rosidl_generate_interfaces_IDL_TUPLES}"
  ROS_INTERFACE_DEPENDENCIES "${_dependencies}"
  OUTPUT_DIR "${_output_path}"
  TEMPLATE_DIR "${rosidl_generator_swift_TEMPLATE_DIR}"
  TARGET_DEPENDENCIES ${target_dependencies}
)

set(_target_suffix "__swift")

set_property(
  SOURCE
  ${_generated_swift_files} ${_generated_modulemap_files} ${_generated_h_files} ${_generated_c_ts_files}
  PROPERTY GENERATED 1)

# This if is only needed because srvs/actions are currently skipped
if(_generated_swift_files)
  add_custom_command(
    OUTPUT ${_generated_swift_files} ${_generated_modulemap_files} ${_generated_h_files} ${_generated_c_ts_files}
    COMMAND ${PYTHON_EXECUTABLE} ${rosidl_generator_swift_BIN}
    --generator-arguments-file "${generator_arguments_file}"
    --typesupport-impls "${_typesupport_impls}"
    DEPENDS ${target_dependencies}
    COMMENT "Generating Swift code for ROS interfaces"
    VERBATIM
  )

  if(TARGET ${rosidl_generate_interfaces_TARGET}${_target_suffix})
    message(WARNING "Custom target ${rosidl_generate_interfaces_TARGET}${_target_suffix} already exists")
  else()
    add_custom_target(
      ${rosidl_generate_interfaces_TARGET}${_target_suffix}
      DEPENDS
      ${_generated_swift_files}
      ${_generated_modulemap_files}
      ${_generated_h_files}
      ${_generated_c_ts_files}
    )
  endif()
endif()

macro(set_properties _build_type)
  set_target_properties(${_target_name} PROPERTIES
    COMPILE_OPTIONS "${_extension_compile_flags}"
    LIBRARY_OUTPUT_DIRECTORY${_build_type} ${_output_path}
    RUNTIME_OUTPUT_DIRECTORY${_build_type} ${_output_path}
    OUTPUT_NAME ${_target_name}_native)
endmacro()

# This if is only needed because srvs/actions are currently skipped
if(_generated_c_ts_files)
  set(_swiftext_suffix "__swiftext")
  set(_target_name "${rosidl_generate_interfaces_TARGET}${_swiftext_suffix}")
  add_library(${_target_name} SHARED
    "${_generated_c_ts_files}"
    "${_generated_h_files}"
  )
  add_dependencies(
    ${_target_name}
    ${rosidl_generate_interfaces_TARGET}${_target_suffix}
    ${rosidl_generate_interfaces_TARGET}__rosidl_typesupport_c
  )
  
  set_target_properties(${_target_name} PROPERTIES LINKER_LANGUAGE C)

  target_link_libraries(
    ${_target_name}
    ${PROJECT_NAME}__rosidl_typesupport_c
  )
  target_include_directories(${_target_name}
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_c>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_swift>
  )

  rosidl_target_interfaces(${_target_name}
    ${rosidl_generate_interfaces_TARGET} rosidl_typesupport_c)

  ament_target_dependencies(${_target_name}
    "rosidl_generator_c"
    "rosidl_typesupport_c"
    "rosidl_typesupport_interface"
  )
  foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
    ament_target_dependencies(${_target_name}
      ${_pkg_name}
    )
  endforeach()

  ament_target_dependencies(${_target_name}
    "rosidl_generator_c"
    "rosidl_generator_swift"
  )

  get_target_property(OUT ${_target_name} LINK_LIBRARIES)
  message(STATUS "Link paths:")
  message(STATUS ${rclswift_common_LIBRARIES})

  add_library(${PROJECT_NAME}_swift SHARED ${_generated_swift_files} ${_generated_modulemap_files})
  set(EMPTY_COMPILE_FLAGS "")
  set_target_properties(${PROJECT_NAME}_swift PROPERTIES COMPILE_OPTIONS "${EMPTY_COMPILE_FLAGS}")
  set_target_properties(${PROJECT_NAME}_swift PROPERTIES Swift_MODULE_DIRECTORY modules)
  set_target_properties(${PROJECT_NAME}_swift PROPERTIES Swift_MODULE_NAME ${PROJECT_NAME})
  target_include_directories(${PROJECT_NAME}_swift PUBLIC  
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>  
    $<INSTALL_INTERFACE:modules> 
  )
  target_link_libraries(${PROJECT_NAME}_swift ${_target_name})

  ament_target_dependencies(${PROJECT_NAME}_swift rclswift_common)
  foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
    message(STATUS "Adding dependency: ${_pkg_name}")
    ament_target_dependencies(${PROJECT_NAME}_swift
      ${_pkg_name}
    )
  endforeach()


  if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
    install(TARGETS ${PROJECT_NAME}_swift ${_target_name}
      EXPORT ${PROJECT_NAME}_swift
      ARCHIVE DESTINATION lib
      LIBRARY DESTINATION lib
      RUNTIME DESTINATION bin
    )

    install(
      DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules/
      DESTINATION modules
    )

    ament_export_targets(${PROJECT_NAME}_swift)

  endif()
endif()

if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
  if(NOT _generated_h_files STREQUAL "")
    install(
      FILES ${_generated_h_files}
      DESTINATION "include/${PROJECT_NAME}/msg"
    )
  endif()
endif()