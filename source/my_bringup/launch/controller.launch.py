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

    rqt_image_view_node = Node(
        package='rqt_image_view',
        executable='rqt_image_view',
        name='rqt_image_view',
        arguments=['--ros-args', '-p', 'qos_overrides./camera/camera/color/image_raw/compressed.subscriber.reliability:=best_effort', '-p', 'image_transport:=compressed'],
        output='screen'
    )

    rviz2_config = PathJoinSubstitution([
        FindPackageShare('my_bringup'),
        'config',
        'controller.rviz'
    ])

    rviz2_node = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        output='screen',
        arguments=[["-d"], [rviz2_config]]
    )

    ld.add_action(rviz2_node)

    ld.add_action(rqt_image_view_node)


    joystick_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            PathJoinSubstitution([
                FindPackageShare("my_bringup"),
                "launch",
                "joystick.launch.py"
            ])
        )
    )

    ld.add_action(joystick_launch)

    # Find the teleop_twist_joy launch file
    # teleop_twist_joy_launch = IncludeLaunchDescription(
    #     PythonLaunchDescriptionSource(
    #         PathJoinSubstitution(
    #             [
    #             FindPackageShare('teleop_twist_joy'), 
    #             'launch', 
    #             'teleop-launch.py'
    #             ]
    #         )
    #     ),
    #     launch_arguments={
    #         'joy_config': "xbox", # Switches button mappings to XBox
    #         # Optional: joy_dev, publish_stapmed_twist
    #     }.items()
    # )


    # ld.add_action(teleop_twist_joy_launch)

    return ld