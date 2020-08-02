cmake_minimum_required(VERSION 3.15.1)

project(rclswift LANGUAGES C Swift)

find_package(ament_cmake REQUIRED)
find_package(rcl REQUIRED)
find_package(rcl_interfaces REQUIRED)
find_package(rmw REQUIRED)
find_package(rmw_implementation REQUIRED)
find_package(rmw_implementation_cmake REQUIRED)
find_package(rosidl_generator_c REQUIRED)

if(NOT WIN32)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,error")
  endif()
endif()

set(SWIFT_SOURCES
  "Sources/Context.swift"
  "Sources/Utils/ErrorHandling.swift"
  "Sources/Utils/Capsule.swift"
)

add_library(RclSwift 
  SHARED
  ${SWIFT_SOURCES}
)

target_include_directories(RclSwift PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR})

ament_target_dependencies(RclSwift rcl)

ament_export_dependencies(ament_cmake)
ament_export_dependencies(builtin_interfaces)
ament_export_dependencies(rcl)
ament_export_dependencies(rosidl_generator_c)
ament_export_dependencies(rosidl_typesupport_c)

ament_package()
