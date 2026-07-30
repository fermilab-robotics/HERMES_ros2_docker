#ifndef HERMES_HARDWARE_SYSTEM_HPP_
#define HERMES_HARDWARE_SYSTEM_HPP

#include <memory>
#include <string>
#include <vector>

#include "hardware_interface/handle.hpp"
#include "hardware_interface/hardware_info.hpp"
#include "hardware_interface/system_interface.hpp"
#include "hardware_interface/types/hardware_interface_return_values.hpp"
#include "rclcpp/clock.hpp"
#include "rclcpp/duration.hpp"
#include "rclcpp/macros.hpp"
#include "rclcpp/time.hpp"
#include "rclcpp_lifecycle/node_interfaces/lifecycle_node_interface.hpp"
#include "rclcpp_lifecycle/state.hpp"

#include "wheel.hpp"
#include "pico_comms.hpp"

namespace hermes_hardware
{
    class HermesSystemHardware : public hardware_interface::SystemInterface
    {

    public:
        RCLCPP_SHARED_PTR_DEFINITIONS(HermesSystemHardware)

        hardware_interface::CallbackReturn on_init(
            const hardware_interface::HardwareComponentInterfaceParams &params) override;

        hardware_interface::CallbackReturn on_configure(
            const rclcpp_lifecycle::State &previous_state) override;

        hardware_interface::CallbackReturn on_activate(
            const rclcpp_lifecycle::State &previous_state) override;

        hardware_interface::CallbackReturn on_deactivate(
            const rclcpp_lifecycle::State &previous_state) override;

        hardware_interface::return_type read(
            const rclcpp::Time &time, const rclcpp::Duration &period) override;

        hardware_interface::return_type write(
            const rclcpp::Time &time, const rclcpp::Duration &period) override;

    private:
        // Parameters for the DiffBot simulation
        double hw_start_sec_;
        double hw_stop_sec_;

        PicoComms comms_;
        std::string serial_port_;
        int baud_rate_;
        float loop_rate_; // how frequently ros2_control loops?
        int timeout_ms_ = 0; // timeout
        int enc_counts_per_rev_;
        Wheel wheel_l_;
        Wheel wheel_r_;
    };

} // namespace ros2_control_demo_example_2

#endif // ROS2_CONTROL_DEMO_EXAMPLE_2__DIFFBOT_SYSTEM_HPP_
