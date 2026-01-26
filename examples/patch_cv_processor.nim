## Patch CV Processor
##
## Utility module for Eurorack: CV quantizer, slew limiter, and sample & hold.
##
## **Features:**
## - CV1: Quantizer (chromatic scale)
## - CV2: Slew limiter (smooth CV changes)
## - CV3: Sample & Hold (triggered by Gate 1)
## - CV4: Pass-through with gate generation
##
## **Controls:**
## - Knob 1: Quantizer scale select
## - Knob 2: Slew rate
## - Knob 3: S&H output level
## - Knob 4: Gate threshold
## - Encoder: Select display mode
## - Gate 1: S&H trigger input
## - Gate 2: Reset all processors
##
## **Hardware:** Daisy Patch (Eurorack module)
## **Note:** Untested on hardware - compilation test example

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_patch
import ../src/libdaisy_macros
import std/math

useDaisyNamespace()

const
  SAMPLE_RATE = 48000.0
  SEMITONES = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0]

type
  DisplayMode = enum
    MODE_CV_VALUES, MODE_PROCESSOR_STATUS, MODE_GATE_STATUS

var
  patch: DaisyPatch
  displayMode = MODE_CV_VALUES
  
  # Quantizer state
  quantizerScale = 0  # 0 = chromatic, 1 = major, 2 = minor
  
  # Slew limiter state
  slewCurrent: float32 = 0.0
  
  # Sample & Hold state
  sampleHoldValue: float32 = 0.0
  lastSampleHoldTrig = false
  
  # Gate generator state
  gateThreshold: float32 = 0.5
  gateState = false

proc quantizeCv(input: float32, scale: int): float32 =
  ## Quantize CV to semitone steps
  let voltsPerOctave = 1.0
  let semitone = input / voltsPerOctave * 12.0
  let quantized = round(semitone).int mod 12
  (SEMITONES[quantized] / 12.0) * voltsPerOctave

proc slewLimit(input: float32, rate: float32): float32 =
  ## Apply slew limiting (exponential smoothing)
  let alpha = clamp(rate, 0.001, 1.0)
  slewCurrent = slewCurrent * (1.0 - alpha) + input * alpha
  slewCurrent

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  ## Process audio (pass-through for now)
  for i in 0..<size:
    output[0][i] = input[0][i]
    output[1][i] = input[1][i]

proc main() =
  patch.init()
  patch.startAdc()
  patch.startAudio(audioCallback)
  
  var lastInc: int32 = 0
  
  while true:
    patch.processAllControls()
    
    # Read CV inputs
    let cv1 = patch.getKnobValue(CTRL_1)
    let cv2 = patch.getKnobValue(CTRL_2)
    let cv3 = patch.getKnobValue(CTRL_3)
    let cv4 = patch.getKnobValue(CTRL_4)
    
    # Process CV1: Quantizer
    let quantized = quantizeCv(cv1, quantizerScale)
    
    # Process CV2: Slew limiter
    let slewRate = patch.getKnobValue(CTRL_2)  # Use knob to control rate
    let slewed = slewLimit(cv2, slewRate)
    
    # Process CV3: Sample & Hold
    let sampleHoldTrig = patch.gateInputTrig(GATE_IN_1)
    if sampleHoldTrig and not lastSampleHoldTrig:
      sampleHoldValue = cv3
    lastSampleHoldTrig = sampleHoldTrig
    
    # Process CV4: Gate generator
    gateThreshold = patch.getKnobValue(CTRL_4)
    let newGateState = cv4 > gateThreshold
    if newGateState != gateState:
      gateState = newGateState
      patch.writeGateOutput(gateState)
    
    # Gate 2: Reset all processors
    if patch.gateInputTrig(GATE_IN_2):
      slewCurrent = 0.0
      sampleHoldValue = 0.0
      quantizerScale = 0
    
    # Encoder: Change display mode
    let inc = patch.encoder.increment()
    if inc != lastInc:
      if inc > lastInc:
        displayMode = DisplayMode((displayMode.ord + 1) mod 3)
      else:
        displayMode = DisplayMode((displayMode.ord + 2) mod 3)
      lastInc = inc
    
    # Encoder button: Toggle quantizer scale
    if patch.encoderRisingEdge():
      quantizerScale = (quantizerScale + 1) mod 3
    
    # Show activity on LED
    patch.seed.setLed(gateState)
    
    patch.delay(1)

when isMainModule:
  main()
