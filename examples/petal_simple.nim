## Simple Control Demo for Daisy Petal
## ====================================
##
## **Hardware:** Daisy Petal guitar pedal platform
##
## **Description:**
## Basic demonstration of Petal controls without audio processing.
## Shows knob reading, footswitch detection, and LED control.
##
## **Functionality:**
## - 6 knobs control RGB ring LED colors and brightness
## - 4 footswitches toggle their respective footswitch LEDs
## - 3 toggle switches affect ring LED patterns
## - Rotary encoder controls overall LED brightness
## - Expression pedal controls LED "intensity" effect
##
## **Control Mapping:**
## - Knob 1-3: RGB color for ring LEDs 1-4 (Red, Green, Blue)
## - Knob 4-6: RGB color for ring LEDs 5-8 (Red, Green, Blue)
## - Footswitch 1-4: Toggle footswitch LEDs on/off
## - Toggle SW 5: Enable/disable ring LED rotation
## - Toggle SW 6: Change ring LED pattern
## - Toggle SW 7: Invert colors
## - Encoder: Adjust global brightness
## - Expression pedal: Modulate LED intensity
##
## **Expected Behavior:**
## - Ring LEDs change color based on knob positions
## - Footswitch LEDs toggle when footswitches are pressed
## - Encoder changes overall brightness
## - All controls are responsive without audio
##
## **Use Cases:**
## - Learning Petal hardware interface
## - Testing Petal board functionality
## - Template for custom LED controllers
## - Non-audio visual feedback applications

import ../src/libdaisy_petal
import ../src/libdaisy_macros

useDaisyNamespace()

proc main() =
  var petal: DaisyPetal
  
  # Initialize hardware
  petal.init()
  petal.startAdc()  # Start ADC for knobs and expression pedal
  
  # LED state tracking
  var footswitchStates: array[4, bool]  # Track footswitch LED states
  var globalBrightness: cfloat = 1.0
  var encoderValue: int32 = 0
  
  # Initialize LEDs - all off
  petal.clearLeds()
  petal.updateLeds()
  
  # Main loop
  while true:
    # Update all controls
    petal.processAllControls()
    
    # Read knobs for RGB color control (0.0 - 1.0)
    let red1   = petal.getKnobValue(KNOB_1.cint)
    let green1 = petal.getKnobValue(KNOB_2.cint)
    let blue1  = petal.getKnobValue(KNOB_3.cint)
    
    let red2   = petal.getKnobValue(KNOB_4.cint)
    let green2 = petal.getKnobValue(KNOB_5.cint)
    let blue2  = petal.getKnobValue(KNOB_6.cint)
    
    # Read expression pedal for intensity modulation
    let expression = petal.getExpression()
    
    # Read encoder for global brightness
    let encoderIncrement = petal.encoder.increment()
    encoderValue += encoderIncrement
    if encoderValue < 0: encoderValue = 0
    if encoderValue > 100: encoderValue = 100
    globalBrightness = encoderValue.cfloat / 100.0
    
    # Read toggle switches for LED pattern control
    let rotationEnabled = petal.switches[SW_5.int].pressed()
    let patternMode = petal.switches[SW_6.int].pressed()
    let invertColors = petal.switches[SW_7.int].pressed()
    
    # Set ring LEDs 1-4 with first color set
    for i in 0..<4:
      var r = red1 * globalBrightness * expression
      var g = green1 * globalBrightness * expression
      var b = blue1 * globalBrightness * expression
      
      if invertColors:
        r = (1.0 - r) * globalBrightness
        g = (1.0 - g) * globalBrightness
        b = (1.0 - b) * globalBrightness
      
      petal.setRingLed(i.cint, r, g, b)
    
    # Set ring LEDs 5-8 with second color set
    for i in 4..<8:
      var r = red2 * globalBrightness * expression
      var g = green2 * globalBrightness * expression
      var b = blue2 * globalBrightness * expression
      
      if invertColors:
        r = (1.0 - r) * globalBrightness
        g = (1.0 - g) * globalBrightness
        b = (1.0 - b) * globalBrightness
      
      petal.setRingLed(i.cint, r, g, b)
    
    # Handle footswitch presses (toggle LED states)
    for i in 0..<4:
      if petal.switches[i].risingEdge():
        footswitchStates[i] = not footswitchStates[i]
        
        # Set LED based on state
        let brightness = if footswitchStates[i]: 1.0 else: 0.0
        petal.setFootswitchLed(i.cint, brightness)
    
    # Update all LEDs
    petal.updateLeds()
    
    # Delay 1ms (1000 Hz control rate)
    petal.delayMs(1)

when isMainModule:
  main()
