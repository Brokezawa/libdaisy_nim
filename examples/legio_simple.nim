## Daisy Legio - Simple Control Demo
## ==================================
## 
## Demonstrates basic LED and control input on the Daisy Legio platform.
## 
## **Hardware**: Daisy Legio (Virt Iter Legio by Olivia Artz Modular + Noise Engineering)
## 
## **Features**:
## - Encoder controls LED brightness and color
## - 3 CV inputs (pitch + 2 knobs) control LED colors
## - 2 three-position switches change LED modes
## - Gate input triggers LED flash
## - No audio processing
## 
## **Controls**:
## - ENCODER: Rotate to change brightness, press to toggle mode
## - CONTROL_PITCH: Control left LED red channel
## - CONTROL_KNOB_TOP: Control left LED green channel
## - CONTROL_KNOB_BOTTOM: Control right LED blue channel
## - SW_LEFT: LED mode (down=individual, center=mirrored, up=all same)
## - SW_RIGHT: Brightness scaling (down=dim, center=normal, up=bright)
## - GATE: Trigger white flash on both LEDs

import ../src/libdaisy
import ../src/libdaisy_legio

useDaisyNamespace()

# LED mode selection
type
  LedMode = enum
    MODE_INDIVIDUAL = 0  # Each LED controlled independently
    MODE_MIRRORED = 1    # Both LEDs show same color
    MODE_ALTERNATE = 2   # LEDs alternate colors

var
  legio: DaisyLegio
  currentMode = MODE_INDIVIDUAL
  brightness = 0.5.cfloat
  encoderPressed = false
  flashActive = false
  flashCounter = 0

const FLASH_DURATION = 30  # frames

proc updateLedMode() =
  ## Update current mode based on SW_LEFT position
  let swPos = legio.sw[0].read()
  case swPos
  of 0:  # Down
    currentMode = MODE_INDIVIDUAL
  of 1:  # Center
    currentMode = MODE_MIRRORED
  of 2:  # Up
    currentMode = MODE_ALTERNATE
  else:
    discard

proc updateBrightness() =
  ## Update brightness scaling based on SW_RIGHT position
  let swPos = legio.sw[1].read()
  case swPos
  of 0:  # Down - dim
    brightness = 0.3
  of 1:  # Center - normal
    brightness = 0.7
  of 2:  # Up - bright
    brightness = 1.0
  else:
    discard

proc updateEncoder() =
  ## Process encoder input
  let increment = legio.encoder.increment()
  if increment != 0:
    # Rotate encoder to adjust global brightness
    brightness += increment.cfloat * 0.05
    if brightness < 0.0: brightness = 0.0
    if brightness > 1.0: brightness = 1.0
  
  # Check button press
  if legio.encoder.risingEdge():
    encoderPressed = not encoderPressed

proc checkGateTrigger() =
  ## Check for gate input trigger
  if legio.gate():
    flashActive = true
    flashCounter = 0

proc updateIndividualMode() =
  ## Each CV input controls different LED channels
  let pitch = legio.getKnobValue(CONTROL_PITCH.cint)
  let knobTop = legio.getKnobValue(CONTROL_KNOB_TOP.cint)
  let knobBottom = legio.getKnobValue(CONTROL_KNOB_BOTTOM.cint)
  
  # Left LED: red=pitch, green=knobTop, blue=0
  legio.setLed(LED_LEFT.csize_t, 
               pitch * brightness,
               knobTop * brightness,
               0.0)
  
  # Right LED: red=0, green=0, blue=knobBottom
  legio.setLed(LED_RIGHT.csize_t,
               0.0,
               0.0,
               knobBottom * brightness)

proc updateMirroredMode() =
  ## Both LEDs show same color (from CV inputs)
  let pitch = legio.getKnobValue(CONTROL_PITCH.cint)
  let knobTop = legio.getKnobValue(CONTROL_KNOB_TOP.cint)
  let knobBottom = legio.getKnobValue(CONTROL_KNOB_BOTTOM.cint)
  
  let r = pitch * brightness
  let g = knobTop * brightness
  let b = knobBottom * brightness
  
  legio.setLed(LED_LEFT.csize_t, r, g, b)
  legio.setLed(LED_RIGHT.csize_t, r, g, b)

proc updateAlternateMode() =
  ## LEDs alternate colors based on encoder button
  let pitch = legio.getKnobValue(CONTROL_PITCH.cint)
  let knobTop = legio.getKnobValue(CONTROL_KNOB_TOP.cint)
  let knobBottom = legio.getKnobValue(CONTROL_KNOB_BOTTOM.cint)
  
  if encoderPressed:
    # Left LED: full color, Right LED: dim
    legio.setLed(LED_LEFT.csize_t, 
                 pitch * brightness,
                 knobTop * brightness,
                 knobBottom * brightness)
    legio.setLed(LED_RIGHT.csize_t,
                 pitch * 0.1,
                 knobTop * 0.1,
                 knobBottom * 0.1)
  else:
    # Left LED: dim, Right LED: full color
    legio.setLed(LED_LEFT.csize_t,
                 pitch * 0.1,
                 knobTop * 0.1,
                 knobBottom * 0.1)
    legio.setLed(LED_RIGHT.csize_t,
                 pitch * brightness,
                 knobTop * brightness,
                 knobBottom * brightness)

proc updateFlash() =
  ## Handle flash effect from gate trigger
  if flashActive:
    # Override both LEDs with white flash
    let flashBrightness = 1.0 - (flashCounter.cfloat / FLASH_DURATION.cfloat)
    legio.setLed(LED_LEFT.csize_t, flashBrightness, flashBrightness, flashBrightness)
    legio.setLed(LED_RIGHT.csize_t, flashBrightness, flashBrightness, flashBrightness)
    
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
    of MODE_MIRRORED:
      updateMirroredMode()
    of MODE_ALTERNATE:
      updateAlternateMode()
  
  # Commit LED updates to hardware
  legio.updateLeds()

proc main() =
  # Initialize Legio hardware
  legio.init()
  
  echo "Daisy Legio - Simple Control Demo"
  echo "=================================="
  echo "ENCODER: Rotate to adjust brightness, press to toggle"
  echo "CONTROL_PITCH: Red channel"
  echo "CONTROL_KNOB_TOP: Green channel"
  echo "CONTROL_KNOB_BOTTOM: Blue channel"
  echo "SW_LEFT: LED mode (individual/mirrored/alternate)"
  echo "SW_RIGHT: Brightness preset (dim/normal/bright)"
  echo "GATE: Trigger flash effect"
  
  # Main loop
  while true:
    # Update control states
    legio.processAllControls()
    updateLedMode()
    updateBrightness()
    updateEncoder()
    checkGateTrigger()
    
    # Update LEDs
    updateLeds()
    
    # Run at ~100Hz
    legio.delayMs(10)

when isMainModule:
  main()
