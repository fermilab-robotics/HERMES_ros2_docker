import os

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from ament_index_python.packages import get_package_share_directory


def generate_launch_description():

    ld = LaunchDescription()

    bringup_package_dir = get_package_share_directory('my_bringup')

    # THE CAMERA
    camera_launch_path = os.path.join(bringup_package_dir, 'launch', 'camera.launch.py')

    camera_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            camera_launch_path
        )
    )

    ld.add_action(camera_launch)

    # THE DRIVE SYSTEM
    description_package_dir = get_package_share_directory('hermes_description')

    drive_system_launch_path = os.path.join(description_package_dir, 'launch', 'hermes.launch.py')

    drive_system_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            drive_system_launch_path
        )
    )

    ld.add_action(drive_system_launch)

    return ld