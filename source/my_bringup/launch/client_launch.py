from launch import LaunchDescription
from launch_ros.actions import Node


# To include launch files from another package: 
# https://youtube.com/watch?v=sl0exwcg3o8

from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource

from launch_ros.substitutions import FindPackageShare
from launch.substitutions import PathJoinSubstitution


def generate_launch_description():
    """Launch joystick and camera nodes"""

    # create a launch description object
    ld = LaunchDescription()

    # Find the teleop_twist_joy launch file
    teleop_twist_joy_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution(
                [
                FindPackageShare('teleop_twist_joy'), 
                'launch', 
                'teleop-launch.py'
                ]
            )
        ),
        launch_arguments={
            'joy_config': "xbox", # Switches button mappings to XBox
            # Optional: joy_dev, publish_stapmed_twist
        }.items()
    )

    ld.add_action(teleop_twist_joy_launch)

    return ld