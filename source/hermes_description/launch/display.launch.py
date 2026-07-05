from launch_ros.actions import Node
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.substitutions import FindPackageShare

from ament_index_python.packages import get_package_share_directory
import xacro
import os

def generate_launch_description():
    # ld = LaunchDescription()

    # Get the share/ directory of the current package
    share_dir = get_package_share_directory("hermes_description")
    urdf_path = os.path.join(share_dir, 'urdf', '01-myfirst.urdf')

    robot_description_config = xacro.process_file(urdf_path)
    robot_description = robot_description_config.toxml()

    # default_rviz_config_path = PathJoinSubstitution([share_dir, 'rviz', 'display.rviz'])

    robot_state_publisher_node = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        parameters=[
            {'robot_description': robot_description}
        ]
    )

    joint_state_publisher_node = Node(
        package='joint_state_publisher',
        executable='joint_state_publisher',
        name='joint_state_publisher'
    )

    rviz_node = Node(
        package='rviz2',
        executable='rviz2',
        output='screen',
        # arguments=['-d', rviz_config_file]
    )

    return LaunchDescription([
        robot_state_publisher_node,
        joint_state_publisher_node,
        rviz_node
    ])
