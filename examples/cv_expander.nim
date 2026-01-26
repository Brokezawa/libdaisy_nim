## CV Expander Example - MAX11300 Eurorack CV/Gate I/O
##
## Demonstrates MAX11300 PIXI with multiple CV inputs/outputs.
## This example shows a practical Eurorack CV processor with:
## - 4x CV inputs (-5V to +5V) on pins 0-3
## - 4x CV outputs (-5V to +5V) on pins 4-7
## - DMA-based continuous updates via Start() method
## - LED feedback for activity
##
## **Processing Examples:**
## - Channel 0: Quantize to semitones (1V/oct standard)
## - Channel 1: Invert signal (-1x gain)
## - Channel 2: Attenuate (0.5x gain)
## - Channel 3: Pass through unchanged
##
## ⚠️ **IMPORTANT**: This implementation has NOT been tested on hardware.
## It follows libDaisy's MAX11300 driver but should be considered experimental
## until hardware validation is complete.

import panicoverride
import ../src/libdaisy
import ../src/dev/max11300
import std/math

useDaisyNamespace()

const
  NUM_CV_IN = 4
  NUM_CV_OUT = 4

var
  pixi: MAX11300[1]
  hw: DaisySeed
  cvInputs: array[NUM_CV_IN, float32]
  cvOutputs: array[NUM_CV_OUT, float32]
  updateCount: uint32 = 0
  errorFlag: bool = false

proc updateComplete(context: pointer) {.cdecl.} =
  ## Called by MAX11300 DMA after each update cycle
  ## Keep this minimal - runs in interrupt context!
  updateCount += 1

proc processCV() =
  ## Main CV processing logic
  ## Read all inputs
  for i in 0..<NUM_CV_IN:
    cvInputs[i] = pixi.readAnalogPinVolts(0, i.MAX11300Pin)
  
  # Example processing algorithms:
  
  # Channel 0: Quantize to semitones (1V/octave standard for modular synths)
  # Each semitone = 1/12 volt, so quantize to nearest 1/12V step
  cvOutputs[0] = (cvInputs[0] * 12.0).round() / 12.0
  
  # Channel 1: Invert (-1x)
  cvOutputs[1] = -cvInputs[1]
  
  # Channel 2: Attenuate (50% = 0.5x)
  cvOutputs[2] = cvInputs[2] * 0.5
  
  # Channel 3: Pass through (unity gain)
  cvOutputs[3] = cvInputs[3]
  
  # Write outputs
  for i in 0..<NUM_CV_OUT:
    pixi.writeAnalogPinVolts(0, (i + NUM_CV_IN).MAX11300Pin, cvOutputs[i])

proc audioCallback(input_buffer, output_buffer: AudioBuffer, size: int) {.cdecl.} =
  ## Minimal audio callback (example focuses on CV I/O, not audio)
  for i in 0 ..< size:
    # Pass through audio unchanged
    output_buffer[0][i] = input_buffer[0][i]
    output_buffer[1][i] = input_buffer[1][i]

# Initialize hardware
hw.init()
hw.setLed(false)

# Configure MAX11300
var config: MAX11300Config
config.transport_config.defaults()

if pixi.init(config) != MAX_OK:
  # Fast blink on init error
  errorFlag = true
  while true:
    hw.setLed(true)
    hw.delay(100)
    hw.setLed(false)
    hw.delay(100)

# Configure input pins (pins 0-3 as ADC)
for i in 0..<NUM_CV_IN:
  if pixi.configurePinAsAnalogRead(0, i.MAX11300Pin, ADC_NEG5_TO_5) != MAX_OK:
    # Medium blink on config error
    errorFlag = true
    while true:
      hw.setLed(true)
      hw.delay(200)
      hw.setLed(false)
      hw.delay(200)

# Configure output pins (pins 4-7 as DAC)
for i in 0..<NUM_CV_OUT:
  let pinNum = (i + NUM_CV_IN).MAX11300Pin
  if pixi.configurePinAsAnalogWrite(0, pinNum, DAC_NEG5_TO_5) != MAX_OK:
    # Slow blink on config error
    errorFlag = true
    while true:
      hw.setLed(true)
      hw.delay(300)
      hw.setLed(false)
      hw.delay(300)

# Start DMA updates for continuous hardware sync
# This enables automatic background updates of ADC/DAC values
if pixi.start(updateComplete, nil) != MAX_OK:
  # DMA start failed - will work in polling mode but slower
  # Could add warning here, but continue operation
  discard

# Start audio processing (minimal - example focuses on CV)
hw.startAudio(audioCallback)

# Main loop
var ledToggle = false
while true:
  # Process CV inputs/outputs
  processCV()
  
  # Blink LED to show activity (based on DMA update counter)
  # Every 1024 updates (~10Hz at 10kHz DMA rate)
  if (updateCount and 0x3FF) == 0:
    ledToggle = true
    hw.setLed(true)
  if (updateCount and 0x3FF) == 0x200:
    ledToggle = false
    hw.setLed(false)
  
  # 1kHz update rate (DMA updates happen faster in background)
  hw.delay(1)
