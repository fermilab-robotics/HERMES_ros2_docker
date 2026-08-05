import os

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
# from ament_index_python.packages import get_package_share_directory
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.substitutions import FindPackageShare
from launch.substitutions import PathJoinSubstitution


def generate_launch_description():

    # For LIDAR
    # TODO: Fix: interferes with URDF
    # lidar_dir = get_package_share_directory('ldlidar_node')

    lidar_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution([
                'ldlidar_node',
                'launch',
                'ldlidar_with_mgr.launch.py'
            ])
        )
    )

    return LaunchDescription([lidar_launch])