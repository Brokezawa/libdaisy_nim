## Controls and sensors support for libDaisy Nim wrapper
##
## This module provides support for encoders, switches, analog controls, and ADC.
##
## Example - Simple button:
## ```nim
## import libdaisy, libdaisy_controls
## 
## var daisy = initDaisy()
## var button = initSwitch(D2())
## 
## while true:
##   button.update()
##   if button.pressed:
##     daisy.setLed(true)
##   elif button.released:
##     daisy.setLed(false)
##   daisy.delay(1)
## ```
##
## Example - Rotary encoder:
## ```nim
## var encoder = initEncoder(D0(), D1(), D2())
## var value = 0
## 
## while true:
##   encoder.update()
##   value += encoder.increment
##   daisy.delay(1)
## ```
##
## Example - Analog input (ADC):
## ```nim
## var adc = initAdc(daisy, [A0(), A1()])
## adc.start()
## 
## while true:
##   let knob1 = adc.value(0)  # 0.0 to 1.0
##   let knob2 = adc.value(1)
##   daisy.delay(10)
## ```

# Import Pin type from main module
# Import libdaisy which provides the macro system
import ../libdaisy


# Use the macro system for this module's compilation unit
useDaisyModules(controls, adc)

{.push header: "daisy_seed.h".}
{.push importcpp.}

type
  # Switch types
  Switch* {.importcpp: "daisy::Switch".} = object
  
  SwitchType* {.importcpp: "daisy::Switch::Type", size: sizeof(cint).} = enum
    TYPE_MOMENTARY = 0
    TYPE_LATCHING
    TYPE_TOGGLE
  
  SwitchPolarity* {.importcpp: "daisy::Switch::Polarity", size: sizeof(cint).} = enum
    POLARITY_NORMAL = 0
    POLARITY_INVERTED
  
  SwitchPull* {.importcpp: "daisy::Switch::Pull", size: sizeof(cint).} = enum
    PULL_UP = 0
    PULL_DOWN
    PULL_NONE

  # Encoder types
  Encoder* {.importcpp: "daisy::Encoder".} = object
  
  # ADC (Analog to Digital Converter) types
  AdcChannelConfig* {.importcpp: "daisy::AdcChannelConfig".} = object
  
  AdcHandle* {.importcpp: "daisy::AdcHandle".} = object
  
  MuxPin* {.importcpp: "daisy::AdcChannelConfig::MuxPin", size: sizeof(cint).} = enum
    MUX_SEL_0 = 0
    MUX_SEL_1
    MUX_SEL_2
    MUX_SEL_LAST
  
  ConversionSpeed* {.importcpp: "daisy::AdcChannelConfig::ConversionSpeed", size: sizeof(cint).} = enum
    SPEED_1CYCLES_5 = 0
    SPEED_2CYCLES_5
    SPEED_8CYCLES_5
    SPEED_16CYCLES_5
    SPEED_32CYCLES_5
    SPEED_64CYCLES_5
    SPEED_387CYCLES_5
    SPEED_810CYCLES_5
  
  OverSampling* {.importcpp: "daisy::AdcHandle::OverSampling", size: sizeof(cint).} = enum
    OVS_NONE = 0
    OVS_4
    OVS_8
    OVS_16
    OVS_32
    OVS_64
    OVS_128
    OVS_256
    OVS_512
    OVS_1024
    OVS_LAST

{.pop.} # importcpp
{.pop.} # header

# Low-level C++ interface (moved outside push blocks for correct code generation)
proc cppInit(this: var Switch, pin: Pin, update_rate: cfloat = 1000.0, 
           typ: SwitchType = TYPE_MOMENTARY, pol: SwitchPolarity = POLARITY_NORMAL,
           pull: SwitchPull = PULL_UP) {.importcpp: "#.Init(@)", header: "daisy_seed.h".}
proc cppDebounce(this: var Switch) {.importcpp: "#.Debounce()", header: "daisy_seed.h".}
proc cppPressed(this: var Switch): bool {.importcpp: "#.Pressed()", header: "daisy_seed.h".}
proc cppReleased(this: var Switch): bool {.importcpp: "#.Released()", header: "daisy_seed.h".}
proc cppFallingEdge(this: var Switch): bool {.importcpp: "#.FallingEdge()", header: "daisy_seed.h".}
proc cppRisingEdge(this: var Switch): bool {.importcpp: "#.RisingEdge()", header: "daisy_seed.h".}
proc cppTimeHeldMs(this: var Switch): cfloat {.importcpp: "#.TimeHeldMs()", header: "daisy_seed.h".}

proc cppInit(this: var Encoder, a: Pin, b: Pin, click: Pin, update_rate: cfloat = 1000.0) {.importcpp: "#.Init(@)", header: "daisy_seed.h".}
proc cppDebounce(this: var Encoder) {.importcpp: "#.Debounce()", header: "daisy_seed.h".}
proc cppIncrement(this: var Encoder): int32 {.importcpp: "#.Increment()", header: "daisy_seed.h".}
proc cppPressed(this: var Encoder): bool {.importcpp: "#.Pressed()", header: "daisy_seed.h".}
proc cppRisingEdge(this: var Encoder): bool {.importcpp: "#.RisingEdge()", header: "daisy_seed.h".}
proc cppFallingEdge(this: var Encoder): bool {.importcpp: "#.FallingEdge()", header: "daisy_seed.h".}
proc cppTimeHeldMs(this: var Encoder): cfloat {.importcpp: "#.TimeHeldMs()", header: "daisy_seed.h".}

proc cppInitSingle(this: var AdcChannelConfig, pin: Pin, speed: ConversionSpeed = SPEED_8CYCLES_5) {.importcpp: "#.InitSingle(@)", header: "daisy_seed.h".}
proc cppInitMux(this: var AdcChannelConfig, adc_pin: Pin, mux_channels: csize_t, 
              mux_0: Pin, mux_1: Pin = Pin(), mux_2: Pin = Pin(), 
              speed: ConversionSpeed = SPEED_8CYCLES_5) {.importcpp: "#.InitMux(@)", header: "daisy_seed.h".}

proc cppInit(this: var AdcHandle, cfg: ptr AdcChannelConfig, num_channels: csize_t, 
           ovs: OverSampling = OVS_32) {.importcpp: "#.Init(@)", header: "daisy_seed.h".}
proc cppStart(this: var AdcHandle) {.importcpp: "#.Start()", header: "daisy_seed.h".}
proc cppStop(this: var AdcHandle) {.importcpp: "#.Stop()", header: "daisy_seed.h".}
proc cppGet(this: AdcHandle, chn: uint8): uint16 {.importcpp: "#.Get(@)", header: "daisy_seed.h".}
proc cppGetPtr(this: AdcHandle, chn: uint8): ptr uint16 {.importcpp: "#.GetPtr(@)", header: "daisy_seed.h".}
proc cppGetFloat(this: AdcHandle, chn: uint8): cfloat {.importcpp: "#.GetFloat(@)", header: "daisy_seed.h".}
proc cppGetMux(this: AdcHandle, chn: uint8, idx: uint8): uint16 {.importcpp: "#.GetMux(@)", header: "daisy_seed.h".}
proc cppGetMuxPtr(this: AdcHandle, chn: uint8, idx: uint8): ptr uint16 {.importcpp: "#.GetMuxPtr(@)", header: "daisy_seed.h".}
proc cppGetMuxFloat(this: AdcHandle, chn: uint8, idx: uint8): cfloat {.importcpp: "#.GetMuxFloat(@)", header: "daisy_seed.h".}

# C++ constructors
proc cppNewSwitch(): Switch {.importcpp: "daisy::Switch()", constructor, header: "daisy_seed.h".}
proc cppNewEncoder(): Encoder {.importcpp: "daisy::Encoder()", constructor, header: "daisy_seed.h".}
proc cppNewAdcChannelConfig(): AdcChannelConfig {.importcpp: "daisy::AdcChannelConfig()", constructor, header: "daisy_seed.h".}
proc cppNewAdcHandle(): AdcHandle {.importcpp: "daisy::AdcHandle()", constructor, header: "daisy_seed.h".}

# ADC methods through DaisySeed
proc cppInitAdc(hw: var DaisySeed, cfg: ptr AdcChannelConfig, num_channels: csize_t, 
              ovs: OverSampling = OVS_32) {.importcpp: "#.adc.Init(@)", header: "daisy_seed.h".}
proc cppStartAdc(hw: var DaisySeed) {.importcpp: "#.adc.Start()", header: "daisy_seed.h".}
proc cppStopAdc(hw: var DaisySeed) {.importcpp: "#.adc.Stop()", header: "daisy_seed.h".}
proc cppGetAdc(hw: var DaisySeed, chn: uint8): uint16 {.importcpp: "#.adc.Get(@)", header: "daisy_seed.h".}
proc cppGetAdcFloat(hw: var DaisySeed, chn: uint8): cfloat {.importcpp: "#.adc.GetFloat(@)", header: "daisy_seed.h".}
proc cppGetAdcMux(hw: var DaisySeed, chn: uint8, idx: uint8): uint16 {.importcpp: "#.adc.GetMux(@)", header: "daisy_seed.h".}
proc cppGetAdcMuxFloat(hw: var DaisySeed, chn: uint8, idx: uint8): cfloat {.importcpp: "#.adc.GetMuxFloat(@)", header: "daisy_seed.h".}

# =============================================================================
# High-Level Nim-Friendly API
# =============================================================================

proc initSwitch*(pin: Pin, updateRate: float = 1000.0,
                switchType: SwitchType = TYPE_MOMENTARY,
                polarity: SwitchPolarity = POLARITY_NORMAL,
                pull: SwitchPull = PULL_UP): Switch =
  ## Initialize a switch/button
  ## 
  ## Parameters:
  ##   pin: The GPIO pin the switch is connected to
  ##   updateRate: How often to check the switch (Hz)
  ##   switchType: TYPE_MOMENTARY, TYPE_LATCHING, or TYPE_TOGGLE
  ##   polarity: POLARITY_NORMAL or POLARITY_INVERTED
  ##   pull: PULL_UP, PULL_DOWN, or PULL_NONE
  ## 
  ## Example:
  ## ```nim
  ## var button = initSwitch(D2())  # Simple momentary button
  ## ```
  result = cppNewSwitch()
  result.cppInit(pin, updateRate.cfloat, switchType, polarity, pull)

proc update*(switch: var Switch) =
  ## Update switch state (call this regularly, typically in main loop)
  switch.cppDebounce()

proc pressed*(switch: var Switch): bool =
  ## Check if switch is currently pressed
  switch.cppPressed()

proc released*(switch: var Switch): bool =
  ## Check if switch is currently released
  switch.cppReleased()

proc risingEdge*(switch: var Switch): bool =
  ## Check if switch just transitioned to pressed (trigger once)
  switch.cppRisingEdge()

proc fallingEdge*(switch: var Switch): bool =
  ## Check if switch just transitioned to released (trigger once)
  switch.cppFallingEdge()

proc timeHeld*(switch: var Switch): float =
  ## Get how long the switch has been held in milliseconds
  switch.cppTimeHeldMs()

proc initEncoder*(pinA, pinB: Pin, clickPin: Pin = Pin(), updateRate: float = 1000.0): Encoder =
  ## Initialize a rotary encoder
  ## 
  ## Parameters:
  ##   pinA, pinB: Encoder signal pins
  ##   clickPin: Optional click button pin (use Pin() to skip)
  ##   updateRate: How often to check the encoder (Hz)
  ## 
  ## Example:
  ## ```nim
  ## var encoder = initEncoder(D0(), D1(), D2())  # With click
  ## var encoderNoClick = initEncoder(D3(), D4())  # Without click
  ## ```
  result = cppNewEncoder()
  result.cppInit(pinA, pinB, clickPin, updateRate.cfloat)

proc update*(encoder: var Encoder) =
  ## Update encoder state (call this regularly)
  encoder.cppDebounce()

proc increment*(encoder: var Encoder): int =
  ## Get encoder position change since last call (-N to +N)
  encoder.cppIncrement().int

proc pressed*(encoder: var Encoder): bool =
  ## Check if encoder button is pressed
  encoder.cppPressed()

proc risingEdge*(encoder: var Encoder): bool =
  ## Check if encoder button was just pressed
  encoder.cppRisingEdge()

proc fallingEdge*(encoder: var Encoder): bool =
  ## Check if encoder button was just released
  encoder.cppFallingEdge()

proc timeHeld*(encoder: var Encoder): float =
  ## Get how long encoder button has been held in milliseconds
  encoder.cppTimeHeldMs()

# ADC wrapper type for cleaner API - using fixed-size array instead of seq
const MAX_ADC_CHANNELS = 16

type
  AdcReader* = object
    configs: array[MAX_ADC_CHANNELS, AdcChannelConfig]
    daisy: ptr DaisySeed
    numChannels: int

proc initAdc*(daisy: var DaisySeed, pins: openArray[Pin], 
              oversampling: int = 4): AdcReader =
  ## Initialize ADC for reading analog inputs
  ## 
  ## Parameters:
  ##   daisy: The DaisySeed instance
  ##   pins: Array of analog pins to read (e.g., [A0(), A1(), A2()])
  ##   oversampling: Oversampling rate (0=NONE, 1=4x, 2=8x, 3=16x, 4=32x (default), 5=64x, etc.)
  ## 
  ## Example:
  ## ```nim
  ## var adc = initAdc(daisy, [A0(), A1(), A6()])
  ## adc.start()
  ## let knob1Value = adc.value(0)  # Read first channel
  ## ```
  result.daisy = addr daisy
  result.numChannels = pins.len
  
  if pins.len > MAX_ADC_CHANNELS:
    # In embedded systems, we can't really handle this error gracefully
    # Just limit to max channels
    result.numChannels = MAX_ADC_CHANNELS
  
  for i in 0..<result.numChannels:
    result.configs[i] = cppNewAdcChannelConfig()
    result.configs[i].cppInitSingle(pins[i])
  
  if result.numChannels > 0:
    daisy.cppInitAdc(addr result.configs[0], result.numChannels.csize_t, cast[OverSampling](oversampling))

proc start*(adc: var AdcReader) =
  ## Start ADC conversions
  adc.daisy[].cppStartAdc()

proc stop*(adc: var AdcReader) =
  ## Stop ADC conversions
  adc.daisy[].cppStopAdc()

proc rawValue*(adc: var AdcReader, channel: int): uint16 =
  ## Get raw ADC value (0-65535) for a channel
  adc.daisy[].cppGetAdc(channel.uint8)

proc value*(adc: var AdcReader, channel: int): float =
  ## Get normalized ADC value (0.0-1.0) for a channel
  adc.daisy[].cppGetAdcFloat(channel.uint8)

when isMainModule:
  echo "libDaisy Controls wrapper - Clean API"
