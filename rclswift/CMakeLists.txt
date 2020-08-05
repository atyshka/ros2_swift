cmake_minimum_required(VERSION 3.15.1)

project(rclswift LANGUAGES C Swift)

find_package(ament_cmake REQUIRED)
find_package(rcl REQUIRED)
find_package(rcl_interfaces REQUIRED)
find_package(rmw REQUIRED)
find_package(rmw_implementation REQUIRED)
find_package(rmw_implementation_cmake REQUIRED)
find_package(rosidl_generator_c REQUIRED)

set(SWIFT_SOURCES
  "Sources/Context.swift"
  "Sources/Utils/ErrorHandling.swift"
  "Sources/Utils/Capsule.swift"
)

add_library(${PROJECT_NAME} 
  SHARED
  ${SWIFT_SOURCES}
)

set_target_properties(${PROJECT_NAME} PROPERTIES Swift_MODULE_DIRECTORY modules)
set_target_properties(${PROJECT_NAME} PROPERTIES Swift_MODULE_NAME RclSwift)

target_include_directories(${PROJECT_NAME} PUBLIC  
$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>  
$<INSTALL_INTERFACE:modules> )

target_include_directories(${PROJECT_NAME} PUBLIC  
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/modules>  
  $<INSTALL_INTERFACE:modules>)

ament_target_dependencies(${PROJECT_NAME} rcl)

add_executable(Test "Executables/Test.swift")
target_link_libraries(Test ${PROJECT_NAME})

ament_export_dependencies(ament_cmake)
ament_export_dependencies(builtin_interfaces)
ament_export_dependencies(rcl)
ament_export_dependencies(rosidl_generator_c)
ament_export_dependencies(rosidl_typesupport_c)

install(
  TARGETS Test
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib/${PROJECT_NAME}
)

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
