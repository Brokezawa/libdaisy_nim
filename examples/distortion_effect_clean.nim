## Audio Distortion Effect - Clean API
##
## Simple distortion/overdrive audio effect

import ../src/libdaisy
import std/math
useDaisyNamespace()


var
  drive = 0.5'f32    # Distortion amount
  mix = 0.5'f32      # Dry/wet mix

proc softClip(x: float32): float32 {.inline.} =
  ## Soft clipping distortion
  if x > 1.0'f32:
    return 1.0'f32
  elif x < -1.0'f32:
    return -1.0'f32
  else:
    return x - (x * x * x) / 3.0'f32

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  for i in 0..<size:
    let inL = input[0][i]
    let inR = input[1][i]
    
    # Apply gain before clipping
    let gainedL = inL * (1.0'f32 + drive * 10.0'f32)
    let gainedR = inR * (1.0'f32 + drive * 10.0'f32)
    
    # Soft clip the signal
    let distortedL = softClip(gainedL)
    let distortedR = softClip(gainedR)
    
    # Mix dry and wet signals
    output[0][i] = inL * (1.0'f32 - mix) + distortedL * mix
    output[1][i] = inR * (1.0'f32 - mix) + distortedR * mix

proc main() =
  var daisy = initDaisy()
  
  # Start audio processing
  daisy.setSampleRate(SAI_48KHZ)
  daisy.setBlockSize(48)
  daisy.startAudio(audioCallback)
  
  # Blink LED to show we're running
  var ledState = false
  while true:
    ledState = not ledState
    daisy.setLed(ledState)
    daisy.delay(500)

when isMainModule:
  main()
