# Build instructions:

Download a swift toolchain from swift.org, installing to /opt/swift and add to $PATH

Install Ninja via Apt

Clone common_interfaces, rcl_interfaces, rosidl, rosidl_defaults, test_interface_files, and unique_indentifier_msgs into workspace along with this repo

Build with:
colcon build --cmake-args " -GNinja" --event-handlers console_direct+
