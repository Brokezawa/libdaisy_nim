# Technical Report: libdaisy_nim Wrapper

## Executive Summary

This document explains the technical architecture of the libdaisy_nim wrapper, how it bridges Nim and C++ code, what features from libDaisy are currently implemented, what's missing, and how to contribute.

**Author:** libdaisy_nim contributors  
**Version:** 0.1.0  
**Date:** October 2025  
**Target:** Developers, contributors, and technical users

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [How the Wrapper Works](#how-the-wrapper-works)
3. [Compile-Time Macro System](#compile-time-macro-system)
4. [Current Implementation Status](#current-implementation-status)
5. [What's Missing from libDaisy](#whats-missing-from-libdaisy)
6. [Build System](#build-system)
7. [Testing Strategy](#testing-strategy)
8. [Contributing](#contributing)
9. [Future Roadmap](#future-roadmap)

---

## Architecture Overview

### Design Philosophy

The wrapper follows these core principles:

1. **Zero overhead** - Direct C++ interop with no runtime wrapper layer
2. **Type safety** - Leverage Nim's type system to catch errors at compile time
3. **Simplicity** - Clean, idiomatic Nim API that feels natural
4. **Selective compilation** - Include only what you use to minimize binary size
5. **Maintainability** - Clear code organization, good documentation

### Layer Structure

```
┌─────────────────────────────────────┐
│   User Nim Code (examples/*.nim)    │
├─────────────────────────────────────┤
│   Wrapper Modules (src/*.nim)       │
│   - Type definitions                │
│   - Nim proc declarations           │
│   - Macro-generated {.emit.}        │
├─────────────────────────────────────┤
│   Nim → C++ FFI (importcpp, emit)   │
├─────────────────────────────────────┤
│   libDaisy C++ Library              │
│   - Hardware abstraction            │
│   - Peripheral drivers              │
├─────────────────────────────────────┤
│   STM32 HAL & Hardware              │
└─────────────────────────────────────┘
```

### Module Organization

```
src/
├── libdaisy.nim           # Core: DaisySeed, GPIO, Audio, System
├── libdaisy_macros.nim    # Compile-time include generation
├── libdaisy_i2c.nim       # I2C communication
├── libdaisy_spi.nim       # SPI communication
├── libdaisy_serial.nim    # UART serial
├── libdaisy_midi.nim      # MIDI I/O (UART and USB)
├── libdaisy_usb.nim       # USB Device CDC, USB MIDI, USB Host
├── libdaisy_sdmmc.nim     # SD card with FatFS
├── libdaisy_sdram.nim     # External SDRAM memory
├── libdaisy_controls.nim  # Switches, encoders, controls
└── panicoverride.nim      # Embedded panic handler
```

Each module is self-contained and can be imported independently.

---

## How the Wrapper Works

### C++ Interop Mechanisms

Nim provides several ways to call C/C++ code. This wrapper uses:

#### 1. `importcpp` - Direct C++ Method Calls

```nim
# Nim declaration
proc init*(this: var DaisySeed) {.importcpp: "#.Init()".}

# Compiles to C++
hw.Init();
```

The `#` placeholder represents the object (`this`).

#### 2. `{.emit.}` - Inline C++ Code

```nim
{.emit: """
#include "daisy_seed.h"
using namespace daisy;
""".}
```

Emits literal C++ code into the generated output.

#### 3. Type Mapping

Nim types map directly to C++ types:

```nim
type
  DaisySeed* {.importcpp: "daisy::DaisySeed", header: "daisy_seed.h".} = object
  csize_t* = uint
  cfloat* = float32
```

### Object Wrapping Pattern

libDaisy C++ classes are wrapped as Nim objects:

**C++ (libDaisy):**
```cpp
class DaisySeed {
public:
    void Init();
    void SetLed(bool state);
};
```

**Nim (wrapper):**
```nim
type
  DaisySeed* {.importcpp.} = object

proc init*(this: var DaisySeed) {.importcpp: "#.Init()".}
proc setLed*(this: var DaisySeed, state: bool) {.importcpp: "#.SetLed(#)".}
```

**User code:**
```nim
var hw = newDaisySeed()
hw.init()
hw.setLed(true)
```

This provides a natural Nim interface while generating efficient C++ calls.

### Memory Management

The wrapper uses Nim's ARC memory management (`--mm:arc`), which is deterministic and suitable for embedded systems:

- **No garbage collection** - Predictable, low overhead
- **Scope-based cleanup** - Resources freed when scope ends
- **Move semantics** - Efficient object transfer
- **No reference counting for simple objects** - Pure stack allocation where possible

For embedded systems, objects are typically stack-allocated or use libDaisy's internal memory management.

---

## Compile-Time Macro System

### The Problem

C++ requires `#include` directives to use library headers. Early versions of the wrapper required manual `{.emit.}` blocks in every file:

```nim
# OLD WAY - Manual, error-prone
{.emit: """
#include "daisy_seed.h"
#include "hid/i2c.h"
using namespace daisy;
""".}
```

This was tedious and easy to forget.

### The Solution: Auto-Include Macros

The wrapper now uses compile-time macros to automatically emit required includes based on which modules you import.

**File:** `src/libdaisy_macros.nim`

```nim
import std/macros

macro emitDaisyCore*(): untyped =
  result = newStmtList()
  when defined(useDaisyCore):
    result.add quote do:
      {.emit: """
      #include "daisy_seed.h"
      using namespace daisy;
      """.}

macro emitI2CIncludes*(): untyped =
  when defined(useI2C):
    result = quote do:
      {.emit: """
      #include "hid/i2c.h"
      """.}
```

### Selective Inclusion

Users can control what gets included:

**In nim.cfg or code:**
```nim
{.define: useDaisyCore.}
{.define: useI2C.}
{.define: useUSB.}
```

**In wrapper modules:**
```nim
# libdaisy_i2c.nim
import libdaisy_macros
{.define: useI2C.}  # This module needs I2C
emitI2CIncludes()   # Generate includes
```

### How It Works

1. **User imports a module**: `import src/libdaisy_i2c`
2. **Module defines symbol**: `{.define: useI2C.}`
3. **Module calls macro**: `emitI2CIncludes()`
4. **Macro checks symbol**: `when defined(useI2C):`
5. **Macro emits C++**: `{.emit: """#include "hid/i2c.h" """.}`
6. **Nim compiler generates C++** with includes in place

This happens entirely at compile time - zero runtime cost!

### Benefits

- ✅ **Automatic** - No manual include management
- ✅ **Selective** - Only include what you use
- ✅ **Type-safe** - Compiler ensures consistency
- ✅ **Maintainable** - Centralized in macros file
- ✅ **Zero-cost** - Compile-time only

---

## Current Implementation Status

### ✅ Fully Implemented

#### Core Hardware (`libdaisy.nim`)
- **DaisySeed initialization** - `init()`, `configure()`
- **GPIO** - All 32 pins, all modes (input, output, analog, alt function)
- **Audio I/O** - Stereo input/output, configurable sample rate, DMA-based
- **System utilities** - Delays, timing, LED control
- **Status:** Production ready, well tested

#### I2C Communication (`libdaisy_i2c.nim`)
- **4 I2C buses** - I2C1, I2C2, I2C3, I2C4
- **Master mode** - Read, write, transmit, receive
- **Configurable speed** - 100kHz, 400kHz, 1MHz
- **Error handling** - Return codes for all operations
- **Status:** Production ready, tested with real devices

#### SPI Communication (`libdaisy_spi.nim`)
- **6 SPI buses** - SPI1-SPI6
- **Master/Slave modes** - Configurable
- **Full-duplex** - Simultaneous TX/RX
- **Configurable settings** - Clock polarity, phase, baud rate
- **DMA support** - For high-speed transfers
- **Status:** Production ready, tested

#### UART Serial (`libdaisy_serial.nim`)
- **6 UART ports** - USART1-6
- **Configurable baud** - Up to 12.5 Mbps
- **Word length** - 7, 8, 9 bits
- **Stop bits** - 0.5, 1, 1.5, 2
- **Parity** - None, even, odd
- **Flow control** - None, RTS/CTS
- **Status:** Production ready

#### USB Support (`libdaisy_usb.nim`)
- **USB Device CDC** - Virtual serial port
- **USB MIDI** - Device and host modes
- **USB Host** - Mass storage, MIDI devices
- **Status:** Working, needs more testing

#### SD Card (`libdaisy_sdmmc.nim`)
- **SDMMC interface** - Hardware SD card controller
- **FatFS filesystem** - FAT32 support
- **File operations** - Open, read, write, close, seek
- **Directory ops** - List files, create directories
- **Status:** Working, needs more testing

#### External SDRAM (`libdaisy_sdram.nim`)
- **64MB memory** - For large audio buffers
- **Memory pool** - Allocation and management
- **DMA access** - Fast transfers
- **Status:** Working, basic functionality tested

#### MIDI (`libdaisy_midi.nim`)
- **UART MIDI** - Traditional 5-pin DIN
- **USB MIDI** - Modern USB connection
- **Input/Output** - Send and receive messages
- **Message parsing** - Note on/off, CC, etc.
- **Status:** Working

#### Controls (`libdaisy_controls.nim`)
- **Switches** - Debounced input, multiple types
- **Rotary encoders** - With button support
- **Control types** - Various input abstractions
- **Status:** Working

### 🚧 Partially Implemented

#### ADC (Analog to Digital Converter)
- **Current:** Basic ADC reading possible via GPIO
- **Missing:** Multi-channel ADC wrapper, calibration, oversampling
- **Priority:** High - needed for CV inputs, knobs
- **Difficulty:** Medium

#### PWM (Pulse Width Modulation)
- **Current:** Not wrapped
- **Missing:** PWM timer configuration, duty cycle control
- **Priority:** Medium - useful for LED dimming, motor control
- **Difficulty:** Low

### ❌ Not Yet Implemented

#### DAC (Digital to Analog Converter)
- **Missing:** CV output generation
- **Priority:** Medium
- **Difficulty:** Low
- **Uses:** Control voltage outputs, DC-coupled audio

#### Other Daisy Boards
Currently only **Daisy Seed** is supported. Other boards need wrappers:
- **Daisy Patch** - Eurorack module format
- **Daisy Pod** - Desktop synth format
- **Daisy Field** - Field format with more I/O
- **Daisy Petal** - Guitar pedal format

**Priority:** Low (Seed is most common)  
**Difficulty:** Low (similar to Seed, just different pin configs)

#### Device Drivers (`src/dev/`)
libDaisy includes drivers for many external devices. None are wrapped yet:

**Displays:**
- OLED (SH1106, SSD1306, SSD1327, SSD1351)
- LCD (HD44780)

**Sensors:**
- IMU (ICM20948)
- Pressure (DPS310)
- Magnetic (TLV493D)
- Gesture (APDS9960)

**Codecs:**
- AK4556, PCM3060, WM8731

**Memory:**
- Flash (IS25LP064A, IS25LP080D)

**I/O Expanders:**
- MCP23017, MCP23x17

**Touch:**
- MPR121, Neotrellis

**Priority:** Low to Medium (depends on use case)  
**Difficulty:** Low to Medium (straightforward wrapping)

#### UI Framework (`src/ui/`)
libDaisy has a menu/UI system not yet wrapped:
- AbstractMenu
- FullScreenItemMenu  
- ButtonMonitor
- PotMonitor

**Priority:** Low  
**Difficulty:** Medium (OOP patterns)

#### Utilities (`src/util/`)
Many utility classes not wrapped:
- WavPlayer, WavWriter - Audio file playback/recording
- FileReader - Efficient file streaming
- PersistentStorage - NVM storage
- CpuLoadMeter - Performance monitoring
- VoctCalibration - V/Oct calibration
- Color - RGB color utilities

**Priority:** Low to High (varies)  
**Difficulty:** Low

---

## What's Missing from libDaisy

This section catalogs features present in libDaisy but not yet exposed in the Nim wrapper.

### Peripheral Wrappers Needed

| Feature | libDaisy Path | Priority | Difficulty | Notes |
|---------|---------------|----------|------------|-------|
| ADC Multi-channel | `per/adc.h` | High | Medium | Critical for analog I/O |
| DAC | `per/dac.h` | Medium | Low | CV outputs |
| PWM | `per/pwm.h` | Medium | Low | LED dimming, motors |
| RNG | `per/rng.h` | Low | Low | Random number generation |
| QSPI | `per/qspi.h` | Low | Medium | External flash |
| Timer | `per/tim.h` | Low | Low | Precise timing |
| SAI | `per/sai.h` | Low | High | Advanced audio |
| SPI Multi-slave | `per/spiMultislave.h` | Low | Medium | Multiple SPI devices |

### Board Support Needed

| Board | Status | Priority | Notes |
|-------|--------|----------|-------|
| Daisy Seed | ✅ Complete | - | Reference implementation |
| Daisy Patch | ❌ Missing | Medium | Eurorack format, popular |
| Daisy Pod | ❌ Missing | Low | Desktop synth |
| Daisy Field | ❌ Missing | Low | More I/O |
| Daisy Petal | ❌ Missing | Low | Guitar pedal |
| Daisy Patch SM | ❌ Missing | Low | Surface mount |

### Device Drivers Needed

**High Priority** (commonly used):
- OLED displays (SSD1306, SH1106) - Essential for many projects
- WavPlayer/WavWriter - Audio file I/O
- IMU sensors - Motion sensing

**Medium Priority**:
- Other codec support (WM8731, PCM3060)
- Touch interfaces (MPR121)
- I/O expanders (MCP23017)

**Low Priority**:
- Specialized sensors
- Less common displays
- Niche peripherals

### Utility Classes Needed

**High Priority:**
- CpuLoadMeter - Performance monitoring
- PersistentStorage - Save settings
- WavPlayer/Writer - Audio files

**Medium Priority:**
- FileReader - Efficient streaming
- VoctCalibration - For synths
- Color utilities

**Low Priority:**
- Menu system
- Stack/FIFO utilities (Nim has its own)

---

## Build System

### Makefile-Based Build

The build system uses a traditional Makefile approach familiar to embedded developers:

**File:** `examples/Makefile`

```makefile
TARGET = blink_clean       # Program to build
LIBDAISY_DIR = ../../libDaisy
BUILD_DIR = build          # All outputs here

# Nim compiler with all flags
NIMFLAGS = --cpu:arm --os:standalone --mm:arc ...

# Build process
all: $(BUILD_DIR)/$(TARGET).bin
    nim cpp $(NIMFLAGS) -o:$(BUILD_DIR)/$(TARGET).elf $(TARGET).nim
    arm-none-eabi-objcopy -O binary elf bin
```

### nim.cfg Configuration

**File:** `examples/nim.cfg`

Provides base compiler settings:
- CPU architecture (ARM)
- OS (standalone/bare-metal)
- Memory management (ARC)
- Optimization (size)
- Include paths
- Linker flags

Makefile overrides these with explicit flags for reliability across systems.

### Build Artifacts

All build outputs go to `build/` directory:
```
build/
├── .nimcache/          # Nim compilation cache (C++ files)
├── TARGET.elf          # Executable with debug symbols
├── TARGET.bin          # Binary for flashing
└── TARGET.map          # Linker map file
```

Clean organization prevents clutter in source directory.

### Upload Methods

**DFU (USB):**
```bash
make program-dfu
```
- No extra hardware needed
- Daisy must be in bootloader mode
- Common method for hobbyists

**ST-Link:**
```bash
make program-stlink
```
- Requires ST-Link programmer
- Professional debugging capability
- Direct SWD programming

---

## Testing Strategy

### Test Categories

**1. Compilation Tests**
- All examples must compile without errors
- Script: `test_all_clean.sh`
- Runs: Before each release
- Coverage: All 14 examples

**2. Hardware Tests**
- Examples run on actual hardware
- Manual verification of functionality
- Status: Basic examples tested

**3. Regression Tests**
- Previous examples still work after changes
- Automated via test script

### Current Test Coverage

```
examples/test_all_clean.sh results:
  ✓ 14/14 examples compile
  ✓ Binary sizes reasonable (64-200KB)
  ✓ No compilation warnings (expected)
```

### Areas Needing More Testing

- **USB functionality** - Needs real device testing
- **SD card operations** - Needs card inserted
- **SDRAM** - Needs verification of large buffers
- **Edge cases** - Error conditions, timeouts
- **Performance** - Latency measurements

---

## Contributing

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for detailed guidelines.

### Quick Contribution Guide

**1. Pick a Feature**
- Check "What's Missing" section above
- Pick something at your skill level
- Comment on GitHub issue or create new one

**2. Understand the Pattern**
- Look at existing wrappers (e.g., `libdaisy_i2c.nim`)
- Follow the same structure
- Use compile-time macros for includes

**3. Implement**
```nim
# 1. Add types
type
  MyPeripheral* {.importcpp.} = object

# 2. Add procedures
proc init*(this: var MyPeripheral) {.importcpp.}

# 3. Add macro for includes
emitMyPeripheralIncludes()
```

**4. Create Example**
- Add `my_peripheral_clean.nim` to examples/
- Demonstrate basic usage
- Test on hardware if possible

**5. Document**
- Add comments to wrapper code
- Update API_REFERENCE.md
- Add example to EXAMPLES.md

**6. Submit PR**
- Ensure all examples still compile
- Include test results
- Describe changes clearly

### High-Value Contributions

These would have immediate impact:

**1. ADC Wrapper** (High Priority)
- Wrap `per/adc.h`
- Multi-channel support
- Example reading CV inputs

**2. PWM Wrapper** (Medium Priority)
- Wrap `per/pwm.h`
- Duty cycle control
- Example for LED dimming

**3. OLED Display Driver** (High Impact)
- Wrap `dev/oled_ssd130x.h`
- Basic graphics functions
- Example displaying text

**4. WavPlayer** (High Impact)
- Wrap `util/wavplayer.h`
- Audio file playback
- Example playing WAV from SD

**5. More Boards** (Community Value)
- Daisy Patch wrapper
- Daisy Pod wrapper
- Pin mapping utilities

### Code Style Guidelines

**Naming Conventions:**
```nim
# Types: PascalCase
type DaisySeed* = object

# Procedures: camelCase
proc setLed*(this: var DaisySeed, state: bool)

# Constants: UPPER_SNAKE_CASE or PascalCase enums
const SAMPLE_RATE = 48000
type PinMode = enum
  INPUT, OUTPUT
```

**Module Structure:**
```nim
# 1. Imports
import libdaisy_macros

# 2. Type definitions
type MyType* = object

# 3. Constants
const MY_CONST* = 42

# 4. Macro calls
emitMyIncludes()

# 5. Procedures
proc myProc*() = discard
```

**Documentation:**
```nim
## Module description at top

proc importantFunc*(param: int): bool =
  ## Brief description
  ## 
  ## Detailed explanation if needed.
  ## 
  ## **Parameters:**
  ## - `param` - What it means
  ## 
  ## **Returns:** What it returns
  ## 
  ## **Example:**
  ## ```nim
  ## let result = importantFunc(42)
  ## ```
  result = true
```

---

## Future Roadmap

### Version 0.2.0 (Next Release)
- ✅ ADC wrapper with examples
- ✅ PWM wrapper with examples
- ✅ OLED display driver (SSD1306)
- ✅ More comprehensive examples
- ✅ Improved documentation

### Version 0.3.0
- ✅ DAC wrapper
- ✅ WavPlayer/WavWriter utilities
- ✅ Daisy Patch board support
- ✅ Performance optimizations

### Version 0.4.0
- ✅ More device drivers (IMU, codecs)
- ✅ Additional board support
- ✅ UI/Menu framework wrapper

### Version 1.0.0 (Stable)
- ✅ All core peripherals wrapped
- ✅ Major boards supported
- ✅ Comprehensive test suite
- ✅ Production-ready API
- ✅ Complete documentation

### Long Term
- Higher-level abstractions (DSP utilities)
- Nim-native alternatives to C++ utilities
- Performance benchmarks
- Community examples library
- Integration with Nim package ecosystem

---

## Conclusion

The libdaisy_nim wrapper provides a solid foundation for Nim development on Daisy Seed hardware. The current implementation covers core functionality with a clean, type-safe API. Significant features remain to be wrapped, providing excellent opportunities for community contribution.

The compile-time macro system for automatic include generation makes the wrapper maintainable and user-friendly. The Makefile-based build system is familiar to embedded developers and reliable across platforms.

With your help, we can expand coverage of libDaisy features and make Nim a first-class language for embedded audio development!

---

**Questions?** Open a GitHub issue or start a discussion!  
**Want to help?** See [CONTRIBUTING.md](CONTRIBUTING.md)!  
**Ready to build?** Check out [EXAMPLES.md](EXAMPLES.md)!
