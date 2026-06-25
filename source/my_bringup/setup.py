from setuptools import find_packages, setup

package_name = 'my_bringup'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        ('share/' + package_name + '/launch', [
            'launch/client_launch.py',
            'launch/server_launch.py',
        ]),
        ('share/' + package_name + '/config', [
            'config/hermes_launch.yaml',
            'config/rvr_launch.yaml',
        ])
    ],
    package_data={'': ['py.typed']},
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='Rayyan Khan',
    maintainer_email='rayyanmhkhan@gmail.com',
    description='TODO: Package description',
    license='TODO: License declaration',
    extras_require={
        'test': [
            'pytest',
        ],
    },
    entry_points={
        'console_scripts': [
        ],
    },
)
