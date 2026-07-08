from launch import LaunchDescription
from launch_ros.actions import Node

# To use .yaml files:
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, LogInfo
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution

from launch.launch_description_sources import PythonLaunchDescriptionSource

from launch_ros.substitutions import FindPackageShare

from ament_index_python.packages import get_package_share_directory

import os

def generate_launch_description():
    """Launch robot motor driver and camera feed with proper launch configuration"""
    # 
    # create a launch description object
    ld = LaunchDescription()

    # Create a dynamic (future) object that will have value at runtime
    config_file = LaunchConfiguration('bringup_config_file')

    # Note: our launch argument cannot conflct with realsense2_camear's launch file
    config_file_arg = DeclareLaunchArgument(
        'bringup_config_file',
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
    # for debugging
    ld.add_action(LogInfo(msg=config_path))


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

    realsense_dir = get_package_share_directory('realsense2_camera')
    # realsense node
    realsense_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(realsense_dir, 'launch', 'rs_launch.py')
        ),
        launch_arguments={
            'enable_color': 'true',
            'enable_image_transport_plugins': 'true'
        }.items()
    )

    # For LIDAR
    lidar_dir = get_package_share_directory('ldrobot-lidar-ros2')

    lidar_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(lidar_dir, 'launch', 'ldlidar_with_mgr.launch.py'),
        )
    )

    # Add nodes to launch description
    ld.add_action(motor_driver_node)
    ld.add_action(realsense_launch)
    ld.add_action(lidar_launch)

    return ld