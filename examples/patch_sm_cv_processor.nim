## Simple CV Processor for Daisy Patch SM
## =======================================
##
## **Hardware:** Daisy Patch SM Eurorack module
##
## **Description:**
## Basic CV processor demonstration showing core functionality.
## No external hardware required - works with floating (disconnected) inputs.
##
## **Functionality:**
## - Reads 8 CV inputs (bipolar +/-5V)
## - Sums CV inputs 1-4, outputs to CV Out 1
## - Sums CV inputs 5-8, outputs to CV Out 2
## - Outputs are scaled to 0-5V range (attenuated)
## - Gate inputs trigger LED
## - LED blinks at 1Hz to show activity
##
## **CV Mapping:**
## - CV In 1-4 → summed → CV Out 1 (scaled 0-5V)
## - CV In 5-8 → summed → CV Out 2 (scaled 0-5V)
## - Gate In 1 or 2 → LED on
##
## **Expected Behavior:**
## - LED blinks steadily at 1Hz
## - CV outputs respond to CV inputs (can test with patch cables)
## - Gate inputs turn LED on while high
## - All functionality works without any patching (safe defaults)
##
## **Use Cases:**
## - CV mixing/summing
## - Learning Patch SM hardware basics
## - Testing Patch SM board functionality
## - Template for custom CV processors

import ../src/libdaisy_patch_sm
import ../src/libdaisy_macros

useDaisyNamespace()

proc main() =
  var patchsm: DaisyPatchSM
  
  # Initialize hardware
  patchsm.init()
  patchsm.startAdc()
  patchsm.startDac()
  
  var ledState = false
  var counter = 0
  
  # Main loop
  while true:
    # Update all control inputs (CV and gates)
    patchsm.processAllControls()
    
    # Read CV inputs 1-4 and sum them
    let cv1 = patchsm.getAdcValue(CV_1.cint)
    let cv2 = patchsm.getAdcValue(CV_2.cint)
    let cv3 = patchsm.getAdcValue(CV_3.cint)
    let cv4 = patchsm.getAdcValue(CV_4.cint)
    let sum1234 = (cv1 + cv2 + cv3 + cv4) * 0.25  # Average (0.0-1.0)
    
    # Read CV inputs 5-8 and sum them
    let cv5 = patchsm.getAdcValue(CV_5.cint)
    let cv6 = patchsm.getAdcValue(CV_6.cint)
    let cv7 = patchsm.getAdcValue(CV_7.cint)
    let cv8 = patchsm.getAdcValue(CV_8.cint)
    let sum5678 = (cv5 + cv6 + cv7 + cv8) * 0.25  # Average (0.0-1.0)
    
    # Output to CV outs (scale 0.0-1.0 to 0-5V)
    patchsm.writeCvOut(CV_OUT_1.cint, sum1234 * 5.0)
    patchsm.writeCvOut(CV_OUT_2.cint, sum5678 * 5.0)
    
    # Check gate inputs - turn LED on if either gate is high
    let gateActive = patchsm.gate_in_1.state() or patchsm.gate_in_2.state()
    
    if gateActive:
      # Gate is active - LED on solid
      patchsm.setLed(true)
    else:
      # No gate - blink LED at 1Hz
      inc counter
      if counter >= 1000:  # 1000ms = 1 second
        counter = 0
        ledState = not ledState
        patchsm.setLed(ledState)
    
    # Delay 1ms (gives 1kHz update rate)
    patchsm.delay(1)

when isMainModule:
  main()
