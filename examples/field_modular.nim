## Field CV/Gate Modular Utility
##
## CV processing and sequencer for Daisy Field:
## - 8-step sequencer with knob-programmable values
## - 4 CV inputs with display
## - Gate pattern generator
## - Keyboard triggers sequencer steps
##
## **Features:**
## - Visual step sequencer with knob control
## - CV input monitoring
## - Gate output patterns
## - Keyboard as step trigger/selector
##
## **Hardware:** Daisy Field
## **Note:** Untested on hardware - compilation test example

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_field
import ../src/libdaisy_macros

useDaisyNamespace()

const
  NUM_STEPS = 8

var
  field: DaisyField
  stepValues: array[NUM_STEPS, float32]
  currentStep = 0
  gateState = false
  cvInputs: array[4, float32]

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  ## Simple passthrough with CV-based amplitude modulation
  for i in 0..<size:
    let cvMod = cvInputs[0]  # Use CV1 as amplitude modulation
    output[0][i] = input[0][i] * cvMod
    output[1][i] = input[1][i] * cvMod

proc updateGateOutput() =
  ## Update gate output based on current step pattern
  # Simple pattern: alternate gates on even/odd steps
  gateState = (currentStep mod 2) == 0
  field.gate_out.write(gateState)

proc updateCvOutputs() =
  ## Set CV outputs based on sequencer state
  # CV Out 1: Current step value (0-5V, 12-bit DAC)
  let cv1Value = (stepValues[currentStep] * 4095.0).uint16
  field.setCvOut1(cv1Value)
  
  # CV Out 2: Inverted step value
  let cv2Value = ((1.0 - stepValues[currentStep]) * 4095.0).uint16
  field.setCvOut2(cv2Value)

proc advanceStep() =
  ## Move to next sequencer step
  currentStep = (currentStep + 1) mod NUM_STEPS
  updateGateOutput()
  updateCvOutputs()

proc main() =
  field.init()
  field.startAdc()
  field.startAudio(audioCallback)
  
  # Initialize step values
  for i in 0..<NUM_STEPS:
    stepValues[i] = float32(i) / float32(NUM_STEPS - 1)
  
  var counter = 0
  var lastKeyPressed = -1
  
  while true:
    field.processAllControls()
    
    # Read CV inputs (scaled from ADC 0-1 to ±5V)
    for i in 0..<4:
      let raw = field.getCvValue((FieldCV.CV_1.ord + i).csize_t)
      cvInputs[i] = (raw - 0.5) * 10.0  # Convert to ±5V range
      # Clamp for amplitude mod (0-1)
      if i == 0:
        cvInputs[i] = if cvInputs[i] < 0: 0.0 else: (if cvInputs[i] > 1.0: 1.0 else: cvInputs[i])
    
    # Keyboard controls step selection and triggering
    for key in 0..<16:
      if field.keyboardRisingEdge(key.csize_t):
        if key < NUM_STEPS:
          # Keys 0-7: Jump to step
          currentStep = key
          updateGateOutput()
          updateCvOutputs()
          lastKeyPressed = key
        else:
          # Keys 8-15: Advance sequencer
          advanceStep()
          lastKeyPressed = key
    
    # Read knobs as step values (knobs 1-8 = steps 1-8)
    for i in 0..<NUM_STEPS:
      stepValues[i] = field.getKnobValue((FieldKnob.KNOB_1.ord + i).csize_t)
    
    # Auto-advance sequencer every 500ms
    counter.inc
    if counter > 500:
      counter = 0
      advanceStep()
    
    # Show active step on seed LED
    field.seed.setLed(currentStep mod 2 == 0)
    
    field.seed.delay(1)

when isMainModule:
  main()
