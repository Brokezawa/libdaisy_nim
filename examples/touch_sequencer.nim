## Touch Sequencer Demo
##
## Demonstrates MPR121 capacitive touch sensor and NeoTrellis RGB button pad
## Creates an interactive step sequencer with visual feedback
##
## Hardware:
##   - Daisy Seed
##   - MPR121 12-channel touch sensor on I2C
##   - NeoTrellis 4x4 RGB button pad on I2C
##   - I2C connections: SCL=D11 (PB8), SDA=D12 (PB9)
##
## Features:
##   - 12-key touch keyboard (MPR121) for note selection
##   - 16-step sequencer with NeoTrellis grid
##   - Visual feedback via RGB LEDs
##   - Touch velocity affects note brightness
##   - Simple drum/tone generation

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_i2c
import ../src/libdaisy_serial
import ../src/dev/mpr121
import ../src/dev/neotrellis
import std/math
useDaisyNamespace()


const
  NUM_STEPS = 16
  NUM_NOTES = 12

var
  touchSensor: Mpr121I2C
  trellis: NeoTrellisI2C
  currentStep = 0
  tempo = 120  # BPM
  stepDelay = 0  # Calculated from tempo
  
  # Sequencer pattern: 16 steps x 12 notes
  pattern: array[NUM_STEPS, array[NUM_NOTES, bool]]
  
  # Touch state tracking
  lastTouched: uint16 = 0
  
  # Note frequencies (chromatic scale starting from C4)
  noteFreqs: array[12, float32] = [
    261.63'f32,  # C4
    277.18'f32,  # C#4
    293.66'f32,  # D4
    311.13'f32,  # D#4
    329.63'f32,  # E4
    349.23'f32,  # F4
    369.99'f32,  # F#4
    392.00'f32,  # G4
    415.30'f32,  # G#4
    440.00'f32,  # A4
    466.16'f32,  # A#4
    493.88'f32   # B4
  ]

# Audio state
var
  phase = 0.0'f32
  frequency = 440.0'f32
  amplitude = 0.0'f32
  envelope = 0.0'f32

proc calculateStepDelay(bpm: int): int =
  ## Calculate delay in milliseconds for each step based on BPM
  ## 16 steps per bar, 4 beats per bar = 4 steps per beat
  result = (60000 div bpm) div 4

proc rgbToColor(r, g, b: uint8): uint32 =
  ## Convert RGB values to packed 32-bit color
  result = (r.uint32 shl 16) or (g.uint32 shl 8) or b.uint32

proc colorToRGB(color: uint32, r, g, b: var uint8) =
  ## Extract RGB values from packed color
  r = uint8((color shr 16) and 0xFF)
  g = uint8((color shr 8) and 0xFF)
  b = uint8(color and 0xFF)

proc updateTrellisDisplay() =
  ## Update NeoTrellis LED display based on current step
  for step in 0..<16:
    var hasNote = false
    for note in 0..<12:
      if pattern[step][note]:
        hasNote = true
        break
    
    var r, g, b: uint8
    if step == currentStep:
      # Current step is bright white
      r = 255; g = 255; b = 255
    elif hasNote:
      # Steps with notes are green
      r = 0; g = 50; b = 0
    else:
      # Empty steps are dim blue
      r = 0; g = 0; b = 10
    
    trellis.pixels.setPixelColor(step.uint16, r, g, b)
  
  trellis.pixels.show()

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  const sampleRate = 48000.0'f32
  const envelopeDecay = 0.9995'f32
  
  for i in 0..<size:
    # Simple sine wave synthesis with envelope
    let sample = sin(phase * 2.0'f32 * PI) * amplitude * envelope
    
    output[0][i] = sample
    output[1][i] = sample
    
    # Update phase
    phase += frequency / sampleRate
    if phase >= 1.0'f32:
      phase -= 1.0'f32
    
    # Decay envelope
    envelope *= envelopeDecay

proc triggerNote(noteIndex: int) =
  ## Trigger a note with envelope
  if noteIndex >= 0 and noteIndex < 12:
    frequency = noteFreqs[noteIndex]
    amplitude = 0.3'f32
    envelope = 1.0'f32

proc main() =
  var daisy = initDaisy()
  
  startLog()
  printLine("Touch Sequencer Demo")
  printLine("====================")
  printLine()
  
  # Initialize MPR121 touch sensor
  var touchConfig: Mpr121Config
  touchConfig.transport_config.periph = I2C_1
  touchConfig.transport_config.speed = I2C_400KHZ
  touchConfig.transport_config.scl = D11()
  touchConfig.transport_config.sda = D12()
  
  let touchInit = touchSensor.init(touchConfig)
  if touchInit != MPR121_OK:
    printLine("ERROR: MPR121 initialization failed!")
  else:
    printLine("MPR121 touch sensor initialized")
    
    # Set touch/release thresholds for all channels
    touchSensor.setThresholds(12, 6)  # Touch=12, Release=6
  
  # Initialize NeoTrellis
  var trellisConfig: NeoTrellisConfig
  trellisConfig.transport_config.periph = I2C_1
  trellisConfig.transport_config.speed = I2C_400KHZ
  trellisConfig.transport_config.scl = D11()
  trellisConfig.transport_config.sda = D12()
  trellisConfig.transport_config.address = NEO_TRELLIS_ADDR
  
  let trellisInit = trellis.init(trellisConfig)
  if trellisInit != NEOTRELLIS_OK:
    printLine("ERROR: NeoTrellis initialization failed!")
  else:
    printLine("NeoTrellis button pad initialized")
    
    # Activate all keys for both rising and falling edges
    let edges = (NEO_TRELLIS_RISING.uint8 or NEO_TRELLIS_FALLING.uint8)
    for row in 0'u8..<4'u8:
      for col in 0'u8..<4'u8:
        trellis.activateKey(col, row, edges, true)
  
  printLine()
  printLine("Controls:")
  printLine("  MPR121: Touch pads 0-11 to play notes")
  printLine("  NeoTrellis: Press buttons to toggle steps")
  printLine()
  
  # Initialize pattern (all off)
  for step in 0..<NUM_STEPS:
    for note in 0..<NUM_NOTES:
      pattern[step][note] = false
  
  # Calculate step delay from tempo
  stepDelay = calculateStepDelay(tempo)
  
  # Start audio processing
  daisy.setSampleRate(SAI_48KHZ)
  daisy.setBlockSize(48)
  daisy.startAudio(audioCallback)
  
  var lastStepCounter = 0'u32
  var ledState = false
  var loopCounter = 0'u32
  
  # Initial display update
  if trellisInit == NEOTRELLIS_OK:
    updateTrellisDisplay()
  
  while true:
    inc loopCounter
    
    # Handle MPR121 touch input
    if touchInit == MPR121_OK:
      let touched = touchSensor.touched()
      
      # Detect newly touched pads
      for i in 0..<12:
        let mask = 1'u16 shl i
        if (touched and mask) != 0 and (lastTouched and mask) == 0:
          # Pad was just touched
          print("Touch: Pad ")
          print(i)
          printLine()
          
          # Play the note
          triggerNote(i)
          
          # Toggle the note in current step
          pattern[currentStep][i] = not pattern[currentStep][i]
          
          if trellisInit == NEOTRELLIS_OK:
            updateTrellisDisplay()
      
      lastTouched = touched
    
    # Handle NeoTrellis button input
    if trellisInit == NEOTRELLIS_OK:
      trellis.process()
      
      for i in 0'u8..<16'u8:
        if trellis.getRising(i):
          print("Button pressed: ")
          print(i.int)
          printLine()
          
          # Jump to this step
          currentStep = i.int
          updateTrellisDisplay()
    
    # Sequencer step advancement (based on loop counter)
    # Advance step every stepDelay loops
    if loopCounter - lastStepCounter >= stepDelay.uint32:
      lastStepCounter = loopCounter
      
      # Trigger notes for current step
      for note in 0..<NUM_NOTES:
        if pattern[currentStep][note]:
          triggerNote(note)
      
      # Advance to next step
      currentStep = (currentStep + 1) mod NUM_STEPS
      
      if trellisInit == NEOTRELLIS_OK:
        updateTrellisDisplay()
      
      # Toggle LED on each step
      ledState = not ledState
      daisy.setLed(ledState)
    
    daisy.delay(1)  # 1ms delay = ~1000 loops/sec

when isMainModule:
  main()
