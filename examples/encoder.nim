## Encoder Control Example
import panicoverride
##
## This example shows using a rotary encoder to control a parameter

import ../src/libdaisy
import ../src/hid/controls
import ../src/per/uart
useDaisyNamespace()


proc main() =
  var daisy = initDaisy()
  
  # Initialize encoder on pins D0 (A), D1 (B), D2 (Click)
  var encoder = initEncoder(D0(), D1(), D2())
  
  startLog()
  printLine("Encoder Control Started")
  
  var value = 50  # Parameter from 0-100
  
  while true:
    encoder.update()
    
    # Adjust value based on encoder rotation
    let change = encoder.increment
    value = max(0, min(100, value + change))
    
    # Check if encoder was clicked
    if encoder.risingEdge:
      value = 50  # Reset to center
      printLine("Reset to 50")
    
    # Print current value when it changes
    if change != 0:
      print("Value: ")
      printLine(value)
    
    daisy.delay(1)

when isMainModule:
  main()
