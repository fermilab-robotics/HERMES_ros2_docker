## Useful links

[SD format spec](https://sdformat.org/spec)

To test ros2_control:
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args --remap /cmd_vel:=/diff_cont/cmd_vel -p stamped:=true
