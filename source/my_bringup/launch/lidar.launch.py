import os

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from ament_index_python.packages import get_package_share_directory
from launch.launch_description_sources import PythonLaunchDescriptionSource

def generate_launch_description():

    ld = LaunchDescription()

    # For LIDAR
    # TODO: Fix: interferes with URDF
    lidar_dir = get_package_share_directory('ldlidar_node')

    lidar_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(lidar_dir, 'launch', 'ldlidar_with_mgr.launch.py'),
        )
    )

    ld.add_action(lidar_launch)

    return ld