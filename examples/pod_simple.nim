## Pod Simple Example
##
## Basic LED and button control for Daisy Pod
## Tests Pod wrapper without audio complexity
##
## **Hardware:** Daisy Pod

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_pod
import ../src/libdaisy_macros

useDaisyNamespace()

var pod: DaisyPod

proc main() =
  pod.init()
  pod.startAdc()  # Enable knob reading
  
  var counter = 0
  
  while true:
    pod.processAllControls()
    
    # Read knobs
    let knob1Val = pod.getKnobValue(KNOB_1)
    let knob2Val = pod.getKnobValue(KNOB_2)
    
    # Set LED colors based on knobs
    pod.led1.set(knob1Val, 0.0, 1.0 - knob1Val)  # Red to Blue
    pod.led2.set(0.0, knob2Val, 1.0 - knob2Val)  # Green to Blue
    pod.updateLeds()
    
    # Button controls
    if pod.button1.risingEdge():
      pod.led1.set(1.0, 1.0, 1.0)  # Flash white
    
    if pod.button2.pressed():
      pod.led2.set(1.0, 0.0, 0.0)  # Solid red while held
    
    # Blink seed LED
    counter.inc
    if counter > 500:
      counter = 0
      pod.seed.setLed(true)
    elif counter > 250:
      pod.seed.setLed(false)
    
    pod.delay(1)

when isMainModule:
  main()
