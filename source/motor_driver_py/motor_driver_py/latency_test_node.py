import rclpy
from rclpy.node import Node
from std_msgs.msg import String
import time, csv, sys

class LatencyTestNode(Node):
    def __init__(self, distance_label, n_trials=20):
        super().__init__('latency_test_node')
        self.pub = self.create_publisher(String, '/latency_ping', 10)
        self.sub = self.create_subscription(String, '/latency_pong', self.on_pong, 10)
        self.distance_label = distance_label
        self.n_trials = n_trials
        self.results = []
        self.pending_id = None
        self.t0 = None
        self.timer = self.create_timer(0.5, self.send_ping)  # one ping every 0.5s

    def send_ping(self):
        if len(self.results) >= self.n_trials:
            self.save_and_exit()
            return
        self.pending_id = str(time.time())
        self.t0 = time.perf_counter()
        msg = String()
        msg.data = self.pending_id
        self.pub.publish(msg)

    def on_pong(self, msg):
        if msg.data == self.pending_id:
            latency_ms = (time.perf_counter() - self.t0) * 1000
            self.results.append(latency_ms)
            print(f"Trial {len(self.results)}: {latency_ms:.1f} ms")
            self.pending_id = None

    def save_and_exit(self):
        with open('latency_results.csv', 'a', newline='') as f:
            writer = csv.writer(f)
            for r in self.results:
                writer.writerow([self.distance_label, r])
        print(f"Saved {len(self.results)} trials at distance={self.distance_label}")
        rclpy.shutdown()

def main():
    distance = sys.argv[1] if len(sys.argv) > 1 else 'unknown'
    rclpy.init()
    node = LatencyTestNode(distance_label=distance)
    rclpy.spin(node)

if __name__ == '__main__':
    main()