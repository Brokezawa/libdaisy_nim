## Daisy Patch Simple Example
import panicoverride
##
## Basic LED blink and control reading

import ../src/libdaisy
import ../src/libdaisy_patch
useDaisyNamespace()

var patch: DaisyPatch

proc main() =
  # Initialize Patch hardware
  patch.init()
  
  # Main loop
  var ledState = false
  var counter = 0
  
  while true:
    # Process controls
    patch.processAllControls()
    
    # Blink LED based on knob 1
    counter.inc
    let blinkRate = int(patch.getKnobValue(CTRL_1) * 1000.0)
    if counter > blinkRate:
      counter = 0
      ledState = not ledState
      patch.seed.setLed(ledState)
    
    # Small delay
    patch.delayMs(1)

when isMainModule:
  main()
