## CV Expander Example - MAX11300 CV/Gate I/O
##
## Demonstrates MAX11300 PIXI for Eurorack CV/gate expansion.
## Simplified example - full implementation would require complete SPI protocol.

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_spi
import ../src/dev/max11300

useDaisyNamespace()

var
  pixi: MAX11300[1]
  hw: DaisySeed

proc audioCallback(input_buffer, output_buffer: AudioBuffer, size: int) {.cdecl.} =
  for i in 0 ..< size:
    output_buffer[0][i] = 0.0
    output_buffer[1][i] = 0.0

hw.init()

var config: MAX11300Config[1]
config.spi_config.defaults()

if pixi.init(config) == MAX_OK:
  # Configure pins (simplified - would need full SPI implementation)
  discard pixi.configurePinAsAnalogRead(0, 0, ADC_NEG5_TO_5)  # CV input
  discard pixi.configurePinAsAnalogWrite(0, 1, DAC_NEG5_TO_5)  # CV output

hw.startAudio(audioCallback)

while true:
  # Read CV input and pass through to output (simplified)
  let cvIn = pixi.readAnalogPinVolts(0, 0)
  pixi.writeAnalogPinVolts(0, 1, cvIn)
  
  hw.delay(1)
