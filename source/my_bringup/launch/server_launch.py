from launch import LaunchDescription
from launch_ros.actions import Node

# To use .yaml files:
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution

from launch_ros.substitutions import FindPackageShare

def generate_launch_description():
    """Launch robot motor driver and camera feed with proper launch configuration"""
    # 
    # create a launch description object
    ld = LaunchDescription()

    # Create a dynamic (future) object that will have value at runtime
    config_file = LaunchConfiguration('config_file')

    config_file_arg = DeclareLaunchArgument(
        'config_file',
        default_value='hermes_launch.yaml',
        description="Which configuartion YAML to load (hermes_launch or rvr_launch)"
    )

    # Build the full path to the config file at runtime
    config_path = PathJoinSubstitution([
        FindPackageShare('my_bringup'),
        'config',
        config_file
    ])

    # Add argument to launch description
    ld.add_action(config_file_arg)


    motor_driver_node = Node(
        package='motor_driver_py',
        executable='motor_subscriber',
        name='motor_driver_subscriber',
        parameters=[config_path]
    )

    # camera_node
    # camera_node = Node(
    #     package='camera_ros',
    #     executable='camera_node',
    #     name='camera_node',
    #     parameters=[config_path]
    # )

    # ld.add_action(camera_node)

    # realsense node
    realsense_node = Node(
        package='realsense2_camera',
        executable='realsense2_camera_node',
        name='realsense2_camera_node',
        parameters=[config_path]
    )

    # Add nodes to launch description
    ld.add_action(motor_driver_node)
    ld.add_action(realsense_node)
    
    return ld