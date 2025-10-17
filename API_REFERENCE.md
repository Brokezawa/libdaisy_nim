# API Reference

Complete reference for all libdaisy_nim wrapper modules.

## Core Module (libdaisy.nim)

### DaisySeed Object

Main hardware controller object.

**Creation:**
```nim
var hw = newDaisySeed()
```

**Initialization:**
```nim
proc init*(this: var DaisySeed)
```
Initialize all hardware with default configuration.

**LED Control:**
```nim
proc setLed*(this: var DaisySeed, state: bool)
```
Control onboard LED. `true` = on, `false` = off.

**Timing:**
```nim
proc delayMs*(this: var DaisySeed, milliseconds: uint32)
```
Blocking delay in milliseconds.

**Audio:**
```nim
proc startAudio*(this: var DaisySeed, callback: AudioCallback)
proc stopAudio*(this: var DaisySeed)
proc changeAudioCallback*(this: var DaisySeed, callback: AudioCallback)
```

Audio callback signature:
```nim
proc myCallback(input: ptr ptr cfloat, output: ptr ptr cfloat,
                size: csize_t) {.cdecl.} =
  # input[channel][sample] - Read audio in
  # output[channel][sample] - Write audio out
  # size - Number of samples per channel
```

**GPIO:**
```nim
proc getPin*(this: var DaisySeed, pin: DaisyPin): var DaisyGPIO
```
Get GPIO object for a pin.

### DaisyGPIO Object

GPIO pin controller.

**Configuration:**
```nim
type
  PinMode* = enum
    INPUT, OUTPUT, OPEN_DRAIN, ANALOG

  Pull* = enum
    NOPULL, PULLUP, PULLDOWN

var pin = hw.getPin(DPin10)
pin.mode = PinMode.OUTPUT
pin.pull = Pull.NOPULL
pin.init()
```

**Digital I/O:**
```nim
proc write*(this: var DaisyGPIO, state: bool)
proc read*(this: var DaisyGPIO): bool
proc toggle*(this: var DaisyGPIO)
```

**Pin Names:**
```
DPin0..DPin31  # 32 GPIO pins
```

---

## I2C Module (libdaisy_i2c.nim)

**Import:**
```nim
import src/libdaisy_i2c
```

### I2CHandle Object

**Configuration:**
```nim
type
  I2CSpeed* = enum
    I2C_100KHZ = 100000
    I2C_400KHZ = 400000
    I2C_1MHZ = 1000000

var i2c: I2CHandle
var cfg: I2CConfig
cfg.periph = I2C_PERIPH_1
cfg.speed = I2C_400KHZ
cfg.pin_config.scl = DPin11
cfg.pin_config.sda = DPin12
i2c.init(cfg)
```

**Communication:**
```nim
proc transmitBlocking*(this: var I2CHandle, addr: uint8, 
                       data: ptr uint8, size: csize_t,
                       timeout: uint32): I2CResult

proc receiveBlocking*(this: var I2CHandle, addr: uint8,
                      data: ptr uint8, size: csize_t,
                      timeout: uint32): I2CResult

proc writeDataAtAddress*(this: var I2CHandle, addr: uint8, 
                         regAddr: uint16, regSize: uint16,
                         data: ptr uint8, dataSize: csize_t,
                         timeout: uint32): I2CResult
```

**Result Codes:**
```nim
type
  I2CResult* = enum
    I2C_OK = 0
    I2C_ERR = 1
```

---

## SPI Module (libdaisy_spi.nim)

**Import:**
```nim
import src/libdaisy_spi
```

### SPIHandle Object

**Configuration:**
```nim
type
  SPIMode* = enum
    SPI_MODE_0 = 0  # CPOL=0, CPHA=0
    SPI_MODE_1 = 1  # CPOL=0, CPHA=1
    SPI_MODE_2 = 2  # CPOL=1, CPHA=0
    SPI_MODE_3 = 3  # CPOL=1, CPHA=1

var spi: SPIHandle
var cfg: SPIConfig
cfg.periph = SPI_PERIPH_1
cfg.mode = SPI_MODE_0
cfg.direction = SPI_DIRECTION_2LINES
cfg.baud_prescaler = SPI_BaudPrescaler.PS_8
spi.init(cfg)
```

**Communication:**
```nim
proc transmitAndReceiveBlocking*(this: var SPIHandle,
                                  txBuff: ptr uint8,
                                  rxBuff: ptr uint8,
                                  size: csize_t,
                                  timeout: uint32): cint
```

---

## Serial/UART Module (libdaisy_serial.nim)

**Import:**
```nim
import src/libdaisy_serial
```

### UartHandler Object

**Configuration:**
```nim
var uart: UartHandler
var cfg: UartConfig
cfg.periph = USART_1
cfg.baudrate = 115200
cfg.stopbits = UART_StopBits.BITS_1
cfg.parity = UART_Parity.NONE
uart.init(cfg)
```

**Communication:**
```nim
proc transmitBlocking*(this: var UartHandler, data: ptr uint8,
                       size: csize_t, timeout: uint32): cint

proc receiveBlocking*(this: var UartHandler, data: ptr uint8,
                      size: csize_t, timeout: uint32): cint

proc readable*(this: var UartHandler): cint
proc popRx*(this: var UartHandler): uint8
```

---

## MIDI Module (libdaisy_midi.nim)

**Import:**
```nim
import src/libdaisy_midi
```

### MidiHandler Object

**Configuration:**
```nim
var midi: MidiHandler
var cfg: MidiUartConfig
cfg.transport = MidiTransport.UART
midi.init(cfg)
```

**Usage:**
```nim
midi.listen()

while midi.hasEvents():
  let event = midi.popEvent()
  if event.`type` == NoteOn:
    let note = event.data[0]
    let velocity = event.data[1]
```

---

## USB Module (libdaisy_usb.nim)

**Import:**
```nim
import src/libdaisy_usb
```

### USB CDC (Serial)

```nim
var usb: USBHandler
usb.init()

# Read
if usb.readable() > 0:
  let c = usb.getRx()

# Write
usb.transmit(data, size)
```

---

## SD Card Module (libdaisy_sdmmc.nim)

**Import:**
```nim
import src/libdaisy_sdmmc
```

### SdmmcHandler Object

**Initialization:**
```nim
var sd: SdmmcHandler
sd.init()
```

**File Operations:**
```nim
# Mount filesystem
fatfs.mount()

# Open file
var file: FIL
var result = fatfs.open(file, "test.txt", FA_READ or FA_WRITE or FA_CREATE_ALWAYS)

# Write
var buffer = "Hello, SD card!"
var written: UINT
fatfs.write(file, buffer, written)

# Close
fatfs.close(file)
```

---

## SDRAM Module (libdaisy_sdram.nim)

**Import:**
```nim
import src/libdaisy_sdram
```

### SdramHandler Object

**Initialization:**
```nim
var sdram: SdramHandler
sdram.init()
```

**Usage:**
```nim
# Allocate memory
let bufferSize = 48000 * 4  # 4 seconds at 48kHz
var buffer = sdram.malloc(bufferSize)

# Use as array
buffer[0] = 1.0'f32
buffer[1] = 0.5'f32
```

---

## Controls Module (libdaisy_controls.nim)

**Import:**
```nim
import src/libdaisy_controls
```

### Switch Object

**Configuration:**
```nim
var button: Switch
button.init(DPin10, updateRate = 1000)
```

**Usage:**
```nim
button.debounce()
if button.risingEdge():
  echo "Button pressed!"
```

### Encoder Object

**Configuration:**
```nim
var encoder: Encoder
encoder.init(pinA = DPin11, pinB = DPin12, pinClick = DPin13)
```

**Usage:**
```nim
encoder.debounce()
let increment = encoder.increment()
if increment != 0:
  position += increment
```

---

## Macros Module (libdaisy_macros.nim)

Compile-time include generation. Not used directly in user code.

---

## Constants and Enums

### Sample Rates
```nim
const
  SAMPLE_RATE_8K* = 8000
  SAMPLE_RATE_16K* = 16000
  SAMPLE_RATE_32K* = 32000
  SAMPLE_RATE_48K* = 48000
  SAMPLE_RATE_96K* = 96000
```

### Buffer Sizes
```nim
const
  DEFAULT_BLOCK_SIZE* = 48  # Audio samples per callback
```

---

## Complete Example

Here's a complete example using multiple modules:

```nim
import src/libdaisy
import src/libdaisy_i2c
import src/libdaisy_controls

var hw = newDaisySeed()
var i2c: I2CHandle
var button: Switch

proc audioCallback(input: ptr ptr cfloat, output: ptr ptr cfloat,
                   size: csize_t) {.cdecl.} =
  for i in 0..<size:
    output[0][i] = input[0][i] * 0.5  # Reduce volume
    output[1][i] = input[1][i] * 0.5

proc main() =
  # Initialize hardware
  hw.init()
  
  # Setup I2C
  var i2cCfg: I2CConfig
  i2cCfg.periph = I2C_PERIPH_1
  i2cCfg.speed = I2C_400KHZ
  i2cCfg.pin_config.scl = DPin11
  i2cCfg.pin_config.sda = DPin12
  i2c.init(i2cCfg)
  
  # Setup button
  button.init(DPin10)
  
  # Start audio
  hw.startAudio(audioCallback)
  
  # Main loop
  while true:
    button.debounce()
    if button.risingEdge():
      hw.setLed(true)
    if button.fallingEdge():
      hw.setLed(false)
    
    hw.delayMs(1)

when isMainModule:
  main()
```

---

For more examples, see [EXAMPLES.md](EXAMPLES.md).

For technical details, see [TECHNICAL_REPORT.md](TECHNICAL_REPORT.md).

For contributing, see [CONTRIBUTING.md](CONTRIBUTING.md).
