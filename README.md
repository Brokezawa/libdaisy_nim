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
- ✅ **Comprehensive** - Covers core audio, peripherals, USB, storage, and more
- ✅ **Production ready** - 14 tested examples demonstrating real-world usage
- ✅ **Well documented** - Complete API reference and technical documentation
- ✅ **Many examples** - 24+ working examples covering all features

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

See **[QUICKSTART.md](QUICKSTART.md)** for detailed setup instructions.

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
- ✅ **UART** - 6 ports, configurable baud rates
- ✅ **ADC** - Analog inputs, multi-channel, multiplexed
- ✅ **PWM** - Hardware PWM output, 4 channels per timer
- ⏳ **DAC** - Analog outputs (coming in v0.3.0)

### USB
- ✅ **USB Device CDC** - Virtual serial port over USB
- ✅ **USB MIDI** - MIDI device and host modes
- ✅ **USB Host** - Mass storage, MIDI devices

### Storage & Memory
- ✅ **SD Card** - SDMMC interface, FatFS filesystem, FAT32 support
- ✅ **External SDRAM** - 64MB for large audio buffers

### User Interface
- ✅ **MIDI** - Hardware UART and USB MIDI I/O
- ✅ **Switches** - Debounced switch handling, multiple types
- ✅ **Encoders** - Rotary encoder support with button
- ✅ **Controls** - Analog knobs, CV inputs (uses ADC)
- ✅ **OLED Displays** - SSD1306 driver with I2C/SPI support

## Examples

The `examples/` directory contains 24+ production-ready examples:

| Category | Example | Description |
|----------|---------|-------------|
| **Basic** | `blink.nim` | LED blink - your first program |
| | `button_led.nim` | Button input controlling LED |
| | `gpio_input.nim` | Reading GPIO pins |
| **Audio** | `audio_passthrough.nim` | Pass audio input to output |
| | `distortion_effect.nim` | Simple overdrive effect |
| | `sine_wave.nim` | Generate sine waves |
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
| **Advanced** | `midi_input.nim` | MIDI note input |
| | `encoder.nim` | Rotary encoder reading |
| | `usb_serial.nim` | USB CDC serial port |
| | `sdram_test.nim` | External memory test |

Each example is a complete, working program that compiles and runs on hardware.

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[API_REFERENCE.md](API_REFERENCE.md)** - Complete API documentation
- **[EXAMPLES.md](examples/EXAMPLES.md)** - Detailed example descriptions
- **[TECHNICAL_REPORT.md](TECHNICAL_REPORT.md)** - How the wrapper works internally
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute to the project

## Project Structure

```
libdaisy_nim/
├── README.md              # This file
├── QUICKSTART.md          # Quick start guide
├── API_REFERENCE.md       # Complete API documentation
├── TECHNICAL_REPORT.md    # Technical internals & architecture
├── CHANGELOG.md           # Version history
├── CONTRIBUTING.md        # Contribution guide
├── LICENSE                # License file
├── libdaisy_nim.nimble    # Nimble package file
│
├── src/                   # Wrapper source code
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
│   └── panicoverride.nim     # Embedded panic handler
│
└── examples/              # Example programs (24+)
    ├── Makefile              # Build system
    ├── nim.cfg               # Nim compiler configuration
    ├── test_all.sh     # Test all examples
    ├── *.nim           # Example programs
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

Contributions are welcome! See **[CONTRIBUTING.md](CONTRIBUTING.md)** for:
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

**Current Version:** 0.2.0 

**Stability:**
- ✅ Core API - Stable, tested
- ✅ Peripherals - I2C, SPI, UART working
- ✅ USB - CDC and MIDI working
- ✅ Storage - SD card and SDRAM working  
- ✅ ADC - ADC multiplexing working  
- ✅ PWM - working  
- ✅ OLED screen (SSD1306) - working  
- 🚧 DAC - Planned
- 🚧 Other boards - Planned (Patch, Pod, Field, etc.)

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

**Ready to build something amazing?** Start with **[QUICKSTART.md](QUICKSTART.md)**!
