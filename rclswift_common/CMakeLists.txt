cmake_minimum_required(VERSION 3.15.1)

project(rclswift_common Swift)

find_package(ament_cmake REQUIRED)

add_library(${PROJECT_NAME}
  "swift/Interfaces.swift"
)

set_target_properties(${PROJECT_NAME} PROPERTIES Swift_MODULE_DIRECTORY modules)
set_target_properties(${PROJECT_NAME} PROPERTIES Swift_MODULE_NAME RclSwiftCommon)

target_include_directories(${PROJECT_NAME} PUBLIC  
$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>  
$<INSTALL_INTERFACE:modules> )

install(
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

install(
  DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules/
  DESTINATION modules
)

ament_export_targets(${PROJECT_NAME} HAS_LIBRARY_TARGET)

ament_package()
