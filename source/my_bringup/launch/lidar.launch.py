import os

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
# from ament_index_python.packages import get_package_share_directory
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.substitutions import FindPackageShare
from launch.substitutions import PathJoinSubstitution


def generate_launch_description():

    lidar_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution([
                FindPackageShare('ldlidar_node'), # Package is called ldlidar_node
                'launch',
                'ldlidar_with_mgr.launch.py'
            ])
        )
    )

    return LaunchDescription([lidar_launch])