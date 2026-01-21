# Changelog

All notable changes to libdaisy_nim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8.0] - 2026-01-21

### Added

#### Sensor Module Support

- **ICM20948 9-Axis IMU Module** (`src/dev/icm20948.nim`) - Motion and orientation sensor
  - 3-axis gyroscope with configurable range (250-2000 dps)
  - 3-axis accelerometer with configurable range (2-16g)
  - 3-axis magnetometer (AK09916) with 16-bit resolution
  - Temperature sensor
  - I2C and SPI transport support
  - Configurable low-pass filters and sample rate dividers
  - Methods: `init()`, `read()`, `setupMag()`, `readMag()`
  - **Note**: Requires libDaisy patch for magnetometer functionality

- **APDS9960 Gesture/Light Sensor Module** (`src/dev/apds9960.nim`) - Multi-function proximity sensor
  - Gesture recognition (up/down/left/right/near/far)
  - Proximity detection (0-255 range)
  - RGB color sensing (16-bit per channel)
  - Ambient light detection
  - I2C interface only
  - Configurable gesture sensitivity and thresholds
  - Methods: `init()`, `enableGesture()`, `readGesture()`, `readProximity()`, `readColor()`

- **DPS310 Barometric Pressure Sensor Module** (`src/dev/dps310.nim`) - Precision altimeter
  - Pressure measurement (260-1260 hPa)
  - Temperature measurement
  - Altitude calculation from pressure
  - I2C and SPI transport support
  - Configurable oversampling and sample rate
  - Methods: `init()`, `startContinuous()`, `getData()`, `getTemperatureC()`, `getAltitude()`

- **TLV493D 3D Magnetic Sensor Module** (`src/dev/tlv493d.nim`) - Triaxial magnetic field sensor
  - 3-axis magnetic field measurement
  - 12-bit resolution per axis
  - I2C interface only
  - Low power mode support
  - Temperature measurement
  - Methods: `init()`, `result()` (returns x, y, z in mT)

- **MPR121 Capacitive Touch Sensor Module** (`src/dev/mpr121.nim`) - 12-channel touch controller
  - 12 independent touch/release channels
  - Configurable touch/release thresholds per channel
  - Configurable debounce settings
  - I2C interface only
  - Methods: `init()`, `touched()` (returns 12-bit bitmask)

- **NeoTrellis 4x4 RGB Button Pad Module** (`src/dev/neotrellis.nim`) - Interactive RGB LED matrix
  - 16 mechanical key switches with RGB LEDs
  - Individually addressable RGB LEDs (Adafruit seesaw)
  - Button state tracking for all 16 keys
  - I2C interface only
  - Methods: `init()`, `setPixelColor()`, `show()`, `readButtons()`

#### New Examples

- `imu_demo.nim` - ICM20948 motion-controlled audio effects
  - Demonstrates 9-axis motion tracking
  - Accelerometer controls audio volume
  - Gyroscope controls audio panning
  - Magnetometer visualized via LEDs
  - Serial output for all sensor readings
  - Temperature monitoring
  
- `gesture_control.nim` - APDS9960 gesture-based audio manipulation
  - Swipe gestures control audio effects
  - Proximity detection adjusts parameters
  - RGB color sensing for visual feedback
  - LED indicators for gesture recognition
  - Serial output for debugging

- `environmental.nim` - DPS310 + TLV493D environmental monitoring
  - Real-time pressure and altitude display
  - Temperature monitoring from DPS310
  - 3-axis magnetic field visualization
  - Dual-sensor I2C demonstration
  - Serial output every 500ms

- `touch_sequencer.nim` - MPR121 + NeoTrellis step sequencer
  - 16-step audio sequencer
  - MPR121 capacitive touch for step programming
  - NeoTrellis RGB LEDs show active steps
  - Real-time playback control
  - Visual feedback for touch events

### Changed

- **Module organization**: Sensor modules added to `src/dev/` subdirectory
- **Macro system**: Added 6 sensor modules to `useDaisyModules()` macro
- **I2C/SPI dependencies**: Sensor modules import transport layers directly

### Fixed

- **ICM20948 upstream bug**: Created patch for libDaisy ReadExternalRegister bug
  - Bug location: `libDaisy/src/dev/icm20948.h:686`
  - Missing 4th argument to `AuxillaryRegisterTransaction()`
  - Prevents magnetometer initialization without patch
  - Patch system documented in `patches/README.md`
  - Apply with `./apply_patches.sh` script

### Technical

- Added to `libdaisy_macros.nim`:
  - `icm20948Typedefs` (8 type aliases)
  - `apds9960Typedefs` (5 type aliases)
  - `dps310Typedefs` (6 type aliases)
  - `tlv493dTypedefs` (2 type aliases)
  - `mpr121Typedefs` (1 type alias)
  - `neotrellisTypedefs` (4 type aliases)
- Module header support for all 6 sensors in `getModuleHeaders()`
- Created patch management system:
  - `patches/icm20948_fix.patch` - Single-line fix for magnetometer
  - `patches/README.md` - Comprehensive patch documentation
  - `apply_patches.sh` - Automated patch application script

### Documentation

- Updated `docs/EXAMPLES.md` with 4 sensor examples
- Updated `docs/API_REFERENCE.md` with 6 sensor module APIs
- Updated `docs/ROADMAP.md` to mark v0.8.0 complete
- Updated `README.md` with patch requirement notes
- All sensor examples marked as "Untested - Requires hardware"

### Statistics

- **Total modules**: 52 (46 → 52)
  - Core: 1
  - Peripherals: 11
  - Controls: 1
  - Audio: 4
  - Data structures: 4
  - Utilities: 9
  - Displays: 3
  - Codecs: 3
  - Sensors: 6 (new)
  - Power: 1
  - Storage: 9
- **Total examples**: 46 (42 → 46)
- **Coverage**: ~72% of libDaisy features
- **Lines added**: ~2930 (sensor modules + examples + docs + patches)

### Breaking Changes

None. All changes are backwards compatible.

### Known Issues

- ICM20948 magnetometer requires applying patch to libDaisy (see patches/README.md)
- All sensor examples untested on actual hardware (compilation verified only)

## [0.7.0] - 2026-01-21

### Added

#### Audio Codec Support

- **AK4556 Codec Module** (`src/dev/codec_ak4556.nim`) - Simple codec for Daisy Seed 1.0
  - Reset pin initialization only
  - No I2C configuration required
  - 24-bit stereo ADC/DAC
  - `init()`, `deInit()` methods

- **WM8731 Codec Module** (`src/dev/codec_wm8731.nim`) - I2C codec for Daisy Seed 1.1
  - I2C control interface
  - Configurable audio format (I2S, LJ, RJ, DSP)
  - Configurable word length (16/20/24/32-bit)
  - Volume control and mute support
  - Default: MCU master, 24-bit, MSB LJ format
  
- **PCM3060 Codec Module** (`src/dev/codec_pcm3060.nim`) - High-performance codec for Daisy Seed 2.0
  - I2C control interface
  - Auto-configures to 24-bit LJ format
  - Simplified initialization

#### Display Support

- **LCD HD44780 Module** (`src/dev/lcd_hd44780.nim`) - Character LCD driver
  - 16x2 and 20x4 display support
  - 4-bit data mode (6 GPIO pins)
  - Configurable cursor visibility and blink
  - Methods: `init()`, `print()`, `printInt()`, `setCursor()`, `clear()`
  
- **OLED Fonts Module** (`src/util/oled_fonts.nim`) - Bitmap fonts for OLED displays
  - 8 font sizes: 4x6, 5x8, 6x8, 7x10, 11x18, 12x16, 16x26
  - Monospaced fonts
  - ASCII printable characters (32-126)
  - Stored in flash (no RAM overhead)
  - Compatible with SSD1306 OLED displays

#### New Examples

- `codec_comparison.nim` - Multi-codec initialization demo
  - Auto-detects Daisy Seed hardware version (1.0/1.1/2.0)
  - Initializes appropriate codec (AK4556/WM8731/PCM3060)
  - LED blink indicates successful initialization
  - Console output shows detected version
  
- `lcd_menu.nim` - Character LCD menu system
  - 3-parameter menu (Volume %, Frequency Hz, Waveform)
  - Rotary encoder navigation
  - Real-time display updates
  - Demonstrates LCD text formatting

### Changed

- **Module organization**: Audio codecs now in `src/dev/` subdirectory
- **I2C dependency**: Codec modules now import `libdaisy_i2c` directly for type safety
- **Macro system**: Added codec and LCD module support to `useDaisyModules()` macro

### Fixed

- **I2CHandle type visibility**: Codec modules now properly import `libdaisy_i2c` for `I2CHandle` type
- **Type imports**: Removed reliance on `useDaisyModules()` for cross-module types

### Technical

- Added to `libdaisy_macros.nim`:
  - `codec_ak4556Typedefs` (empty - no types exported)
  - `codec_wm8731Typedefs` (4 type aliases)
  - `codec_pcm3060Typedefs` (1 type alias)
  - `lcd_hd44780Typedefs` (1 type alias)
  - `oled_fontsTypedefs` (1 type alias)
- Module header support for all new modules in `getModuleHeaders()`
- Comprehensive API documentation in docs/API_REFERENCE.md
- Hardware setup guides in docs/EXAMPLES.md

### Documentation

- Added agent rule for documenting examples in `docs/AGENTS.md`
- Added codec and LCD examples to `docs/EXAMPLES.md` testing matrix
- Added hardware setup sections for LCD and codec examples
- Updated `docs/API_REFERENCE.md` with v0.7.0 modules
- Updated example count: 42 examples (40 → 42)

### Statistics

- **Total modules**: 46 (41 → 46)
  - Core: 1
  - Peripherals: 11
  - Controls: 1
  - Audio: 4
  - Data structures: 4
  - Utilities: 9
  - System: 4
  - Board-specific: 1
  - **Audio codecs: 3 (NEW)**
  - **Displays: 2 (NEW)**
  - Macros: 1
  - USB/MIDI/Serial: 3
  - SD card: 1
  - Timer: 1
  
- **Examples**: 42
- **Test suite**: All 42 examples pass compilation

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
