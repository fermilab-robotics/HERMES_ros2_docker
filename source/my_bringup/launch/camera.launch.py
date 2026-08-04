import os

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from ament_index_python.packages import get_package_share_directory
from launch.launch_description_sources import PythonLaunchDescriptionSource


def generate_launch_description():
    ld = LaunchDescription()

    realsense_dir = get_package_share_directory('realsense2_camera')
    # realsense node
    realsense_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(realsense_dir, 'launch', 'rs_launch.py')
        ),
        launch_arguments={
            'enable_color': 'true',
            'enable_image_transport_plugins': 'true',
            'enable_depth': 'false',
            # 30fps, 720p
            'rgb_camera.color_profile': '1280x720x30',
            
            # Force the raw publisher to use Best Effort (Stops the network from getting stuck)
            'qos_overrides./camera/camera/color/image_raw.publisher.reliability': 'best_effort',
            
            # Force the compressed publisher to use Best Effort
            'qos_overrides./camera/camera/color/image_raw/compressed.publisher.reliability': 'best_effort',
        }.items()
    )

    ld.add_action(realsense_launch)

    return ld