# Nim Examples for libDaisy

This directory contains example programs demonstrating how to use the libDaisy Nim wrapper.

## Prerequisites

Before running these examples, you need:

1. **Nim compiler** (version 1.6.0 or later)
2. **ARM GNU Toolchain** (arm-none-eabi-gcc)
3. **libDaisy** compiled for your Daisy Seed
4. **dfu-util** for flashing firmware to the Daisy Seed

## Building Examples

### Option 1: Using the Makefile Template

1. Copy `Makefile.template` to `Makefile`
2. Copy `nim.cfg.template` to `nim.cfg`
3. Edit the paths in both files to match your libDaisy installation
4. Build an example:

```bash
make TARGET=blink
```

5. Flash to Daisy Seed:

```bash
make program-dfu
```

### Option 2: Manual Compilation

Use the Nim compiler directly with appropriate flags:

```bash
nim cpp \
  --cpu:arm \
  --os:standalone \
  --gc:arc \
  --nimcache:.nimcache \
  --passC:"-mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard" \
  --passL:"-mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard" \
  --passL:"-L../build -ldaisy" \
  --passL:"-T../core/STM32H750IB_flash.lds" \
  --gcc.exe:arm-none-eabi-gcc \
  --gcc.linkerexe:arm-none-eabi-g++ \
  blink.nim
```

Then create a binary and flash:

```bash
arm-none-eabi-objcopy -O binary blink blink.bin
dfu-util -a 0 -s 0x08000000:leave -D blink.bin
```

## Examples Overview

### Basic Examples

#### `blink.nim`
Simple LED blink example. Great for testing your setup.

**Features:**
- Basic initialization
- LED control
- Delay timing

#### `gpio_input.nim`
Demonstrates reading digital inputs.

**Hardware Setup:**
- Connect button between D0 and GND

**Features:**
- GPIO input configuration
- Pull-up resistors
- Reading digital states

### Audio Examples

#### `audio_passthrough.nim`
Simple audio passthrough - input goes directly to output.

**Features:**
- Audio callback setup
- Stereo audio processing
- Non-interleaved buffer handling

#### `sine_generator.nim`
Generates a 440Hz sine wave tone.

**Features:**
- Audio synthesis
- Phase accumulation
- Mathematical operations in audio callbacks

#### `distortion_effect.nim`
Audio effect that applies waveshaping distortion.

**Features:**
- Real-time audio processing
- Effect bypass switching
- Non-linear signal processing

### Control Examples

#### `switch_example.nim`
Demonstrates using momentary switches with debouncing.

**Hardware Setup:**
- Connect switches between D0, D1, D2 and GND

**Features:**
- Multiple switch handling
- Debouncing
- Edge detection
- State management

#### `encoder_control.nim`
Shows how to use a rotary encoder for parameter control.

**Hardware Setup:**
- Connect rotary encoder:
  - A pin to D0
  - B pin to D1
  - Button to D2

**Features:**
- Rotary encoder reading
- Parameter control
- Button integration

### MIDI Examples

#### `midi_input.nim`
Receives and processes MIDI messages.

**Hardware Setup:**
- Connect MIDI input to UART1 pins (or use USB MIDI)

**Features:**
- MIDI initialization
- Message parsing
- Note on/off handling

### I2C Examples

#### `i2c_scanner.nim`
Scans the I2C bus for connected devices.

**Hardware Setup:**
- Connect I2C devices to:
  - SCL: Pin D11 (PB8)
  - SDA: Pin D12 (PB9)
  - Use 4.7kΩ pull-up resistors

**Features:**
- I2C bus scanning
- Device detection
- Address reporting

#### `i2c_oled_basic.nim`
Initializes and controls an SSD1306 OLED display.

**Hardware Setup:**
- Connect SSD1306 OLED:
  - SCL: Pin D11 (PB8)
  - SDA: Pin D12 (PB9)
  - VCC: 3.3V or 5V
  - GND: GND

**Features:**
- I2C initialization
- SSD1306 command sending
- Display clearing
- Basic display control

#### `i2c_sensor_read.nim`
Reads data from an I2C sensor (MPU6050 IMU example).

**Hardware Setup:**
- Connect MPU6050 or similar I2C sensor:
  - SCL: Pin D11 (PB8)
  - SDA: Pin D12 (PB9)
  - Pull-up resistors

**Features:**
- Register reading and writing
- Multi-byte data reads
- Sensor initialization
- Periodic data sampling

### SD Card Examples

#### `sdcard_basic.nim`
Basic SD card initialization and file I/O test.

**Hardware Setup:**
- Insert SD card into Daisy Seed's SD card slot
- Pins are fixed by hardware (see SDCARD_REFERENCE.md)

**Features:**
- SDMMC initialization
- FatFS mounting
- File writing and reading
- Error indication via LED

#### `sdcard_files.nim`
Demonstrates various file operations.

**Hardware Setup:**
- Insert SD card into Daisy Seed's SD card slot

**Features:**
- Creating and writing files
- Reading files
- Directory operations
- File deletion and renaming
- Directory listing

#### `sdcard_audio_record.nim`
Records audio input to SD card as raw PCM data.

**Hardware Setup:**
- Insert SD card
- Connect audio input

**Features:**
- Audio buffering
- PCM format conversion
- SD card writing
- Recording management

## Common Patterns

### Initialization Sequence

All examples follow this pattern:

```nim
var hw = newDaisySeed()

proc main() =
  hw.init()
  startLog()  # Optional but recommended
  
  # Your setup code here
  
  while true:
    # Your main loop
    hw.delayMs(1)

when isMainModule:
  main()
```

### Audio Callback Structure

```nim
proc audioCallback(input: ptr ptr cfloat, output: ptr ptr cfloat, size: csize_t) {.cdecl.} =
  for i in 0..<size:
    # Process samples
    output[0][i] = processLeft(input[0][i])
    output[1][i] = processRight(input[1][i])
```

### GPIO Handling

```nim
var pin = newGPIO()
pin.init(D0, INPUT, PULLUP)

# In main loop:
let state = pin.read()
```

### I2C Communication

```nim
var i2c = newI2CHandle()
var config = newI2CConfig()
config.periph = I2C_1
config.speed = I2C_400KHZ
config.mode = I2C_MASTER
config.pin_config.scl = D11
config.pin_config.sda = D12

if i2c.init(config) != I2C_OK:
  # Handle error
  return

# Write/read operations
discard i2c.writeRegister(0x48, 0x01, 0xFF)
let (result, value) = i2c.readRegister(0x48, 0x00)
```

## Tips and Best Practices

### Memory Management

- Use `--gc:arc` for embedded systems
- Avoid allocations in audio callbacks
- Pre-allocate buffers at initialization

### Audio Callbacks

- Keep audio callbacks fast and deterministic
- Avoid system calls (no printing, no delays)
- Use global variables for audio state
- Process audio in small blocks

### Timing

- Use `hw.delayMs()` for blocking delays
- For periodic tasks, use the audio callback or timers
- Control debouncing happens at specified update rates

### Debugging

- Use the serial logger for debugging
- Print before starting audio (audio callbacks can't print)
- Use LED for simple status indication

## Troubleshooting

### Compilation Errors

**Error: Cannot find libdaisy**
- Check that libDaisy is compiled in `../build/`
- Verify paths in nim.cfg or Makefile

**Error: Undefined reference**
- Make sure you're linking with `-ldaisy`
- Check that all required C++ symbols are properly imported

### Runtime Issues

**No audio output**
- Verify audio callback is registered: `hw.startAudio(callback)`
- Check audio cable connections
- Verify sample rate matches your expectations

**LED doesn't blink**
- Check that hardware is initialized: `hw.init()`
- Verify you're calling `hw.setLed(true/false)`
- Test with a different example

**MIDI not working**
- Verify MIDI mode matches hardware connection
- Check baud rate and hardware wiring
- Try USB MIDI mode for testing

**I2C not working**
- Check pull-up resistors (4.7kΩ typical)
- Verify correct pins (D11=SCL, D12=SDA for I2C_1)
- Use i2c_scanner.nim to detect devices
- Check device address (7-bit vs 8-bit addressing)
- Verify device power supply

**SD card not working**
- Check SD card is inserted properly
- Format as FAT32
- Try slower speed (SD_STANDARD instead of SD_FAST)
- Check card is not write-protected
- Verify adequate power supply
- Try different SD card

## Next Steps

After trying these examples:

1. Modify them to experiment with different parameters
2. Combine multiple examples (e.g., encoder controlling audio effect)
3. Create your own audio processors
4. Explore the full libDaisy API

## Resources

- [libDaisy Documentation](https://daisy.audio/software/)
- [Nim Manual](https://nim-lang.org/docs/manual.html)
- [Daisy Forum](https://forum.electro-smith.com/)
- [Main README](../README_NIM.md)

## Contributing

Have an interesting example? Contributions are welcome! Submit a pull request with:

- Well-commented code
- Hardware setup description
- Clear explanation of what it demonstrates
