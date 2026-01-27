# libdaisy_nim

A comprehensive, type-safe Nim wrapper for the [libDaisy](https://github.com/electro-smith/libDaisy) hardware abstraction library, enabling Nim development for the Electro-Smith Daisy Seed embedded audio platform.

[![Platform](https://img.shields.io/badge/platform-ARM%20Cortex--M7-blue)](https://www.st.com/en/microcontrollers-microprocessors/stm32h750xb.html)
[![Nim](https://img.shields.io/badge/nim-2.0%2B-orange)](https://nim-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## What is this?

This wrapper allows you to write firmware for the Daisy Seed embedded audio board using the Nim programming language instead of C++. It provides a clean, type-safe API that wraps libDaisy's hardware abstraction layer.

**Key Features:**
- ✅ **Zero overhead** - Direct C++ interop with no runtime cost
- ✅ **Type safety** - Nim's strong type system catches errors at compile time
- ✅ **Clean API** - Idiomatic Nim interfaces to libDaisy functionality
- ✅ **Comprehensive** - Covers core audio, peripherals, USB, storage, sensors, and more
- ✅ **Production ready** - 71 tested examples demonstrating real-world usage
- ✅ **Well documented** - Complete API reference and technical documentation
- ✅ **Many examples** - 71 working examples covering all features
- ✅ **65 modules** - Comprehensive hardware and utility coverage including sensors, LED drivers, I/O expansion, and system utilities

## Quick Start

### Hardware Requirements
- **Daisy Seed** - STM32H750-based embedded audio board
- **USB cable** - For programming and power
- **Audio I/O** (optional) - For audio applications

### Software Requirements
- **Nim** - 2.0 or later
- **ARM Toolchain** - `arm-none-eabi-gcc` and related tools
- **libDaisy** - The C++ library this wraps (sibling directory)
- **dfu-util** or **st-flash** - For uploading firmware

### Installation

1. **Clone this wrapper with submodules**:
```bash
cd /path/to/your/projects
git clone --recursive https://github.com/yourusername/libdaisy_nim
cd libdaisy_nim
```

2. **Build libDaisy** (required dependency):
```bash
cd libDaisy
make
cd ..
```

Your directory structure will be:
```
libdaisy_nim/
├── libDaisy/          # C++ library (submodule)
├── src/               # Nim wrapper
└── examples/          # Example programs
```

3. **Try an example**:
```bash
cd libdaisy_nim/examples
make                    # Builds current TARGET
make program-dfu        # Flash to Daisy via USB
```

### Applying Patches (Required for ICM20948 Sensor)

**Note**: If you plan to use the ICM20948 9-axis IMU sensor, you must apply a patch to libDaisy first:

```bash
cd libdaisy_nim
./apply_patches.sh
```

This fixes an upstream bug in libDaisy's ICM20948 magnetometer initialization. See `patches/README.md` for details. The patch is safe and only affects ICM20948 functionality.

**Why is this needed?**
- The ICM20948 module in libDaisy has a bug preventing magnetometer initialization
- We've created a minimal 1-line patch that fixes the issue
- This patch has been prepared for upstream submission to libDaisy
- Other sensors (APDS9960, DPS310, TLV493D, MPR121, NeoTrellis) work without patches

See **[QUICKSTART.md](docs/QUICKSTART.md)** for detailed setup instructions.

## What Can You Build?

The Daisy Seed is a powerful embedded audio platform perfect for:

🎵 **Audio Effects** - Delays, reverbs, distortion, filters, modulation  
🎹 **Synthesizers** - Wavetable, FM, subtractive, granular synthesis  
🥁 **Instruments** - Samplers, sequencers, drum machines, loopers  
🎛️ **Controllers** - MIDI devices, CV interfaces, sensor systems  
📊 **Data Systems** - Audio recorders, analyzers, data loggers  

## Features

### Core Hardware
- ✅ **Audio I/O** - Stereo input/output, 8-96kHz sample rates, DMA-based
- ✅ **GPIO** - 32 configurable pins, all standard modes
- ✅ **System** - Initialization, timing, utilities

### Peripherals  
- ✅ **I2C** - 4 buses, master/slave modes, up to 1MHz
- ✅ **SPI** - 6 buses, master/slave, full-duplex
- ✅ **Multi-Slave SPI** - Share SPI bus between up to 4 devices (NEW in v0.10.0)
- ✅ **UART** - 6 ports, configurable baud rates
- ✅ **ADC** - Analog inputs, multi-channel, multiplexed
- ✅ **PWM** - Hardware PWM output, 4 channels per timer
- ✅ **DAC** - Analog voltage outputs (NEW in v0.3.0)

### USB
- ✅ **USB Device CDC** - Virtual serial port over USB
- ✅ **USB MIDI** - MIDI device and host modes
- ✅ **USB Host** - Mass storage, MIDI devices

### Storage & Memory
- ✅ **SD Card** - SDMMC interface, FatFS filesystem, FAT32 support
- ✅ **WAV Files** - WAV parser, streaming player, real-time recorder (NEW in v0.6.0)
- ✅ **Wavetable Loading** - Multi-bank wavetable loader from SD (NEW in v0.6.0)
- ✅ **QSPI Flash** - 8MB QSPI flash read/write/erase operations
- ✅ **Persistent Storage** - Type-safe settings storage with dirty detection (NEW in v0.10.0)
- ✅ **External SDRAM** - 64MB for large audio buffers

### User Interface
- ✅ **MIDI** - Hardware UART and USB MIDI I/O
- ✅ **Switches** - Debounced switch handling, multiple types (enhanced in v0.6.0)
- ✅ **Encoders** - Rotary encoder support with button
- ✅ **Controls** - Analog knobs, CV inputs (uses ADC)
- ✅ **OLED Displays** - SSD1306 driver with I2C/SPI support

### Data Structures & Utilities (NEW in v0.5.0)
- ✅ **FIFO Queue** - Lock-free queue for audio/event buffering
- ✅ **Stack** - Fixed-capacity LIFO stack
- ✅ **RingBuffer** - Circular buffer for delay effects
- ✅ **FixedStr** - Stack-allocated string for displays
- ✅ **Parameter Mapping** - Curve-based control mapping (exp/log/cubic)
- ✅ **MappedValue** - Value scaling and quantization utilities
- ✅ **UniqueId** - STM32 device unique identifier
- ✅ **CpuLoad** - Real-time CPU usage monitoring

### Sensor Modules (NEW in v0.8.0)
- ✅ **ICM20948** - 9-axis IMU (gyro, accel, magnetometer, temp) - I2C/SPI
- ✅ **APDS9960** - Gesture/proximity/RGB/light sensor - I2C
- ✅ **DPS310** - Barometric pressure and altitude sensor - I2C/SPI
- ✅ **TLV493D** - 3D magnetic field sensor - I2C
- ✅ **MPR121** - 12-channel capacitive touch controller - I2C
- ✅ **NeoTrellis** - 4x4 RGB LED button matrix (Adafruit seesaw) - I2C

### Audio Codecs & Displays (NEW in v0.7.0)
- ✅ **AK4556** - Audio codec for Daisy Seed 1.0
- ✅ **WM8731** - I2C audio codec for Daisy Seed 1.1
- ✅ **PCM3060** - High-performance codec for Daisy Seed 2.0
- ✅ **LCD HD44780** - Character LCD driver (16x2, 20x4)
- ✅ **OLED Fonts** - 8 bitmap fonts for OLED displays

### Device Drivers & Expansion (NEW in v0.9.0)
- ✅ **PCA9685** - 16-channel 12-bit PWM LED driver - I2C
- ✅ **DotStar** - High-speed RGB LED strips - SPI
- ✅ **74HC595** - 8-bit shift register (output) - SPI
- ✅ **74HC4021** - 8-bit shift register (input) - SPI
- ✅ **MCP23017** - 16-channel GPIO expander - I2C
- ⚠️ **MAX11300 PIXI** - 20-channel programmable mixed-signal I/O (ADC/DAC/GPIO) - SPI
  - **EXPERIMENTAL**: Full implementation available but **NOT tested on hardware**
  - Wraps libDaisy C++ driver with complete API coverage
  - Should be considered experimental until community validation
  - See CHANGELOG.md for implementation details

### Board Support (NEW in v0.11.0)
- ✅ **Daisy Seed** - Base platform (STM32H750, 480MHz ARM Cortex-M7)
- ✅ **Daisy Pod** - Desktop synthesizer format (encoder, 2 knobs, 2 buttons, RGB LEDs, MIDI)
- ✅ **Daisy Patch** - Eurorack module format (OLED, encoder, 4 CV/knobs, gate I/O, MIDI)
- ✅ **Daisy Field** - Keyboard/CV interface (16-key keyboard, 8 knobs, 26 RGB LEDs, 4 CV I/O)

### System Features (NEW in v0.14.0)
- ✅ **System Control** - Clock configuration, timing functions (ms/μs), bootloader access
- ✅ **DMA Cache Coherency** - Cache management for STM32H750 DMA operations
- ✅ **V/Oct Calibration** - Eurorack pitch CV calibration (1V/octave tracking)
- ✅ **Scoped IRQ Blocking** - RAII-pattern interrupt control for critical sections
- ✅ **Logger** - USB/UART debug logging with string-based API
- ✅ **File Table** - FAT filesystem indexing for fast file access

## Examples

The `examples/` directory contains 71 production-ready examples:

| Category | Example | Description |
|----------|---------|-------------|
| **Basic** | `blink.nim` | LED blink - your first program |
| | `button_led.nim` | Button input controlling LED |
| | `gpio_input.nim` | Reading GPIO pins |
| **Audio** | `audio_passthrough.nim` | Pass audio input to output |
| | `distortion_effect.nim` | Simple overdrive effect |
| | `sine_wave.nim` | Generate sine waves |
| **File I/O** | `wav_player.nim` | WAV file playback with track navigation (v0.6.0) |
| | `wav_recorder.nim` | Record audio to SD in WAV format (v0.6.0) |
| | `sampler.nim` | Trigger and play multiple WAV samples (v0.6.0) |
| | `looper.nim` | Record and loop audio with overdub (v0.6.0) |
| | `wavetable_synth.nim` | Wavetable synthesis from SD (v0.6.0) |
| | `qspi_storage.nim` | QSPI flash memory operations (v0.6.0) |
| **ADC** | `adc_simple.nim` | Single analog input |
| | `adc_multichannel.nim` | Multiple ADC channels |
| | `adc_multiplexed.nim` | Multiplexed inputs |
| | `adc_config.nim` | Custom ADC configuration |
| | `analog_knobs.nim` | Real-world analog controls |
| **PWM** | `pwm_led.nim` | LED brightness control |
| | `pwm_rgb.nim` | RGB LED color mixing |
| | `pwm_servo.nim` | Servo motor control |
| **Displays** | `oled_basic.nim` | Basic OLED text |
| | `oled_graphics.nim` | Drawing shapes and graphics |
| | `oled_spi.nim` | SPI-based OLED |
| | `oled_visualizer.nim` | Audio level visualizer |
| **Peripherals** | `i2c_scanner.nim` | Scan I2C bus for devices |
| | `spi_basic.nim` | Basic SPI communication |
| **Data & Utils** | `data_structures.nim` | FIFO/Stack/RingBuffer with audio delay |
| | `control_mapping.nim` | Parameter curves and value mapping |
| | `system_info.nim` | Device ID and CPU load monitoring |
| **Advanced** | `midi_input.nim` | MIDI note input |
| | `encoder.nim` | Rotary encoder reading |
| | `usb_serial.nim` | USB CDC serial port |
| | `sdram_test.nim` | External memory test |
| **Board Examples** | `pod_simple.nim` | Daisy Pod LED/knob/button test (v0.11.0) |
| | `pod_synth.nim` | Daisy Pod monophonic synthesizer (v0.11.0) |
| | `pod_effect.nim` | Daisy Pod multi-effect processor (v0.11.0) |
| | `patch_effect.nim` | Daisy Patch multi-effect with CV (v0.11.0) |
| | `patch_cv_processor.nim` | Daisy Patch CV utilities (v0.11.0) |
| | `field_keyboard.nim` | Daisy Field keyboard synthesizer (v0.11.0) |
| | `field_modular.nim` | Daisy Field CV/gate sequencer (v0.11.0) |
| **System** | `system_control.nim` | System info, timing, bootloader control (v0.14.0) |
| | `advanced_logging.nim` | Performance profiling with USB logger (v0.14.0) |

Each example is a complete, working program that compiles and runs on hardware.

## Documentation

- **[QUICKSTART.md](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[API_REFERENCE.md](docs/API_REFERENCE.md)** - Complete API documentation
- **[BOARD_TESTING_GUIDE.md](docs/BOARD_TESTING_GUIDE.md)** - Hardware testing for Pod, Patch, Field (NEW in v0.11.0)
- **[FLASH_GUIDE.md](docs/FLASH_GUIDE.md)** - QSPI flash memory usage guide (NEW in v0.10.0)
- **[EXAMPLES.md](docs/EXAMPLES.md)** - Example testing matrix with expected behavior
- **[TESTING_CHECKLIST.md](docs/TESTING_CHECKLIST.md)** - Printable hardware testing checklist
- **[TECHNICAL_REPORT.md](docs/TECHNICAL_REPORT.md)** - How the wrapper works internally
- **[ROADMAP.md](docs/ROADMAP.md)** - v1.0.0 roadmap and development plan
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** - How to contribute to the project
- **[HARDWARE_TESTING.md](docs/HARDWARE_TESTING.md)** - Community hardware testing guide

## Project Structure

```
libdaisy_nim/
├── AGENTS.md              # AI agent guide
├── README.md              # This file
├── LICENSE                # License file
├── libdaisy_nim.nimble    # Nimble package file
│
├── docs/                  # Documentation
│   ├── QUICKSTART.md         # Quick start guide
│   ├── API_REFERENCE.md      # Complete API documentation
│   ├── BOARD_TESTING_GUIDE.md # Board testing guide (v0.11.0)
│   ├── FLASH_GUIDE.md        # QSPI flash memory guide (v0.10.0)
│   ├── EXAMPLES.md           # Example testing matrix
│   ├── TESTING_CHECKLIST.md  # Hardware testing checklist
│   ├── TECHNICAL_REPORT.md   # Technical internals & architecture
│   ├── ROADMAP.md            # v1.0.0 development plan
│   ├── CONTRIBUTING.md       # Contribution guide
│   ├── HARDWARE_TESTING.md   # Community testing guide
│   └── CHANGELOG.md          # Version history
│
├── src/                   # Wrapper source code (65 modules)
│   ├── libdaisy.nim          # Core API (GPIO, audio, system)
│   ├── libdaisy_macros.nim   # Compile-time macro system
│   ├── libdaisy_adc.nim      # ADC (analog input)
│   ├── libdaisy_pwm.nim      # PWM (pulse width modulation)
│   ├── libdaisy_oled.nim     # OLED displays (SSD1306)
│   ├── libdaisy_i2c.nim      # I2C communication
│   ├── libdaisy_spi.nim      # SPI communication
│   ├── libdaisy_serial.nim   # UART serial
│   ├── libdaisy_midi.nim     # MIDI I/O
│   ├── libdaisy_usb.nim      # USB device/host/MIDI
│   ├── libdaisy_sdmmc.nim    # SD card & FatFS
│   ├── libdaisy_sdram.nim    # External SDRAM
│   ├── libdaisy_controls.nim # Switches & encoders
│   ├── libdaisy_switch.nim   # Debounced button/switch (v0.6.0)
│   ├── libdaisy_wavparser.nim # WAV file parser (v0.6.0)
│   ├── libdaisy_wavplayer.nim # WAV streaming player (v0.6.0)
│   ├── libdaisy_wavwriter.nim # WAV recorder (v0.6.0)
│   ├── libdaisy_wavetable_loader.nim # Wavetable loader (v0.6.0)
│   ├── libdaisy_qspi.nim     # QSPI flash memory (v0.6.0)
│   ├── libdaisy_fifo.nim     # Lock-free FIFO queue (v0.5.0)
│   ├── libdaisy_stack.nim    # Fixed-capacity stack (v0.5.0)
│   ├── libdaisy_ringbuffer.nim # Circular buffer (v0.5.0)
│   ├── libdaisy_fixedstr.nim # Stack-allocated string (v0.5.0)
│   ├── libdaisy_parameter.nim # Parameter mapping (v0.5.0)
│   ├── libdaisy_mapped_value.nim # Value utilities (v0.5.0)
│   ├── libdaisy_uniqueid.nim # Device unique ID (v0.5.0)
│   ├── libdaisy_cpuload.nim  # CPU load monitoring (v0.5.0)
│   ├── libdaisy_system.nim   # System control & timing (v0.14.0)
│   ├── libdaisy_dma.nim      # DMA cache coherency (v0.14.0)
│   ├── libdaisy_voct_calibration.nim # V/Oct CV calibration (v0.14.0)
│   ├── libdaisy_scoped_irq.nim # RAII interrupt blocking (v0.14.0)
│   ├── libdaisy_logger.nim   # Debug logging (v0.14.0)
│   ├── libdaisy_file_table.nim # FAT filesystem indexing (v0.14.0)
│   └── panicoverride.nim     # Embedded panic handler
│
└── examples/              # Example programs (71)
    ├── Makefile              # Build system
    ├── nim.cfg               # Nim compiler configuration
    ├── test_all.sh           # Test all examples
    └── *.nim                 # Example programs
```

## Technical Highlights

### Automatic Include Management
The wrapper uses a compile-time macro system to automatically emit required C++ includes based on which modules you import. No manual include management needed!

```nim
import src/libdaisy        # Automatically includes daisy_seed.h
import src/libdaisy_i2c    # Automatically includes hid/i2c.h
```

### Selective Compilation
Define symbols to include only what you need:
```nim
# In your code or nim.cfg
{.define: useI2C.}
{.define: useUSB.}
```

### Zero-Cost Abstractions
All wrapper functions compile to direct C++ calls with no overhead:
```nim
hw.setLed(true)  # Compiles to: hw.SetLed(true);
```

### Type Safety
Nim's type system prevents common embedded errors:
```nim
var pin: DaisyPin = DPin0       # Type-safe pin selection
var rate: I2CSpeed = I2C_400KHZ # Enumerated constants
```

## Hardware Specifications

**Daisy Seed Features:**
- **MCU:** STM32H750IBK6 (ARM Cortex-M7, 480MHz)
- **RAM:** 512KB internal + 64MB external SDRAM
- **Flash:** 128KB internal (bootloader) + 8MB QSPI
- **Audio:** 24-bit stereo ADC/DAC, up to 96kHz
- **GPIO:** 32 pins, 3.3V logic
- **Interfaces:** 4×I2C, 6×SPI, 6×UART, USB, SDMMC
- **Storage:** MicroSD card slot
- **Power:** USB or external 3.3-5V

## Performance

- **Compile time:** ~0.6s per example (Nim → C++)
- **Binary size:** ~64KB typical (minimal example)
- **Audio latency:** <3ms typical (depends on buffer size)
- **Memory overhead:** Zero - direct C++ interop

## Requirements

**Development Machine:**
- Linux, macOS, or Windows
- Nim 2.0 or later
- ARM embedded toolchain (`arm-none-eabi-gcc`)
- dfu-util (for USB flashing) or ST-Link tools

**Target Hardware:**
- Daisy Seed board
- USB cable for programming
- Power supply (USB or external)

## Building

Standard Makefile-based build system:

```bash
cd examples
make                  # Build current TARGET
make program-dfu      # Build and flash via DFU (USB)
make program-stlink   # Build and flash via ST-Link
make clean            # Clean build directory
```

All build artifacts go into `build/` directory for clean organization.

## License

This wrapper follows the same MIT license as libDaisy. See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! See **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** for:
- Development setup
- Code style guidelines
- Testing requirements
- Areas needing work
- How to submit PRs

## Resources

- **[libDaisy GitHub](https://github.com/electro-smith/libDaisy)** - The C++ library
- **[Daisy Wiki](https://github.com/electro-smith/DaisyWiki/wiki)** - Hardware documentation
- **[Electro-Smith Forum](https://forum.electro-smith.com/)** - Community support
- **[Nim Language](https://nim-lang.org/)** - Nim programming language
- **[STM32H750 Datasheet](https://www.st.com/resource/en/datasheet/stm32h750xb.pdf)** - MCU details

## Status

**Current Version:** 0.14.0

**Latest Updates (v0.14.0):**
- ✅ **System Control** - Clock config, timing, bootloader access (689 lines)
- ✅ **DMA Cache Coherency** - Cache management for STM32H750 (343 lines)
- ✅ **V/Oct Calibration** - Eurorack pitch CV calibration (526 lines)
- ✅ **Scoped IRQ** - RAII interrupt blocking for critical sections (431 lines)
- ✅ **Logger** - USB/UART debug logging with string API (498 lines)
- ✅ **File Table** - FAT filesystem indexing (591 lines)

**Stability:**
- ✅ Core API - Stable, tested
- ✅ Peripherals - I2C, SPI, UART, Multi-Slave SPI working
- ✅ USB - CDC and MIDI working
- ✅ Storage - SD card, SDRAM, QSPI flash, persistent settings working
- ✅ ADC - ADC multiplexing working  
- ✅ PWM - working  
- ✅ OLED screen (SSD1306) - working  
- ✅ DAC - working (v0.3.0)
- ✅ Daisy Patch board - working (v0.3.0)
- ✅ File I/O - WAV playback/recording, QSPI flash working (v0.6.0)
- ✅ System Features - Clock control, logging, calibration working (v0.14.0)
- 🚧 Other boards - Pod, Patch, Field working (v0.11.0), Petal/Versio/PatchSM/Legio added (v0.13.0)

**Production Readiness:** Experimental - use at your own risk. APIs may change.

## Support

- **Issues:** Use GitHub issues for bug reports
- **Discussions:** GitHub discussions for questions
- **Forum:** [Electro-Smith forum](https://forum.electro-smith.com/) for hardware questions

## Acknowledgments

- **Electro-Smith** for creating Daisy and libDaisy
- **Nim Community** for the excellent language and tools
- **Contributors** who helped test and improve this wrapper

---

**Ready to build something amazing?** Start with **[QUICKSTART.md](docs/QUICKSTART.md)**!
