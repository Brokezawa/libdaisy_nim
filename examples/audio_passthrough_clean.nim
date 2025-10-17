## Audio Passthrough Example - Clean API
## 
## This example demonstrates simple audio passthrough using the clean Nim-friendly API

import panicoverride
import ../src/libdaisy
useDaisyNamespace()


# Audio callback - simply pass input to output
proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  for i in 0..<size:
    output[0][i] = input[0][i]  # Left channel
    output[1][i] = input[1][i]  # Right channel

proc main() =
  var daisy = initDaisy()
  
  # Start audio processing
  daisy.startAudio(audioCallback)
  
  # Blink LED to show we're running
  var ledState = false
  while true:
    ledState = not ledState
    daisy.setLed(ledState)
    daisy.delay(500)

when isMainModule:
  main()
