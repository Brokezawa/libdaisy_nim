## Pod Multi-Effect Processor
##
## Stereo audio effect processor for Daisy Pod:
## - Encoder: Effect selection
## - Knob 1: Mix/wet-dry blend
## - Knob 2: Effect parameter (time, depth, etc.)
## - Button 1: Bypass toggle
## - Button 2: Tap tempo
## - RGB LEDs: Effect status indication
##
## **Effects:** Delay, Tremolo, Distortion, Bitcrusher
## **Hardware:** Daisy Pod
## **Note:** Untested on hardware - compilation test example

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_pod
import ../src/libdaisy_macros
import std/math

useDaisyNamespace()

const
  SAMPLE_RATE = 48000.0
  MAX_DELAY = 24000  # 0.5 seconds at 48kHz

type
  EffectType = enum
    FX_DELAY, FX_TREMOLO, FX_DISTORTION, FX_BITCRUSH

var
  pod: DaisyPod
  currentEffect = FX_DELAY
  bypass = false
  mix: float32 = 0.5
  param: float32 = 0.5
  
  # Effect state
  delayBuffer: array[MAX_DELAY, float32]
  delayIndex: int = 0
  tremoloPhase: float32 = 0.0

proc processDelay(input: float32, delayTime: float32): float32 =
  let samples = (delayTime * (MAX_DELAY - 1).float32).int
  let delayed = delayBuffer[(delayIndex - samples + MAX_DELAY) mod MAX_DELAY]
  delayBuffer[delayIndex] = input + delayed * 0.5
  delayIndex = (delayIndex + 1) mod MAX_DELAY
  delayed

proc processTremolo(input: float32, depth: float32, rate: float32): float32 =
  let lfo = sin(tremoloPhase * 2.0 * PI) * 0.5 + 0.5
  tremoloPhase += rate / SAMPLE_RATE
  if tremoloPhase >= 1.0:
    tremoloPhase -= 1.0
  input * (1.0 - depth + lfo * depth)

proc processDistortion(input: float32, drive: float32): float32 =
  let boosted = input * (1.0 + drive * 10.0)
  tanh(boosted.float64).float32

proc processBitcrush(input: float32, bits: float32): float32 =
  let levels = pow(2.0, (bits * 12.0 + 4.0).float64)  # 4-16 bits
  (floor(input.float64 * levels) / levels).float32

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  for i in 0..<size:
    var wet: float32
    let dry = input[0][i]
    
    if bypass:
      wet = dry
    else:
      case currentEffect
      of FX_DELAY:
        wet = processDelay(dry, param)
      of FX_TREMOLO:
        wet = processTremolo(dry, param, mix * 10.0)
      of FX_DISTORTION:
        wet = processDistortion(dry, param)
      of FX_BITCRUSH:
        wet = processBitcrush(dry, param)
    
    let output_sample = dry * (1.0 - mix) + wet * mix
    output[0][i] = output_sample
    output[1][i] = output_sample

proc main() =
  pod.init()
  pod.startAdc()
  pod.startAudio(audioCallback)
  
  var lastInc: int32 = 0
  
  while true:
    pod.processAllControls()
    
    # Encoder: Effect selection
    let inc = pod.encoder.increment()
    if inc != lastInc:
      if inc > lastInc:
        currentEffect = EffectType((currentEffect.ord + 1) mod 4)
      elif inc < lastInc:
        currentEffect = EffectType((currentEffect.ord + 3) mod 4)
      lastInc = inc
    
    # Button 1: Bypass
    if pod.button1.risingEdge():
      bypass = not bypass
    
    # Knobs
    mix = pod.getKnobValue(KNOB_1)
    param = pod.getKnobValue(KNOB_2)
    
    # LED feedback
    if bypass:
      pod.led1.set(0.2, 0.0, 0.0)
    else:
      case currentEffect
      of FX_DELAY:
        pod.led1.set(1.0, 0.0, 0.0)
      of FX_TREMOLO:
        pod.led1.set(0.0, 1.0, 0.0)
      of FX_DISTORTION:
        pod.led1.set(1.0, 0.5, 0.0)
      of FX_BITCRUSH:
        pod.led1.set(0.0, 0.0, 1.0)
    
    pod.led2.set(mix, 0.0, 1.0 - mix)
    pod.updateLeds()
    
    pod.delay(1)

when isMainModule:
  main()
