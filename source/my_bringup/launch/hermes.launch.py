import os

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.substitutions import FindPackageShare
from launch.substitutions import PathJoinSubstitution


def generate_launch_description():

    # ld = LaunchDescription()

    # bringup_package_dir = get_package_share_directory('my_bringup')

    # THE CAMERA
    # camera_launch_path = os.path.join(bringup_package_dir, 'launch', 'camera.launch.py')

    camera_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution([
                FindPackageShare("my_bringup"),
                'launch',
                'camera.launch.py'
            ])
        )
    )

    # THE DRIVE SYSTEM
    # description_package_dir = get_package_share_directory('hermes_description')

    # drive_system_launch_path = os.path.join(description_package_dir, 'launch', 'hermes.launch.py')

    drive_system_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution([
                FindPackageShare("hermes_description"),
                "launch",
                "drive.launch.py"
            ])
        )
    )

    lidar_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution([
                FindPackageShare("my_bringup"),
                "launch",
                "lidar.launch.py"
            ])
        )
    )

    return LaunchDescription([
        camera_launch,
        drive_system_launch,
        lidar_launch
    ])