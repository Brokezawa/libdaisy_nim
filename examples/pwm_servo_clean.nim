## PWM Servo Control Example
## 
## Demonstrates PWM for servo motor control.
## Standard servos use 50Hz PWM with pulse widths:
## - 1.0ms = 0 degrees (left)
## - 1.5ms = 90 degrees (center)
## - 2.0ms = 180 degrees (right)
## 
## Hardware setup:
## - Servo signal wire to D25 (TIM5 CH1)
## - Servo power and ground to external 5V supply
## - Ground must be shared with Daisy

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_pwm
import ../src/libdaisy_serial

useDaisyNamespace()

proc servoPosition(degrees: float): float =
  ## Convert degrees (0-180) to PWM duty cycle for 50Hz servo
  ## 
  ## At 50Hz (20ms period):
  ## - 1.0ms = 5% duty cycle = 0 degrees
  ## - 1.5ms = 7.5% duty cycle = 90 degrees  
  ## - 2.0ms = 10% duty cycle = 180 degrees
  
  const MIN_PULSE_MS = 1.0   # Minimum pulse width
  const MAX_PULSE_MS = 2.0   # Maximum pulse width
  const PERIOD_MS = 20.0     # 50Hz = 20ms period
  
  # Clamp degrees to valid range
  var deg = degrees
  if deg < 0.0: deg = 0.0
  if deg > 180.0: deg = 180.0
  
  # Calculate pulse width in milliseconds
  let pulseMs = MIN_PULSE_MS + (deg / 180.0) * (MAX_PULSE_MS - MIN_PULSE_MS)
  
  # Convert to duty cycle (0.0 to 1.0)
  result = pulseMs / PERIOD_MS

proc main() =
  var hw = initDaisy()
  
  # Initialize PWM at 50Hz for servo control
  var pwm {.noinit.}: PwmHandle
  pwm.cppInit(TIM_5, 50.0)
  
  # Initialize channel 1 (D25)
  discard pwm.channel1.init()
  
  startLog()
  printLine("PWM Servo Control Example")
  printLine("Sweeping servo between 0 and 180 degrees")
  printLine()
  
  while true:
    # Sweep from 0 to 180 degrees
    for degrees in 0..180:
      let duty = servoPosition(degrees.float)
      pwm.channel1.set(duty)
      
      if (degrees mod 30) == 0:
        print("Position: ")
        print(degrees)
        print(" degrees (")
        print(duty)
        printLine(" duty)")
      
      hw.delay(20)
    
    hw.delay(500)
    
    # Sweep back from 180 to 0 degrees
    for degrees in countdown(180, 0):
      let duty = servoPosition(degrees.float)
      pwm.channel1.set(duty)
      
      if (degrees mod 30) == 0:
        print("Position: ")
        print(degrees)
        print(" degrees (")
        print(duty)
        printLine(" duty)")
      
      hw.delay(20)
    
    hw.delay(500)

when isMainModule:
  main()
