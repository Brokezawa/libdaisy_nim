# Changelog

All notable changes to libdaisy_nim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2026-01-22

### Added

#### File I/O & Storage Modules (6 new modules)

- **WAV Parser Module** (`ui/wavparser.nim`) - WAV file format parsing and validation
  - Parse WAV file headers from SD card
  - Extract format information (sample rate, bit depth, channels)
  - Validate file format and detect corrupt headers
  - Error handling for unsupported formats
  - Integration with SDMMC file system

- **WAV Player Module** (`ui/wavplayer.nim`) - Streaming WAV playback with looping support
  - Stream WAV files from SD card to audio output
  - Buffered playback with DMA-safe operations
  - Playback control: play, pause, stop
  - Looping support (single file or playlist)
  - Seek functionality
  - Multi-file playlist support
  - Integration with audio callback system

- **WAV Writer Module** (`ui/wavwriter.nim`) - Real-time WAV recording to SD card
  - Record audio input to WAV files on SD card
  - Real-time buffering for continuous recording
  - Start/stop recording control
  - File management (naming, overwrite protection)
  - Configurable sample rate and bit depth
  - Integration with audio callback system

- **Wavetable Loader Module** (`ui/wavetable_loader.nim`) - Multi-bank wavetable loading from SD
  - Load wavetable banks from SD card
  - Multiple format support (raw binary, WAV)
  - Single-cycle waveform extraction
  - Wavetable bank management
  - Memory-efficient loading strategies
  - Synthesis integration helpers

- **QSPI Flash Module** (`per/qspi.nim`) - QSPI flash memory operations
  - Access external QSPI flash (8MB on Daisy Seed)
  - Memory-mapped read mode
  - Sector erase operations (4KB, 32KB, 64KB)
  - Page write operations (256 bytes)
  - Read operations (arbitrary size)
  - Flash information queries
  - Wavetable/sample storage alternative to SD card

- **Switch Module** (`hid/switch.nim`) - Debounced button/switch with edge detection
  - Debounced button/switch input handling
  - Rising edge detection (`risingEdge()`)
  - Falling edge detection (`fallingEdge()`)
  - State tracking (`pressed()`, `released()`)
  - Time-held measurement (`timeHeldMs()`)
  - Configurable debounce timing
  - Integration with controls system

#### New Examples (6 examples)

- **wav_player.nim** - WAV file playback demonstration
  - Load and play WAV files from SD card
  - Track navigation (next/previous)
  - Simple transport controls
  - OLED display showing file information
  - Button-based control interface

- **wav_recorder.nim** - Real-time audio recording
  - Record audio input to WAV file on SD card
  - Start/stop recording with button
  - LED recording indicator
  - File naming with timestamps
  - OLED display showing recording status

- **sampler.nim** - Multi-sample triggering and playback
  - Load multiple samples from SD card
  - Trigger samples with gates/buttons
  - Pitch shifting support
  - Volume control per sample
  - Sample browser with encoder
  - Complete sampler implementation

- **looper.nim** - Audio loop recording with overdub
  - Record loops in real-time
  - Overdub functionality
  - Loop playback with sync
  - Save/load loops to SD card
  - Multi-layer loop recording
  - Live looper pedal implementation

- **wavetable_synth.nim** - Wavetable synthesis
  - Load wavetable banks from SD card
  - Wavetable position CV control
  - Multiple oscillators
  - Classic wavetable synthesis
  - Bank switching support

- **qspi_storage.nim** - QSPI flash memory demonstration
  - Store and retrieve samples in QSPI flash
  - Faster access than SD card
  - Persistent sample library
  - Erase/write/read operations
  - Performance comparison with SD card

### Changed

#### Major Source Code Reorganization

Reorganized all 41 source modules into subdirectories matching libDaisy's C++ structure for better organization and clarity:

**New Directory Structure:**
```
src/
├── per/          # Peripherals (9 modules)
├── hid/          # Human Interface Devices (8 modules)
├── dev/          # Device Drivers (2 modules)
├── sys/          # System Modules (2 modules)
├── util/         # Utility Data Structures (8 modules)
└── ui/           # UI and File I/O (5 modules)
```

**Module Mapping:**
- `libdaisy_adc.nim` → `per/adc.nim`
- `libdaisy_dac.nim` → `per/dac.nim`
- `libdaisy_i2c.nim` → `per/i2c.nim`
- `libdaisy_spi.nim` → `per/spi.nim`
- `libdaisy_serial.nim` → `per/uart.nim` *(renamed)*
- `libdaisy_pwm.nim` → `per/pwm.nim`
- `libdaisy_qspi.nim` → `per/qspi.nim`
- `libdaisy_rng.nim` → `per/rng.nim`
- `libdaisy_timer.nim` → `per/timer.nim`
- `libdaisy_controls.nim` → `hid/controls.nim`
- `libdaisy_gatein.nim` → `hid/gatein.nim`
- `libdaisy_led.nim` → `hid/led.nim`
- `libdaisy_midi.nim` → `hid/midi.nim`
- `libdaisy_parameter.nim` → `hid/parameter.nim`
- `libdaisy_rgbled.nim` → `hid/rgbled.nim`
- `libdaisy_switch.nim` → `hid/switch.nim`
- `libdaisy_switch3.nim` → `hid/switch3.nim`
- `libdaisy_oled.nim` → `dev/oled.nim`
- `libdaisy_sdram.nim` → `dev/sdram.nim`
- `libdaisy_sdmmc.nim` → `sys/sdmmc.nim`
- `libdaisy_usb.nim` → `sys/usb.nim`
- `libdaisy_color.nim` → `util/color.nim`
- `libdaisy_cpuload.nim` → `util/cpuload.nim`
- `libdaisy_fifo.nim` → `util/fifo.nim`
- `libdaisy_fixedstr.nim` → `util/fixedstr.nim`
- `libdaisy_mapped_value.nim` → `util/mapped_value.nim`
- `libdaisy_ringbuffer.nim` → `util/ringbuffer.nim`
- `libdaisy_stack.nim` → `util/stack.nim`
- `libdaisy_uniqueid.nim` → `util/uniqueid.nim`
- `libdaisy_wavformat.nim` → `ui/wavformat.nim`
- `libdaisy_wavparser.nim` → `ui/wavparser.nim`
- `libdaisy_wavplayer.nim` → `ui/wavplayer.nim`
- `libdaisy_wavwriter.nim` → `ui/wavwriter.nim`
- `libdaisy_wavetable_loader.nim` → `ui/wavetable_loader.nim`

**BREAKING CHANGE - Import Path Updates:**

All import paths have been updated throughout the project:

```nim
# Old import style (v0.5.0 and earlier):
import ../src/libdaisy_adc
import ../src/libdaisy_i2c

# New import style (v0.6.0+):
import ../src/per/adc
import ../src/per/i2c
```

**Name Conflict Resolution:**

Some modules now use qualified imports to avoid variable name conflicts:

```nim
# SDMMC module imported with alias to avoid 'sdmmc' variable conflict
import ../src/sys/sdmmc as sd
var sd_card: sd.SDMMCHandler

# USB module uses qualified import
import ../src/sys/usb as usb_module
var usb: usb_module.UsbHandle

# DAC module uses qualified import
import ../src/per/dac as dac_module
var dac: dac_module.DacHandle

# Patch module uses qualified import
import ../src/patch as patch_module
var patch: patch_module.DaisyPatch
```

**File History Preservation:**

All file moves were performed using `git mv` to preserve complete file history and attribution.

#### Module Improvements

- **libdaisy_macros.nim**:
  - Added `emitSwitchIncludes()` macro for Switch module
  - Added `emitSdmmcTypedefs()` macro for SDMMC type definitions

- **All examples (40 files)**:
  - Updated import paths to new directory structure
  - Applied qualified import patterns where needed
  - All examples compile successfully after reorganization

### Fixed

#### Compilation Issues

- **SDMMC Init Method**: Fixed importcpp pattern from `"#.Init(@)"` to `"#.Init(#)"` for proper argument passing
- **FatFS Unicode Support**: Added ccsbcs.c to Makefile compilation for proper Unicode filename handling
- **WavPlayer Template Result Types**: Resolved C++ template Result type ambiguity using emit block with static_cast workaround
- **Import Keyword Conflict**: Used backticks for `\`import\`` to avoid Nim keyword conflict in SDMMC wrapper
- **ADC Type Ambiguity**: Resolved type conflicts using qualified imports in examples

### Technical

- All 40 examples compile successfully (36 main examples + 4 test variants)
- Compilation test pass rate: 100% (`./test_all.sh`)
- Source reorganization completed with git history preserved
- Module count increased from 35 to 41 modules
- Example count increased from 30 to 36 main examples

### Performance

- File I/O operations use buffered DMA transfers for efficiency
- QSPI flash access provides faster sample loading than SD card
- Zero heap allocation in all audio-rate code paths
- Optimized wavetable loading for minimal startup time

## [0.5.0] - 2026-01-22

### Added

#### New Pure Nim Data Structures (Zero Heap Allocation)

- **FIFO Module** (`libdaisy_fifo.nim`) - Lock-free FIFO queue (SPSC)
  - Fixed capacity with compile-time sizing
  - Lock-free single producer/single consumer
  - Audio-rate safe operations
  - `push()`, `pop()`, `available()`, `writable()`, `reset()`
  
- **Stack Module** (`libdaisy_stack.nim`) - Fixed-capacity stack (LIFO)
  - Zero heap allocation
  - Compile-time capacity specification
  - `push()`, `pop()`, `peek()`, `isFull()`, `isEmpty()`
  
- **RingBuffer Module** (`libdaisy_ringbuffer.nim`) - Circular buffer for audio streaming
  - Lock-free SPSC implementation
  - Optimized for audio sample buffering
  - `write()`, `read()`, `available()`, `writable()`, `reset()`
  
- **FixedStr Module** (`libdaisy_fixedstr.nim`) - Stack-allocated string for displays
  - No heap allocation for embedded displays
  - String manipulation and concatenation
  - Printf-style formatting
  - Automatic null termination

#### New Wrapped Utilities

- **UniqueId Module** (`libdaisy_uniqueid.nim`) - STM32 96-bit unique device identifier
  - Read STM32 factory-programmed unique ID
  - Access as 3x 32-bit words or 12-byte array
  - Custom hex formatting (no heap allocation)
  - Device serialization support
  
- **CpuLoad Module** (`libdaisy_cpuload.nim`) - Real-time CPU load monitoring
  - Track audio callback CPU usage percentage
  - Average and peak load measurement
  - Configurable smoothing filter
  - Performance optimization detection
  
- **Parameter Module** (`libdaisy_parameter.nim`) - Parameter mapping with curves
  - Linear, exponential, logarithmic, and cubic curves
  - Input value mapping (knobs/CV to parameters)
  - Min/max range specification
  - Curve bias control

#### New Pure Nim Utilities

- **MappedValue Module** (`libdaisy_mapped_value.nim`) - Value mapping, quantization, normalization
  - Bidirectional range mapping
  - Quantization to discrete steps
  - Unit normalization (0.0-1.0)
  - Integer and float support

#### New Examples

- `data_structures.nim` - FIFO/Stack/RingBuffer/FixedStr demonstration
  - Audio delay effect using RingBuffer
  - FIFO/Stack basic operations
  - FixedStr display formatting
  
- `control_mapping.nim` - Parameter curves and value mapping
  - Exponential frequency control
  - Linear/log/cubic parameter curves
  - Value quantization for scales
  
- `system_info.nim` - UniqueId and CpuLoad monitoring
  - Device ID reading and display
  - Real-time CPU usage monitoring
  - Performance optimization tips

### Technical

- All data structures use compile-time fixed capacity (no heap allocation)
- Added 4 new emit macros to `libdaisy_macros.nim`:
  - `emitUniqueIdIncludes()`
  - `emitCpuLoadIncludes()`
  - `emitParameterIncludes()`
  - `emitMappedValueIncludes()`
- All modules are audio-rate safe
- Comprehensive API documentation in docs/API_REFERENCE.md

### Performance

- Zero heap allocation in all new data structures
- Lock-free implementations for FIFO and RingBuffer
- Optimized for embedded/real-time audio use
- Fixed-capacity types prevent runtime allocation
- Custom hex formatting avoids standard library overhead

## [0.4.0] - 2026-01-22

### Added

#### New Modules
- **RNG Module** (`libdaisy_rng.nim`) - Hardware True Random Number Generator
  - `randomGetValue()` - Get random 32-bit unsigned integer
  - `randomGetFloat()` - Get random float (0.0 to 1.0)
  - `randomIsReady()` - Check if hardware RNG is ready
  
- **Timer Module** (`libdaisy_timer.nim`) - Hardware timer peripherals (TIM2-TIM5)
  - Free-running counter support (32-bit and 16-bit)
  - Precise tick measurement
  - Time conversion (ms/us)
  - Period-based callbacks (interrupt support)
  - Multiple timer coordination
  
- **Color Module** (`libdaisy_color.nim`) - RGB color utilities
  - Preset colors (RED, GREEN, BLUE, WHITE, PURPLE, CYAN, GOLD, OFF)
  - RGB creation and manipulation
  - Color blending with `colorBlend()`
  - Arithmetic operators (`*` for scaling, `+` for addition)
  - 8-bit and float getters/setters
  
- **GateIn Module** (`libdaisy_gatein.nim`) - Gate/trigger input handler
  - Rising edge detection with `trig()`
  - Current state reading with `state()`
  - Inversion support for BJT input circuits
  - Eurorack-compatible gate input handling
  
- **LED Module** (`libdaisy_led.nim`) - Single LED control
  - Software PWM brightness control
  - Automatic gamma correction (cubic curve)
  - Configurable update rate
  - Inversion support for active-low LEDs
  
- **RgbLed Module** (`libdaisy_rgbled.nim`) - RGB LED control
  - 3-channel LED control (R, G, B pins)
  - Integration with Color module
  - Per-channel and combined color setting
  - Software PWM with gamma correction
  
- **Switch3 Module** (`libdaisy_switch3.nim`) - 3-position switch handler
  - Three positions: CENTER, UP/LEFT, DOWN/RIGHT
  - Simple 2-pin configuration
  - Direct position reading

#### New Examples
- `peripherals_basic.nim` - RNG + Timer + LED demonstration
  - Random LED blink patterns using hardware TRNG
  - Timer-based delay measurements
  - LED PWM brightness control
  
- `eurorack_basics.nim` - GateIn + Switch3 for eurorack-style I/O
  - Gate trigger detection
  - Gate state monitoring
  - 3-position switch reading
  - Typical eurorack input handling patterns
  
- `led_control.nim` - RGB LED + Color utilities
  - Primary and mixed color display
  - Color blending demonstration
  - Rainbow cycling effect using HSV-like conversion
  
- `timer_advanced.nim` - Multiple timers with callbacks
  - Free-running counter for measurements
  - Periodic interrupt callbacks
  - Multiple timer coordination
  - Callback statistics tracking

### Changed

#### Module Improvements
- **libdaisy_led.nim**, **libdaisy_rgbled.nim**, **libdaisy_gatein.nim**, **libdaisy_switch3.nim**:
  - Added `import libdaisy` for Pin type support
- **libdaisy_rgbled.nim**:
  - Added `import libdaisy_color` for Color type integration
- **libdaisy_macros.nim**:
  - Added 7 new emit macros: `emitRNGIncludes`, `emitTimerIncludes`, `emitColorIncludes`, `emitGateInIncludes`, `emitLedIncludes`, `emitRgbLedIncludes`, `emitSwitch3Includes`

### Documentation
- Updated docs/API_REFERENCE.md with 7 new module sections
- Updated docs/CHANGELOG.md with v0.4.0 entry
- Organized all documentation into docs/ directory
- Added docs/ROADMAP.md with complete v1.0.0 roadmap (13 milestones)
- Added docs/HARDWARE_TESTING.md - Community hardware testing guide
- Added docs/TESTING_CHECKLIST.md - Fillable hardware testing checklist
- Redesigned docs/EXAMPLES.md as comprehensive hardware testing reference

## [0.3.0] - 2026-01-21

### Added

#### New Modules
- **DAC Module** (`libdaisy_dac.nim`) - Digital to Analog Converter wrapper
  - Polling mode for single value writes
  - DMA mode for buffered output
  - Dual channel support (PA4, PA5)
  - 8-bit and 12-bit resolution
  - Configurable output buffer
  
- **WAV Format Module** (`libdaisy_wavformat.nim`) - WAV file format utilities
  - WAV header structure definitions
  - Format constants and codes
  - Support for PCM, IEEE float, A-law, μ-law formats
  - Ready for integration with SDMMC audio file I/O

- **Daisy Patch Board Module** (`libdaisy_patch.nim`) - Complete Patch board support
  - Full board initialization
  - 4 CV/Knob controls with gate inputs
  - OLED display (128x64 SPI)
  - Rotary encoder
  - MIDI I/O
  - Audio I/O with AK4556 codec
  - Helper functions for control processing

#### New Examples
- `dac_simple.nim` - DAC sine wave output in polling mode
- `patch_simple.nim` - Daisy Patch audio passthrough with controls

### Documentation
- Updated TECHNICAL_REPORT.md with v0.3.0 completion status
- Updated CONTRIBUTING.md with completed items

## [0.2.0] - 2025-10-29

### Added

#### New Modules
- **ADC Module** (`libdaisy_adc.nim`) - Complete analog input wrapper
  - Multi-channel support (up to 8 single-ended channels)
  - Multiplexed input support (4 channels × 8 mux = 32 inputs)
  - Configurable oversampling ratios
  - DMA-based continuous conversion
  - Float conversion API (0.0-1.0 normalized values)
  - High-level Nim-friendly API with `createAdc()` helpers

- **PWM Module** (`libdaisy_pwm.nim`) - Pulse width modulation wrapper
  - Support for all timers (TIM1, TIM2, TIM3, TIM4, TIM5, TIM8)
  - 4 independent channels per timer
  - Configurable frequency via prescaler and period
  - Float-based duty cycle API (0.0-1.0)
  - Raw value API for precise control
  - LED dimming and servo control support

- **OLED Display Module** (`libdaisy_oled.nim`) - SSD1306 OLED driver
  - Generic template system for type-safe configuration
  - Multiple screen sizes (128x64, 128x32, 96x16)
  - I2C transport support
  - SPI transport support (4-wire)
  - Complete graphics primitives (pixels, lines, rectangles, circles)
  - Text rendering support
  - Efficient buffer management

#### New Examples
- `adc_simple.nim` - Basic single-channel ADC reading
- `adc_multichannel.nim` - Multiple ADC channels
- `adc_multiplexed.nim` - Multiplexed analog inputs
- `adc_config.nim` - Custom ADC configuration
- `analog_knobs.nim` - Real-world analog control example
- `pwm_led.nim` - LED brightness control with PWM
- `pwm_rgb.nim` - RGB LED color mixing
- `pwm_servo.nim` - Servo motor control
- `oled_basic.nim` - Basic OLED text display
- `oled_graphics.nim` - Drawing shapes and graphics
- `oled_spi.nim` - SPI-based OLED display
- `oled_visualizer.nim` - Audio level visualizer

### Changed

#### Performance Improvements
- Added `inline` pragmas to hot-path functions across all modules:
  - OLED: `Width()`, `Height()`, `DrawPixel()`, constructors
  - ADC: All getter functions (`Get()`, `GetFloat()`, etc.)
  - PWM: Channel accessors, setters, constructors
  - I2C: `GetConfig()`, blocking I/O operations
  - SPI: `GetConfig()`, blocking I/O operations
- Improved compile-time code generation efficiency

#### Documentation
- Updated README.md with v0.2.0 features
- Updated TECHNICAL_REPORT.md with architecture details
- Expanded API_REFERENCE.md with comprehensive ADC, PWM, and OLED sections
- Added detailed examples and usage patterns
- Updated roadmap reflecting v0.2.0 completion

#### Code Organization
- Implemented generic template system for OLED displays
- Removed `{.emit.}` pragmas in favor of pure `importcpp` where possible
- Improved type safety through compile-time generics
- Better separation of low-level and high-level APIs

### Fixed
- Resolved C++ template instantiation issues in OLED driver
- Fixed generic type parameter passing to C++ templates
- Improved error messages for configuration mistakes
- Better handling of default constructors

### Technical Details

#### ADC Implementation
The ADC wrapper provides both low-level C++ interop and high-level Nim-friendly APIs:
- Direct mapping to libDaisy's `AdcHandle` and `AdcChannelConfig`
- Zero-overhead wrappers using `importcpp`
- Compile-time channel configuration
- Runtime performance equivalent to native C++

#### PWM Implementation
PWM support includes:
- Full timer configuration with prescaler and period
- Per-channel duty cycle control
- Both normalized float (0.0-1.0) and raw value APIs
- Support for all 6 hardware timers with 4 channels each

#### OLED Implementation
The OLED driver uses Nim's generic system to provide:
- Type-safe screen size selection at compile time
- Transport-agnostic interface (I2C or SPI)
- Efficient C++ template instantiation
- Zero-cost abstractions over libDaisy's driver

## [0.1.0] - 2025-10-20

### Added
- Initial release
- Core DaisySeed hardware support
- Audio I/O with callback system
- GPIO with all standard modes
- I2C communication (4 buses)
- SPI communication (6 buses)
- UART serial (6 ports)
- USB Device CDC
- USB MIDI
- SD card with FatFS
- External SDRAM
- MIDI I/O (UART and USB)
- Control abstractions (switches, encoders)
- Compile-time macro system for selective compilation
- 14 working examples
- Comprehensive documentation

[0.2.0]: https://github.com/Brokezawa/libdaisy_nim/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Brokezawa/libdaisy_nim/releases/tag/v0.1.0
