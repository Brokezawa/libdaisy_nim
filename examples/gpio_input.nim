## GPIO Input Example
##
## Reading a digital input and controlling LED

import ../src/libdaisy
useDaisyNamespace()


proc main() =
  var daisy = initDaisy()
  
  # Initialize button on D2 as input with pull-up
  var button = initGpio(newPin(PORTC, 10), INPUT, PULLUP)
  
  # Initialize external LED on D7 as output
  var externalLed = initGpio(newPin(PORTG, 10), OUTPUT)
  
  while true:
    # Read button state (LOW when pressed due to pull-up)
    let buttonPressed = not button.read()
    
    # Control both LEDs based on button
    daisy.setLed(buttonPressed)
    externalLed.write(buttonPressed)
    
    daisy.delay(10)

when isMainModule:
  main()
