## Sine Wave Generator
##
## This example generates a simple sine wave using the audio callback

import ../src/libdaisy
import std/math
useDaisyNamespace()


const SAMPLE_RATE = 48000.0
var phase = 0.0
var frequency = 440.0  # A4 note

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  let phaseIncrement = frequency * 2.0 * PI / SAMPLE_RATE
  
  for i in 0..<size:
    let sample = sin(phase).float32
    output[0][i] = sample * 0.5  # Left channel (50% volume)
    output[1][i] = sample * 0.5  # Right channel
    
    phase += phaseIncrement
    if phase >= 2.0 * PI:
      phase -= 2.0 * PI

proc main() =
  var daisy = initDaisy()
  
  # Set sample rate and block size
  daisy.setSampleRate(SAI_48KHZ)
  daisy.setBlockSize(48)
  
  # Start audio
  daisy.startAudio(audioCallback)
  
  # Blink LED
  var ledState = false
  while true:
    ledState = not ledState
    daisy.setLed(ledState)
    daisy.delay(500)

when isMainModule:
  main()
