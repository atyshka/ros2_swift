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

Clone the following into your workspace along with this repo:

- `common_interfaces`
- `rcl_interfaces`
- `rosidl`
- `rosidl_default`s
- `test_interface_files`
- `unique_indentifier_msgs`

## Build

```bash
~$ colcon build --cmake-args " -GNinja" --event-handlers console_direct+
```
