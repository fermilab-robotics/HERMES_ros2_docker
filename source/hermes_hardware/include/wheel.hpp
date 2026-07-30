#ifndef WHEEL_HPP
#define WHEEL_HPP

#include <string>
#include <cmath>

class Wheel
{
public:
    std::string name;

    // encoder raw read value
    int enc;
    int cmd_vel_rad_per_s;
    double pos;
    double vel;
    double rads_per_count; // radians per count of encoder

public:
    Wheel() = default;

    Wheel(const std::string &wheel_name, int counts_per_rev);

    void setup(const std::string &wheel_name, int counts_per_rev);
    double calc_enc_angle();

};

#endif // DIFFDRIVE_ARDUINO_WHEEL_HPP