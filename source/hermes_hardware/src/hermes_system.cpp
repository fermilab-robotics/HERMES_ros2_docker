#include "hermes_system.hpp"

#include <chrono>
#include <cmath>
#include <cstddef>
#include <iomanip>
#include <limits>
#include <memory>
#include <sstream>
#include <vector>

#include "hardware_interface/lexical_casts.hpp"
#include "hardware_interface/types/hardware_interface_type_values.hpp"
#include <hardware_interface/macros.hpp>
#include "rclcpp/rclcpp.hpp"

#include "pico_comms.hpp"

// Note: export_state_interfaces() and export_command_interfaces() are now auto_done! no need to manually create!
namespace hermes_hardware
{
    hardware_interface::CallbackReturn HermesSystemHardware::on_init(
        const hardware_interface::HardwareComponentInterfaceParams &params)
    {
        // Initialize: Startup the robot, if can't, it's ok
        if (
            hardware_interface::SystemInterface::on_init(params) !=
            hardware_interface::CallbackReturn::SUCCESS)
        {
            return hardware_interface::CallbackReturn::ERROR;
        }

        hw_start_sec_ = hardware_interface::stod(info_.hardware_parameters["example_param_hw_start_duration_sec"]);
        hw_stop_sec_ = hardware_interface::stod(info_.hardware_parameters["example_param_hw_stop_duration_sec"]);

        serial_port_ = info_.hardware_parameters["serial_port"];

        // comms_;
        baud_rate_ = hardware_interface::stoi32(info_.hardware_parameters["baud_rate"]);
        loop_rate_ = hardware_interface::stof(info_.hardware_parameters["loop_rate"]);
        timeout_ms_ = hardware_interface::stoi32(info_.hardware_parameters["timeout_ms"]);
        // encoder_counts_per_rev_ = hardware_interface::stoi32(info_hardware_parameters["encoder_counts_per_rev"])

        

        // float loop_rate_;
        // int timeout_ms_ = 0;
        // int enc_counts_per_rev_;
        
        //The aslong has a 1:30 gear reduction ratio, and 11 PPR (pulses per revolution), so 1320 CPR with 4x decoding
        wheel_l_.setup("left_middle_wheel_joint", 1320);
        wheel_r_.setup("right_middle_wheel_joint", 1320);

        for (const hardware_interface::ComponentInfo &joint : info_.joints)
        {
            // HermesSystemHardware has exactly two state interfaces and one command interface on each joint
            if (joint.command_interfaces.size() != 1)
            {
                RCLCPP_FATAL(
                    get_logger(), "Joint '%s' has %zu command interfaces found. 1 expected.",
                    joint.name.c_str(), joint.command_interfaces.size());
                return hardware_interface::CallbackReturn::ERROR;
            }

            if (joint.command_interfaces[0].name != hardware_interface::HW_IF_VELOCITY)
            {
                RCLCPP_FATAL(
                    get_logger(), "Joint '%s' have %s command interfaces found. '%s' expected.",
                    joint.name.c_str(), joint.command_interfaces[0].name.c_str(),
                    hardware_interface::HW_IF_VELOCITY);
                return hardware_interface::CallbackReturn::ERROR;
            }

            if (joint.state_interfaces.size() != 2)
            {
                RCLCPP_FATAL(
                    get_logger(), "Joint '%s' has %zu state interface. 2 expected.", joint.name.c_str(),
                    joint.state_interfaces.size());
                return hardware_interface::CallbackReturn::ERROR;
            }

            if (joint.state_interfaces[0].name != hardware_interface::HW_IF_POSITION)
            {
                RCLCPP_FATAL(
                    get_logger(), "Joint '%s' have '%s' as first state interface. '%s' expected.",
                    joint.name.c_str(), joint.state_interfaces[0].name.c_str(),
                    hardware_interface::HW_IF_POSITION);
                return hardware_interface::CallbackReturn::ERROR;
            }

            if (joint.state_interfaces[1].name != hardware_interface::HW_IF_VELOCITY)
            {
                RCLCPP_FATAL(
                    get_logger(), "Joint '%s' have '%s' as second state interface. '%s' expected.",
                    joint.name.c_str(), joint.state_interfaces[1].name.c_str(),
                    hardware_interface::HW_IF_VELOCITY);
                return hardware_interface::CallbackReturn::ERROR;
            }
        }

        return hardware_interface::CallbackReturn::SUCCESS;
    }

    hardware_interface::CallbackReturn HermesSystemHardware::on_configure(
        const rclcpp_lifecycle::State & /*previous_state*/)
    {
        RCLCPP_INFO(get_logger(), "Configuring ...please wait...");

        if (comms_.connected())
        {
            comms_.disconnect();
        }
        // 1000 ms timeout time! If the pico doesn't respond in 1000ms, it means it's waiting for a confirmation! Ah!
        comms_.connect(serial_port_, baud_rate_, timeout_ms_); 

        // reset values to zero , always when configuring hardware
        for (const auto &[name, descr] : joint_state_interfaces_)
        {
            set_state(name, 0.0);
        }
        for (const auto &[name, descr] : joint_command_interfaces_)
        {
            set_command(name, 0.0);
        }
        RCLCPP_INFO(get_logger(), "Successfully configured!");

        return hardware_interface::CallbackReturn::SUCCESS;
    }

    hardware_interface::CallbackReturn HermesSystemHardware::on_activate(
        const rclcpp_lifecycle::State & /*previous_state*/)
    {
        // BEGIN: This part here is for exemplary purposes - Please do not copy to your production code
        RCLCPP_INFO(get_logger(), "Activating ...please wait...");

        if (!comms_.connected())
        {
            return hardware_interface::CallbackReturn::ERROR;
        }
        // for (auto i = 0; i < hw_start_sec_; i++)
        // {
        //     rclcpp::sleep_for(std::chrono::seconds(1));
        //     RCLCPP_INFO(get_logger(), "%.1f seconds left...", hw_start_sec_ - i);
        // }
        // END: This part here is for exemplary purposes - Please do not copy to your production code

        // command and state should be equal when starting
        for (const auto &[name, descr] : joint_command_interfaces_)
        {
            set_command(name, get_state(name));
        }

        RCLCPP_INFO(get_logger(), "Successfully activated!");

        return hardware_interface::CallbackReturn::SUCCESS;
    }

    hardware_interface::CallbackReturn HermesSystemHardware::on_deactivate(
        const rclcpp_lifecycle::State & /*previous_state*/)
    {

        if (comms_.connected())
        {
            comms_.disconnect();
        }

        // BEGIN: This part here is for exemplary purposes - Please do not copy to your production code
        // RCLCPP_INFO(get_logger(), "Deactivating ...please wait...");

        // for (auto i = 0; i < hw_stop_sec_; i++)
        // {
        //     rclcpp::sleep_for(std::chrono::seconds(1));
        //     RCLCPP_INFO(get_logger(), "%.1f seconds left...", hw_stop_sec_ - i);
        // }
        // // END: This part here is for exemplary purposes - Please do not copy to your production code


        // RCLCPP_INFO(get_logger(), "Successfully deactivated!");

        return hardware_interface::CallbackReturn::SUCCESS;
    }

    hardware_interface::return_type HermesSystemHardware::read(
        const rclcpp::Time & /*time*/, const rclcpp::Duration &period)
    {

        if (!comms_.connected())
        {
            return hardware_interface::return_type::ERROR;
        }
        
        comms_.read_encoder_values(wheel_l_.enc, wheel_r_.enc);
        
        double delta_seconds = period.seconds();

        // Store the previous wheel position

        // TODO: ditch the wheel class thing maybe, and just make it a function
        double pos_prev = wheel_l_.pos;

        wheel_l_.pos = wheel_l_.calc_enc_angle();
        wheel_l_.vel = (wheel_l_.pos - pos_prev) / delta_seconds;

        pos_prev = wheel_r_.pos;

        wheel_r_.pos = wheel_r_.calc_enc_angle();
        wheel_r_.vel = (wheel_r_.pos - pos_prev) / delta_seconds;

        this->set_state("left_middle_wheel_joint/position", wheel_l_.pos);
        this->set_state("right_middle_wheel_joint/position", wheel_r_.pos);

        this->set_state("left_middle_wheel_joint/velocity", wheel_l_.vel);
        this->set_state("right_middle_wheel_joint/velocity", wheel_r_.vel);

        


        // RCLCPP_INFO(this->get_logger(), "l%d r%d", wheel_l_.enc, wheel_r_.enc);

        // Read wheel data, and calcuate encoder angle, and evlocity
        // BEGIN: This part here is for exemplary purposes - Please do not copy to your production code
        // std::stringstream ss;
        // ss << "Reading states:";
        // ss << std::fixed << std::setprecision(2);
        // for (const auto &[name, descr] : joint_state_interfaces_)
        // {
        //     if (descr.get_interface_name() == hardware_interface::HW_IF_POSITION)
        //     {
        //         // Simulate DiffBot wheels's movement as a first-order system
        //         // Update the joint status: this is a revolute joint without any limit.
        //         // Simply integrates
        //         auto velo = get_command(descr.get_prefix_name() + "/" + hardware_interface::HW_IF_VELOCITY);
        //         set_state(name, get_state(name) + period.seconds() * velo);

        //         ss << std::endl
        //            << "\t position " << get_state(name) << " and velocity " << velo << " for '" << name
        //            << "'!";
        //     }
        // }
        // RCLCPP_INFO_THROTTLE(get_logger(), *get_clock(), 500, "%s", ss.str().c_str());
        // END: This part here is for exemplary purposes - Please do not copy to your production code

        return hardware_interface::return_type::OK;
    }

    hardware_interface::return_type hermes_hardware::HermesSystemHardware::write(
        const rclcpp::Time & /*time*/, const rclcpp::Duration & /*period*/)
    {

        if (!comms_.connected())
        {
            return hardware_interface::return_type::ERROR;
        }

        // Initialize velocity variables we will write to the contrtoller
        double left_velocity_request = this->get_command("left_middle_wheel_joint/velocity");
        double right_velocity_request = this->get_command("right_middle_wheel_joint/velocity");

        // auto left_cmd_interface = joint_command_interfaces_.at("left_middle_wheel_joint/velocity");
        // auto right_cmd_interface = joint_command_interfaces_.at("right_wheel_joint/velocity");

        // // 2. Safely extract the double values (if available)
        // double left_velocity_request = left_cmd_interface.get_optional().value_or(0.0);
        // double right_velocity_request = right_cmd_interface.get_optional().value_or(0.0);

        // Derivation going to be explained
        // int motor_l_counts_per_loop = wheel_l_.cmd_vel_rad_per_s / wheel_l_.rads_per_count / loop_rate;
        // int motor_r_counts_per_loop = wheel_r_.cmd_vel_rad_per_s / wheel_r_.rads_per_count / loop_rate;

        // TODO: Replace with PID
        int motor_l_duty_cycle = static_cast<int>(((left_velocity_request / 0.50) * 100.0));
        int motor_r_duty_cycle = static_cast<int>(((right_velocity_request / 0.50)* 100.0));

        // RCLCPP_INFO(this->get_logger(), "loop rate: %.2f\n", loop_rate_);

        // RCLCPP_INFO(this->get_logger(), "l%dr%d\n", motor_l_duty_cycle, motor_r_duty_cycle);

        // comms_.set_motor_values(motor_l_counts_per_loop, motor_r_counts_per_loop);

        comms_.set_motor_values(motor_l_duty_cycle, motor_r_duty_cycle);

        // duty_cycle = cmd_vel/max_vel * 100

        // Write motor data, converting rads to amount
        // BEGIN: This part here is for exemplary purposes - Please do not copy to your production code
        // std::stringstream ss;
        // ss << "Writing commands:";
        // for (const auto &[name, descr] : joint_command_interfaces_)
        // {
        //     // Simulate sending commands to the hardware
        //     set_state(name, get_command(name));

        //     ss << std::fixed << std::setprecision(2) << std::endl
        //        << "\t" << "command " << get_command(name) << " for '" << name << "'!";
        // }
        // RCLCPP_INFO_THROTTLE(get_logger(), *get_clock(), 500, "%s", ss.str().c_str());
        // END: This part here is for exemplary purposes - Please do not copy to your production code

        return hardware_interface::return_type::OK;
    }


} // namespace hermes_hardware

#include "pluginlib/class_list_macros.hpp"
PLUGINLIB_EXPORT_CLASS(
    hermes_hardware::HermesSystemHardware, hardware_interface::SystemInterface)
