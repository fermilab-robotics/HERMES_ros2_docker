import os

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription

from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource

from launch_ros.substitutions import FindPackageShare
from launch.substitutions import PathJoinSubstitution

from launch.actions import GroupAction
from launch_ros.actions import SetRemap


def generate_launch_description():

    ld = LaunchDescription()

    joy_params = os.path.join(get_package_share_directory('my_bringup'), 'config', 'joystick.yaml')


    # Find the teleop_twist_joy launch file
    teleop_twist_joy_launch = GroupAction(
        actions = [
            # remap original topic '/cmd_vel' to '/diff_cont/cmd_vel'
            SetRemap(src='/cmd_vel', dst='/diff_cont/cmd_vel'),
            
            IncludeLaunchDescription(
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
                    'joy_config': 'xbox',
                    # 'config_filepath': joy_params,
                    'require_enable_button': 'false', # don't require confirm button
                    'publish_stamped_twist': 'true' # wasn't working in yaml for some reason
                    #'joy_config': "xbox", # Switches button mappings to XBox
                    # Optional: joy_dev, publish_stapmed_twist
                }.items()
            )
        ]
    )

    ld.add_action(teleop_twist_joy_launch)

    return ld