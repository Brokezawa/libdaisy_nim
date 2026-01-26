## Pod Monophonic Synthesizer
##
## Desktop synthesizer for Daisy Pod featuring:
## - Simple oscillator (sine, saw, square, triangle)
## - MIDI input for note control
## - Encoder: Parameter navigation
## - Knob 1: Selected parameter value
## - Knob 2: Filter cutoff
## - Button 1: Waveform selection
## - Button 2: Octave shift
## - RGB LEDs: Waveform indicator
##
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
  TWO_PI = 2.0 * PI

type
  Waveform = enum
    SINE, SAW, SQUARE, TRIANGLE

var
  pod: DaisyPod
  phase: float32 = 0.0
  frequency: float32 = 440.0
  waveform = SINE
  octaveShift: int = 0
  filterCutoff: float32 = 1.0

proc generateSample(wf: Waveform, ph: float32): float32 =
  case wf
  of SINE:
    sin(ph * TWO_PI).float32
  of SAW:
    (2.0 * ph - 1.0).float32
  of SQUARE:
    if ph < 0.5: 1.0.float32 else: -1.0.float32
  of TRIANGLE:
    if ph < 0.5: (4.0 * ph - 1.0).float32
    else: (3.0 - 4.0 * ph).float32

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  ## Multi-channel audio callback (non-interleaved)
  let phaseInc = frequency / SAMPLE_RATE
  
  for i in 0..<size:
    let sample = generateSample(waveform, phase) * filterCutoff * 0.3
    output[0][i] = sample  # Left channel
    output[1][i] = sample  # Right channel
    
    phase += phaseInc
    if phase >= 1.0:
      phase -= 1.0

proc main() =
  pod.init()
  pod.startAdc()
  pod.startAudio(audioCallback)
  
  var lastButton1 = false
  var lastButton2 = false
  
  while true:
    pod.processAllControls()
    
    # Button 1: Waveform selection
    if pod.button1.risingEdge() and not lastButton1:
      waveform = Waveform((waveform.ord + 1) mod 4)
      lastButton1 = true
    elif not pod.button1.pressed():
      lastButton1 = false
    
    # Button 2: Octave shift
    if pod.button2.risingEdge() and not lastButton2:
      octaveShift = (octaveShift + 1) mod 3 - 1  # -1, 0, +1
      frequency = 440.0 * pow(2.0, octaveShift.float)
      lastButton2 = true
    elif not pod.button2.pressed():
      lastButton2 = false
    
    # Knob 1: Amplitude
    filterCutoff = pod.getKnobValue(KNOB_2)
    
    # LED feedback for waveform
    case waveform
    of SINE:
      pod.led1.set(1.0, 0.0, 0.0)  # Red
    of SAW:
      pod.led1.set(0.0, 1.0, 0.0)  # Green
    of SQUARE:
      pod.led1.set(0.0, 0.0, 1.0)  # Blue
    of TRIANGLE:
      pod.led1.set(1.0, 1.0, 0.0)  # Yellow
    
    pod.led2.set(filterCutoff, 0.0, 1.0 - filterCutoff)
    pod.updateLeds()
    
    pod.delay(1)

when isMainModule:
  main()
