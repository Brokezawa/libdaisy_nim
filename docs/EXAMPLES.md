# libdaisy_nim Examples - Testing Reference

This document provides a comprehensive testing reference for all examples in libdaisy_nim. Use this to verify hardware behavior and track any discrepancies between expected and actual behavior.

## Table of Contents

- [How to Use This Guide](#how-to-use-this-guide)
- [Example Testing Matrix](#example-testing-matrix)
- [Hardware Setup Requirements](#hardware-setup-requirements)
- [Building and Running Examples](#building-and-running-examples)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

## How to Use This Guide

### For Testing

1. **Build and flash** the example to your Daisy Seed
2. **Observe behavior** against the "Expected Behavior" column
3. **Mark status** in your test report:
   - ✅ **PASS** - Behaves exactly as expected
   - ⚠️ **PARTIAL** - Works but with minor differences
   - ❌ **FAIL** - Does not work or crashes
   - ⏭️ **SKIP** - Hardware not available

4. **Document differences** if behavior doesn't match exactly

### Reporting Issues

If you find a discrepancy:

1. Check the "Common Issues" column first
2. Verify your hardware setup matches requirements
3. If still failing, open a GitHub issue with:
   - Example name
   - Expected vs actual behavior
   - Hardware setup
   - Test results from working examples

---

## Example Testing Matrix

### Basic Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **blink.nim** | Basic | None (onboard LED) | Onboard LED blinks at ~2Hz (500ms on, 500ms off). Should continue indefinitely. | None - simplest example | ⬜ |
| **button_led.nim** | GPIO | Button on D0 | LED turns ON when button pressed, OFF when released. No debounce delay, instant response. | If inverted, check button wiring (needs pull-up) | ⬜ |
| **gpio_input.nim** | GPIO | Button on D0 | Reads digital input state. LED mirrors button state. Console output shows pin state changes. | Check pull-up/pull-down configuration | ⬜ |

### Audio Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **audio_passthrough.nim** | Audio | Audio input/output | Clean audio passthrough with minimal latency (<3ms typical). Input signal appears unmodified at output. | Silence = check audio connections; Distortion = check levels | ⬜ |
| **sine_wave.nim** | Audio | Audio output | Generates clean 440Hz sine wave (A4 note) on both channels. Should be pure tone with no harmonics or clicks. | Clicking = buffer issue; Wrong pitch = sample rate mismatch | ⬜ |
| **distortion_effect.nim** | Audio | Audio input/output | Clean passthrough by default. Warm overdrive distortion when activated. LED indicates effect on/off. | Harsh distortion = gain too high; No effect = bypass stuck | ⬜ |

### Audio Codec Examples (v0.7.0)

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **codec_comparison.nim** | Audio Codec | None (onboard codec) | Detects Daisy Seed hardware version and initializes appropriate codec (AK4556/WM8731/PCM3060). LED blinks to indicate successful codec initialization. Console output shows detected version. | No LED blink = codec init failed; Check board version detection | ⬜ |

### ADC (Analog Input) Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **adc_simple.nim** | ADC | Potentiometer on A0 | Reads single analog input (0-3.3V). LED brightness or console output reflects pot position. Updates continuously. | Noisy readings = add capacitor; Inverted = check wiring | ⬜ |
| **adc_multichannel.nim** | ADC | Pots on A0, A1, A2 | Reads 3 independent analog channels simultaneously. Each channel updates independently. Console shows all values. | Channel crosstalk = ADC config issue | ⬜ |
| **adc_multiplexed.nim** | ADC | External ADC mux chip | Reads multiple inputs through multiplexer. Sequentially scans all mux channels. May have slight delay between channels. | Switching glitches = add settling time | ⬜ |
| **adc_config.nim** | ADC | Potentiometer on A0 | Demonstrates custom ADC configuration (resolution, speed, oversampling). Behavior similar to adc_simple but with specific timing. | Configuration errors = check libDaisy compatibility | ⬜ |
| **analog_knobs.nim** | ADC | 4 pots on A0-A3 | Real-world analog control demo. Smooth value changes, optional smoothing/filtering. May include deadzone handling. | Jitter = enable filtering; Jumps = check connections | ⬜ |

### PWM Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **pwm_led.nim** | PWM | LED on D0 (PWM capable) | LED brightness fades smoothly from 0% to 100% and repeats. No visible flickering or steps. | Flickering = PWM freq too low; No change = pin not PWM | ⬜ |
| **pwm_rgb.nim** | PWM | RGB LED on D0,D1,D2 | RGB LED cycles through rainbow colors smoothly. Red→Yellow→Green→Cyan→Blue→Magenta→Red. ~5s per cycle. | Wrong colors = check LED pinout; Dim = check current limit | ⬜ |
| **pwm_servo.nim** | PWM | Servo motor on D0 | Servo sweeps from 0° to 180° and back continuously. Smooth motion, ~2s per sweep. Standard 50Hz servo signal. | Jitter = power supply issue; Wrong range = calibrate limits | ⬜ |

### Display Examples (OLED)

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **oled_basic.nim** | OLED/I2C | SSD1306 I2C OLED (128x64) | Display initializes and shows text "Hello Daisy!". Text should be crisp and readable. May show demo pattern or counter. | Blank screen = check I2C address (0x3C or 0x3D) | ⬜ |
| **oled_graphics.nim** | OLED/I2C | SSD1306 I2C OLED | Draws shapes (rectangles, circles, lines). Shapes should be clean with no artifacts. May animate or update periodically. | Corrupted graphics = timing issue; Partial = buffer problem | ⬜ |
| **oled_spi.nim** | OLED/SPI | SSD1306 SPI OLED | Same as oled_basic but using SPI interface. Faster updates than I2C version. Text or graphics displayed clearly. | Blank = check CS/DC pins; Shifted = clock issue | ⬜ |
| **oled_visualizer.nim** | OLED/Audio | SSD1306 + Audio input | Real-time audio level meter or waveform display. Bars or scope trace react to audio input. 10-30 FPS typical. | No movement = audio not connected; Slow = optimize drawing | ⬜ |

### Display Examples (LCD) (v0.7.0)

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **lcd_menu.nim** | LCD/Encoder | HD44780 16x2 LCD + Encoder | Character LCD displays 3-parameter menu (Volume %, Frequency Hz, Waveform name). Encoder rotation changes values, button press cycles menu items. Display updates in real-time. | Garbled text = timing/wiring issue; No encoder response = check encoder pins | ⬜ |

### Communication Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **i2c_scanner.nim** | I2C | I2C devices on bus | Scans addresses 0x03-0x77. Reports found devices via console/LED. Empty bus shows "No devices found". | False positives = pull-up resistor issue | ⬜ |
| **spi_basic.nim** | SPI | SPI device (EEPROM/sensor) | Sends/receives SPI data. May write then read back for verification. Success indicated by LED or console. | No response = check MISO/MOSI; Wrong data = clock polarity | ⬜ |
| **usb_serial.nim** | USB | USB cable to computer | Creates virtual serial port. Text typed in terminal echoes back. Baud rate doesn't matter (USB CDC). | Not detected = enter DFU mode first; No echo = driver issue | ⬜ |
| **midi_input.nim** | MIDI | MIDI controller (USB/UART) | Receives MIDI note on/off messages. LED flashes on note events. Console shows note number and velocity. | No response = check MIDI mode (USB vs UART) | ⬜ |

### Control Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **encoder.nim** | Encoder | Rotary encoder on D0,D1,D2 | Turning encoder changes value (displayed on LED/console). Button press may reset. Detents should feel accurate (no skips). | Skips = debounce issue; Reversed = swap A/B pins | ⬜ |
| **lcd_menu.nim** | LCD/Encoder | HD44780 LCD + Encoder | See "Display Examples (LCD)" section above for details | See LCD section | ⬜ |

### Storage Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **sdram_test.nim** | SDRAM | External SDRAM chip | Writes test pattern to SDRAM, reads back and verifies. LED blinks on success, stays on for failure. May test full 64MB. | Fails = check SDRAM soldering/power | ⬜ |

### DAC Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **dac_simple.nim** | DAC | Voltmeter or scope on DAC pins | Outputs ramping voltage on DAC channel 1. Voltage sweeps from 0V to 3.3V continuously. ~1V per second typical. | Flat line = DAC not enabled; Wrong range = 12-bit config | ⬜ |

### Board-Specific Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **patch_simple.nim** | Patch Board | Daisy Patch | Initializes Patch hardware. May test controls (encoder, gate inputs) and OLED display. Audio passthrough with patch-specific routing. | Controls not working = check Patch Init board variant | ⬜ |

### Peripherals Examples (v0.4.0)

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **peripherals_basic.nim** | RNG/Timer/LED | LED on D7 | Random LED blink patterns using hardware TRNG. Brightness varies randomly (0.0-1.0). Timer measures actual delay duration. Console prints timing stats every 5th loop. | LED stays on/off = update() not called; No randomness = RNG not ready | ⬜ |
| **eurorack_basics.nim** | GateIn/Switch3 | Gates on D0,D1; Switch on D2,D3 | Gate inputs detect rising edges (triggers). Switch reads 3 positions: UP/CENTER/DOWN. Console shows trigger counts and current states. Status printed every 500ms. | No triggers = check gate voltage (>2V); Switch stuck = check wiring | ⬜ |
| **led_control.nim** | RgbLed/Color | RGB LED on D10,D11,D12 | RGB LED cycles through: Primary colors (R,G,B) → Mixed colors (Purple,Cyan,Orange,White) → Red-to-Blue blend → Rainbow cycle (3 loops). ~20 seconds total sequence. | Wrong colors = check RGB pin order; Dim = check current limiting | ⬜ |
| **timer_advanced.nim** | Timer | None (uses serial) | Coordinates 3 timers: TIM2 (free-running counter), TIM3 (periodic callback), TIM5 (faster callback). Runs for 20 seconds showing callback counts and tick measurements. | Callbacks = 0 = IRQ not enabled; Tick overflow = period too short | ⬜ |

### Data Structures & Utilities Examples (v0.5.0)

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **data_structures.nim** | Data Structures | Audio input/output | Demonstrates FIFO queue, Stack, RingBuffer, and FixedStr. Audio delay effect using RingBuffer (300ms delay). Serial output shows FIFO/Stack operations. OLED-style string formatting examples. | No delay = RingBuffer size too small; Distorted = buffer overflow | ⬜ |
| **control_mapping.nim** | Parameter Mapping | Serial output | Shows Parameter curves (linear/exp/log/cubic) and MappedValue quantization. Simulates synth controls: frequency (exp curve), filter (linear), resonance (log), steps (quantized). Prints mapped values. | Values out of range = curve misconfiguration | ⬜ |
| **system_info.nim** | System Monitoring | Serial output | Displays STM32 unique device ID (96-bit hex). Real-time CPU load monitoring showing average and peak usage. Performance tips based on CPU load thresholds. Runs indefinitely. | CPU = 0% = CpuLoad not measuring; ID all zeros = chip issue | ⬜ |

### Special Examples

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **panicoverride.nim** | System | None | Demonstrates custom panic handler. Intentionally crashes to show LED blink pattern on panic. LED blinks rapidly (SOS pattern). | Normal - this example is supposed to crash! | ⬜ |

### File I/O Examples (v0.6.0)

| Example | Category | Hardware Required | Expected Behavior | Common Issues | Status |
|---------|----------|-------------------|-------------------|---------------|--------|
| **wav_player.nim** | File I/O | SD card breakout with WAV files, Audio output | Plays WAV files from SD card. Button navigation between tracks. LED indicates playback status. Supports various sample rates and bit depths (16/24-bit). Audio output on standard Daisy audio pins. | No sound = check SD wiring/FAT32 format; Distortion = sample rate mismatch; Won't mount = check SPI connections | ⬜ |
| **wav_recorder.nim** | File I/O | SD card breakout, Audio input/output | Records audio input to SD card as WAV file. Button starts/stops recording. LED indicates recording status (on=recording). Creates timestamped/numbered files. Real-time writing with proper WAV headers. | No file created = SD full/write-protected/wiring; Clipping = input gain too high; Silent recording = check audio input connections | ⬜ |
| **sampler.nim** | File I/O | SD card breakout with WAV samples, Buttons, Audio output | Triggers multiple WAV samples via buttons. Each button plays different sample. Polyphonic playback supported. Samples loaded at startup from SD card. One-shot or looped playback modes. | Samples cut off = buffer size too small; No sound = check file names in code match SD files; Clicks = sample not properly loaded | ⬜ |
| **looper.nim** | File I/O | SD card breakout, Audio input/output, Buttons | Records audio loop and plays back continuously. Button controls: record, play, stop, overdub. LED shows current mode (off=idle, blink=recording, on=playing). Loop saved to SD card for persistence. | Sync issues = buffer timing; Pops/clicks = loop not sample-aligned; Drift = clock mismatch | ⬜ |
| **wavetable_synth.nim** | File I/O | SD card breakout with wavetable files, ADC/CV input, Audio output | Wavetable synthesizer loads waveforms from SD. CV/ADC controls oscillator pitch and wavetable position. Multiple wavetable banks supported. Smooth interpolation between waveforms. Typical wavetable size: 256-2048 samples per wave. | No sound = wavetable files missing/wrong format; Aliasing = sample rate too low; Zipper noise = no interpolation | ⬜ |
| **qspi_storage.nim** | Storage | None (internal QSPI flash) | Demonstrates QSPI flash read/write/erase operations. Writes test patterns to internal 8MB QSPI flash, reads back for verification. LED indicates success/failure. Serial output shows progress and timing. Tests sector erase and page programming. | All zeros = QSPI not detected; Verify fails = bad flash chip/interference; Slow = check clock speed config | ⬜ |

---

## Hardware Setup Requirements

### Minimal Setup (No External Hardware)

These examples work with Daisy Seed alone (no external components needed):
- ✅ `blink.nim` - Onboard LED only
- ✅ `codec_comparison.nim` - Onboard codec detection (v0.7.0)
- ✅ `panicoverride.nim` - Onboard LED only
- ✅ `timer_advanced.nim` - Serial output only (v0.4.0)
- ✅ `control_mapping.nim` - Serial output only (v0.5.0)
- ✅ `system_info.nim` - Serial output only (v0.5.0)
- ✅ `qspi_storage.nim` - Internal QSPI flash only (v0.6.0)

### Basic GPIO Setup

**Required:** Breadboard, jumper wires, push button, 10kΩ resistor

```
Examples: button_led.nim, gpio_input.nim

Wiring:
  D0 ────────┬──── Button ──── GND
             │
            10kΩ
             │
            3.3V
```

### Audio Setup

**Required:** Audio cable, headphones or amp

```
Examples: audio_passthrough.nim, sine_wave.nim, distortion_effect.nim

Connections:
  IN_L  ──── Audio source left
  IN_R  ──── Audio source right
  OUT_L ──── Headphones/amp left
  OUT_R ──── Headphones/amp right
  AGND  ──── Audio ground
```

### ADC Setup

**Required:** Potentiometers (10kΩ recommended), breadboard

```
Examples: adc_simple.nim, adc_multichannel.nim, analog_knobs.nim

Wiring (per pot):
  Pin 1 (CCW) ──── GND
  Pin 2 (Wiper) ─── A0 (or A1, A2, etc.)
  Pin 3 (CW) ───── 3.3V
```

### PWM Setup

**Required for LED:** LED, 220Ω resistor

```
Example: pwm_led.nim

Wiring:
  D0 ──── 220Ω ──── LED+ ──── LED- ──── GND
```

**Required for RGB:** Common cathode RGB LED, 3x 220Ω resistors

```
Example: pwm_rgb.nim

Wiring:
  D0 ──── 220Ω ──── LED Red
  D1 ──── 220Ω ──── LED Green
  D2 ──── 220Ω ──── LED Blue
  Common cathode ──── GND
```

**Required for Servo:** Servo motor, external 5V power supply

```
Example: pwm_servo.nim

Wiring:
  D0 ────────────── Servo signal (yellow/white)
  5V (external) ─── Servo power (red)
  GND ──┬────────── Servo ground (brown/black)
        └────────── External PSU ground
```

### I2C Setup

**Required:** I2C device (OLED/sensor), 2x 4.7kΩ pull-up resistors

```
Examples: i2c_scanner.nim, oled_basic.nim, oled_graphics.nim

Wiring:
  D11 (SCL) ──┬──── Device SCL
              │
            4.7kΩ
              │
             3.3V

  D12 (SDA) ──┬──── Device SDA
              │
            4.7kΩ
              │
             3.3V

  3.3V ──────────── Device VCC (or 5V if device supports)
  GND ───────────── Device GND
```

**Note:** Many I2C breakout boards include pull-ups. Check before adding external resistors.

### SPI Setup

**Required:** SPI device (EEPROM, sensor, or SD card)

```
Example: spi_basic.nim

Standard SPI wiring:
  D7 (MOSI) ──── Device MOSI (or SDI)
  D8 (MISO) ──── Device MISO (or SDO)
  D9 (SCK)  ──── Device SCK
  D10 (CS)  ──── Device CS (or SS)
  3.3V ─────────  Device VCC
  GND ──────────── Device GND
```

**For OLED SPI:**

```
Example: oled_spi.nim

  D7 (MOSI) ──── OLED MOSI/SDA
  D9 (SCK)  ──── OLED SCK
  D10 (CS)  ──── OLED CS
  D11 ──────────  OLED DC (data/command)
  D13 ──────────  OLED RST (reset)
  3.3V ─────────  OLED VCC
  GND ──────────── OLED GND
```

### USB Setup

**Required:** USB cable (same cable used for programming)

```
Example: usb_serial.nim

Connection:
  - Connect Daisy Seed to computer via USB
  - After flashing, device appears as virtual COM port
  - Open serial terminal (115200 baud or any - USB CDC ignores baud rate)
```

### MIDI Setup

**Option 1: USB MIDI** (easiest)

```
Example: midi_input.nim (configure for USB)

Connection:
  - Connect Daisy Seed to computer via USB
  - Use MIDI controller software or hardware MIDI-to-USB adapter
```

**Option 2: Hardware UART MIDI**

```
Example: midi_input.nim (configure for UART)

MIDI Input (5-pin DIN):
  MIDI Pin 4 ──── UART RX (via optocoupler circuit)
  MIDI Pin 5 ──── 220Ω ──── UART RX
  MIDI Pin 2 ──── GND

(Requires standard MIDI input circuit with 6N138 optocoupler)
```

### Encoder Setup

**Required:** Rotary encoder with button

```
Example: encoder.nim, lcd_menu.nim

Wiring:
  Encoder A ──── D0 (or D7 for lcd_menu)
  Encoder B ──── D1 (or D8 for lcd_menu)
  Encoder SW ─── D2 (or D9 for lcd_menu)
  Encoder GND ── GND
  Common ──────── GND (if separate from switch ground)
```

### LCD HD44780 Setup (v0.7.0)

**Required:** HD44780 16x2 or 20x4 character LCD, 6 GPIO connections

```
Example: lcd_menu.nim

Wiring (4-bit mode):
  D1 (RS) ────── LCD RS (Register Select)
  D2 (EN) ────── LCD E (Enable)
  D3 (D4) ────── LCD D4 (Data bit 4)
  D4 (D5) ────── LCD D5 (Data bit 5)
  D5 (D6) ────── LCD D6 (Data bit 6)
  D6 (D7) ────── LCD D7 (Data bit 7)
  5V ───────────  LCD VCC
  GND ──────────── LCD GND (also connect VSS)
  Pot wiper ───── LCD V0 (contrast adjust)
  5V ───────────  LCD LED+ (backlight, via resistor)
  GND ──────────── LCD LED- (backlight)

Contrast pot wiring:
  Pin 1 ──── GND
  Pin 2 ──── LCD V0 (pin 3)
  Pin 3 ──── 5V

Note: Most HD44780 displays require 5V logic. Use level shifters
if connecting directly to 3.3V Daisy Seed pins, or use 5V-tolerant
pins and configure LCD for 3.3V operation if supported.
```

For lcd_menu.nim with encoder, combine with encoder wiring above (using D7,D8,D9).

### SDRAM Setup

**Required:** Daisy Seed with SDRAM chip soldered (optional hardware mod)

```
Example: sdram_test.nim

No external wiring needed - SDRAM is surface-mount chip on Daisy Seed.
If SDRAM not installed, example will fail immediately.
```

### DAC Setup

**Required:** Voltmeter or oscilloscope

```
Example: dac_simple.nim

Connections:
  DAC1 (Pin 22) ──── Voltmeter/scope probe
  GND ───────────────  Voltmeter/scope ground

Expected: 0-3.3V ramping output
```

### Peripherals Setup (v0.4.0)

**Required for peripherals_basic.nim:** LED on D7

```
Example: peripherals_basic.nim

Wiring:
  D7 ────────┬──── LED Anode (+)
             │
          220Ω
             │
            GND

Features tested:
  - Hardware RNG (random numbers)
  - Timer TIM2 (tick counting)
  - LED software PWM (brightness control)
```

**Required for eurorack_basics.nim:** Gate inputs on D0, D1; 3-position switch on D2, D3

```
Example: eurorack_basics.nim

Wiring (Gate inputs):
  D0 ────────── Gate Input 1 (0-5V eurorack signal)
  D1 ────────── Gate Input 2 (0-5V eurorack signal)

Wiring (3-position switch):
  D2 ────────── Switch position A
  D3 ────────── Switch position B
  
Switch positions:
  - CENTER: Both pins HIGH
  - UP:     D2 LOW, D3 HIGH  
  - DOWN:   D2 HIGH, D3 LOW

Features tested:
  - GateIn (trigger detection, state reading)
  - Switch3 (3-position reading)
```

**Required for led_control.nim:** RGB LED on D10, D11, D12

```
Example: led_control.nim

Wiring:
  D10 ───── 220Ω ───── LED Red anode
  D11 ───── 220Ω ───── LED Green anode
  D12 ───── 220Ω ───── LED Blue anode
  GND ───────────────── LED cathode (common cathode RGB LED)

Features tested:
  - RgbLed (3-channel control)
  - Color utilities (blending, presets, operators)
  - Rainbow effects
```

**Required for timer_advanced.nim:** None (serial output only)

```
Example: timer_advanced.nim

No additional hardware needed - uses serial console output

Features tested:
  - Multiple hardware timers (TIM2, TIM3, TIM5)
  - Free-running counters
  - Periodic callbacks
   - Tick measurement and conversion
```

### Data Structures & Utilities Setup (v0.5.0)

**Required for data_structures.nim:** Audio input/output

```
Example: data_structures.nim

Audio setup (same as audio examples):
  IN_L  ──── Audio source left
  IN_R  ──── Audio source right
  OUT_L ──── Headphones/amp left
  OUT_R ──── Headphones/amp right
  AGND  ──── Audio ground

Features tested:
  - FIFO queue (audio sample buffering)
  - Stack (LIFO operations)
  - RingBuffer (delay line, 300ms)
  - FixedStr (display formatting)
```

**Required for control_mapping.nim:** None (serial output only)

```
Example: control_mapping.nim

No additional hardware needed - uses serial console output

Features tested:
  - Parameter (exponential/linear/log/cubic curves)
  - MappedValue (range mapping, quantization)
  - Simulated synth controls
```

**Required for system_info.nim:** None (serial output only)

```
Example: system_info.nim

No additional hardware needed - uses serial console output

Features tested:
  - UniqueId (STM32 96-bit device ID)
  - CpuLoad (real-time CPU usage monitoring)
  - Performance monitoring and optimization tips
```

### Daisy Patch Setup

**Required:** Daisy Patch board (not Daisy Seed)

```
Example: patch_simple.nim

No additional wiring - Patch has built-in:
  - 4 knobs
  - 4 CV inputs
  - 2 gate inputs
  - Encoder with button
  - OLED display
  - Audio I/O (1/8" jacks)
```

### SD Card Setup (v0.6.0 File I/O)

**Required:** SD card breakout module (SPI interface), SD card formatted FAT32

**⚠️ Important:** Daisy Seed does NOT have a built-in SD card slot. You must connect an external SD card breakout board via SPI.

```
Examples: wav_player.nim, wav_recorder.nim, sampler.nim, looper.nim, wavetable_synth.nim

SD Card Module Wiring (SPI interface):
  Daisy Pin → SD Module
  ---------------------
  D7  (MOSI) ──── MOSI/DI
  D8  (MISO) ──── MISO/DO
  D9  (SCK)  ──── SCK/CLK
  D10 (CS)   ──── CS/SS
  3.3V ─────────  VCC (use 3.3V, NOT 5V!)
  GND ──────────── GND

SD Card Preparation:
  1. Format SD card as FAT32 (exFAT not supported)
  2. Card capacity: 32GB max recommended for FAT32
  3. Use quality cards (Class 10 or UHS-I recommended for audio)
  
  For wav_player.nim:
    - Copy WAV files to root directory of SD card
    - Supported formats: 16-bit or 24-bit PCM
    - Sample rates: 8kHz - 96kHz
    - Mono or stereo
  
  For sampler.nim:
    - Create files named: sample1.wav, sample2.wav, sample3.wav, etc.
    - Place in root directory
  
  For wavetable_synth.nim:
    - Create wavetable files (raw 16-bit PCM or WAV format)
    - Typical wavetable: 256 samples per waveform, multiple waveforms per file
    - Place in root directory or subdirectory as configured in code

Audio Connections (for recorder/looper/player examples):
  IN_L  ──── Audio source left channel
  IN_R  ──── Audio source right channel
  OUT_L ──── Headphones/amplifier left
  OUT_R ──── Headphones/amplifier right
  AGND  ──── Audio ground (common with source/output)

Troubleshooting SD Card Issues:
  - "Mount failed" = Check wiring, especially CS pin
  - "No files found" = Verify FAT32 format and file names
  - Audio corruption = Try slower SPI speed or better SD card
  - Write errors = Check SD card not write-protected
```

### QSPI Flash Setup (v0.6.0)

**Required:** None (uses internal QSPI flash chip)

```
Example: qspi_storage.nim

No external hardware needed - Daisy Seed has 8MB QSPI flash chip onboard.
Serial console output shows test progress and results.
LED indicates pass/fail status.

QSPI Flash Details:
  - Type: W25Q64 or compatible
  - Capacity: 8MB (64Mbit)
  - Interface: Quad SPI (internal to STM32)
  - Speed: Up to 133MHz
  - Use cases: Wavetable storage, sample storage, data logging

Note: QSPI is separate from SD card storage - always available.
```

---

## Building and Running Examples

### Quick Start

```bash
cd examples

# Build specific example
sed -i "s/^TARGET = .*/TARGET = blink/" Makefile
make clean && make

# Flash to Daisy Seed
make program-dfu
```

### Test All Examples (Compilation Only)

```bash
cd examples
./test_all.sh

# Expected output:
# ========================================
# SUMMARY:
#   Passed: 36
#   Failed: 0
# ========================================
```

### Build System Details

The build system uses:
- **Makefile** - Controls ARM GCC toolchain
- **nim.cfg** - Nim cross-compilation settings
- **TARGET variable** (line 9 of Makefile) - Selects which example to build

Build artifacts go into `build/` directory:
- `build/*.elf` - Executable with debug symbols
- `build/*.bin` - Binary for flashing
- `build/*.map` - Memory map

---

## Common Patterns

### Standard Initialization

All examples follow this pattern:

```nim
import ../src/libdaisy
import ../src/libdaisy_module  # If using specific peripheral

useDaisyNamespace()  # Macro for C++ includes

var hw: DaisySeed  # Global hardware object

proc main() =
  hw = initDaisy()  # Initialize hardware
  
  # Your setup code here
  
  while true:
    # Main loop
    hw.delay(100)

when isMainModule:
  main()
```

### Audio Callback Structure

```nim
proc audioCallback(input: ptr ptr cfloat, output: ptr ptr cfloat, size: csize_t) {.cdecl.} =
  ## Real-time audio processing
  ## RULES:
  ## - No allocations (no seq, no string)
  ## - No printing/logging
  ## - No delays or blocking calls
  ## - Keep processing fast and deterministic
  
  for i in 0..<size:
    # Process left channel
    output[0][i] = processLeft(input[0][i])
    # Process right channel
    output[1][i] = processRight(input[1][i])

proc main() =
  hw = initDaisy()
  hw.startAudio(audioCallback)  # Register callback
  
  while true:
    # Main loop runs independently from audio
    hw.delay(10)
```

### GPIO Pattern

```nim
var pin: GPIO

proc main() =
  hw = initDaisy()
  
  pin.init(DPin0, MODE_INPUT, PULL_UP)
  
  while true:
    let state = pin.read()
    hw.setLed(state)
    hw.delay(10)
```

### I2C Pattern

```nim
var i2c: I2CHandle

proc main() =
  hw = initDaisy()
  
  var cfg = createI2CConfig()
  cfg.periph = I2C_PERIPH_1
  cfg.speed = I2C_SPEED_400KHZ
  cfg.pin_config.scl = DPin11
  cfg.pin_config.sda = DPin12
  
  discard i2c.init(cfg)
  
  # Write to device
  discard i2c.transmitBlocking(0x3C, addr data, 1, 1000)
```

---

## Troubleshooting

### Compilation Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `Error: cannot open file 'libdaisy.nim'` | Wrong directory | Run from `examples/` directory |
| `undefined reference to daisy::DaisySeed` | libDaisy not built | `cd libDaisy && make` |
| `arm-none-eabi-gcc: command not found` | Toolchain not installed | Install ARM embedded toolchain |
| `Error: undeclared identifier` | Missing import | Add required `import ../src/libdaisy_*` |

### Flashing Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `dfu-util: Cannot open DFU device` | Not in DFU mode | Hold BOOT, press RESET, release BOOT |
| `No DFU capable USB device available` | Driver issue (Windows) | Install Zadig drivers for DFU device |
| `Lost device after RESET` | Normal | Device rebooted - not an error |
| `Error during download` | Corrupted binary | `make clean && make` |

### Runtime Issues

#### No LED Activity

1. Check hardware initialization: `hw.init()`
2. Try `blink.nim` (simplest example)
3. Verify power supply (USB or external 3.3-5V)
4. Check for panic crash (LED might blink SOS pattern)

#### No Audio Output

1. Verify audio callback registered: `hw.startAudio(callback)`
2. Check audio cable connections (input and output)
3. Test with `sine_wave.nim` (doesn't need input)
4. Verify sample rate matches hardware (48kHz default)
5. Check volume level on amp/headphones

#### Peripheral Not Working

**I2C:**
- Run `i2c_scanner.nim` to detect devices
- Check pull-up resistors (4.7kΩ to 3.3V)
- Verify device address (7-bit: 0x3C, not 8-bit: 0x78)
- Check power supply to peripheral (3.3V or 5V)

**SPI:**
- Verify MOSI/MISO not swapped
- Check clock polarity/phase settings
- Confirm CS pin actively driven
- Scope the signals if available

**ADC:**
- Ensure voltage range 0-3.3V (exceeding may damage chip!)
- Check pot wiring (wiper to ADC pin, ends to GND/3.3V)
- Add 100nF capacitor for noise filtering
- Verify ADC pin supports analog input (A0-A11)

**PWM:**
- Confirm pin supports PWM (not all GPIO pins do)
- Check PWM frequency (visible flicker = too low)
- Verify duty cycle range (0-100%)
- Test with different pins if issue persists

### Performance Issues

**Audio Glitches/Clicks:**
- Audio callback taking too long
- Remove logging/printing from callback
- Reduce buffer processing complexity
- Increase audio buffer size (tradeoff: more latency)

**Slow Display Updates:**
- I2C speed too low (use 400kHz)
- Drawing too much per frame
- Use partial updates instead of full clears
- SPI faster than I2C for displays

**Controls Feel Sluggish:**
- Main loop has delays too large
- Reduce `hw.delay()` duration
- Use hardware timers for precise timing
- Check update rate in control library

---

## Test Report Template

When testing examples, use this format to report results:

```markdown
### Test Report: [Example Name]

**Tester:** [Your Name/GitHub]
**Date:** YYYY-MM-DD
**Hardware:** Daisy Seed [+ any peripherals]
**Firmware:** v0.X.X

**Test Result:** ✅ PASS / ⚠️ PARTIAL / ❌ FAIL

**Expected Behavior:**
[Copy from table above]

**Actual Behavior:**
[What actually happened]

**Differences Noted:**
- [Any deviations from expected behavior]

**Hardware Setup:**
- [List components and wiring]

**Additional Notes:**
[Any other observations]

**Photos/Scope Captures:** [If applicable]
```

---

## Contributing New Examples

When adding a new example:

1. **Add row to testing matrix** with expected behavior
2. **Test on hardware** before submitting
3. **Document hardware requirements** clearly
4. **Include comments** explaining key sections
5. **Follow naming conventions**: `category_description.nim`
6. **Update `test_all.sh`** if needed

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## Resources

- **[API Reference](API_REFERENCE.md)** - Complete API documentation
- **[Technical Report](TECHNICAL_REPORT.md)** - How wrappers work
- **[Hardware Testing Guide](HARDWARE_TESTING.md)** - Community testing procedures
- **[libDaisy Docs](https://github.com/electro-smith/DaisyWiki/wiki)** - Hardware documentation
- **[Nim Manual](https://nim-lang.org/docs/manual.html)** - Nim language reference

---

**Questions?** Open a GitHub discussion or issue!
