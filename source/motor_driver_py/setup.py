from setuptools import find_packages, setup

package_name = 'motor_driver_py'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    package_data={'': ['py.typed']},
    install_requires=[
        'setuptools',
        'python3-lgpio',
        'python3-gpiozero'
        ],
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
            "motor_subscriber = motor_driver_py.motor_subscriber:main",
        ],
    },
)
