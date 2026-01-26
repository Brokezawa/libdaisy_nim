## Field Keyboard Synthesizer
##
## 16-key keyboard synthesizer for Daisy Field:
## - 16 capacitive touch keys (2 rows × 8 keys)
## - 8 knobs control voice parameters
## - CV inputs for modulation
##
## **Features:**
## - Monophonic synthesizer with 6 waveforms
## - Keyboard scanning with rising/falling edge detection
## - Simple envelope on note on/off
##
## **Hardware:** Daisy Field
## **Note:** Untested on hardware - compilation test example
## **Note:** LED feedback disabled due to type system complexity

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_field
import ../src/libdaisy_macros
import std/[math, random]

useDaisyNamespace()

const
  SAMPLE_RATE = 48000.0
  TWO_PI = 2.0 * PI
  
  # Note frequencies for chromatic scale starting at C4
  NOTE_FREQS: array[16, float32] = [
    261.63, 277.18, 293.66, 311.13,  # C4, C#4, D4, D#4
    329.63, 349.23, 369.99, 392.00,  # E4, F4, F#4, G4
    415.30, 440.00, 466.16, 493.88,  # G#4, A4, A#4, B4
    523.25, 554.37, 587.33, 622.25   # C5, C#5, D5, D#5
  ]

type
  Waveform = enum
    SINE, SAW, SQUARE, TRIANGLE, PULSE, NOISE

var
  field: DaisyField
  phase: float32 = 0.0
  frequency: float32 = 440.0
  amplitude: float32 = 0.0
  waveform = SINE
  activeKey: int = -1  # Currently playing key (-1 = none)

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
  of PULSE:
    if ph < 0.25: 1.0.float32 else: -1.0.float32
  of NOISE:
    (float32(rand(1000)) / 500.0 - 1.0).float32

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  let phaseInc = frequency / SAMPLE_RATE
  
  for i in 0..<size:
    let sample = generateSample(waveform, phase) * amplitude * 0.3
    output[0][i] = sample
    output[1][i] = sample
    
    phase += phaseInc
    if phase >= 1.0:
      phase -= 1.0
    
    # Envelope release
    if amplitude > 0.001:
      amplitude *= 0.9995  # Slow release

proc main() =
  field.init()
  field.startAdc()
  field.startAudio(audioCallback)
  
  while true:
    field.processAllControls()
    
    # Scan keyboard
    for key in 0..<16:
      # Rising edge - key press
      if field.keyboardRisingEdge(key.csize_t):
        activeKey = key
        frequency = NOTE_FREQS[key]
        amplitude = 0.8
      
      # Falling edge - key release
      if field.keyboardFallingEdge(key.csize_t):
        if activeKey == key:
          activeKey = -1
          amplitude = 0.0
    
    # Knobs control parameters
    let knob1 = field.getKnobValue(KNOB_1.csize_t)  # Waveform select
    waveform = Waveform(int(knob1 * 5.99))  # 0-5 for 6 waveforms
    
    field.seed.delay(1)

when isMainModule:
  main()
