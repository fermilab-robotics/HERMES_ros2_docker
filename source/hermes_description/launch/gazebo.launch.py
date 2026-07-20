from launch_ros.actions import Node
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, SetEnvironmentVariable, RegisterEventHandler
from launch.event_handlers import OnProcessExit
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.substitutions import FindPackageShare
from launch.conditions import IfCondition, UnlessCondition
from ament_index_python.packages import get_package_share_directory
import xacro
import os

def generate_launch_description():
    # ld = LaunchDescription()
    ros_gz_sim_pkg_path = get_package_share_directory('ros_gz_sim')
    gz_launch_path = PathJoinSubstitution([ros_gz_sim_pkg_path, 'launch', 'gz_sim.launch.py'])

    # Get the share/ directory of the current package
    share_dir = get_package_share_directory("hermes_description")
    urdf_path = os.path.join(share_dir, 'urdf', 'hermes.urdf.xacro')

    robot_description_config = xacro.process_file(urdf_path)
    robot_description = robot_description_config.toxml()

    rviz_config_file = os.path.join(share_dir, 'config', 'display.rviz')
    # default_rviz_config_path = PathJoinSubstitution([share_dir, 'rviz', 'display.rviz'])


    robot_state_publisher_node = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        parameters=[
            # Must use simulation time with gazebo
            {'robot_description': robot_description, 'use_sim_time': True}
        ]
    )

    world_path = os.path.join(share_dir, 'worlds', 'hermes_world.sdf')

    gazebo_sim = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(gz_launch_path),
        launch_arguments= {
            'gz_args': f'-r {world_path}',
            'on_exit_shutdown': 'true'
        }.items()
    )

    urdf_spawn_node = Node(
        package="ros_gz_sim",
        executable='create',
        arguments=[
            '-topic',
            'robot_description',
            '-name',
            'hermes',
            '-x', '0.0',
            '-y', '0.0',
            '-z', '0.5'
        ]         
    )

    # Diff_drive_spawner
    diff_drive_spawn_node = Node(
        package="controller_manager",
        executable="spawner",
        # Add this to wait for controller manager
        arguments=["diff_cont", "--controller-manager", "/controller_manager"]
    )

    joint_broad_spawn_node = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["joint_state_broadcaster", "--controller-manager", "/controller_manager"],
        remappings=[
            # Remap cmd_vel from the controller onto diff_cont/cmd_vel
            ('/cmd_vel', '/diff_cont/cmd_vel')
        ]
    )

     # Code for delaying a node (I haven't tested how effective it is)
    # 
#     # First add the below lines to imports
    # from launch.actions import RegisterEventHandler
    # from launch.event_handlers import OnProcessExit
    
    
    delayed_joint_broad_spawner = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=urdf_spawn_node,
            on_exit=[joint_broad_spawn_node],
        )
    )
   #  Then add the following below the current diff_drive_spawner
    delayed_diff_drive_spawner = RegisterEventHandler(
        event_handler=OnProcessExit(
            target_action=joint_broad_spawn_node,
            on_exit=[diff_drive_spawn_node],
        )
    )

    # Very important so we can control the robot in gazebo from ROS2
    bridge_params = os.path.join(share_dir, 'parameters', 'bridge_parameters.yml')

    gz_bridge = Node(
        package="ros_gz_bridge",
        executable="parameter_bridge",
        arguments=[
            '--ros-args',
            '-p',
            f'config_file:={bridge_params}',
        ],
        parameters=[{
         "qos_overrides./tf_static.publisher.durability": "transient_local"
        }],
        output="screen",
    )

    image_compression_node = Node(
        package="image_transport",
        executable="republish",
        name="image_transport",
          # Pass the transport types as positional CLI arguments
        arguments=["raw", "compressed"], 
        # Tell the node what topics to hook into
        remappings=[
            ("in", "/camera/image_raw"),
            ("out", "/camera/image_raw")
        ]
    )

    return LaunchDescription([
        # SetEnvironmentVariable(
        #     'GZ_SIM_RESOURCE_PATH',
        #     os.path.join(share_dir, 'models')
        # ),
        robot_state_publisher_node,
        gazebo_sim,
        gz_bridge,
        urdf_spawn_node,
        delayed_diff_drive_spawner,
        delayed_joint_broad_spawner,
        image_compression_node
    ])
