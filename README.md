# Build instructions:

Download a swift toolchain from swift.org, installing to /opt/swift and add to $PATH

## Install Ninja via apt or homebrew

For Ubuntu:

```bash
~$ sudo apt install ninja
```

For macOS:

```bash
~$ brew install ninja
```

## Additional Dependencies

This repo currently requires a few packages to be built from source in order to build the swift versions. Also using forked versions of sensor_msgs and test_msgs since currently linker language is problematic when using tests.

Dependencies are in the repos file and easily installable with vcs:
```
curl -sk https://raw.githubusercontent.com/atyshka/ros2_swift/master/ros2_swift.repos -o ros2_swift.repos
vcs import ~/ros2/src/ < rclswift.repos
```
Choose the source directory of your colcon workspace, in my case ros2/src

## Build

```bash
~$ colcon build --cmake-args " -GNinja" --event-handlers console_direct+
```
