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

## Random Number Generator Module (libdaisy_rng.nim) - NEW in v0.4.0

**Import:**
```nim
import src/libdaisy_rng
```

Hardware True Random Number Generator (TRNG) peripheral wrapper.

**Check Availability:**
```nim
proc randomIsReady*(): bool
```
Returns `true` if the hardware RNG is ready for use.

**Get Random Value:**
```nim
proc randomGetValue*(): uint32
```
Returns a random 32-bit unsigned integer.

**Get Random Float:**
```nim
proc randomGetFloat*(): cfloat
```
Returns a random float between 0.0 and 1.0.

**Example:**
```nim
import src/libdaisy_rng

if randomIsReady():
  let randInt = randomGetValue()
  let randFloat = randomGetFloat()
```

---

## Hardware Timer Module (libdaisy_timer.nim) - NEW in v0.4.0

**Import:**
```nim
import src/libdaisy_timer
```

Hardware timer peripherals (TIM2-TIM5) for precise timing and callbacks.

**Configuration Types:**
```nim
type
  TimerPeripheral = enum
    TIM_PERIPH_TIM2  # 32-bit counter
    TIM_PERIPH_TIM3  # 16-bit counter
    TIM_PERIPH_TIM4  # 16-bit counter
    TIM_PERIPH_TIM5  # 32-bit counter
  
  TimerCounterDir = enum
    TIMER_DIR_UP     # Count up from 0 to period
    TIMER_DIR_DOWN   # Count down from period to 0
  
  TimerResult = enum
    TIMER_OK   # Operation successful
    TIMER_ERR  # Operation failed
  
  TimerConfig = object
    periph: TimerPeripheral
    dir: TimerCounterDir
    period: uint32
    enable_irq: bool
  
  TimerCallback = proc(data: pointer) {.cdecl.}
```

**Initialization:**
```nim
var timer: TimerHandle
var config: TimerConfig
config.periph = TIM_PERIPH_TIM2
config.dir = TIMER_DIR_UP
config.period = 0xffffffff  # Max for 32-bit
config.enable_irq = false

discard timer.init(config)
discard timer.start()
```

**Timing Methods:**
```nim
proc getTick*(this: var TimerHandle): uint32
proc getMs*(this: var TimerHandle): uint32
proc getUs*(this: var TimerHandle): uint32
```

**Callback Support:**
```nim
proc setCallback*(this: var TimerHandle, callback: TimerCallback, data: pointer)

proc onTimer(data: pointer) {.cdecl.} =
  echo "Timer elapsed!"

config.enable_irq = true
discard timer.init(config)
timer.setCallback(onTimer, nil)
```

---

## Color Utilities Module (libdaisy_color.nim) - NEW in v0.4.0

**Import:**
```nim
import src/libdaisy_color
```

RGB color representation and manipulation utilities.

**Preset Colors:**
```nim
type
  PresetColor = enum
    COLOR_RED, COLOR_GREEN, COLOR_BLUE,
    COLOR_WHITE, COLOR_PURPLE, COLOR_CYAN,
    COLOR_GOLD, COLOR_OFF
```

**Create Color:**
```nim
proc createColor*(): Color
proc createColor*(r, g, b: cfloat): Color

var red = createColor()
red.init(COLOR_RED)

var orange = createColor(1.0, 0.5, 0.0)
```

**Getters:**
```nim
proc red*(this: Color): cfloat      # 0.0 to 1.0
proc green*(this: Color): cfloat
proc blue*(this: Color): cfloat
proc red8*(this: Color): uint8      # 0 to 255
proc green8*(this: Color): uint8
proc blue8*(this: Color): uint8
```

**Setters:**
```nim
proc setRed*(this: var Color, val: cfloat)
proc setGreen*(this: var Color, val: cfloat)
proc setBlue*(this: var Color, val: cfloat)
```

**Operators:**
```nim
proc `*`*(this: Color, scale: cfloat): Color  # Scale brightness
proc `+`*(lhs, rhs: Color): Color             # Add/saturate

var dimmed = myColor * 0.5
var combined = red + blue
```

**Blending:**
```nim
proc colorBlend*(a, b: Color, amt: cfloat): Color

var blended = colorBlend(red, blue, 0.5)  # 50/50 mix
```

---

## Gate Input Module (libdaisy_gatein.nim) - NEW in v0.4.0

**Import:**
```nim
import src/libdaisy_gatein
```

Gate/trigger input handler for eurorack-style gate signals.

**Initialization:**
```nim
var gate: GateIn
gate.init(D0(), true)  # Pin D0, inverted (typical for eurorack BJT circuits)
```

**Trigger Detection:**
```nim
proc trig*(this: var GateIn): bool
```
Returns `true` on rising edge detection. Call regularly to detect edges.

**State Reading:**
```nim
proc state*(this: var GateIn): bool
```
Returns current gate state (high/low).

**Example:**
```nim
while true:
  if gate.trig():
    echo "Gate triggered!"
  
  let isHigh = gate.state()
  delay(1)
```

---

## LED Control Module (libdaisy_led.nim) - NEW in v0.4.0

**Import:**
```nim
import src/libdaisy_led
```

Single LED control with software PWM and gamma correction.

**Initialization:**
```nim
var led: Led
led.init(D10(), false, 1000.0)  # Pin D10, not inverted, 1kHz update rate
```

**Set Brightness:**
```nim
proc set*(this: var Led, brightness: cfloat)
```
Set brightness 0.0 to 1.0 (automatically gamma corrected).

**Update:**
```nim
proc update*(this: var Led)
```
Must be called at the sample rate specified during init (e.g., 1kHz).

**Example:**
```nim
led.set(0.5)  # 50% brightness

while true:
  led.update()  # Call at 1kHz
  delay(1)
```

---

## RGB LED Module (libdaisy_rgbled.nim) - NEW in v0.4.0

**Import:**
```nim
import src/libdaisy_rgbled
import src/libdaisy_color
```

3-channel RGB LED control with software PWM.

**Initialization:**
```nim
var rgb: RgbLed
rgb.init(D10(), D11(), D12(), false)  # R, G, B pins, not inverted
```

**Set by Channels:**
```nim
proc set*(this: var RgbLed, r, g, b: cfloat)

rgb.set(1.0, 0.0, 0.0)  # Red
```

**Set by Color:**
```nim
proc setColor*(this: var RgbLed, c: Color)

var purple = createColor(0.5, 0.0, 0.5)
rgb.setColor(purple)
```

**Individual Channels:**
```nim
proc setRed*(this: var RgbLed, val: cfloat)
proc setGreen*(this: var RgbLed, val: cfloat)
proc setBlue*(this: var RgbLed, val: cfloat)
```

**Update:**
```nim
proc update*(this: var RgbLed)
```
Must be called regularly (e.g., 1kHz) for PWM.

---

## 3-Position Switch Module (libdaisy_switch3.nim) - NEW in v0.4.0

**Import:**
```nim
import src/libdaisy_switch3
```

3-position switch/toggle handler.

**Position Constants:**
```nim
const
  SWITCH3_POS_CENTER = 0
  SWITCH3_POS_UP = 1     # or POS_LEFT
  SWITCH3_POS_DOWN = 2   # or POS_RIGHT
```

**Initialization:**
```nim
var sw: Switch3
sw.init(D2(), D3())  # Two pins for 3 positions
```

**Read Position:**
```nim
proc read*(this: var Switch3): uint8

let pos = sw.read()
case pos
of SWITCH3_POS_CENTER:
  echo "Center"
of SWITCH3_POS_UP:
  echo "Up"
of SWITCH3_POS_DOWN:
  echo "Down"
```

---

## Data Structures & Utilities (v0.5.0)

### FIFO Module (libdaisy_fifo.nim)

**Import:**
```nim
import src/libdaisy_fifo
```

Lock-free FIFO (First-In-First-Out) queue with fixed capacity. Thread-safe for single-producer/single-consumer scenarios.

**Type:**
```nim
type
  Fifo*[N: static int, T] = object
    # N = capacity (compile-time constant)
    # T = element type
```

**Methods:**
```nim
proc init*[N: static int, T](this: var Fifo[N, T])
  # Initialize empty FIFO

proc clear*[N: static int, T](this: var Fifo[N, T])
  # Clear all elements

proc push*[N: static int, T](this: var Fifo[N, T], value: T): bool
  # Push value to queue. Returns false if full.

proc pop*[N: static int, T](this: var Fifo[N, T], value: var T): bool
  # Pop value from queue. Returns false if empty.

proc peek*[N: static int, T](this: Fifo[N, T], value: var T): bool
  # Peek at front without removing

proc len*[N: static int, T](this: Fifo[N, T]): int
  # Get current number of elements

proc capacity*[N: static int, T](this: Fifo[N, T]): int
  # Get maximum capacity (always N)

proc isEmpty*[N: static int, T](this: Fifo[N, T]): bool
proc isFull*[N: static int, T](this: Fifo[N, T]): bool
```

**Example:**
```nim
var eventQueue: Fifo[16, int]
eventQueue.init()

# Push events
assert eventQueue.push(1)
assert eventQueue.push(2)

# Pop events (FIFO order)
var event: int
while eventQueue.pop(event):
  echo "Processing event: ", event
```

**Performance Notes:**
- Zero heap allocation (all stack-based)
- O(1) push/pop operations
- Audio-rate safe
- Lock-free for SPSC (single producer, single consumer)

---

### Stack Module (libdaisy_stack.nim)

**Import:**
```nim
import src/libdaisy_stack
```

Fixed-capacity stack (Last-In-First-Out) with compile-time size.

**Type:**
```nim
type
  Stack*[N: static int, T] = object
```

**Methods:**
```nim
proc init*[N: static int, T](this: var Stack[N, T])
proc clear*[N: static int, T](this: var Stack[N, T])

proc push*[N: static int, T](this: var Stack[N, T], value: T): bool
  # Push to top. Returns false if full.

proc pop*[N: static int, T](this: var Stack[N, T], value: var T): bool
  # Pop from top. Returns false if empty.

proc peek*[N: static int, T](this: Stack[N, T], value: var T): bool
  # Peek at top without removing

proc len*[N: static int, T](this: Stack[N, T]): int
proc capacity*[N: static int, T](this: Stack[N, T]): int
proc isEmpty*[N: static int, T](this: Stack[N, T]): bool
proc isFull*[N: static int, T](this: Stack[N, T]): bool
```

**Example:**
```nim
var undoStack: Stack[8, float32]
undoStack.init()

# Record parameter changes
assert undoStack.push(0.5)
assert undoStack.push(0.7)

# Undo (LIFO order)
var value: float32
while undoStack.pop(value):
  echo "Restored: ", value  # 0.7, then 0.5
```

---

### RingBuffer Module (libdaisy_ringbuffer.nim)

**Import:**
```nim
import src/libdaisy_ringbuffer
```

Lock-free circular buffer optimized for audio streaming. Supports block read/write and configurable overflow behavior.

**Type:**
```nim
type
  RingBufferMode* = enum
    OVERWRITE_OLDEST  # Overwrite old data when full
    REJECT_NEW        # Reject new writes when full
  
  RingBuffer*[N: static int, T] = object
```

**Methods:**
```nim
proc init*[N: static int, T](this: var RingBuffer[N, T], 
                             mode: RingBufferMode = OVERWRITE_OLDEST)

proc clear*[N: static int, T](this: var RingBuffer[N, T])

proc write*[N: static int, T](this: var RingBuffer[N, T], value: T): bool
  # Write single value

proc read*[N: static int, T](this: var RingBuffer[N, T], value: var T): bool
  # Read single value

proc writeBlock*[N: static int, T](this: var RingBuffer[N, T], 
                                   data: openArray[T]): int
  # Write multiple values, returns count written

proc readBlock*[N: static int, T](this: var RingBuffer[N, T], 
                                  data: var openArray[T]): int
  # Read multiple values, returns count read

proc peek*[N: static int, T](this: RingBuffer[N, T], value: var T, 
                             offset: int = 0): bool
  # Peek at value without removing

proc available*[N: static int, T](this: RingBuffer[N, T]): int
  # Get number of readable elements

proc remaining*[N: static int, T](this: RingBuffer[N, T]): int
  # Get space remaining for writes

proc capacity*[N: static int, T](this: RingBuffer[N, T]): int
proc isEmpty*[N: static int, T](this: RingBuffer[N, T]): bool
proc isFull*[N: static int, T](this: RingBuffer[N, T]): bool
```

**Example:**
```nim
# 100ms delay buffer at 48kHz
const DELAY_SAMPLES = 4800
var delayLine: RingBuffer[DELAY_SAMPLES, float32]
delayLine.init()

# In audio callback
proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  for i in 0 ..< size:
    var delayed: float32
    discard delayLine.read(delayed)
    discard delayLine.write(input[0][i])
    output[0][i] = input[0][i] * 0.5 + delayed * 0.5
```

---

### FixedStr Module (libdaisy_fixedstr.nim)

**Import:**
```nim
import src/libdaisy_fixedstr
```

Stack-allocated fixed-capacity string for embedded displays and UI. No heap allocation.

**Type:**
```nim
type
  FixedStr*[N: static int] = object
    # N = maximum capacity in characters
```

**Methods:**
```nim
proc init*[N: static int](this: var FixedStr[N])
proc clear*[N: static int](this: var FixedStr[N])

proc add*[N: static int](this: var FixedStr[N], c: char): bool
proc add*[N: static int](this: var FixedStr[N], str: string): int
proc add*[N: static int](this: var FixedStr[N], value: int): int
proc add*[N: static int](this: var FixedStr[N], value: float): int
  # Add content. Returns chars added or false if full.

proc set*[N: static int](this: var FixedStr[N], str: string): int
  # Replace entire contents

proc `[]`*[N: static int](this: FixedStr[N], index: int): char
proc `[]=`*[N: static int](this: var FixedStr[N], index: int, c: char)
  # Character access

proc `$`*[N: static int](this: FixedStr[N]): string
  # Convert to string (allocates)

proc len*[N: static int](this: FixedStr[N]): int
proc capacity*[N: static int](this: FixedStr[N]): int
proc isEmpty*[N: static int](this: FixedStr[N]): bool
proc isFull*[N: static int](this: FixedStr[N]): bool
```

**Example:**
```nim
var display: FixedStr[32]
display.init()

discard display.add("Cutoff: ")
discard display.add(1200)
discard display.add(" Hz")

echo $display  # "Cutoff: 1200 Hz"

# Update
display.clear()
discard display.add("Volume: 75%")
```

---

### UniqueId Module (libdaisy_uniqueid.nim)

**Import:**
```nim
import src/libdaisy_uniqueid
```

Read STM32 microcontroller's factory-programmed 96-bit unique identifier.

**Type:**
```nim
type
  UniqueId* = object
    w0*: uint32  # Bits 0-31
    w1*: uint32  # Bits 32-63
    w2*: uint32  # Bits 64-95
```

**Functions:**
```nim
proc getUniqueId*(): UniqueId
  # Read 96-bit unique ID

proc getUniqueIdString*(): string
  # Get as "XXXXXXXX-XXXXXXXX-XXXXXXXX" format

proc `$`*(uid: UniqueId): string
  # String representation

proc `==`*(a, b: UniqueId): bool
  # Equality comparison
```

**Example:**
```nim
let uid = getUniqueId()
echo uid  # UniqueId(0x12345678-0x9ABCDEF0-0x13579BDF)

let serial = getUniqueIdString()
echo "Device: ", serial  # Device: 12345678-9ABCDEF0-13579BDF

# Use for device identification
var deviceName: FixedStr[64]
deviceName.init()
discard deviceName.add("DaisySeed-")
discard deviceName.add(serial)
```

**Use Cases:**
- Device identification and registration
- License/authentication systems
- Hardware-based encryption keys
- Generating unique serial numbers

---

### CpuLoadMeter Module (libdaisy_cpuload.nim)

**Import:**
```nim
import src/libdaisy_cpuload
```

Real-time CPU load measurement for audio processing optimization.

**Type:**
```nim
type
  CpuLoadMeter* {.importcpp: "daisy::CpuLoadMeter".} = object
```

**Methods:**
```nim
proc init*(this: var CpuLoadMeter, sampleRateInHz: float32, 
           blockSizeInSamples: int, 
           smoothingFilterCutoffHz: float32 = 1.0)
  # Initialize with audio configuration

proc onBlockStart*(this: var CpuLoadMeter)
  # Call at beginning of audio callback

proc onBlockEnd*(this: var CpuLoadMeter)
  # Call at end of audio callback

proc getAvgCpuLoad*(this: CpuLoadMeter): float32
  # Get smoothed average load (0.0 to 1.0)

proc getMinCpuLoad*(this: CpuLoadMeter): float32
  # Get minimum observed load

proc getMaxCpuLoad*(this: CpuLoadMeter): float32
  # Get maximum observed load

proc reset*(this: var CpuLoadMeter)
  # Reset statistics
```

**Example:**
```nim
var cpuMeter: CpuLoadMeter
cpuMeter.init(48000.0, 48)  # 48kHz, 48 samples/block

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  cpuMeter.onBlockStart()
  
  # Your DSP processing here
  for i in 0 ..< size:
    output[0][i] = input[0][i]
  
  cpuMeter.onBlockEnd()

# In main loop
while true:
  let load = cpuMeter.getAvgCpuLoad()
  echo "CPU: ", int(load * 100), "%"
  if load > 0.9:
    echo "WARNING: High CPU usage!"
  daisy.delay(1000)
```

**Interpretation:**
- **0-50%**: Plenty of headroom
- **50-70%**: Moderate usage
- **70-90%**: High usage - consider optimization
- **90-100%**: Critical - risk of audio dropouts
- **>100%**: Audio dropouts occurring

---

### Parameter Module (libdaisy_parameter.nim)

**Import:**
```nim
import src/libdaisy_parameter
```

Parameter mapping with various scaling curves for natural control feel.

**Types:**
```nim
type
  Curve* = enum
    LINEAR       # Direct proportional (y = x)
    EXPONENTIAL  # Fast rise at high end (y = x²)
    LOGARITHMIC  # Fast rise at low end
    CUBE         # Smooth S-curve (y = x³)
```

**Functions:**
```nim
proc mapParameter*(input: float32, min: float32, max: float32, 
                   curve: Curve): float32
  # Map 0-1 input to min-max with curve

proc mapParameterExp*(input: float32, min: float32, max: float32): float32
proc mapParameterLog*(input: float32, min: float32, max: float32): float32
proc mapParameterLin*(input: float32, min: float32, max: float32): float32
proc mapParameterCube*(input: float32, min: float32, max: float32): float32
  # Convenience functions for specific curves
```

**Example:**
```nim
let knobValue = 0.6  # ADC reading (0.0 to 1.0)

# Filter cutoff: exponential feels natural for frequency
let cutoff = mapParameterExp(knobValue, 100.0, 10000.0)
echo "Cutoff: ", int(cutoff), " Hz"  # ~3700 Hz

# Volume: logarithmic feels natural for amplitude
let volume = mapParameterLog(knobValue, 0.0, 1.0)

# Mix: linear is fine
let mix = mapParameterLin(knobValue, 0.0, 1.0)
```

**Curve Recommendations:**
- **Frequency parameters**: Use EXPONENTIAL (cutoff, pitch, delay time)
- **Amplitude/Volume**: Use LOGARITHMIC (gain, mix level)
- **Time parameters**: Use EXPONENTIAL (attack, decay, release)
- **Position/Mix**: Use LINEAR (pan, dry/wet)
- **Smooth non-linear**: Use CUBE

---

### MappedValue Module (libdaisy_mapped_value.nim)

**Import:**
```nim
import src/libdaisy_mapped_value
```

Value mapping, quantization, and normalization utilities. Pure Nim implementation.

**Functions:**
```nim
# Basic mapping
proc mapValueFloat*(input: float32, min: float32, max: float32): float32
  # Map 0-1 to float range

proc mapValueInt*(input: float32, min: int, max: int): int
  # Map 0-1 to integer range (rounded)

# Quantization
proc mapValueFloatQuantized*(input: float32, min: float32, max: float32, 
                             numSteps: int): float32
  # Map to quantized steps

proc quantizeFloat*(value: float32, stepSize: float32): float32
  # Quantize to nearest multiple

# Bipolar/Unipolar
proc mapValueBipolar*(input: float32, min: float32, max: float32): float32
  # Map with center at 0.5

proc mapValueUnipolar*(input: float32, max: float32): float32
  # Map 0-1 to 0-max

# Normalization (inverse operations)
proc normalizeValue*(value: float32, min: float32, max: float32): float32
proc normalizeValueInt*(value: int, min: int, max: int): float32

# Interpolation
proc lerp*(a: float32, b: float32, t: float32): float32
  # Linear interpolation

proc inverseLerp*(a: float32, b: float32, value: float32): float32
  # Find t for given value
```

**Examples:**
```nim
# Discrete parameter selection
let waveform = mapValueInt(0.7, 0, 3)  # Returns 2
# Maps to: 0=Sine, 1=Saw, 2=Square, 3=Triangle

# Quantize to semitones
let semitone = mapValueFloatQuantized(0.45, 0.0, 12.0, 12)
let freq = 220.0 * pow(2.0, semitone / 12.0)

# Bipolar CV input (0.5 = center/zero)
let panPosition = mapValueBipolar(0.75, -1.0, 1.0)  # Returns 0.5

# Normalize for display
let normalized = normalizeValue(440.0, 20.0, 20000.0)
echo "Frequency slider: ", int(normalized * 100), "%"

# Quantize mix to 5% increments
let mix = quantizeFloat(0.47, 0.05)  # Returns 0.45
```

**Common Patterns:**
```nim
# Octave selection (-2 to +2)
let octave = mapValueInt(knobValue, -2, 2)

# Quantize frequency to 10 Hz steps
let freq = quantizeFloat(mapValueFloat(knobValue, 20.0, 2000.0), 10.0)

# Map CV input ±5V (0.5 = 0V)
let cvVolts = mapValueBipolar(adcValue, -5.0, 5.0)
```

---

## Audio Codecs & Displays (v0.7.0)

### AK4556 Codec Module (codec_ak4556.nim)

**Import:**
```nim
import src/dev/codec_ak4556
```

**Description:**
Simple 24-bit stereo audio codec used on Daisy Seed 1.0. Requires only reset pin initialization - no I2C configuration.

**Types:**
```nim
type
  Ak4556* = object
    ## AK4556 codec driver
```

**Methods:**
```nim
proc init*(this: var Ak4556, resetPin: Pin)
  ## Initialize codec with reset pin
  
proc deInit*(this: var Ak4556)
  ## Deinitialize codec
```

**Example:**
```nim
import src/libdaisy
import src/dev/codec_ak4556

var codec: Ak4556
codec.init(getPin(0))  # Reset pin on D0
# Audio hardware now configured for Daisy Seed 1.0
codec.deInit()  # Clean up when done
```

---

### WM8731 Codec Module (codec_wm8731.nim)

**Import:**
```nim
import src/libdaisy_i2c
import src/dev/codec_wm8731
```

**Description:**
I2C-controlled 24-bit stereo codec used on Daisy Seed 1.1. Provides configurable audio format and word length.

**Types:**
```nim
type
  Wm8731Result* = enum
    OK   ## Success
    ERR  ## Failure
    
  Wm8731Format* = enum
    MSB_FIRST_RJ  ## MSB first, right-justified
    MSB_FIRST_LJ  ## MSB first, left-justified (default)
    I2S           ## I2S format
    DSP           ## DSP format
    
  Wm8731WordLength* = enum
    BITS_16  ## 16-bit samples
    BITS_20  ## 20-bit samples
    BITS_24  ## 24-bit samples (default)
    BITS_32  ## 32-bit samples
    
  Wm8731Config* = object
    mcu_is_master*: bool        ## MCU master mode
    lr_swap*: bool              ## Swap L/R channels
    csb_pin_state*: bool        ## CSB pin state
    fmt*: Wm8731Format          ## Audio format
    wl*: Wm8731WordLength       ## Word length
```

**Methods:**
```nim
proc defaults*(this: var Wm8731Config)
  ## Set default configuration
  ## MCU master, 24-bit, MSB LJ format
  
proc init*(this: var Wm8731, config: Wm8731Config, i2c: I2CHandle): Wm8731Result
  ## Initialize codec via I2C
```

**Example:**
```nim
import src/libdaisy
import src/libdaisy_i2c
import src/dev/codec_wm8731

var i2c = initI2C(I2C_1, getPin(11), getPin(12), I2C_400KHZ)
var codec: Wm8731
var config: Wm8731Config

config.defaults()  # Standard config
config.fmt = Wm8731Format.I2S  # Override to I2S if needed

if codec.init(config, i2c) == Wm8731Result.OK:
  echo "WM8731 initialized successfully"
```

---

### PCM3060 Codec Module (codec_pcm3060.nim)

**Import:**
```nim
import src/libdaisy_i2c
import src/dev/codec_pcm3060
```

**Description:**
High-performance 24-bit stereo codec used on Daisy Seed 2.0. Auto-configures to 24-bit LJ format.

**Types:**
```nim
type
  Pcm3060Result* = enum
    OK   ## Success
    ERR  ## Failure
```

**Methods:**
```nim
proc init*(this: var Pcm3060, i2c: I2CHandle): Pcm3060Result
  ## Initialize codec via I2C
  ## Auto-configures to 24-bit LJ format
```

**Example:**
```nim
import src/libdaisy
import src/libdaisy_i2c
import src/dev/codec_pcm3060

var i2c = initI2C(I2C_1, getPin(11), getPin(12), I2C_400KHZ)
var codec: Pcm3060

if codec.init(i2c) == Pcm3060Result.OK:
  echo "PCM3060 initialized successfully"
```

---

### HD44780 LCD Module (lcd_hd44780.nim)

**Import:**
```nim
import src/dev/lcd_hd44780
```

**Description:**
Character LCD driver for HD44780-compatible displays (16x2, 20x4). Uses 4-bit data mode with 6 GPIO connections.

**Types:**
```nim
type
  LcdHD44780Config* = object
    cursor_on*: bool      ## Show cursor
    cursor_blink*: bool   ## Blink cursor
    rs*: Pin              ## Register select pin
    en*: Pin              ## Enable pin
    d4*: Pin              ## Data bit 4
    d5*: Pin              ## Data bit 5
    d6*: Pin              ## Data bit 6
    d7*: Pin              ## Data bit 7
```

**Methods:**
```nim
proc init*(this: var LcdHD44780, config: LcdHD44780Config)
  ## Initialize LCD with configuration
  
proc print*(this: var LcdHD44780, text: cstring)
  ## Print text at current cursor position
  
proc printInt*(this: var LcdHD44780, value: cint)
  ## Print integer value
  
proc setCursor*(this: var LcdHD44780, row: uint8, col: uint8)
  ## Set cursor position (row 0-1, col 0-15 for 16x2)
  
proc clear*(this: var LcdHD44780)
  ## Clear display and reset cursor
```

**Example:**
```nim
import src/libdaisy
import src/dev/lcd_hd44780

var lcd: LcdHD44780
var config: LcdHD44780Config

config.cursor_on = false
config.cursor_blink = false
config.rs = getPin(1)
config.en = getPin(2)
config.d4 = getPin(3)
config.d5 = getPin(4)
config.d6 = getPin(5)
config.d7 = getPin(6)

lcd.init(config)
lcd.clear()
lcd.setCursor(0, 0)  # Row 0, Column 0
lcd.print("Hello Daisy!")
lcd.setCursor(1, 0)  # Row 1, Column 0
lcd.print("Volume: ")
lcd.printInt(75)  # Print "75"
```

---

### OLED Fonts Module (oled_fonts.nim)

**Import:**
```nim
import src/util/oled_fonts
```

**Description:**
Font data for OLED displays. Provides 8 bitmap fonts in various sizes for use with SSD1306 and similar displays.

**Types:**
```nim
type
  FontDef* = object
    ## Font definition structure
    ## Contains character bitmap data and dimensions
```

**Available Fonts:**
```nim
var Font_4x6*: FontDef      ## 4x6 pixel font (smallest)
var Font_5x8*: FontDef      ## 5x8 pixel font
var Font_6x8*: FontDef      ## 6x8 pixel font  
var Font_7x10*: FontDef     ## 7x10 pixel font
var Font_11x18*: FontDef    ## 11x18 pixel font
var Font_12x16*: FontDef    ## 12x16 pixel font
var Font_16x26*: FontDef    ## 16x26 pixel font (largest)
```

**Usage:**
```nim
import src/libdaisy_oled
import src/util/oled_fonts

var display: OledDisplay
# ... initialize display ...

# Use font with OLED display
display.setFont(Font_7x10)
display.writeString("Hello", Font_7x10, true)  # true = white text
```

**Font Characteristics:**
- All fonts are monospaced (fixed width)
- Characters are ASCII printable (32-126)
- Stored in flash memory (no RAM overhead)
- Compatible with common OLED libraries

---

## Sensor Modules (v0.8.0)

### ICM20948 9-Axis IMU Module (icm20948.nim)

**Import:**
```nim
import src/dev/icm20948
import src/libdaisy_i2c  # or libdaisy_spi
```

**Description:**
9-axis motion sensor with 3-axis gyroscope, 3-axis accelerometer, 3-axis magnetometer (AK09916), and temperature sensor. Supports both I2C and SPI interfaces.

**Important:** Requires applying libDaisy patch before use. See `patches/README.md` for details.

**Types:**
```nim
type
  AccelFullScale* {.size: sizeof(cint).} = enum
    ## Accelerometer full scale range
    ACCEL_RANGE_2G = 0
    ACCEL_RANGE_4G = 1
    ACCEL_RANGE_8G = 2
    ACCEL_RANGE_16G = 3

  GyroFullScale* {.size: sizeof(cint).} = enum
    ## Gyroscope full scale range
    GYRO_RANGE_250DPS = 0
    GYRO_RANGE_500DPS = 1
    GYRO_RANGE_1000DPS = 2
    GYRO_RANGE_2000DPS = 3

  ICM20948I2CTransportConfig* = object
    ## I2C transport configuration
    periph*: I2CPeripheral
    speed*: I2CSpeed
    scl*: Pin
    sda*: Pin
    address*: uint8  # 0x68 (AD0=LOW) or 0x69 (AD0=HIGH)

  ICM20948Config* = object
    ## Main configuration structure
    transport_config*: ICM20948I2CTransportConfig  # or SPITransportConfig
    accel_scale*: AccelFullScale
    gyro_scale*: GyroFullScale
    accel_odr_div*: uint16  # Sample rate divider (1-4095)
    gyro_odr_div*: uint8    # Sample rate divider (0-255)

  ICM20948I2C* = object
    ## Main sensor type (I2C version)

  ICM20948Data* = object
    ## Sensor reading structure
    accel_x*, accel_y*, accel_z*: float32  # m/s²
    gyro_x*, gyro_y*, gyro_z*: float32     # degrees/sec
    mag_x*, mag_y*, mag_z*: float32        # microtesla (µT)
    temp*: float32                          # Celsius
```

**Methods:**
```nim
proc init*(config: ICM20948Config): Result[ICM20948I2C, string]
  ## Initialize the sensor. Returns Result with sensor object or error message.

proc read*(imu: var ICM20948I2C): ICM20948Data
  ## Read accelerometer and gyroscope data (not magnetometer)

proc setupMag*(imu: var ICM20948I2C): bool
  ## Initialize magnetometer (AK09916). Returns true on success.
  ## Requires libDaisy patch to function correctly.

proc readMag*(imu: var ICM20948I2C): tuple[x, y, z: float32]
  ## Read magnetometer data in microtesla (µT)

proc getTemp*(imu: var ICM20948I2C): float32
  ## Read temperature in Celsius
```

**Example:**
```nim
import src/dev/icm20948
import src/libdaisy_i2c

var config: ICM20948Config
config.transport_config.periph = I2C_1
config.transport_config.speed = I2C_400KHZ
config.transport_config.scl = D11()
config.transport_config.sda = D12()
config.transport_config.address = 0x68
config.accel_scale = ACCEL_RANGE_4G
config.gyro_scale = GYRO_RANGE_500DPS

let result = init(config)
if result.isOk:
  var imu = result.get()
  discard imu.setupMag()  # Enable magnetometer
  
  while true:
    let data = imu.read()
    let mag = imu.readMag()
    # Use data.accel_x, data.gyro_y, mag.x, etc.
```

---

### APDS9960 Gesture/Light Sensor Module (apds9960.nim)

**Import:**
```nim
import src/dev/apds9960
import src/libdaisy_i2c
```

**Description:**
Multi-function sensor with gesture recognition, proximity detection, RGB color sensing, and ambient light detection. I2C interface only.

**Types:**
```nim
type
  Gesture* {.size: sizeof(cint).} = enum
    ## Recognized gestures
    NONE = 0
    UP = 1
    DOWN = 2
    LEFT = 3
    RIGHT = 4
    NEAR = 5
    FAR = 6

  APDS9960I2CTransportConfig* = object
    periph*: I2CPeripheral
    speed*: I2CSpeed
    scl*: Pin
    sda*: Pin

  APDS9960Config* = object
    transport_config*: APDS9960I2CTransportConfig

  APDS9960I2C* = object
    ## Main sensor type
```

**Methods:**
```nim
proc init*(config: APDS9960Config): Result[APDS9960I2C, string]
  ## Initialize the sensor

proc enableGesture*(sensor: var APDS9960I2C, enable: bool): bool
  ## Enable or disable gesture detection. Returns true on success.

proc readGesture*(sensor: var APDS9960I2C): Gesture
  ## Read detected gesture. Returns NONE if no gesture detected.

proc readProximity*(sensor: var APDS9960I2C): uint8
  ## Read proximity value (0-255, higher = closer)

proc readColor*(sensor: var APDS9960I2C): tuple[r, g, b, c: uint16]
  ## Read RGBC values (16-bit per channel, c = clear/ambient)

proc setGestureGain*(sensor: var APDS9960I2C, gain: uint8): bool
  ## Set gesture sensitivity (0=1x, 1=2x, 2=4x, 3=8x)
```

**Example:**
```nim
import src/dev/apds9960

var config: APDS9960Config
config.transport_config.periph = I2C_1
config.transport_config.speed = I2C_400KHZ
config.transport_config.scl = D11()
config.transport_config.sda = D12()

let result = init(config)
if result.isOk:
  var sensor = result.get()
  discard sensor.enableGesture(true)
  
  while true:
    let gesture = sensor.readGesture()
    if gesture != NONE:
      # Handle UP, DOWN, LEFT, RIGHT, NEAR, FAR
      discard
```

---

### DPS310 Barometric Pressure Sensor Module (dps310.nim)

**Import:**
```nim
import src/dev/dps310
import src/libdaisy_i2c  # or libdaisy_spi
```

**Description:**
High-precision barometric pressure and temperature sensor with altitude calculation. Supports both I2C and SPI interfaces.

**Types:**
```nim
type
  DPS310I2CTransportConfig* = object
    periph*: I2CPeripheral
    speed*: I2CSpeed
    scl*: Pin
    sda*: Pin

  DPS310Config* = object
    transport_config*: DPS310I2CTransportConfig  # or SPITransportConfig

  DPS310I2C* = object
    ## Main sensor type (I2C version)
```

**Methods:**
```nim
proc init*(config: DPS310Config): Result[DPS310I2C, string]
  ## Initialize the sensor

proc startContinuous*(sensor: var DPS310I2C): bool
  ## Start continuous measurement mode. Returns true on success.

proc getData*(sensor: var DPS310I2C): tuple[pressure: float32, hasData: bool]
  ## Read pressure in Pascals (Pa). hasData indicates if new data available.

proc getTemperatureC*(sensor: var DPS310I2C): float32
  ## Read temperature in Celsius

proc getAltitude*(sensor: var DPS310I2C, seaLevelPressure: float32 = 101325.0): float32
  ## Calculate altitude in meters from current pressure
  ## seaLevelPressure: reference pressure in Pa (default 101325 Pa = 1013.25 hPa)
```

**Example:**
```nim
import src/dev/dps310

var config: DPS310Config
config.transport_config.periph = I2C_1
config.transport_config.speed = I2C_400KHZ
config.transport_config.scl = D11()
config.transport_config.sda = D12()

let result = init(config)
if result.isOk:
  var sensor = result.get()
  discard sensor.startContinuous()
  
  while true:
    let (pressure, hasData) = sensor.getData()
    if hasData:
      let temp = sensor.getTemperatureC()
      let altitude = sensor.getAltitude()  # Default sea level pressure
      # pressure in Pa, temp in °C, altitude in meters
```

---

### TLV493D 3D Magnetic Sensor Module (tlv493d.nim)

**Import:**
```nim
import src/dev/tlv493d
import src/libdaisy_i2c
```

**Description:**
3-axis magnetic field sensor with 12-bit resolution. I2C interface only. Useful for position sensing, compass applications, and magnetic field measurement.

**Types:**
```nim
type
  TLV493DI2CTransportConfig* = object
    periph*: I2CPeripheral
    speed*: I2CSpeed
    scl*: Pin
    sda*: Pin

  TLV493DConfig* = object
    transport_config*: TLV493DI2CTransportConfig

  TLV493DI2C* = object
    ## Main sensor type
```

**Methods:**
```nim
proc init*(config: TLV493DConfig): Result[TLV493DI2C, string]
  ## Initialize the sensor

proc result*(sensor: var TLV493DI2C): tuple[x, y, z: float32]
  ## Read magnetic field values in millitesla (mT)
  ## Returns x, y, z magnetic field components
```

**Example:**
```nim
import src/dev/tlv493d

var config: TLV493DConfig
config.transport_config.periph = I2C_1
config.transport_config.speed = I2C_400KHZ
config.transport_config.scl = D11()
config.transport_config.sda = D12()

let result = init(config)
if result.isOk:
  var sensor = result.get()
  
  while true:
    let mag = sensor.result()
    # mag.x, mag.y, mag.z in millitesla (mT)
```

---

### MPR121 Capacitive Touch Sensor Module (mpr121.nim)

**Import:**
```nim
import src/dev/mpr121
import src/libdaisy_i2c
```

**Description:**
12-channel capacitive touch controller. Detects touch/release on 12 independent electrodes. I2C interface only.

**Types:**
```nim
type
  MPR121I2CTransportConfig* = object
    periph*: I2CPeripheral
    speed*: I2CSpeed
    scl*: Pin
    sda*: Pin

  MPR121Config* = object
    transport_config*: MPR121I2CTransportConfig

  MPR121I2C* = object
    ## Main sensor type
```

**Methods:**
```nim
proc init*(config: MPR121Config): Result[MPR121I2C, string]
  ## Initialize the sensor with default touch/release thresholds

proc touched*(sensor: var MPR121I2C): uint16
  ## Read touch state of all 12 channels as bitmask
  ## Bit 0 = channel 0, bit 1 = channel 1, etc.
  ## Returns 0 if no channels touched

proc setThresholds*(sensor: var MPR121I2C, touch, release: uint8): bool
  ## Set global touch and release thresholds for all channels
  ## Higher values = less sensitive (default: touch=12, release=6)
```

**Example:**
```nim
import src/dev/mpr121

var config: MPR121Config
config.transport_config.periph = I2C_1
config.transport_config.speed = I2C_400KHZ
config.transport_config.scl = D11()
config.transport_config.sda = D12()

let result = init(config)
if result.isOk:
  var sensor = result.get()
  
  while true:
    let state = sensor.touched()
    
    # Check individual channels
    if (state and (1 shl 0)) != 0:
      # Channel 0 is touched
      discard
    if (state and (1 shl 5)) != 0:
      # Channel 5 is touched
      discard
```

---

### NeoTrellis 4x4 RGB Button Pad Module (neotrellis.nim)

**Import:**
```nim
import src/dev/neotrellis
import src/libdaisy_i2c
```

**Description:**
4x4 matrix of mechanical switches with RGB LEDs. Based on Adafruit seesaw firmware. I2C interface only.

**Types:**
```nim
type
  NeoTrellisI2CTransportConfig* = object
    periph*: I2CPeripheral
    speed*: I2CSpeed
    scl*: Pin
    sda*: Pin

  NeoTrellisConfig* = object
    transport_config*: NeoTrellisI2CTransportConfig

  NeoTrellisI2C* = object
    ## Main device type

  KeyEvent* = object
    ## Button event structure
    key*: uint8   # Key number (0-15)
    edge*: uint8  # 0=released, 1=pressed
```

**Methods:**
```nim
proc init*(config: NeoTrellisConfig): Result[NeoTrellisI2C, string]
  ## Initialize the device

proc setPixelColor*(trellis: var NeoTrellisI2C, index: uint8, r, g, b: uint8): bool
  ## Set RGB color for button LED (index 0-15)
  ## Returns true on success

proc show*(trellis: var NeoTrellisI2C): bool
  ## Update all LEDs with set colors. Must call after setPixelColor.

proc readButtons*(trellis: var NeoTrellisI2C): seq[KeyEvent]
  ## Read button events since last call
  ## Returns sequence of press/release events
```

**Example:**
```nim
import src/dev/neotrellis

var config: NeoTrellisConfig
config.transport_config.periph = I2C_1
config.transport_config.speed = I2C_400KHZ
config.transport_config.scl = D11()
config.transport_config.sda = D12()

let result = init(config)
if result.isOk:
  var trellis = result.get()
  
  # Set button 0 to red
  discard trellis.setPixelColor(0, 255, 0, 0)
  discard trellis.show()
  
  while true:
    let events = trellis.readButtons()
    for event in events:
      if event.edge == 1:
        # Button pressed
        discard trellis.setPixelColor(event.key, 0, 255, 0)  # Green
      else:
        # Button released
        discard trellis.setPixelColor(event.key, 0, 0, 0)    # Off
    discard trellis.show()
```

---

For more examples, see [EXAMPLES.md](EXAMPLES.md).

For technical details, see [TECHNICAL_REPORT.md](TECHNICAL_REPORT.md).

For contributing, see [CONTRIBUTING.md](CONTRIBUTING.md).
