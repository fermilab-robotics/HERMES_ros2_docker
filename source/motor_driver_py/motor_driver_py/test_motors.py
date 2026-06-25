import time

from gpiozero import PhaseEnableMotor
from utils_py.utils_py.gpio_fix import patch_gpiozero

# Call the patch
patch_gpiozero()


# The RH set of motor pins
M_1 = 5
PWM_1 = 20

# The LH set of motor pins
M_2 = 6 
PWM_2 = 19

left_motor = PhaseEnableMotor(phase=M_1, enable=PWM_1, pwm=True)
right_motor = PhaseEnableMotor(phase=M_2, enable=PWM_2, pwm=True)

# Forward is 
# Spin both wheels forward for 2 seconds
print("Spinning both wheels forward for 2 seconds!")
left_motor.forward()
right_motor.forward()

time.sleep(2)

# Spin both wheels backward for two seconds
print("Spinning both wheels backward for two seconds!")
left_motor.backward()
right_motor.backward()

time.sleep(2)

# Stop both motors
print("Stopping both motors!")
left_motor.stop()
right_motor.stop()
