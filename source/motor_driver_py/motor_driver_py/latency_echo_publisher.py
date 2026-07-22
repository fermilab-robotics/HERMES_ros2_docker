import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class LatencyEchoNode(Node):
    def __init__(self):
        super().__init__('latency_echo_node')
        self.sub = self.create_subscription(String, '/latency_ping', self.callback, 10)
        self.pub = self.create_publisher(String, '/latency_pong', 10)

    def callback(self, msg):
        self.pub.publish(msg)  # bounce it straight back, unchanged

def main():
    rclpy.init()
    rclpy.spin(LatencyEchoNode())
    rclpy.shutdown()

if __name__ == '__main__':
    main()