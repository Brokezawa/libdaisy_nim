## PWM LED Dimming Example
## 
## Demonstrates basic PWM usage by fading the Daisy Seed's internal LED.
## The LED is connected to TIM3 Channel 2 (PC7).

import panicoverride
import ../src/libdaisy
import ../src/per/pwm

useDaisyNamespace()

proc main() =
  var hw = initDaisy()
  
  # Create PWM handle inline to avoid copy constructor issues
  # Initialize PWM on TIM3 at 1kHz
  var pwm {.noinit.}: PwmHandle
  pwm.cppInit(TIM_3, 1000.0)
  
  # Initialize channel 2 (LED - default pin PC7)
  discard pwm.channel2.init()
  
  # Fade in and out forever
  while true:
    # Fade in (0% to 100%)
    for brightness in 0..100:
      pwm.channel2.set(brightness.float / 100.0)
      hw.delay(10)
    
    # Fade out (100% to 0%)
    for brightness in countdown(100, 0):
      pwm.channel2.set(brightness.float / 100.0)
      hw.delay(10)

when isMainModule:
  main()
