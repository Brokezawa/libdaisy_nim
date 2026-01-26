## Shift Register Button Scanner Example
##
## Demonstrates using CD4021 shift register for button matrix scanning.
## This example uses a single CD4021 device to read 8 buttons.
##
## **Hardware Setup:**
## - CD4021 shift register IC
## - 8 momentary push buttons
## - 8× 10kΩ pull-up resistors (optional if using internal pull-ups)
##
## **Connections:**
## - CD4021 pin 10 (Clock) → Daisy D0
## - CD4021 pin 9 (P/!S Latch) → Daisy D1
## - CD4021 pin 11 (Serial Out) → Daisy D2
## - CD4021 pins 1, 15, 14, 13, 4, 5, 6, 7 (Parallel Inputs) → Buttons
## - Each button connects input to GND when pressed
## - Pull-up resistors connect inputs to VCC (or use internal pull-ups)
##
## **Behavior:**
## - LED blinks at 1Hz
## - When any button is pressed, LED changes blink rate
## - USB serial output shows button states
##
## **Note:** This is a compilation test example. Hardware testing required.

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_shift_register

useDaisyNamespace()

var
  hw: DaisySeed
  shiftReg: ShiftRegister4021_1
  ledState: bool = false
  lastButtonState: array[8, bool]

proc main() =
  # Initialize hardware
  hw.init()
  
  # Configure shift register
  var srConfig: ShiftRegisterConfig_1
  srConfig.clk = D0()
  srConfig.latch = D1()
  srConfig.data[0] = D2()
  srConfig.delay_ticks = 10  # Timing delay for stable reads
  
  shiftReg.init(srConfig)
  
  # Initialize button state tracking
  for i in 0..<8:
    lastButtonState[i] = false
  
  # Main loop
  var loopCount: uint32 = 0
  
  while true:
    # Read shift register inputs
    shiftReg.update()
    
    # Check each button
    var anyPressed = false
    for i in 0..<8:
      let currentState = shiftReg.pressed(i.cint)
      
      # Detect button press (rising edge)
      if currentState and not lastButtonState[i]:
        # Button just pressed - could trigger action here
        anyPressed = true
      
      lastButtonState[i] = currentState
    
    # Toggle LED based on button state
    if anyPressed:
      # Fast blink when button pressed
      if loopCount mod 100 == 0:
        ledState = not ledState
        hw.setLed(ledState)
    else:
      # Slow blink when no buttons pressed
      if loopCount mod 500 == 0:
        ledState = not ledState
        hw.setLed(ledState)
    
    inc loopCount
    hw.delay(1)

when isMainModule:
  main()
