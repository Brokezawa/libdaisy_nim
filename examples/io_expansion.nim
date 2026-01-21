## I/O Expansion Example - MCP23017 GPIO Demo
##
## Demonstrates the MCP23017 16-bit I/O expander.
## Reads 8 buttons on Port A and controls 8 LEDs on Port B.

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_i2c
import ../src/dev/mcp23x17

useDaisyNamespace()

var 
  mcp: Mcp23017
  hw: DaisySeed

proc audioCallback(input_buffer, output_buffer: AudioBuffer, size: int) {.cdecl.} =
  for i in 0 ..< size:
    output_buffer[0][i] = 0.0
    output_buffer[1][i] = 0.0

hw.init()

var config: Mcp23017Config
config.defaults()
mcp.init(config)

# Port A = inputs with pullups
mcp.portMode(MCP_PORT_A, 0xFF, 0xFF, 0x00)

# Port B = outputs  
mcp.portMode(MCP_PORT_B, 0x00, 0x00, 0x00)

hw.startAudio(audioCallback)

while true:
  # Read Port A (buttons)
  let inputs = mcp.readPort(MCP_PORT_A)
  
  # Mirror to Port B (LEDs)
  mcp.digitalWrite(MCP_PORT_B, not inputs)  # Invert for active-high LEDs
  
  hw.delay(10)
