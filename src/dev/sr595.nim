## 74HC595 Shift Register Module - 8-bit Serial-to-Parallel Output
##
## Device driver for CD74HC595 8-bit shift register (output expander).
## Supports daisy-chaining up to 16 devices.

import ../libdaisy
import ../libdaisy_macros

useDaisyModules(sr_595)

const MAX_SR595_DAISY_CHAIN* = 16

type
  ShiftRegister595Config* = object
    latch_pin*: Pin  ## RCLK (pin 12)
    clk_pin*: Pin    ## SRCLK (pin 11)
    data_pin*: Pin   ## SER (pin 14)
    num_daisy_chained*: csize_t  ## Number of chained devices (1-16)

  ShiftRegister595* = object
    latchPin, clkPin, dataPin: GPIO
    state: array[MAX_SR595_DAISY_CHAIN, uint8]
    numDevices: csize_t

proc init*(sr: var ShiftRegister595, config: ShiftRegister595Config) =
  sr.latchPin.init(config.latch_pin, OUTPUT)
  sr.clkPin.init(config.clk_pin, OUTPUT)
  sr.dataPin.init(config.data_pin, OUTPUT)
  sr.numDevices = min(config.num_daisy_chained, MAX_SR595_DAISY_CHAIN)
  
  for i in 0 ..< MAX_SR595_DAISY_CHAIN:
    sr.state[i] = 0

proc set*(sr: var ShiftRegister595, idx: uint8, state: bool) =
  ## Set output state (QA-QH across all devices)
  if idx < (sr.numDevices.uint8 * 8):
    let
      device = idx div 8
      bit = idx mod 8
    if state:
      sr.state[device] = sr.state[device] or (1'u8 shl bit)
    else:
      sr.state[device] = sr.state[device] and not (1'u8 shl bit)

proc write*(sr: var ShiftRegister595) =
  ## Shift out all data to registers
  sr.latchPin.write(false)
  
  # Shift out MSB first, last device first
  for d in countdown(sr.numDevices - 1, 0):
    for bit in countdown(7, 0):
      sr.clkPin.write(false)
      sr.dataPin.write((sr.state[d] and (1'u8 shl bit.uint8)) != 0)
      sr.clkPin.write(true)
  
  sr.latchPin.write(true)

{.pop.}
