## PWM Multi-Channel Example
## 
## Demonstrates using multiple PWM channels for RGB LED control.
## Uses TIM4 with 4 independent channels.
## 
## Hardware setup:
## - Red LED on D13 (TIM4 CH1)
## - Green LED on D14 (TIM4 CH2)
## - Blue LED on D11 (TIM4 CH3)
## - Extra output on D12 (TIM4 CH4)

import panicoverride
import ../src/libdaisy
import ../src/per/pwm

useDaisyNamespace()

proc main() =
  var hw = initDaisy()
  
  # Initialize PWM on TIM4 at 10kHz for smooth LED dimming
  var pwm {.noinit.}: PwmHandle
  pwm.cppInit(TIM_4, 10000.0)
  
  # Initialize all 4 channels with their default pins
  discard pwm.channel1.init()  # D13
  discard pwm.channel2.init()  # D14
  discard pwm.channel3.init()  # D11
  discard pwm.channel4.init()  # D12
  
  var hue: float = 0.0
  
  while true:
    # Simple HSV to RGB conversion for color cycling
    # This creates a rainbow effect
    
    let sector = int(hue * 6.0)
    let f = hue * 6.0 - sector.float
    let p = 0.0
    let q = 1.0 - f
    let t = f
    
    var r, g, b: float
    
    let sectorMod = sector mod 6
    
    case sectorMod
    of 0:
      r = 1.0; g = t; b = p
    of 1:
      r = q; g = 1.0; b = p
    of 2:
      r = p; g = 1.0; b = t
    of 3:
      r = p; g = q; b = 1.0
    of 4:
      r = t; g = p; b = 1.0
    else:
      r = 1.0; g = p; b = q
    
    # Set RGB values
    pwm.channel1.set(r)  # Red
    pwm.channel2.set(g)  # Green
    pwm.channel3.set(b)  # Blue
    
    # Channel 4 pulses independently
    let pulse = hue * 2.0
    let pulseMod = if pulse >= 1.0: pulse - 1.0 else: pulse
    pwm.channel4.set(pulseMod)
    
    # Increment hue
    hue += 0.002
    if hue >= 1.0:
      hue = 0.0
    
    hw.delay(10)

when isMainModule:
  main()
