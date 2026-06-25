import rclpy
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node

# For Motor Driver Speed Messages
from geometry_msgs.msg import Twist

# Note: the original Rpi.GPIO library does not work on the Pi 5!
from gpiozero import PhaseEnableMotor
from utils_py.gpio_fix import patch_gpiozero


def _clamp(value, minimum, maximum):
    """Ensures value is in between minimum and maximum"""
    if value < minimum:
        return minimum
    elif value > maximum:
        return maximum
    else:
        return value
    
class MotorSubscriber(Node):
    """Subscriber that listens for Twist messages from server and drives motors via GPIO"""

    def __init__(self):
        """Constructor"""

        # Call the parent node class constructor with the node name
        super().__init__('motor_subscriber')

        patch_gpiozero()

 

        # Declare parameters

        # The pin numbers
        self.declare_parameter('motor_pin_left', 5)
        self.declare_parameter('motor_pin_right', 6)

        self.declare_parameter('pwm_pin_left', 20)
        self.declare_parameter('pwm_pin_right', 19)

        # The track width is around 0.33 meters
        self.declare_parameter('track_width', 0.33)
        self.declare_parameter('max_speed', 1.0)

        # Set to attributes
        self._track_width = self.get_parameter('track_width').value
        self._max_speed = self.get_parameter('max_speed').value

        # Get GPIO pin numbers: Use python convention of _ for member variables, and Capital for pins
        self._motor_pin_left = self.get_parameter('motor_pin_left').value # The right-hand set of motors
        self._motor_pin_right = self.get_parameter('motor_pin_right').value

        self._pwm_pin_left = self.get_parameter('pwm_pin_left').value
        self._pwm_pin_right = self.get_parameter('pwm_pin_right').value

        self._left_motor = PhaseEnableMotor(phase=self._motor_pin_left, enable=self._pwm_pin_left, pwm=True)
        self._right_motor = PhaseEnableMotor(phase=self._motor_pin_right, enable=self._pwm_pin_right, pwm=True)

        self._left_pwm_speed = 0
        self._right_pwm_speed = 0

        # Create a subscriber object
        # note that we must subscribe to cmd_vel, not sometihng else
        self._subscription = self.create_subscription(Twist, 'cmd_vel', self._velocity_received_callback, 10)

    
    def _velocity_received_callback(self, twist_msg):
        """Drives motors according to speed and direction"""
        self.get_logger().info(f"Received twist command. Linear X: {twist_msg.linear.x} Angular Z: {twist_msg.angular.z}")

        # Extract linear and angular speeds from the message
        linear = twist_msg.linear.x
        angular = -twist_msg.angular.z * 5 # Scale angular velocity

        # Calculate wheel speeds in m/s
        left_speed = linear - angular * self._track_width / 2
        right_speed = linear + angular * self._track_width / 2

        # Calculate duty cycle (-1 to 1)
        left_speed_pwm = _clamp(left_speed / self._max_speed, -1.0, 1.0)
        right_speed_pwm = _clamp(right_speed / self._max_speed, -1.0, 1.0)

        # DEBUG: Check pwm values
        self.get_logger().info(f"Left Speed: {left_speed_pwm}, Right speed: {right_speed_pwm}")
        
        # TODO: Replace with state table?

        # Motion
        # the forward() method can only accept values between 0 and 1
        if left_speed_pwm >= 0:
            self._left_motor.backward(left_speed_pwm)
        else:
            self._left_motor.forward(-left_speed_pwm)

        if right_speed_pwm >= 0:
            self._right_motor.forward(right_speed_pwm)
        else:
            self._right_motor.backward(-right_speed_pwm)


    def _stop_motors(self):
        self._left_motor.stop()
        self._right_motor.stop()
        
        

def main(args=None):
    """Main entrypoint"""

    # Initialize node to None first
    node = None
    # Initialize and run node
    try:
        rclpy.init()
        node = MotorSubscriber()
        rclpy.spin(node)

    except (KeyboardInterrupt, ExternalShutdownException):
        pass

    # Destroy node and gracefully exit
    finally:
        if node is not None:
            # shutting down motors
            node._stop_motors()
            node.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()

if __name__ == "__main__":
    main()