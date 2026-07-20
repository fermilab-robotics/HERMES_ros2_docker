from launch_ros.actions import Node
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, SetEnvironmentVariable, RegisterEventHandler
from launch.event_handlers import OnProcessStart
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.substitutions import FindPackageShare
from launch.conditions import IfCondition, UnlessCondition
from ament_index_python.packages import get_package_share_directory
import xacro
import os

def generate_launch_description():
    # ld = LaunchDescription()

    # Get the share/ directory of the current package
    share_dir = get_package_share_directory("hermes_description")

    # Process urdf / xacro
    urdf_path = os.path.join(share_dir, 'urdf', 'hermes.urdf.xacro')
    robot_description_config = xacro.process_file(urdf_path)
    robot_description = robot_description_config.toxml()

    # Path to controller configuration files
    controller_params_file = os.path.join(share_dir, 'config', 'my_controllers.yaml')


    # Robot state publisher (sends URDF to robot_description"
    robot_state_publisher_node = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        parameters=[
            # Must use simulation time with gazebo
            {'robot_description': robot_description}
        ]
    )

    controller_manager_node = Node(
        package='controller_manager',
        executable="ros2_control_node",
        parameters=[robot_description, controller_params_file],
        output="screen"
    )

    # Diff_drive_spawner
    diff_drive_spawn_node = Node(
        package="controller_manager",
        executable="spawner",
        # Add this to wait for controller manager
        arguments=["diff_cont", "--controller-manager", "/controller_manager"],
        output='screen'
    )

    joint_broad_spawn_node = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["joint_state_broadcaster", "--controller-manager", "/controller_manager"],
        output='screen'
    )

    # Wait for the controller manager to startup
    delayed_spawners = RegisterEventHandler(
        event_handler=OnProcessStart(
            target_action=controller_manager_node,
            on_start=[joint_broad_spawn_node, diff_drive_spawn_node],
        )
    )


    return LaunchDescription([
        robot_state_publisher_node,
        controller_manager_node,
        delayed_spawners,
    ])