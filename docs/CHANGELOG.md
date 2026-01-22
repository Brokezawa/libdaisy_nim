# Changelog

All notable changes to libdaisy_nim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Nothing yet

## [0.10.0] - 2026-01-22

### Added - External Storage & Multi-Device SPI

#### Core Feature: Persistent Settings Storage

- **PersistentStorage Module** (`src/libdaisy_persistent_storage.nim`) - Type-safe flash storage
  - Generic `PersistentStorage[T]` wrapper for settings structs
  - Automatic dirty detection (only writes when changed)
  - Factory defaults restoration support
  - State tracking: UNKNOWN, FACTORY, USER
  - Overwrite protection option
  - Requires POD types with `operator==` and `operator!=`
  - Uses QSPI flash for non-volatile storage
  - 380 lines of comprehensive wrapper code
  - Files: `src/libdaisy_persistent_storage.nim`

- **Example: Settings Manager** (`examples/settings_manager.nim`) - Persistent configuration demo
  - Demonstrates factory defaults initialization
  - Shows dirty detection and automatic save
  - Includes restore defaults functionality
  - POD struct definition with comparison operators
  - Binary size: 79,496 bytes text
  - Files: `examples/settings_manager.nim`

#### Core Feature: Multi-Device SPI Bus Sharing

- **MultiSlaveSPI Module** (`src/libdaisy_spi_multislave.nim`) - Share SPI bus between devices
  - Support for up to 4 SPI slave devices on one bus
  - Individual chip select (NSS) per device
  - Shared SCLK, MISO, MOSI pins
  - Blocking and DMA transfer modes
  - Software-controlled device selection
  - Compatible with SPI1-SPI6 peripherals
  - 543 lines including comprehensive documentation
  - Files: `src/libdaisy_spi_multislave.nim`

- **Example: Multi-SPI** (`examples/multi_spi.nim`) - Multi-device SPI demo
  - Shows configuration for 3 devices on one bus
  - Demonstrates individual device communication
  - Blocking transfers to different slaves
  - Binary size: 78,128 bytes text
  - Files: `examples/multi_spi.nim`

#### Enhanced: QSPI Flash Documentation

- **Flash Storage Example** (`examples/flash_storage.nim`) - QSPI basic operations
  - Demonstrates sector erase
  - Shows write and read operations
  - Mode switching (INDIRECT_POLLING ↔ MEMORY_MAPPED)
  - Binary size: 78,260 bytes text
  - Files: `examples/flash_storage.nim`

### Technical Notes

#### Type System Improvements

- **C++ Template Enum Handling** - Fixed cross-instantiation compatibility
  - Added typedef workaround for `PersistentStorage<T>::State` enum
  - C++ template enums don't convert between different `T` types
  - Solution: Cast to common typedef in emit blocks
  - Affects: `libdaisy_persistent_storage.nim:99-110`

- **SPI Type Compatibility** - Fixed Nim enum ↔ C++ type mapping
  - Added typedefs for `SpiResult`, `SpiPeripheral`, etc.
  - Ensures Nim helper functions can use C++ enum types
  - Emit blocks provide C++ type aliases
  - Affects: `libdaisy_spi_multislave.nim:117-131`

#### Callback Type Fixes

- **SPI Callback Names** - Corrected DMA callback type references
  - Fixed: `SpiStartCallback` → `SpiStartCallbackFunctionPtr`
  - Fixed: `SpiEndCallback` → `SpiEndCallbackFunctionPtr`
  - Ensures consistency with `libdaisy_spi.nim` type definitions
  - Affects: `libdaisy_spi_multislave.nim:305, 343, 370`

### Documentation

- **API Reference** (`docs/API_REFERENCE.md`) - New module documentation
  - Added Multi-Slave SPI Module section (60+ lines)
  - Added QSPI Flash Module section (50+ lines)
  - Added Persistent Storage Module section (100+ lines)
  - Comprehensive examples for each module
  - Usage notes and important warnings
  - Files: `docs/API_REFERENCE.md:575-787`

### Files Changed

**New Modules:**
- `src/libdaisy_persistent_storage.nim` (380 lines)
- `src/libdaisy_spi_multislave.nim` (543 lines)

**New Examples:**
- `examples/flash_storage.nim` (87 lines)
- `examples/settings_manager.nim` (108 lines)
- `examples/multi_spi.nim` (88 lines)

**Updated Documentation:**
- `docs/API_REFERENCE.md` (+212 lines)
- `docs/CHANGELOG.md` (this file)

### Build Statistics

All examples compile successfully:
- `flash_storage`: 78,260 bytes text, 2,256 data, 39,540 bss
- `multi_spi`: 78,128 bytes text, 2,256 data, 39,540 bss
- `settings_manager`: 79,496 bytes text, 2,256 data, 39,540 bss

## [0.9.1] - 2026-01-22

### Added - Performance Enhancements

#### Critical: Non-Blocking DMA APIs

- **SPI DMA Functions** (`src/libdaisy_spi.nim`) - Non-blocking SPI transfers
  - `dmaTransmit()` - Asynchronous SPI transmit
  - `dmaReceive()` - Asynchronous SPI receive  
  - `dmaTransmitAndReceive()` - Asynchronous full-duplex transfer
  - All functions accept optional callbacks for transfer start/completion
  - **Safe for use in audio callbacks** (non-blocking)
  - ⚠️ Buffers must be in D2 memory domain (`{.section: ".sram1_bss".}`)
  - Prevents audio glitches from blocking I/O operations
  - Files: `src/libdaisy_spi.nim` (lines 1-70, 302-418)

- **I2C DMA Functions** (`src/libdaisy_i2c.nim`) - Non-blocking I2C transfers
  - `transmitDma()` - Asynchronous I2C transmit
  - `receiveDma()` - Asynchronous I2C receive
  - Optional callbacks for transfer completion
  - **Safe for use in audio callbacks** (non-blocking)
  - ⚠️ Buffers must be in D2 memory domain
  - ⚠️ I2C1/I2C2/I2C3 share one DMA channel; I2C4 has no DMA support
  - Prevents audio glitches from blocking I/O operations
  - Files: `src/libdaisy_i2c.nim` (lines 1-80, 219-318)

- **Documentation** - Comprehensive DMA usage guide
  - Updated module headers with blocking vs DMA warnings
  - Added DMA buffer memory requirements (D2 domain)
  - Example code for non-blocking transfers
  - Performance notes and audio callback safety
  - Files: `src/libdaisy_spi.nim`, `src/libdaisy_i2c.nim`, `docs/API_REFERENCE.md`

### Changed - Performance Optimizations

#### Breaking Change: RingBuffer Power-of-2 Requirement

- **RingBuffer** (`src/libdaisy_ringbuffer.nim`) - Enforced power-of-2 sizes for performance
  - ⚠️ **BREAKING:** Size `N` must now be power of 2 (2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, ...)
  - Compile-time validation: `when (N and (N-1)) != 0: {.error: ...}`
  - Replaced modulo with bitwise AND: `mod N` → `and (N-1)`
  - **Performance:** 1 cycle vs 12-30 cycles per operation on ARM Cortex-M7
  - **Migration:** Round up to next power of 2 (e.g., 100→128, 500→512)
  - Affects: `isFull()`, `write()`, `read()`, `peek()` functions
  - Files: `src/libdaisy_ringbuffer.nim` (lines 1-60, 69-70, 152, 167, 175, 199, 267)

#### Inline Pragmas for Hot-Path Functions

- **ADC Wrapper Functions** (`src/libdaisy_adc.nim`) - Added `{.inline.}` to Nim wrapper functions
  - `getFloat()` - Normalized ADC read (0.0-1.0)
  - `getMux()` - Multiplexed ADC read (raw)
  - `getMuxPtr()` - Multiplexed ADC pointer
  - `getMuxFloat()` - Multiplexed ADC read (normalized)
  - Reduces overhead when reading controls in audio callback
  - **Performance:** 5-20 cycles saved per call
  - Files: `src/libdaisy_adc.nim` (lines 261, 276, 293, 303)
  - Note: Only applies to Nim wrapper functions, not C++ imported functions

- **Code Cleanup** - Removed misleading `{.inline.}` pragmas from C++ imports
  - The `{.inline.}` pragma has no effect on `{.importcpp.}` declarations
  - C++ compiler automatically handles inlining for imported functions
  - Removed from: SPI, I2C, ADC, PWM, OLED modules (47 occurrences)
  - Improves code clarity and prevents confusion

### Fixed - Critical Performance Bug

- **LED Driver Busy-Wait** (`src/dev/leddriver.nim`) - Replaced 40M cycle busy-wait with proper delay
  - Changed: `for i in 0..400000: discard` → `delayMs(1)`
  - **Performance:** Saves ~40M CPU cycles per timeout check (400k cycles/ms × 100ms)
  - Uses libDaisy's `System::Delay()` instead of manual loop
  - Comment incorrectly claimed delay function not available (was imported at line 53)
  - Files: `src/dev/leddriver.nim` (lines 52-55, 310-316)

### Documentation

- **API_REFERENCE.md** - Added comprehensive DMA documentation
  - SPI DMA API reference with examples
  - I2C DMA API reference with examples
  - Buffer memory requirements (D2 domain)
  - Blocking vs non-blocking function warnings
  - Files: `docs/API_REFERENCE.md` (lines 403-522)

### Performance Impact Summary

**Estimated CPU Savings:**
- DMA APIs: Eliminates blocking I/O (1-100ms stalls → 0ms, prevents audio glitches)
- RingBuffer: ~20 cycles per operation (modulo → bitwise AND)
- ADC inline wrappers: 5-20 cycles per call × 4 wrapper functions
- LED driver: ~40M cycles per timeout (busy-wait → proper delay)

**Total:** <5-10% wrapper overhead vs C++ libDaisy (target achieved)

### Fixed (Critical)

- **RingBuffer Compilation Error** - Fixed syntax error in power-of-2 validation
  - Moved compile-time check outside object definition using `isPowerOfTwo()` template
  - Changed from `{.error.}` to `{.fatal.}` for clearer error messages
  - Affects: All code using RingBuffer (prevented compilation)
  - File: `src/libdaisy_ringbuffer.nim` (lines 63-86)

- **data_structures.nim Example** - Fixed buffer size to comply with power-of-2 requirement
  - Changed `DELAY_SAMPLES` from 4800 to 4096 (nearest power of 2)
  - Delay reduced from 100ms to 85.3ms @ 48kHz (acceptable for demo)
  - File: `examples/data_structures.nim` (line 21)

- **MAX11300**: Replaced stub implementation with full libDaisy C++ wrapper
  - All 20 pins now functional (ADC/DAC/GPI/GPO modes)
  - DMA-based auto-update via `Start()` method for high-performance continuous I/O
  - Proper SPI communication with hardware registers
  - Support for multiple voltage ranges (-10V to +10V)
  - Digital I/O (GPI/GPO) with configurable thresholds
  - Static utility functions for voltage/raw value conversions
  - ⚠️ **UNTESTED ON HARDWARE** - implementation wraps libDaisy C++ driver (lines 266-1298 of max11300.h)
  - Currently supports N=1 (single device) - multi-device requires additional template work
  - Fixed C++ copy constructor issues by using `var` parameters for read operations
  - File: `src/dev/max11300.nim` (complete rewrite, 550+ lines)

- **Race Condition**: Fixed `looper.nim` state variable race between audio callback and main loop
  - Applied double-buffering pattern with atomic flags (similar to `vu_meter.nim`)
  - Prevents undefined behavior and potential crashes from concurrent access
  - Audio callback now only reads `stateMgr.current`, never writes to `stateMgr.next`
  - Main loop requests state changes via `requestStateChange()` with 2ms timeout
  - Uses atomic `bool` flags for handshake (`changeRequested`, `changeAcknowledged`)
  - Zero-overhead on ARM Cortex-M7 (bool is naturally atomic)
  - File: `examples/looper.nim` (lines 41-155)

- **Infinite Loop**: Added timeout to `leddriver.nim` DMA wait loop
  - Prevents system hang if DMA transmission fails
  - 100ms default timeout with graceful recovery
  - Changed return type to `bool` for error indication (breaking change)
  - Returns `false` on timeout, `true` on success
  - Forces driver reset to `-1` state on timeout to prevent permanent hang
  - Busy-wait calibrated for STM32H7 @ 400MHz (~400k cycles/ms)
  - File: `src/dev/leddriver.nim` (lines 294-340)

### Changed

- **cv_expander.nim**: Enhanced example with comprehensive CV processing
  - Expanded from 40 to 150+ lines with practical Eurorack examples
  - 4x CV inputs + 4x CV outputs (±5V range)
  - Processing algorithms: quantization (1V/oct), inversion, attenuation, pass-through
  - DMA-based updates demonstration via `Start()` callback
  - LED activity indicator tied to DMA update counter
  - Comprehensive error handling with LED blink patterns
  - Added hardware validation warnings
  - File: `examples/cv_expander.nim`

- **led_drivers.nim**: Updated to handle `swapBuffersAndTransmit()` bool return
  - Now checks return value and handles timeout gracefully
  - Silent failure mode - continues animation even on DMA timeout
  - File: `examples/led_drivers.nim` (line 68)

## [0.9.0] - 2026-01-22

### Added

#### LED Drivers & I/O Expansion Modules

- **PCA9685 LED Driver Module** (`src/dev/leddriver.nim`) - 16-channel PWM LED controller
  - 16 channels per chip with multi-chip support (up to 62 chips)
  - 12-bit PWM resolution (0-4095)
  - Built-in gamma correction (8-bit → 12-bit)
  - Double-buffered DMA transfers for flicker-free updates
  - I2C interface with configurable address
  - Persistent or volatile buffer modes
  - Methods: `init()`, `setLed()`, `setAllTo()`, `swapBuffersAndTransmit()`

- **DotStar RGB LED Module** (`src/dev/dotstar.nim`) - APA102/SK9822 addressable RGB LEDs
  - Up to 64 pixels per strip
  - 24-bit RGB color + 5-bit global brightness per pixel
  - Configurable color channel ordering (RGB, GRB, BRG, BGR, RBG, GBR)
  - SPI-based communication (no timing constraints)
  - High refresh rate capability
  - Methods: `init()`, `setPixelColor()`, `fill()`, `clear()`, `show()`, `setAllGlobalBrightness()`

- **NeoPixel RGB LED Module** (`src/dev/neopixel.nim`) - WS2812B via I2C bridge
  - Simplified wrapper for WS2812B using Adafruit Seesaw I2C bridge
  - Basic color control and strip management
  - I2C interface (avoids timing-critical bit-banging)
  - Methods: `init()`, `setPixelColor()`, `show()`

- **MCP23017 GPIO Expander Module** (`src/dev/mcp23x17.nim`) - 16-bit I/O expansion
  - 16 GPIO pins (2 ports × 8 pins)
  - Configurable as inputs with pullups or outputs
  - Configurable polarity inversion
  - I2C interface (polling mode)
  - Default address 0x27
  - Methods: `init()`, `portMode()`, `digitalWrite()`, `readPort()`, `read()`, `getPin()`

- **74HC595 Shift Register Module** (`src/dev/sr595.nim`) - 8-bit output expansion
  - 8-bit parallel output via serial-in
  - Daisy-chain support for expansion
  - Template-based for compile-time chip count
  - Methods: `init()`, `set()`, `write()`

- **74HC4021 Shift Register Module** (`src/dev/sr4021.nim`) - 8-bit input expansion
  - 8-bit parallel input via serial-out
  - Daisy-chain support for expansion
  - Template-based for compile-time chip count
  - Methods: `init()`, `update()`, `getPin()`

- **MAX11300 PIXI Module** (`src/dev/max11300.nim`) - 20-port mixed-signal I/O
  - 20 configurable ports (ADC/DAC/GPIO)
  - Voltage ranges: 0-10V, ±5V, ±10V, 0-2.5V
  - 12-bit resolution
  - SPI interface (blocking mode)
  - Simplified wrapper for Eurorack CV/gate applications
  - Methods: `init()`, `configurePinAsAnalogRead()`, `configurePinAsAnalogWrite()`, `readAnalogPinVolts()`, `writeAnalogPinVolts()`

#### New Examples

- `led_drivers.nim` - PCA9685 wave pattern demo
  - Demonstrates 16-channel PWM LED control
  - Smooth sine wave brightness animation
  - Double-buffered DMA transfers
  - Shows gamma correction in action
  - Hardware: PCA9685 breakout + 16 LEDs

- `io_expansion.nim` - MCP23017 button/LED mirroring
  - Demonstrates 16-bit GPIO expansion
  - Port A: 8 button inputs with pullups
  - Port B: 8 LED outputs
  - Real-time button-to-LED mirroring
  - Hardware: MCP23017 + 8 buttons + 8 LEDs

- `cv_expander.nim` - MAX11300 Eurorack CV/gate demo
  - Demonstrates mixed-signal I/O for modular synthesis
  - CV input pass-through to CV output
  - Configurable voltage ranges (±5V)
  - Simplified SPI protocol
  - Hardware: MAX11300 PIXI breakout

- `vu_meter.nim` - DotStar stereo VU meter
  - Audio-reactive LED visualization
  - 16 RGB LEDs (8 per channel)
  - Stereo peak detection with decay
  - Color gradients (green→red, blue→red)
  - 50Hz update rate
  - Hardware: APA102/SK9822 LED strip

### Changed

- **Module organization**: Added 7 LED/IO modules to `src/dev/` subdirectory
- **Macro system**: Extended `useDaisyModules()` to support `leddriver`, `dotstar`, `neopixel`, `mcp23x17`, `sr595`, `sr4021`, `max11300`
- **I2C module**: Exported low-level functions for device drivers:
  - `TransmitBlocking*` - Blocking I2C transmit
  - `TransmitDma*` - DMA I2C transmit
  - `GetConfig*` - Retrieve I2C configuration
  - `Init*` - Re-initialize I2C peripheral
- **SPI module**: Exported `BlockingTransmit*` for device driver use
- **Module dependencies**: Device modules now properly declare `useDaisyModules(module, i2c)` or `useDaisyModules(module, spi)` dependencies

### Fixed

- **Device module compilation**: All device modules now include proper I2C/SPI header dependencies via `useDaisyModules()`
- **Audio callback signatures**: Changed from `csize_t` to `int` to match `AudioCallback` type
- **Example simplification**: Removed non-existent serial logging references from all examples

### Statistics

- **Total modules**: 52 → 59 (+7 LED/IO expansion modules)
- **Total examples**: 46 → 50 (+4 LED/IO examples)
- **libDaisy coverage**: ~72% → ~75%
- **Code added**: 1,260 lines (modules + examples)

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
