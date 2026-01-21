## Analog Knob Control Example
import panicoverride
##
## This example reads analog inputs from potentiometers

import ../src/libdaisy
import ../src/hid/controls
import ../src/per/uart
useDaisyNamespace()


proc main() =
  var daisy = initDaisy()
  
  # Initialize ADC for 3 analog inputs
  var adc = initAdc(daisy, [A0(), A1(), A6()])
  adc.start()
  
  # Start logging to USB
  startLog()
  printLine("Analog Input Reader Started")
  
  while true:
    # Read knob values (0.0 to 1.0)
    let knob1 = adc.value(0)
    let knob2 = adc.value(1)
    let knob3 = adc.value(2)
    
    # Print values
    print("Knob 1: ")
    print(knob1)
    print(" | Knob 2: ")
    print(knob2)
    print(" | Knob 3: ")
    printLine(knob3)
    
    daisy.delay(100)

when isMainModule:
  main()
