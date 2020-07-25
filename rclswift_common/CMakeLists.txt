cmake_minimum_required(VERSION 3.15.1)

project(rclswift_common Swift)

find_package(ament_cmake REQUIRED)

add_library(RclSwiftCommon
  "swift/Interfaces.swift"
)

set_target_properties(RclSwiftCommon PROPERTIES Swift_MODULE_DIRECTORY modules)

target_include_directories(RclSwiftCommon PUBLIC  
$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>  
$<INSTALL_INTERFACE:modules> )

install(
  TARGETS RclSwiftCommon
  EXPORT RclSwiftCommon
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

install(
  DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules/
  DESTINATION modules
)

ament_export_targets(RclSwiftCommon HAS_LIBRARY_TARGET)

ament_package()
