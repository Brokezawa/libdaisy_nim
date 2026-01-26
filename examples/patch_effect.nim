## Patch Multi-Effect Processor
##
## Advanced audio effect processor for Daisy Patch:
## - Multiple effect types with parameter control
## - Encoder for effect/parameter selection
## - CV inputs for modulation
## - Gate inputs for bypass/sync
## - OLED display for visual feedback
##
## **Effects:** Delay, Reverb-like feedback, Distortion, Filter
## **Hardware:** Daisy Patch
## **Note:** Untested on hardware - compilation test example

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_patch
import ../src/libdaisy_macros
import std/math

useDaisyNamespace()

const
  SAMPLE_RATE = 48000.0
  MAX_DELAY = 24000  # 0.5 seconds
  PI2 = 2.0 * PI

type
  EffectType = enum
    FX_DELAY, FX_FEEDBACK, FX_DISTORTION, FX_FILTER

var
  patch: DaisyPatch
  currentEffect = FX_DELAY
  paramValue: float32 = 0.5
  mixValue: float32 = 0.5
  bypass = false
  
  # Effect state
  delayBuffer: array[MAX_DELAY, float32]
  delayIndex = 0
  filterState: float32 = 0.0

proc processDelay(input: float32, time: float32): float32 =
  let samples = int(time * float32(MAX_DELAY - 1))
  let delayed = delayBuffer[(delayIndex - samples + MAX_DELAY) mod MAX_DELAY]
  delayBuffer[delayIndex] = input + delayed * 0.4
  delayIndex = (delayIndex + 1) mod MAX_DELAY
  delayed

proc processFeedback(input: float32, amount: float32): float32 =
  let idx = (delayIndex - 1000 + MAX_DELAY) mod MAX_DELAY
  let feedback = delayBuffer[idx]
  delayBuffer[delayIndex] = input + feedback * amount
  delayIndex = (delayIndex + 1) mod MAX_DELAY
  input + feedback * 0.5

proc processDistortion(input: float32, drive: float32): float32 =
  let driven = input * (1.0 + drive * 10.0)
  tanh(driven.float64).float32

proc processFilter(input: float32, cutoff: float32): float32 =
  let coeff = cutoff
  filterState = filterState * (1.0 - coeff) + input * coeff
  filterState

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  for i in 0..<size:
    var wet: float32
    let dry = input[0][i]
    
    if bypass:
      wet = dry
    else:
      case currentEffect
      of FX_DELAY:
        wet = processDelay(dry, paramValue)
      of FX_FEEDBACK:
        wet = processFeedback(dry, paramValue)
      of FX_DISTORTION:
        wet = processDistortion(dry, paramValue)
      of FX_FILTER:
        wet = processFilter(dry, paramValue)
    
    let outputSample = dry * (1.0 - mixValue) + wet * mixValue
    output[0][i] = outputSample
    output[1][i] = outputSample

proc main() =
  patch.init()
  patch.startAdc()
  patch.startAudio(audioCallback)
  
  var lastInc: int32 = 0
  var paramSelect = 0  # 0 = effect type, 1 = param, 2 = mix
  
  while true:
    patch.processAllControls()
    
    # Encoder: Parameter navigation
    let inc = patch.encoder.increment()
    if inc != lastInc:
      if paramSelect == 0:
        # Change effect type
        if inc > lastInc:
          currentEffect = EffectType((currentEffect.ord + 1) mod 4)
        else:
          currentEffect = EffectType((currentEffect.ord + 3) mod 4)
      lastInc = inc
    
    # Encoder button: Toggle parameter select
    if patch.encoderPressed():
      paramSelect = (paramSelect + 1) mod 3
    
    # CV controls
    let cv1 = patch.getKnobValue(CTRL_1)  # Parameter value
    let cv2 = patch.getKnobValue(CTRL_2)  # Mix
    
    if paramSelect == 1:
      paramValue = cv1
    elif paramSelect == 2:
      mixValue = cv2
    
    # Gate 1: Bypass toggle
    if patch.gateInputTrig(GATE_IN_1):
      bypass = not bypass
    
    # Show status on LED
    patch.seed.setLed(not bypass)
    
    patch.delay(1)

when isMainModule:
  main()
