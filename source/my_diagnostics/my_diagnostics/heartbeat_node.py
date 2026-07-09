import rclpy
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from diagnostic_updater import Updater, Heartbeat



class HeartbeatNode(Node):
    def __init__(self):
        super().__init__('heartbeat_node')

        self.updater = Updater(self)

        self.updater.setHardwareID('heartbeat_node')
        self.updater.add(Heartbeat())

def main():
    node = None

    try:
        rclpy.init()
        node = HeartbeatNode()
        rclpy.spin(node)
    except (KeyboardInterrupt, ExternalShutdownException):
        pass
    finally:
        if node is not None:
            node.destroy_node()
        
        if rclpy.ok():
            rclpy.shutdown()



if __name__ == '__main__':
    main()
