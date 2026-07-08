from launch import LaunchDescription
from launch_ros.actions import Node, ComposableNodeContainer

# To use .yaml files:
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, LogInfo
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution

from launch.launch_description_sources import PythonLaunchDescriptionSource

from launch_ros.substitutions import FindPackageShare
from launch_ros.descriptions import ComposableNode

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

  # 1. Paths to configuration files
    ldlidar_config_path = os.path.join(
        get_package_share_directory('ldlidar_node'),
        'params',
        'ldlidar.yaml'
    )
    
    lc_mgr_config_path = os.path.join(
        get_package_share_directory('ldlidar_node'),
        'params',
        'lifecycle_mgr.yaml'
    )

    # spin up composable node container
    ldlidar_container = ComposableNodeContainer(
        name='ldlidar_container',
        namespace='',
        package='rclcpp_components',
        executable='component_container_isolated',
        composable_node_descriptions=[
            ComposableNode(
                package='ldlidar_component',
                plugin='ldlidar::LdLidarComponent', 
                name='ldlidar_node',
                parameters=[ldlidar_config_path],
                extra_arguments=[{'use_intra_process_comms': True}] # performance tweak
            )
        ],
        output='screen'
    )

    # 2. The core LiDAR driver node (launched directly as a standalone lifecycle node)
    ldlidar_node = Node(
        package='ldlidar_component',
        executable='ldlidar_component_node',
        name='ldlidar_node',
        output='screen',
        parameters=[ldlidar_config_path]
    )

    # 3. Nav2 Lifecycle Manager (to automatically configure and activate the node)
    lc_mgr_node = Node(
        package='nav2_lifecycle_manager',
        executable='lifecycle_manager',
        name='lifecycle_manager',
        output='screen',
        parameters=[lc_mgr_config_path]
    )

    ld.add_action(ldlidar_node)
    ld.add_action(lc_mgr_node)
    # Add nodes to launch description
    ld.add_action(motor_driver_node)
    ld.add_action(realsense_launch)

    return ld