## Button and LED Example
##
## This example shows how to use a button to control the LED

import ../src/libdaisy
import ../src/libdaisy_controls
useDaisyNamespace()


proc main() =
  var daisy = initDaisy()
  var button = initSwitch(D2())  # Button on pin D2
  
  while true:
    button.update()
    
    # LED mirrors button state
    if button.pressed:
      daisy.setLed(true)
    else:
      daisy.setLed(false)
    
    daisy.delay(1)  # Update at 1kHz

when isMainModule:
  main()
