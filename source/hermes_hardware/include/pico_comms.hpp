#ifndef PICO_COMMS_HPP
#define PICO_COMMS_HPP

#include <libserial/SerialPort.h>
#include <iostream>

LibSerial::BaudRate convert_baud_rate(int baud_rate);

class PicoComms
{
public:
    PicoComms() = default;

    void connect(const std::string &serial_device, int32_t baud_rate, int timeout_ms);
    void disconnect();

    std::string send_msg(const std::string &msg_to_send, bool print_output = true);
    void send_empty_msg();
    void read_encoder_values(int &val_1, int &val_2);
    void set_motor_values(int val_1, int val_2);

private:
    LibSerial::SerialPort serial_conn_;
    int timeout_ms_;
    // bool connected_ = false;
};

#endif