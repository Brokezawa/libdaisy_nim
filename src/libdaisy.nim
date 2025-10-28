## libDaisy - Nim wrapper for the Daisy Audio Platform Hardware Abstraction Library
## 
## This module provides Nim bindings to libDaisy, a C++ library for the Daisy Audio Platform
## by Electro-Smith. It enables easy access to audio, controls, GPIO, MIDI, USB, and more.
##
## Basic Example:
## ```nim
## import libdaisy
## useDaisyNamespace()  # Required: sets up C++ interop
## 
## proc main() =
##   var daisy = initDaisy()
##   daisy.setLed(true)
##   daisy.delay(500)
##   daisy.setLed(false)
## 
## when isMainModule:
##   main()
## ```
##
## Audio Example:
## ```nim
## import libdaisy
## useDaisyNamespace()  # Required: sets up C++ interop
## 
## proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
##   for i in 0..<size:
##     output[0][i] = input[0][i]  # Left channel passthrough
##     output[1][i] = input[1][i]  # Right channel passthrough
## 
## proc main() =
##   var daisy = initDaisy()
##   daisy.startAudio(audioCallback)
##   while true:
##     discard
## 
## when isMainModule:
##   main()
## ```
##
## Note: The `useDaisyNamespace()` macro automatically generates all necessary
## C++ interop code at compile time. You just need to call it once after your imports!

# Import and re-export the macro system for C++ interop
import libdaisy_macros
export useDaisyNamespace, useDaisyModules

# Workaround for WavPlayer compilation error in libDaisy
{.passC: "-DFILEIO_ENABLE_FATFS_READER".}

# Use the macro system for THIS compilation unit (libdaisy.nim)
useDaisyNamespace()

{.push header: "daisy_seed.h".}
{.push importcpp.}

type
  # Forward declarations
  AudioHandle* {.importcpp: "daisy::AudioHandle".} = object
  AdcHandle* {.importcpp: "daisy::AdcHandle".} = object
  DacHandle* {.importcpp: "daisy::DacHandle".} = object
  UsbHandle* {.importcpp: "daisy::UsbHandle".} = object
  QSPIHandle* {.importcpp: "daisy::QSPIHandle".} = object
  SdramHandle* {.importcpp: "daisy::SdramHandle".} = object
  System* {.importcpp: "daisy::System".} = object
  
  # GPIO types
  GPIOPort* {.importcpp: "daisy::GPIOPort", size: sizeof(cint).} = enum
    PORTA = 0, PORTB, PORTC, PORTD, PORTE, PORTF, PORTG, PORTH, PORTI, PORTJ, PORTK, PORTX
  
  Pin* {.importcpp: "daisy::Pin".} = object
    port* {.importc: "port".}: GPIOPort
    pin* {.importc: "pin".}: uint8
  
  GPIOMode* {.importcpp: "daisy::GPIO::Mode", size: sizeof(cint).} = enum
    INPUT = 0
    OUTPUT
    OPEN_DRAIN
    ANALOG
  
  GPIOPull* {.importcpp: "daisy::GPIO::Pull", size: sizeof(cint).} = enum
    NOPULL = 0
    PULLUP
    PULLDOWN
  
  GPIOSpeed* {.importcpp: "daisy::GPIO::Speed", size: sizeof(cint).} = enum
    LOW = 0
    MEDIUM
    HIGH
    VERY_HIGH
  
  GPIO* {.importcpp: "daisy::GPIO".} = object
  
  # Audio callback types (low-level C++ types matching libDaisy signatures)
  # InputBuffer = const float* const*, OutputBuffer = float**
  ConstFloatPtrPtr* = ptr ptr cfloat  # We'll cast this properly in C++ emit
  FloatPtrPtr* = ptr ptr cfloat
  AudioCallbackC* = proc(input: ConstFloatPtrPtr, output: FloatPtrPtr, size: csize_t) {.cdecl.}
  # InterleavingInputBuffer = const float*, InterleavingOutputBuffer = float*
  ConstFloatPtr* = ptr cfloat
  FloatPtr* = ptr cfloat
  InterleavingAudioCallbackC* = proc(input: ConstFloatPtr, output: FloatPtr, size: csize_t) {.cdecl.}

# Nim-friendly audio buffer types
type
  AudioBuffer* = ptr UncheckedArray[ptr UncheckedArray[cfloat]]
    ## Multi-channel audio buffer (non-interleaved)
  InterleavedAudioBuffer* = ptr UncheckedArray[cfloat]
    ## Interleaved audio buffer
  
  AudioCallback* = proc(input, output: AudioBuffer, size: int) {.cdecl.}
    ## Nim-friendly multi-channel audio callback
  InterleavingAudioCallback* = proc(input, output: InterleavedAudioBuffer, size: int) {.cdecl.}
    ## Nim-friendly interleaved audio callback
  
  # Sample rate enum
  SampleRate* {.importcpp: "daisy::SaiHandle::Config::SampleRate", size: sizeof(cint).} = enum
    SAI_8KHZ = 0
    SAI_16KHZ
    SAI_32KHZ
    SAI_48KHZ
    SAI_96KHZ
  
  # Board version
  BoardVersion* {.importcpp: "daisy::DaisySeed::BoardVersion", size: sizeof(cint).} = enum
    BOARD_DAISY_SEED = 0
    BOARD_DAISY_SEED_1_1
    BOARD_DAISY_SEED_2_DFM

  # Main DaisySeed class
  DaisySeed* {.importcpp: "daisy::DaisySeed".} = object
    qspi* {.importc: "qspi".}: QSPIHandle
    sdram_handle* {.importc: "sdram_handle".}: SdramHandle
    audio_handle* {.importc: "audio_handle".}: AudioHandle
    adc* {.importc: "adc".}: AdcHandle
    dac* {.importc: "dac".}: DacHandle
    usb_handle* {.importc: "usb_handle".}: UsbHandle
    led* {.importc: "led".}: GPIO
    testpoint* {.importc: "testpoint".}: GPIO
    system* {.importc: "system".}: System

{.pop.} # importcpp
{.pop.} # header

# Pin constructor (must be outside push blocks for correct code generation)
proc newPin*(port: GPIOPort, pin: uint8): Pin {.importcpp: "daisy::Pin(@)", constructor, header: "daisy_seed.h".}

# Low-level C++ constructors (must be outside push blocks to work correctly)
proc cppNewDaisySeed(): DaisySeed {.importcpp: "daisy::DaisySeed()", constructor, header: "daisy_seed.h".}
proc cppNewGPIO(): GPIO {.importcpp: "daisy::GPIO()", constructor, header: "daisy_seed.h".}

# Re-declare methods outside of push blocks with explicit pragmas to ensure correct C++ mapping
proc cppInit(this: var DaisySeed, boost: bool = false) {.importcpp: "#.Init(@)", header: "daisy_seed.h".}
proc cppDeInit(this: var DaisySeed) {.importcpp: "#.DeInit()", header: "daisy_seed.h".}
proc cppDelayMs(this: var DaisySeed, del: csize_t) {.importcpp: "#.DelayMs(@)", header: "daisy_seed.h".}
proc cppGetPin(pin_idx: uint8): Pin {.importcpp: "daisy::DaisySeed::GetPin(@)", header: "daisy_seed.h".}

proc cppStartAudio(this: var DaisySeed, cb: AudioCallbackC) {.importcpp: "#.StartAudio(@)", header: "daisy_seed.h".}
proc cppStartAudio(this: var DaisySeed, cb: InterleavingAudioCallbackC) {.importcpp: "#.StartAudio(@)", header: "daisy_seed.h".}
proc cppChangeAudioCallback(this: var DaisySeed, cb: AudioCallbackC) {.importcpp: "#.ChangeAudioCallback(@)", header: "daisy_seed.h".}
proc cppChangeAudioCallback(this: var DaisySeed, cb: InterleavingAudioCallbackC) {.importcpp: "#.ChangeAudioCallback(@)", header: "daisy_seed.h".}
proc cppStopAudio(this: var DaisySeed) {.importcpp: "#.StopAudio()", header: "daisy_seed.h".}

proc cppSetAudioSampleRate(this: var DaisySeed, samplerate: SampleRate) {.importcpp: "#.SetAudioSampleRate(@)", header: "daisy_seed.h".}
proc cppAudioSampleRate(this: var DaisySeed): cfloat {.importcpp: "#.AudioSampleRate()", header: "daisy_seed.h".}
proc cppSetAudioBlockSize(this: var DaisySeed, blocksize: csize_t) {.importcpp: "#.SetAudioBlockSize(@)", header: "daisy_seed.h".}
proc cppAudioBlockSize(this: var DaisySeed): csize_t {.importcpp: "#.AudioBlockSize()", header: "daisy_seed.h".}
proc cppAudioCallbackRate(this: DaisySeed): cfloat {.importcpp: "#.AudioCallbackRate()", header: "daisy_seed.h".}

proc cppSetLed(this: var DaisySeed, state: bool) {.importcpp: "#.SetLed(@)", header: "daisy_seed.h".}
proc cppSetTestPoint(this: var DaisySeed, state: bool) {.importcpp: "#.SetTestPoint(@)", header: "daisy_seed.h".}

proc cppCheckBoardVersion(this: var DaisySeed): BoardVersion {.importcpp: "#.CheckBoardVersion()", header: "daisy_seed.h".}
proc cppGetNow(this: var DaisySeed): cfloat {.importcpp: "#.system.GetNow()", header: "daisy_seed.h".}

# GPIO methods  (low-level) - also re-declared outside push blocks
proc cppInit(this: var GPIO, pin: Pin, mode: GPIOMode, pull: GPIOPull = NOPULL, speed: GPIOSpeed = LOW) {.importcpp: "#.Init(@)", header: "daisy_seed.h".}
proc cppDeInit(this: var GPIO) {.importcpp: "#.DeInit()", header: "daisy_seed.h".}
proc cppWrite(this: var GPIO, state: bool) {.importcpp: "#.Write(@)", header: "daisy_seed.h".}
proc cppRead(this: var GPIO): bool {.importcpp: "#.Read()", header: "daisy_seed.h".}
proc cppToggle(this: var GPIO) {.importcpp: "#.Toggle()", header: "daisy_seed.h".}

# Pin constants for Daisy Seed - using templates to allow importc constructors
template D0*(): Pin = newPin(PORTB, 12)
template D1*(): Pin = newPin(PORTC, 11)
template D2*(): Pin = newPin(PORTC, 10)
template D3*(): Pin = newPin(PORTC, 9)
template D4*(): Pin = newPin(PORTC, 8)
template D5*(): Pin = newPin(PORTD, 2)
template D6*(): Pin = newPin(PORTC, 12)
template D7*(): Pin = newPin(PORTG, 10)
template D8*(): Pin = newPin(PORTG, 11)
template D9*(): Pin = newPin(PORTB, 4)
template D10*(): Pin = newPin(PORTB, 5)
template D11*(): Pin = newPin(PORTB, 8)
template D12*(): Pin = newPin(PORTB, 9)
template D13*(): Pin = newPin(PORTB, 6)
template D14*(): Pin = newPin(PORTB, 7)
template D15*(): Pin = newPin(PORTC, 0)
template D16*(): Pin = newPin(PORTA, 3)
template D17*(): Pin = newPin(PORTB, 1)
template D18*(): Pin = newPin(PORTA, 7)
template D19*(): Pin = newPin(PORTA, 6)
template D20*(): Pin = newPin(PORTC, 1)
template D21*(): Pin = newPin(PORTC, 4)
template D22*(): Pin = newPin(PORTA, 5)
template D23*(): Pin = newPin(PORTA, 4)
template D24*(): Pin = newPin(PORTA, 1)
template D25*(): Pin = newPin(PORTA, 0)
template D26*(): Pin = newPin(PORTD, 11)
template D27*(): Pin = newPin(PORTG, 9)
template D28*(): Pin = newPin(PORTA, 2)
template D29*(): Pin = newPin(PORTB, 14)
template D30*(): Pin = newPin(PORTB, 15)
template D31*(): Pin = newPin(PORTC, 2)
template D32*(): Pin = newPin(PORTC, 3)

# Analog pin aliases
template A0*(): Pin = D15()
template A1*(): Pin = D16()
template A2*(): Pin = D17()
template A3*(): Pin = D18()
template A4*(): Pin = D19()
template A5*(): Pin = D20()
template A6*(): Pin = D21()
template A7*(): Pin = D22()
template A8*(): Pin = D23()
template A9*(): Pin = D24()
template A10*(): Pin = D25()
template A11*(): Pin = D28()
template A12*(): Pin = D31()
template A13*(): Pin = D32()

# Utility functions for audio sample conversion
proc s16ToFloat*(x: int16): float32 {.inline.} =
  ## Converts signed 16-bit to float
  result = float32(x) * 3.0517578125e-05'f32

proc floatToS16*(x: float32): int16 {.inline.} =
  ## Converts float to signed 16-bit
  var val = x
  val = if val <= -0.999985'f32: -0.999985'f32 else: val
  val = if val >= 0.999985'f32: 0.999985'f32 else: val
  result = int16(val * 32767.0'f32)

proc s24ToFloat*(x: int32): float32 {.inline.} =
  ## Converts signed 24-bit to float
  let extended = (x xor 0x800000) - 0x800000
  result = float32(extended) * 1.192092896e-07'f32

proc floatToS24*(x: float32): int32 {.inline.} =
  ## Converts float to signed 24-bit
  var val = x
  val = if val <= -0.999985'f32: -0.999985'f32 else: val
  val = if val >= 0.999985'f32: 0.999985'f32 else: val
  result = int32(val * 8388608.0'f32)

# =============================================================================
# High-Level Nim-Friendly API
# =============================================================================

proc initDaisy*(boost: bool = false): DaisySeed =
  ## Initialize a Daisy Seed board
  ## 
  ## Parameters:
  ##   boost: Enable clock boost mode for higher performance
  ## 
  ## Example:
  ## ```nim
  ## var daisy = initDaisy()
  ## ```
  result = cppNewDaisySeed()
  result.cppInit(boost)

proc init*(daisy: var DaisySeed, boost: bool = false) =
  ## Initialize the Daisy Seed hardware
  daisy.cppInit(boost)

proc deinit*(daisy: var DaisySeed) =
  ## Deinitialize the Daisy Seed hardware
  daisy.cppDeInit()

proc delay*(daisy: var DaisySeed, milliseconds: int) =
  ## Delay for a specified number of milliseconds
  daisy.cppDelayMs(milliseconds.csize_t)

proc setLed*(daisy: var DaisySeed, state: bool) =
  ## Set the built-in LED state
  ## 
  ## Parameters:
  ##   state: true = ON, false = OFF
  daisy.cppSetLed(state)

proc toggleLed*(daisy: var DaisySeed) =
  ## Toggle the built-in LED (uses GPIO toggle internally)
  daisy.led.cppToggle()

proc setTestPoint*(daisy: var DaisySeed, state: bool) =
  ## Set the test point pin state (for oscilloscope debugging)
  daisy.cppSetTestPoint(state)

proc getPin*(pinIndex: int): Pin =
  ## Get a Pin object by its index (0-32)
  cppGetPin(pinIndex.uint8)

proc boardVersion*(daisy: var DaisySeed): BoardVersion =
  ## Check which version of Daisy Seed board is connected
  daisy.cppCheckBoardVersion()

proc now*(daisy: var DaisySeed): float =
  ## Get current system time in seconds since startup
  daisy.cppGetNow()

# Audio API
proc setSampleRate*(daisy: var DaisySeed, rate: SampleRate) =
  ## Set the audio sample rate
  ## 
  ## Available rates: SAI_8KHZ, SAI_16KHZ, SAI_32KHZ, SAI_48KHZ, SAI_96KHZ
  daisy.cppSetAudioSampleRate(rate)

proc sampleRate*(daisy: var DaisySeed): float =
  ## Get the current audio sample rate in Hz
  daisy.cppAudioSampleRate()

proc setBlockSize*(daisy: var DaisySeed, size: int) =
  ## Set the audio block size (number of samples per callback)
  daisy.cppSetAudioBlockSize(size.csize_t)

proc blockSize*(daisy: var DaisySeed): int =
  ## Get the current audio block size
  daisy.cppAudioBlockSize().int

proc callbackRate*(daisy: DaisySeed): float =
  ## Get the audio callback rate in Hz
  daisy.cppAudioCallbackRate()

# Audio callback wrapper types - remove the unused CppAudioCallback types
# We'll use exportc to create C-compatible wrappers

# Global callback storage
var globalNimAudioCallback: AudioCallback = nil
var globalNimInterleavingCallback: InterleavingAudioCallback = nil

# C-compatible wrapper that calls Nim callback
# The C++ compiler will accept this and handle const casting
proc audioCallbackWrapper(input: ptr ptr cfloat, output: ptr ptr cfloat, size: csize_t) {.exportc: "audioCallbackWrapper", cdecl.} =
  if not globalNimAudioCallback.isNil:
    globalNimAudioCallback(cast[AudioBuffer](input),
                          cast[AudioBuffer](output),
                          size.int)

proc interleavingCallbackWrapper(input: ptr cfloat, output: ptr cfloat, size: csize_t) {.exportc: "interleavingCallbackWrapper", cdecl.} =
  if not globalNimInterleavingCallback.isNil:
    globalNimInterleavingCallback(cast[InterleavedAudioBuffer](input),
                                 cast[InterleavedAudioBuffer](output),
                                 size.int)

proc startAudio*(daisy: var DaisySeed, callback: AudioCallback) =
  ## Start audio processing with a multi-channel (non-interleaved) callback
  ## 
  ## The callback receives separate channels as arrays of float samples.
  ## 
  ## Example:
  ## ```nim
  ## proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  ##   for i in 0..<size:
  ##     output[0][i] = input[0][i] * 0.5  # Left channel, reduce volume
  ##     output[1][i] = input[1][i] * 0.5  # Right channel
  ## 
  ## daisy.startAudio(audioCallback)
  ## ```
  globalNimAudioCallback = callback
  # Use emit to properly cast the wrapper function to AudioCallback type
  {.emit: "`daisy`.StartAudio(reinterpret_cast<daisy::AudioHandle::AudioCallback>(audioCallbackWrapper));".}

proc startAudio*(daisy: var DaisySeed, callback: InterleavingAudioCallback) =
  ## Start audio processing with an interleaved callback
  ## 
  ## The callback receives interleaved samples (L, R, L, R, ...)
  globalNimInterleavingCallback = callback
  # Use emit to properly cast the wrapper function to InterleavingAudioCallback type
  {.emit: "`daisy`.StartAudio(reinterpret_cast<daisy::AudioHandle::InterleavingAudioCallback>(interleavingCallbackWrapper));".}

proc changeAudioCallback*(daisy: var DaisySeed, callback: AudioCallback) =
  ## Change the audio callback while audio is running
  globalNimAudioCallback = callback

proc changeAudioCallback*(daisy: var DaisySeed, callback: InterleavingAudioCallback) =
  ## Change the interleaved audio callback while audio is running
  globalNimInterleavingCallback = callback

proc stopAudio*(daisy: var DaisySeed) =
  ## Stop audio processing
  daisy.cppStopAudio()
  globalNimAudioCallback = nil
  globalNimInterleavingCallback = nil

# GPIO API
proc initGpio*(pin: Pin, mode: GPIOMode = OUTPUT, 
               pull: GPIOPull = NOPULL, speed: GPIOSpeed = LOW): GPIO =
  ## Initialize a GPIO pin
  ## 
  ## Parameters:
  ##   pin: The pin to configure (use D0(), D1(), A0(), etc.)
  ##   mode: INPUT, OUTPUT, OPEN_DRAIN, or ANALOG
  ##   pull: NOPULL, PULLUP, or PULLDOWN
  ##   speed: LOW, MEDIUM, HIGH, or VERY_HIGH
  ## 
  ## Example:
  ## ```nim
  ## var led = initGpio(D7(), OUTPUT)
  ## led.write(true)
  ## ```
  result = cppNewGPIO()
  result.cppInit(pin, mode, pull, speed)

proc deinit*(gpio: var GPIO) =
  ## Deinitialize a GPIO pin
  gpio.cppDeInit()

proc write*(gpio: var GPIO, state: bool) =
  ## Write a digital value to a GPIO pin
  gpio.cppWrite(state)

proc read*(gpio: var GPIO): bool =
  ## Read a digital value from a GPIO pin
  gpio.cppRead()

proc toggle*(gpio: var GPIO) =
  ## Toggle a GPIO pin state
  gpio.cppToggle()

when isMainModule:
  # Example usage
  echo "libDaisy Nim wrapper"
  echo "This is a binding library for the Daisy Audio Platform"
  echo "To use: import libdaisy"
