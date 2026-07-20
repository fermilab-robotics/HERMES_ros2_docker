#include "wheel.hpp"

class Wheel
{
public:
    Wheel(const std::string &wheel_name, int counts_per_rev)
    {
        setup(wheel_name, counts_per_rev);
    }

    void setup(const std::string &wheel_name, int counts_per_rev)
    {
        name = wheel_name;
        rads_per_count = (2 * M_PI) / counts_per_rev;
    }

    double calc_enc_angle()
    {
        return enc * rads_per_count;
    }
};

#endif // DIFFDRIVE_ARDUINO_WHEEL_HPP