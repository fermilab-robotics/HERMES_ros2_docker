#ifndef WHEEL_HPP
#define WHEEL_HPP

#include <string>
#include <cmath>

class Wheel
{
private:
    std::string name;
    int enc;
    double cmd;
    double pos;
    double vel;
    double rads_per_count;

public:
    Wheel() = default;

    Wheel(const std::string &wheel_name, int counts_per_rev);

    void setup(const std::string &wheel_name, int counts_per_rev);
    double calc_enc_angle();
};

#endif // DIFFDRIVE_ARDUINO_WHEEL_HPP