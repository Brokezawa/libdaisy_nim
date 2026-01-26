## Daisy Legio - CV Meter with Audio Passthrough
## ===============================================
## 
## CV monitoring utility with audio passthrough and LED visualization.
## 
## **Hardware**: Daisy Legio (Virt Iter Legio)
## 
## **Features**:
## - Audio passthrough with gain control
## - CV input visualization using RGB LEDs
## - Encoder-controlled gain and mode selection
## - Gate-triggered hold mode
## - Three-position switches for routing
## 
## **Controls**:
## - ENCODER: Rotate to adjust gain, press to toggle meter mode
## - CONTROL_PITCH: Displayed on left LED (red channel)
## - CONTROL_KNOB_TOP: Displayed on left LED (green channel)
## - CONTROL_KNOB_BOTTOM: Displayed on right LED (blue channel)
## - SW_LEFT: Input routing (down=stereo, center=mono L, up=mono R)
## - SW_RIGHT: Gain range (down=0.5x, center=1.0x, up=2.0x)
## - GATE: Hold current CV readings (freeze display)

import ../src/libdaisy
import ../src/libdaisy_legio

useDaisyNamespace()

# Meter mode
type
  MeterMode = enum
    METER_CV = 0      # Show CV inputs
    METER_AUDIO = 1   # Show audio levels

var
  legio: DaisyLegio
  gain = 1.0.cfloat
  meterMode = METER_CV
  holdActive = false
  heldPitch, heldKnobTop, heldKnobBottom: cfloat
  audioLevelL, audioLevelR: cfloat

proc abs(x: cfloat): cfloat {.inline.} =
  if x < 0.0: -x else: x

proc clamp(x: cfloat, minVal: cfloat, maxVal: cfloat): cfloat {.inline.} =
  if x < minVal: minVal
  elif x > maxVal: maxVal
  else: x

proc updateEncoder() =
  ## Process encoder input for gain adjustment
  let increment = legio.encoder.increment()
  if increment != 0:
    # Rotate to adjust gain
    gain += increment.cfloat * 0.05
    gain = clamp(gain, 0.0, 4.0)  # Allow up to 4x gain
  
  # Press to toggle meter mode
  if legio.encoder.risingEdge():
    if meterMode == METER_CV:
      meterMode = METER_AUDIO
    else:
      meterMode = METER_CV

proc updateGainRange() =
  ## Apply coarse gain adjustment from SW_RIGHT
  let swPos = legio.sw[1].read()
  var baseGain = 1.0.cfloat
  
  case swPos
  of 0:  # Down - reduce gain
    baseGain = 0.5
  of 1:  # Center - unity
    baseGain = 1.0
  of 2:  # Up - boost
    baseGain = 2.0
  else:
    baseGain = 1.0
  
  # Combine with encoder fine adjustment
  gain = baseGain * clamp(gain / baseGain, 0.5, 2.0)

proc checkHoldMode() =
  ## Check gate for hold/freeze mode
  holdActive = legio.gate()
  
  # Capture CV values when hold is first activated
  if holdActive:
    heldPitch = legio.getKnobValue(CONTROL_PITCH.cint)
    heldKnobTop = legio.getKnobValue(CONTROL_KNOB_TOP.cint)
    heldKnobBottom = legio.getKnobValue(CONTROL_KNOB_BOTTOM.cint)

proc updateCvMeter() =
  ## Display CV inputs on LEDs
  var pitch, knobTop, knobBottom: cfloat
  
  if holdActive:
    # Show held values
    pitch = heldPitch
    knobTop = heldKnobTop
    knobBottom = heldKnobBottom
  else:
    # Show current values
    pitch = legio.getKnobValue(CONTROL_PITCH.cint)
    knobTop = legio.getKnobValue(CONTROL_KNOB_TOP.cint)
    knobBottom = legio.getKnobValue(CONTROL_KNOB_BOTTOM.cint)
  
  # Left LED: pitch (red) + knobTop (green)
  legio.setLed(LED_LEFT.csize_t, pitch, knobTop, 0.0)
  
  # Right LED: knobBottom (blue)
  legio.setLed(LED_RIGHT.csize_t, 0.0, 0.0, knobBottom)

proc updateAudioMeter() =
  ## Display audio levels on LEDs
  # Left LED shows left channel (red=level)
  legio.setLed(LED_LEFT.csize_t, audioLevelL, 0.0, 0.0)
  
  # Right LED shows right channel (blue=level)
  legio.setLed(LED_RIGHT.csize_t, 0.0, 0.0, audioLevelR)

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  # Get routing mode from SW_LEFT
  let swPos = legio.sw[0].read()
  
  var maxLevelL = 0.0.cfloat
  var maxLevelR = 0.0.cfloat
  
  for i in 0..<size:
    # Read input
    let inL = input[0][i]
    let inR = input[1][i]
    
    # Apply routing
    var outL, outR: cfloat
    case swPos
    of 0:  # Down - stereo
      outL = inL * gain
      outR = inR * gain
    of 1:  # Center - mono left
      outL = inL * gain
      outR = inL * gain
    of 2:  # Up - mono right
      outL = inR * gain
      outR = inR * gain
    else:
      outL = inL * gain
      outR = inR * gain
    
    # Soft clip to prevent harsh distortion
    outL = clamp(outL, -1.0, 1.0)
    outR = clamp(outR, -1.0, 1.0)
    
    # Track peak levels for meter
    maxLevelL = max(maxLevelL, abs(outL))
    maxLevelR = max(maxLevelR, abs(outR))
    
    # Write output
    output[0][i] = outL
    output[1][i] = outR
  
  # Update audio levels (with decay for smoother display)
  audioLevelL = audioLevelL * 0.9 + maxLevelL * 0.1
  audioLevelR = audioLevelR * 0.9 + maxLevelR * 0.1

proc main() =
  # Initialize Legio hardware
  legio.init()
  
  echo "Daisy Legio - CV Meter & Audio Passthrough"
  echo "==========================================="
  echo "ENCODER: Rotate to adjust gain, press to toggle meter mode"
  echo "CONTROL_PITCH: CV input 1 (pitch)"
  echo "CONTROL_KNOB_TOP: CV input 2"
  echo "CONTROL_KNOB_BOTTOM: CV input 3"
  echo "SW_LEFT: Audio routing (stereo/mono L/mono R)"
  echo "SW_RIGHT: Gain range (0.5x/1.0x/2.0x)"
  echo "GATE: Hold CV readings"
  echo ""
  echo "LED modes:"
  echo "  CV mode: Left LED = pitch(R) + knob1(G), Right LED = knob2(B)"
  echo "  Audio mode: Left LED = L channel(R), Right LED = R channel(B)"
  
  # Initialize audio levels
  audioLevelL = 0.0
  audioLevelR = 0.0
  
  # Start audio processing
  legio.startAudio(audioCallback)
  
  # Main control loop
  while true:
    # Update controls
    legio.processAllControls()
    updateEncoder()
    updateGainRange()
    checkHoldMode()
    
    # Update LEDs based on mode
    case meterMode
    of METER_CV:
      updateCvMeter()
    of METER_AUDIO:
      updateAudioMeter()
    
    legio.updateLeds()
    
    # Update at ~60Hz
    legio.delayMs(16)

when isMainModule:
  main()
