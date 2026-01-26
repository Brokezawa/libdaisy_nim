## Daisy Versio - Simple LED Control Demo
## ======================================
## 
## Demonstrates basic LED and control input on the Daisy Versio platform.
## 
## **Hardware**: Daisy Versio (Noise Engineering Eurorack module)
## 
## **Features**:
## - 7 knobs control LED colors and patterns
## - 2 three-position switches change LED modes
## - Gate input triggers LED flash effect
## - No audio processing (LED control only)
## 
## **Controls**:
## - KNOB_0-2: Control LED 0 RGB values
## - KNOB_3-4: Control LED 1 RG values
## - KNOB_5-6: Control LED 2-3 brightness
## - SW_0: LED mode (down=individual, center=chase, up=all)
## - SW_1: Speed control (down=slow, center=medium, up=fast)
## - GATE_IN: Trigger white flash on all LEDs

import ../src/libdaisy
import ../src/libdaisy_versio

useDaisyNamespace()

# LED mode selection
type
  LedMode = enum
    MODE_INDIVIDUAL = 0  # Each knob controls individual LED
    MODE_CHASE = 1       # Chasing pattern
    MODE_ALL = 2         # All LEDs same color

var
  versio: DaisyVersio
  currentMode = MODE_INDIVIDUAL
  chasePosition = 0
  frameCounter = 0
  speedMultiplier = 1
  flashActive = false
  flashCounter = 0

const FLASH_DURATION = 50  # frames

proc updateLedMode() =
  ## Update current mode based on SW_0 position
  let sw0Pos = versio.sw[0].read()
  case sw0Pos
  of 0:  # Down
    currentMode = MODE_INDIVIDUAL
  of 1:  # Center
    currentMode = MODE_CHASE
  of 2:  # Up
    currentMode = MODE_ALL
  else:
    discard

proc updateSpeed() =
  ## Update speed multiplier based on SW_1 position
  let sw1Pos = versio.sw[1].read()
  case sw1Pos
  of 0:  # Down - slow
    speedMultiplier = 4
  of 1:  # Center - medium
    speedMultiplier = 2
  of 2:  # Up - fast
    speedMultiplier = 1
  else:
    discard

proc checkGateTrigger() =
  ## Check for gate input trigger
  if versio.gate.state():
    flashActive = true
    flashCounter = 0

proc updateIndividualMode() =
  ## Each knob controls specific LED RGB values
  let r0 = versio.getKnobValue(KNOB_0.cint)
  let g0 = versio.getKnobValue(KNOB_1.cint)
  let b0 = versio.getKnobValue(KNOB_2.cint)
  versio.setLed(LED_0.csize_t, r0, g0, b0)
  
  let r1 = versio.getKnobValue(KNOB_3.cint)
  let g1 = versio.getKnobValue(KNOB_4.cint)
  versio.setLed(LED_1.csize_t, r1, g1, 0.0)
  
  let brightness2 = versio.getKnobValue(KNOB_5.cint)
  versio.setLed(LED_2.csize_t, brightness2, 0.0, brightness2)
  
  let brightness3 = versio.getKnobValue(KNOB_6.cint)
  versio.setLed(LED_3.csize_t, 0.0, brightness3, brightness3)

proc updateChaseMode() =
  ## Chasing LED pattern
  for i in 0..<4:
    if i == chasePosition:
      # Active LED is bright white
      versio.setLed(i.csize_t, 1.0, 1.0, 1.0)
    else:
      # Other LEDs are dim
      versio.setLed(i.csize_t, 0.1, 0.1, 0.1)

proc updateAllMode() =
  ## All LEDs same color (controlled by KNOB_0-2)
  let r = versio.getKnobValue(KNOB_0.cint)
  let g = versio.getKnobValue(KNOB_1.cint)
  let b = versio.getKnobValue(KNOB_2.cint)
  
  for i in 0..<4:
    versio.setLed(i.csize_t, r, g, b)

proc updateFlash() =
  ## Handle flash effect from gate trigger
  if flashActive:
    # Override all LEDs with white flash
    let brightness = 1.0 - (flashCounter.cfloat / FLASH_DURATION.cfloat)
    for i in 0..<4:
      versio.setLed(i.csize_t, brightness, brightness, brightness)
    
    inc flashCounter
    if flashCounter >= FLASH_DURATION:
      flashActive = false

proc updateLeds() =
  ## Main LED update logic
  if flashActive:
    updateFlash()
  else:
    case currentMode
    of MODE_INDIVIDUAL:
      updateIndividualMode()
    of MODE_CHASE:
      updateChaseMode()
    of MODE_ALL:
      updateAllMode()
  
  # Commit LED updates to hardware
  versio.updateLeds()

proc advanceChase() =
  ## Advance chase position based on speed
  if currentMode == MODE_CHASE:
    inc frameCounter
    if frameCounter >= (10 * speedMultiplier):
      frameCounter = 0
      chasePosition = (chasePosition + 1) mod 4

proc main() =
  # Initialize Versio hardware
  versio.init()
  
  echo "Daisy Versio - Simple LED Demo"
  echo "================================"
  echo "SW_0: LED mode (individual/chase/all)"
  echo "SW_1: Speed (slow/medium/fast)"
  echo "GATE_IN: Trigger flash effect"
  echo "KNOB_0-6: Control LED colors/brightness"
  
  # Main loop
  while true:
    # Update control states
    updateLedMode()
    updateSpeed()
    checkGateTrigger()
    
    # Update LEDs
    updateLeds()
    advanceChase()
    
    # Run at ~100Hz
    versio.delayMs(10)

when isMainModule:
  main()
