# Examples Guide

This guide describes all example programs included with libdaisy_nim.

## Quick Reference

| Example | Category | Hardware Needed | Description |
|---------|----------|-----------------|-------------|
| `blink_clean.nim` | Basic | Just Daisy | LED blink - Hello World |
| `button_led_clean.nim` | Basic | Button on DPin10 | Button controls LED |
| `gpio_input_clean.nim` | Basic | Button/switch | Read GPIO input |
| `audio_passthrough_clean.nim` | Audio | Audio I/O | Pass audio through |
| `sine_wave_clean.nim` | Audio | Audio output | Generate sine wave |
| `distortion_effect_clean.nim` | Audio | Audio I/O | Simple overdrive |
| `adc_simple_clean.nim` | ADC | Potentiometer on ADC pin | Read analog input |
| `analog_knobs_clean.nim` | ADC | Multiple pots | Multi-channel ADC |
| `i2c_scanner_clean.nim` | I2C | I2C device (optional) | Scan I2C bus |
| `spi_basic_clean.nim` | SPI | SPI device | Basic SPI comm |
| `midi_input_clean.nim` | MIDI | MIDI input | Receive MIDI notes |
| `encoder_clean.nim` | Controls | Rotary encoder | Read encoder |
| `usb_serial_clean.nim` | USB | USB cable | USB CDC serial |
| `sdram_test_clean.nim` | Memory | None | Test SDRAM |

## Basic Examples

### blink_clean.nim

**Purpose:** Your first program - blinks the onboard LED.

**Hardware:** None required beyond Daisy Seed.

**What it demonstrates:**
- Basic project structure
- Hardware initialization
- LED control
- Timing/delays

**Key code:**
```nim
import ../src/libdaisy

var hw = newDaisySeed()

proc main() =
  hw.init()
  while true:
    hw.setLed(true)
    hw.delayMs(500)
    hw.setLed(false)
    hw.delayMs(500)
```

**Expected behavior:** Onboard LED blinks at 1Hz (500ms on, 500ms off).

---

### button_led_clean.nim

**Purpose:** Read a button and control the LED.

**Hardware:**
- Button/switch connected between DPin10 and GND
- Internal pull-up used

**What it demonstrates:**
- GPIO input configuration
- Pull-up resistors
- Digital read
- Real-time input response

**Key code:**
```nim
var pin = hw.getPin(DPin10)
pin.mode = PinMode.INPUT
pin.pull = Pull.PULLUP
pin.init()

while true:
  let state = pin.read()
  hw.setLed(state)
```

**Expected behavior:** LED reflects button state (inverted due to pull-up).

---

### gpio_input_clean.nim

**Purpose:** Demonstrate GPIO input reading.

**Hardware:** Button or switch on any GPIO pin.

**What it demonstrates:**
- GPIO pin configuration
- Different pull modes
- Polling vs interrupt (polling shown)
- Debouncing (basic delay method)

---

## Audio Examples

### audio_passthrough_clean.nim

**Purpose:** Pass audio input directly to output.

**Hardware:** Audio source (jack/line in) and output (headphones/speakers).

**What it demonstrates:**
- Audio callback setup
- Stereo I/O
- DMA-based audio
- Zero-latency processing

**Key code:**
```nim
proc audioCallback(input: ptr ptr cfloat, output: ptr ptr cfloat,
                   size: csize_t) {.cdecl.} =
  for i in 0..<size:
    output[0][i] = input[0][i]  # Left
    output[1][i] = input[1][i]  # Right

hw.startAudio(audioCallback)
```

**Expected behavior:** Audio input passes through to output unchanged.

---

### sine_wave_clean.nim

**Purpose:** Generate a sine wave tone.

**Hardware:** Audio output (headphones/speakers).

**What it demonstrates:**
- Audio synthesis
- Phase accumulation
- Sample rate math
- Waveform generation

**Expected behavior:** Continuous sine wave tone at specified frequency.

---

### distortion_effect_clean.nim

**Purpose:** Simple overdrive/distortion effect.

**Hardware:** Audio I/O.

**What it demonstrates:**
- Audio processing
- Non-linear functions
- Gain control
- Real-time DSP

**Expected behavior:** Distorted audio output (adjust drive parameter).

---

## Peripheral Examples

### i2c_scanner_clean.nim

**Purpose:** Scan I2C bus for connected devices.

**Hardware:**
- I2C device (optional - will show nothing if none connected)
- SCL/SDA connections

**What it demonstrates:**
- I2C initialization
- Device scanning
- Error handling
- Serial output of results

**Key code:**
```nim
for addr in 0x08..0x77:
  if i2c.transmitBlocking(addr.uint8, nil, 0, 10) == I2C_OK:
    echo "Found device at 0x", toHex(addr, 2)
```

**Expected behavior:** Lists all I2C devices found on the bus.

---

### spi_basic_clean.nim

**Purpose:** Basic SPI communication.

**Hardware:** SPI device (e.g., external DAC, shift register).

**What it demonstrates:**
- SPI initialization
- SPI configuration (mode, baud rate)
- Transmit/receive
- Chip select control

---

## ADC Examples

### adc_simple_clean.nim

**Purpose:** Read a single analog input.

**Hardware:** Potentiometer connected to ADC-capable pin.

**What it demonstrates:**
- ADC configuration
- Analog reading
- Value scaling
- LED brightness control based on pot

**Expected behavior:** LED brightness varies with potentiometer position.

---

### analog_knobs_clean.nim

**Purpose:** Read multiple analog controls.

**Hardware:** Multiple potentiometers on ADC pins.

**What it demonstrates:**
- Multi-channel ADC
- Control mapping
- Parameter control
- Real-time modulation

---

## MIDI Examples

### midi_input_clean.nim

**Purpose:** Receive and process MIDI messages.

**Hardware:**
- MIDI input on UART pins, OR
- USB MIDI connection

**What it demonstrates:**
- MIDI initialization
- Message parsing
- Note on/off handling
- MIDI event processing

**Key code:**
```nim
midi.listen()
while midi.hasEvents():
  let event = midi.popEvent()
  if event.type == NoteOn:
    echo "Note: ", event.data[0]
```

**Expected behavior:** Prints received MIDI notes to console.

---

## Control Examples

### encoder_clean.nim

**Purpose:** Read a rotary encoder.

**Hardware:** Rotary encoder with A, B, and button pins.

**What it demonstrates:**
- Encoder initialization
- Incremental reading
- Button press detection
- Debouncing

**Expected behavior:** Reports encoder position and button state.

---

## USB Examples

### usb_serial_clean.nim

**Purpose:** USB CDC serial communication.

**Hardware:** USB cable to computer.

**What it demonstrates:**
- USB Device CDC setup
- Virtual COM port
- Serial read/write
- Echo functionality

**Key code:**
```nim
usb.init()
while true:
  if usb.readable():
    let c = usb.getRx()
    usb.transmit(c)  # Echo back
```

**Expected behavior:** Acts as USB serial port, echoes typed characters.

**Testing:** Open serial terminal (screen, minicom, Arduino IDE) at 115200 baud.

---

## Memory Examples

### sdram_test_clean.nim

**Purpose:** Test external SDRAM memory.

**Hardware:** None (SDRAM is onboard).

**What it demonstrates:**
- SDRAM initialization
- Memory allocation
- Read/write operations
- Memory testing

**Expected behavior:** Writes and reads patterns to SDRAM, reports success/failure.

---

## Building and Running Examples

### Build Single Example

```bash
cd examples

# Edit Makefile, set TARGET
TARGET=blink_clean

# Build
make

# Flash
make program-dfu
```

### Test All Examples

```bash
cd examples
./test_all_clean.sh
```

Output:
```
========================================
SUMMARY:
  Passed: 14
  Failed: 0
========================================
```

### Create Your Own

```bash
# Copy an example as template
cp blink_clean.nim my_project.nim

# Edit Makefile
sed -i 's/TARGET = .*/TARGET = my_project/' Makefile

# Build and flash
make
make program-dfu
```

## Example Code Structure

All examples follow this pattern:

```nim
# 1. Imports
import ../src/libdaisy
import ../src/libdaisy_somemodule  # If needed

# 2. Global variables
var hw = newDaisySeed()
var peripheral: SomePeripheral

# 3. Callback functions (if needed)
proc audioCallback(input: ptr ptr cfloat, output: ptr ptr cfloat,
                   size: csize_t) {.cdecl.} =
  # Audio processing here
  discard

# 4. Main function
proc main() =
  hw.init()
  # Setup peripherals
  # Start processing
  while true:
    # Main loop
    hw.delayMs(100)

# 5. Entry point
when isMainModule:
  main()
```

## Troubleshooting Examples

### Compilation Errors

**"cannot open file: libdaisy"**
- Import path wrong
- Use `import ../src/libdaisy` from examples/

**"undefined reference to Init"**
- Missing macro call
- Check module has `emitXxxIncludes()`

### Runtime Issues

**LED doesn't blink**
- Check LED polarity
- Verify upload succeeded
- Try resetting Daisy

**No audio output**
- Check audio connections
- Verify sample rate
- Check callback is running

**I2C scanner finds nothing**
- Check pull-up resistors (4.7kΩ)
- Verify connections
- Try different I2C bus

**USB serial doesn't work**
- Wait a few seconds after boot
- Check USB cable (data, not charge-only)
- Try different terminal program

## Next Steps

After trying examples:

1. **Modify examples** - Change parameters, add features
2. **Combine examples** - Use multiple peripherals together
3. **Build your project** - Start from scratch with what you learned
4. **Read API docs** - See `API_REFERENCE.md` for all functions
5. **Contribute** - Share your examples with the community!

---

For complete API documentation, see [API_REFERENCE.md](API_REFERENCE.md).

For technical details, see [TECHNICAL_REPORT.md](TECHNICAL_REPORT.md).
