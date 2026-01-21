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

## ADC Module (libdaisy_adc.nim)

**Import:**
```nim
import src/libdaisy_adc
```

### AdcHandle Object

Analog to Digital Converter for reading analog inputs.

**Configuration:**
```nim
type
  AdcChannelConfig* = object
    InitMux*: bool        # Enable multiplexed inputs
    MuxChannels*: uint8   # Number of mux channels (1-8)

var adc: AdcHandle
var channel1, channel2: AdcChannelConfig

# Simple single-ended channel
channel1.InitMux = false
adc.init(addr channel1, 1)  # 1 channel

# Multiplexed channel (4 mux inputs)
channel2.InitMux = true
channel2.MuxChannels = 4
adc.init(addr channel2, 1)  # 1 channel x 4 mux = 4 inputs
```

**Reading Values:**
```nim
# Start continuous conversion
adc.start()

# Read raw 12-bit value (0-4095)
let raw = adc.get(0)  # Channel 0

# Read as float (0.0 - 1.0)
let normalized = adc.getFloat(0)

# Read multiplexed input
let muxValue = adc.getMuxFloat(0, 2)  # Channel 0, Mux index 2

# Stop conversion
adc.stop()
```

**Pin Assignment:**
Analog pins on Daisy Seed:
- `PIN_ADC_0` through `PIN_ADC_7` - 8 ADC-capable pins
- Can be single-ended or differential pairs
- Multiplexed channels allow 32 total inputs

**High-Level API:**
```nim
# Create with specific channels
let adc = createAdc(1)  # 1 simple channel
let adc = createAdcMux(1, 8)  # 1 channel with 8 mux inputs

# Read values
let value = adc.read(0)  # Returns float 0.0-1.0
```

**Example:**
```nim
import src/libdaisy
import src/libdaisy_adc

var hw = newDaisySeed()
hw.init()

# Configure ADC for 2 channels
var channels: array[2, AdcChannelConfig]
channels[0].InitMux = false
channels[1].InitMux = false

var adc = newAdcHandle()
discard adc.init(addr channels[0], 2)
adc.start()

while true:
  let knob1 = adc.getFloat(0)
  let knob2 = adc.getFloat(1)
  # Use knob values...
  hw.delayMs(10)
```

---

## PWM Module (libdaisy_pwm.nim)

**Import:**
```nim
import src/libdaisy_pwm
```

### PwmHandle Object

Pulse Width Modulation for controlling servos, LEDs, motors.

**Configuration:**
```nim
type
  PwmPeripheral* = enum
    TIM_1, TIM_2, TIM_3, TIM_4, TIM_5, TIM_8

  PwmPolarity* = enum
    PWM_POL_NORMAL   # High during pulse
    PWM_POL_INVERTED # Low during pulse

var pwm: PwmHandle
var pwmCfg: PwmConfig
var ch1Cfg: PwmChannelConfig

# Configure timer (frequency = clock / (prescaler * period))
pwmCfg.periph = TIM_2
pwmCfg.prescaler = 0
pwmCfg.period = 47999  # ~1kHz at 48MHz clock

# Configure channel
ch1Cfg.pin = DPin10
ch1Cfg.polarity = PWM_POL_NORMAL

discard pwm.init(pwmCfg)
discard pwm.channel1().init(ch1Cfg)
```

**Setting Duty Cycle:**
```nim
# Using float (0.0 = 0%, 1.0 = 100%)
pwm.channel1().set(0.5)  # 50% duty cycle

# Using raw value
pwm.channel1().setRaw(24000)  # 50% of period (47999)
```

**Channel Access:**
```nim
var ch1 = pwm.channel1()  # Channel 1
var ch2 = pwm.channel2()  # Channel 2
var ch3 = pwm.channel3()  # Channel 3
var ch4 = pwm.channel4()  # Channel 4
```

**High-Level API:**
```nim
# Create PWM with frequency in Hz
let pwm = createPwm(TIM_2, 1000)  # 1kHz

# Setup a channel
pwm.setupChannel(1, DPin10)  # Channel 1 on pin 10

# Set duty cycle
pwm.setDutyCycle(1, 0.75)  # 75% duty
```

**Example - LED Dimming:**
```nim
import src/libdaisy
import src/libdaisy_pwm

var hw = newDaisySeed()
hw.init()

let pwm = createPwm(TIM_2, 1000)  # 1kHz
pwm.setupChannel(1, DPin10)

var brightness = 0.0
while true:
  pwm.setDutyCycle(1, brightness)
  brightness += 0.01
  if brightness > 1.0:
    brightness = 0.0
  hw.delayMs(20)
```

**Example - Servo Control:**
```nim
# Servo: 50Hz, 1-2ms pulse width
let pwm = createPwm(TIM_2, 50)  # 50Hz
pwm.setupChannel(1, DPin10)

proc setServoAngle(pwm: PwmHandle, angle: float) =
  # Map angle (0-180) to duty (0.05-0.10)
  let duty = 0.05 + (angle / 180.0) * 0.05
  pwm.setDutyCycle(1, duty)

pwm.setServoAngle(90.0)  # Center position
```

---

## OLED Display Module (libdaisy_oled.nim)

**Import:**
```nim
import src/libdaisy_oled
```

### SSD1306 OLED Driver

Generic driver supporting multiple screen sizes and transports.

**Supported Configurations:**
- **Sizes:** 128x64, 128x32, 96x16 pixels
- **Transports:** I2C, SPI (4-wire)

**Creating a Display:**
```nim
# I2C transport
var display = newOledDisplay[OledSize128x64, OledI2cTransport]()

# SPI transport
var display = newOledDisplay[OledSize128x64, OledSpiTransport]()
```

**Configuration:**
```nim
var cfg: OledDisplayConfig[OledI2cTransport]

# I2C configuration
cfg.transport.periph = I2C_PERIPH_1
cfg.transport.speed = I2C_400KHZ
cfg.transport.pin_config.scl = DPin11
cfg.transport.pin_config.sda = DPin12
cfg.transport.address = 0x3C

# SPI configuration (for SPI transport)
cfg.transport.periph = SPI_PERIPH_1
cfg.transport.pin_config.sclk = DPin8
cfg.transport.pin_config.mosi = DPin10
cfg.transport.pin_config.dc = DPin9   # Data/Command
cfg.transport.pin_config.reset = DPin30

display.init(cfg)
```

**Basic Drawing:**
```nim
# Clear display
display.fill(false)

# Set individual pixel
display.drawPixel(x, y, true)  # true = on, false = off

# Get display dimensions
let w = display.width()
let h = display.height()

# Send buffer to display
display.update()
```

**Drawing Functions:**
```nim
proc drawPixel*(x, y: uint32, on: bool)
proc drawLine*(x0, y0, x1, y1: uint32, on: bool)
proc drawRect*(x, y, width, height: uint32, on: bool, fill: bool)
proc drawCircle*(x, y, radius: uint32, on: bool)
proc drawChar*(ch: char, x, y: uint32, on: bool)
proc drawString*(str: string, x, y: uint32, on: bool)
```

**Example - Basic Text:**
```nim
import src/libdaisy
import src/libdaisy_oled

var hw = newDaisySeed()
hw.init()

var display = newOledDisplay[OledSize128x64, OledI2cTransport]()
var cfg: OledDisplayConfig[OledI2cTransport]
cfg.transport = getDefaultI2cConfig(I2C_PERIPH_1, DPin11, DPin12)
cfg.transport.address = 0x3C

display.init(cfg)
display.fill(false)
display.drawString("Hello Daisy!", 0, 0, true)
display.update()
```

**Example - Graphics:**
```nim
display.fill(false)

# Draw a box
display.drawRect(10, 10, 50, 30, true, false)

# Draw a filled circle
display.drawCircle(80, 32, 20, true)

# Draw a line
display.drawLine(0, 0, 127, 63, true)

display.update()
```

**Example - Animation:**
```nim
var x = 0
while true:
  display.fill(false)
  display.drawCircle(x, 32, 5, true)
  display.update()
  
  x = (x + 1) mod 128
  hw.delayMs(10)
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

## DAC Module (libdaisy_dac.nim) - NEW in v0.3.0

**Import:**
```nim
import src/libdaisy_dac
```

### DacHandle Object

Digital to Analog Converter for analog voltage output.

**Pins:**
- DAC Channel 1: PA4
- DAC Channel 2: PA5

**Configuration:**
```nim
type
  DacChannel* = enum
    DAC_CHN_ONE    # PA4
    DAC_CHN_TWO    # PA5
    DAC_CHN_BOTH   # Both channels

  DacMode* = enum
    DAC_MODE_POLLING  # Single value writes
    DAC_MODE_DMA      # Buffered output

  DacBitDepth* = enum
    DAC_BITS_8   # 8-bit (0-255)
    DAC_BITS_12  # 12-bit (0-4095)

var dac: DacHandle
var config = DacConfig(
  target_samplerate: 48000,
  chn: DAC_CHN_ONE,
  mode: DAC_MODE_POLLING,
  bitdepth: DAC_BITS_12,
  buff_state: DAC_BUFFER_ENABLED
)
discard dac.init(config)
```

**Basic Operations:**
```nim
# Write single value (polling mode)
discard dac.writeValue(DAC_CHN_ONE, 2048)  # Mid-range

# Start DMA mode (single channel)
proc dacCallback(output: ptr ptr uint16, size: csize_t) {.cdecl.} =
  for i in 0..<size:
    output[0][i] = uint16(i * 100)  # Generate pattern

discard dac.start(buffer, bufferSize, dacCallback)

# Stop DAC
discard dac.stop()
```

---

## WAV Format Module (libdaisy_wavformat.nim) - NEW in v0.3.0

**Import:**
```nim
import src/libdaisy_wavformat
```

### WAV File Format

Structures and constants for WAV audio files.

**Constants:**
```nim
const
  kWavFileChunkId* = 0x46464952'u32     # "RIFF"
  kWavFileWaveId* = 0x45564157'u32      # "WAVE"
  kWavFileSubChunk1Id* = 0x20746d66'u32 # "fmt "
  kWavFileSubChunk2Id* = 0x61746164'u32 # "data"
```

**Format Codes:**
```nim
type WavFileFormatCode* = enum
  WAVE_FORMAT_PCM = 0x0001
  WAVE_FORMAT_IEEE_FLOAT = 0x0003
  WAVE_FORMAT_ALAW = 0x0006
  WAVE_FORMAT_ULAW = 0x0007
  WAVE_FORMAT_EXTENSIBLE = 0xFFFE
```

**Header Structure:**
```nim
type WavFormatTypeDef* = object
  ChunkId*: uint32       # "RIFF"
  FileSize*: uint32      # File size - 8
  FileFormat*: uint32    # "WAVE"
  SubChunk1ID*: uint32   # "fmt "
  SubChunk1Size*: uint32 # Format chunk size
  AudioFormat*: uint16   # Format code
  NbrChannels*: uint16   # Number of channels
  SampleRate*: uint32    # Sample rate (Hz)
  ByteRate*: uint32      # Bytes per second
  BlockAlign*: uint16    # Frame size in bytes
  BitPerSample*: uint16  # Bits per sample
  SubChunk2ID*: uint32   # "data"
  SubCHunk2Size*: uint32 # Data size

# Usage example (with SDMMC)
var header: WavFormatTypeDef
# Read from file...
if header.ChunkId == kWavFileChunkId:
  echo "Valid WAV: ", header.SampleRate, "Hz, ", header.NbrChannels, " channels"
```

---

## Daisy Patch Board Module (libdaisy_patch.nim) - NEW in v0.3.0

**Import:**
```nim
import src/libdaisy_patch
```

### DaisyPatch Object

Complete Daisy Patch Eurorack module support.

**Hardware Features:**
- 4 CV/Knob inputs with gate inputs
- OLED display (128x64)
- Rotary encoder
- MIDI I/O
- Gate inputs/outputs
- Audio I/O with AK4556 codec

**Initialization:**
```nim
var patch: DaisyPatch
patch.init()  # Or patch.init(boost = true) for 480MHz
```

**Audio:**
```nim
proc audioCallback(input, output: ptr ptr cfloat, size: csize_t) {.cdecl.} =
  # 4 input channels, 4 output channels
  for i in 0..<size:
    output[0][i] = input[0][i]  # Channel 1
    output[1][i] = input[1][i]  # Channel 2
    output[2][i] = input[2][i]  # Channel 3
    output[3][i] = input[3][i]  # Channel 4

patch.startAudio(audioCallback)
patch.stopAudio()
patch.setAudioSampleRate(SR_48KHZ)
patch.setAudioBlockSize(48)
```

**Controls:**
```nim
type PatchCtrl* = enum
  CTRL_1, CTRL_2, CTRL_3, CTRL_4

# Process controls
patch.processAllControls()  # Both analog and digital
# Or separately:
patch.processAnalogControls()
patch.processDigitalControls()

# Read control values
let knob1 = patch.getKnobValue(CTRL_1)  # 0.0 to 1.0

# Display control values on OLED
patch.displayControls()
```

**Direct Hardware Access:**
```nim
# Access underlying components
patch.seed.setLed(true)
patch.encoder  # Rotary encoder
patch.display  # OLED display
patch.midi     # MIDI handler
patch.gate_input[0]  # Gate input 1
patch.gate_output    # Gate output
```

---

For more examples, see [EXAMPLES.md](examples/EXAMPLES.md).

For technical details, see [TECHNICAL_REPORT.md](TECHNICAL_REPORT.md).

For contributing, see [CONTRIBUTING.md](CONTRIBUTING.md).
