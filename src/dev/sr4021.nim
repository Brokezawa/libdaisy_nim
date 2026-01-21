## 74HC4021 Shift Register Module - 8-bit Parallel-to-Serial Input
##
## Device driver for CD4021 8-bit shift register (input expander).
## Supports daisy-chaining and parallel chains.

import ../libdaisy
import ../libdaisy_macros

useDaisyModules(sr_4021)

type
  ShiftRegister4021Config*[NumDaisy, NumParallel: static int] = object
    clk_pin*: Pin     ## Clock pin (pin 10)
    latch_pin*: Pin   ## P/!S pin (pin 9)  
    data_pins*: array[NumParallel, Pin]  ## Serial data input pins (pin 11)
    delay_ticks*: uint32  ## Delay between operations (default 10)

  ShiftRegister4021*[NumDaisy, NumParallel: static int] = object
    clk, latch: GPIO
    data: array[NumParallel, GPIO]
    delayTicks: uint32
    states: array[8 * NumDaisy * NumParallel, bool]

proc init*[ND, NP](sr: var ShiftRegister4021[ND, NP], config: ShiftRegister4021Config[ND, NP]) =
  sr.clk.init(config.clk_pin, INPUT)
  sr.latch.init(config.latch_pin, OUTPUT)
  for i in 0 ..< NP:
    sr.data[i].init(config.data_pins[i], INPUT)
  sr.delayTicks = if config.delay_ticks == 0: 10 else: config.delay_ticks
  
  for i in 0 ..< sr.states.len:
    sr.states[i] = false

proc update*[ND, NP](sr: var ShiftRegister4021[ND, NP]) =
  ## Read all inputs from shift registers
  sr.clk.write(false)
  sr.latch.write(true)
  delayTicks(sr.delayTicks)
  sr.latch.write(false)
  
  for i in 0 ..< (8 * ND):
    sr.clk.write(false)
    delayTicks(sr.delayTicks)
    
    for j in 0 ..< NP:
      let idx = (8 * ND - 1 - i) + (8 * ND * j)
      sr.states[idx] = sr.data[j].read()
    
    sr.clk.write(true)
    delayTicks(sr.delayTicks)

proc state*[ND, NP](sr: ShiftRegister4021[ND, NP], index: int): bool =
  ## Get state of input at index
  if index >= 0 and index < sr.states.len:
    sr.states[index]
  else:
    false

{.pop.}
