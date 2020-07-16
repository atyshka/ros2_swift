cmake_minimum_required(VERSION 3.5)

project(rclswift_common C Swift)

find_package(ament_cmake REQUIRED)

add_library(RclSwiftCommon
  SHARED
  "Interfaces.swift"
)
install(TARGETS RclSwiftCommon DESTINATION lib/${PROJECT_NAME}/swift)

ament_package()
