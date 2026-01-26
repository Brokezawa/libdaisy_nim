## CV Quantizer for Daisy Patch SM
## =================================
##
## **Hardware:** Daisy Patch SM Eurorack module
##
## **Description:**
## Musical CV quantizer that snaps incoming voltage to chromatic scale.
## Demonstrates CV processing for pitch quantization (1V/octave standard).
##
## **Functionality:**
## - Quantizes CV input 1 to chromatic scale (12-TET)
## - CV input 2 controls quantization amount (dry/wet mix)
## - Quantized output on CV Out 1
## - Raw (unquantized) output on CV Out 2
## - Gate input 1 triggers note hold
## - LED indicates gate state
##
## **CV Mapping:**
## - CV In 1: Pitch input (1V/octave, 0V = C4)
## - CV In 2: Quantize amount (0V = bypass, 5V = full quantize)
## - CV Out 1: Quantized pitch output
## - CV Out 2: Raw pitch output (bypass)
## - Gate In 1: Hold current note
##
## **Expected Behavior:**
## - CV Out 1 snaps to semitone grid when CV In 2 > 0V
## - CV Out 2 always passes CV In 1 unmodified
## - Gate In 1 holds the current quantized note
## - LED on when gate is high
##
## **Use Cases:**
## - Eurorack pitch quantizer
## - Chromatic scale quantization
## - Learning CV quantization algorithms
## - Sample & hold with gate trigger

import ../src/libdaisy_patch_sm
import ../src/libdaisy_macros

useDaisyNamespace()

# Simple round function for embedded (no std/math available)
proc round(x: cfloat): cfloat {.inline.} =
  if x >= 0.0: (x + 0.5).cfloat.int.cfloat
  else: (x - 0.5).cfloat.int.cfloat

# Quantize voltage to nearest semitone (1V/octave standard)
proc quantizeToSemitone(voltage: cfloat): cfloat =
  ## Quantize a 1V/octave CV to nearest semitone
  ##
  ## 1V/octave standard: Each semitone = 1/12 volt
  ## Example: C4 = 0V, C#4 = 0.0833V, D4 = 0.1667V, etc.
  
  # Convert voltage to semitones (12 semitones per volt)
  let semitones = voltage * 12.0
  
  # Round to nearest integer semitone
  let quantized_semitones = round(semitones)
  
  # Convert back to voltage
  result = quantized_semitones / 12.0

proc main() =
  var patchsm: DaisyPatchSM
  
  # Initialize hardware
  patchsm.init()
  patchsm.startAdc()
  patchsm.startDac()
  
  var heldNote: cfloat = 0.0  # Held note voltage
  var isHolding = false       # Hold state
  
  # Main loop
  while true:
    # Update all control inputs
    patchsm.processAllControls()
    
    # Read CV inputs (normalize to voltage)
    # CV inputs are bipolar: 0.0 = -5V, 0.5 = 0V, 1.0 = +5V
    # Convert to actual voltage: (normalized - 0.5) * 10.0
    let pitchNormalized = patchsm.getAdcValue(CV_1.cint)
    let pitchVoltage = (pitchNormalized - 0.5) * 10.0  # -5V to +5V
    
    # Quantize amount: 0.0 = bypass, 1.0 = full quantize
    let quantizeAmount = patchsm.getAdcValue(CV_2.cint)
    
    # Quantize the pitch
    let quantizedPitch = quantizeToSemitone(pitchVoltage)
    
    # Mix between dry (raw) and wet (quantized) based on amount
    let outputPitch = pitchVoltage * (1.0 - quantizeAmount) + quantizedPitch * quantizeAmount
    
    # Check gate input for note hold (sample & hold)
    let gateActive = patchsm.gate_in_1.state()
    
    if gateActive and not isHolding:
      # Rising edge - capture current note
      heldNote = outputPitch
      isHolding = true
    elif not gateActive:
      # Gate released
      isHolding = false
    
    # Determine final output (held or live)
    let finalOutput = if isHolding: heldNote else: outputPitch
    
    # Output to CV outs
    # Convert back to 0-5V range for DAC: (voltage + 5) / 2
    # But clamp to avoid DAC out of range
    var cvOut1 = (finalOutput + 5.0) / 2.0
    var cvOut2 = (pitchVoltage + 5.0) / 2.0
    
    # Clamp to 0-5V range
    if cvOut1 < 0.0: cvOut1 = 0.0
    if cvOut1 > 5.0: cvOut1 = 5.0
    if cvOut2 < 0.0: cvOut2 = 0.0
    if cvOut2 > 5.0: cvOut2 = 5.0
    
    patchsm.writeCvOut(CV_OUT_1.cint, cvOut1)  # Quantized output
    patchsm.writeCvOut(CV_OUT_2.cint, cvOut2)  # Raw output
    
    # LED indicates gate state
    patchsm.setLed(gateActive)
    
    # Delay 1ms
    patchsm.delay(1)

when isMainModule:
  main()
