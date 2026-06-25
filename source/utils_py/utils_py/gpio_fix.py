# gpio_utils.py
import gpiozero
import lgpio
from gpiozero import Device
from gpiozero.pins.lgpio import LGPIOFactory

def patch_gpiozero():
    """
    Workaround for ACTIVE BUG in GPIOZERO Library: 
    https://github.com/gpiozero/gpiozero/issues/1166
    """
    def __patched_init(self, chip=None):
        # Call the original base class init
        gpiozero.pins.lgpio.LGPIOFactory.__bases__[0].__init__(self)
        chip = 0
        self._handle = lgpio.gpiochip_open(chip)
        self._chip = chip
        self.pin_class = gpiozero.pins.lgpio.LGPIOPin

    # Apply the monkey-patch
    LGPIOFactory.__init__ = __patched_init
    
    # Set the global pin factory
    Device.pin_factory = LGPIOFactory()
    
    print("GPIOZero patched successfully.")