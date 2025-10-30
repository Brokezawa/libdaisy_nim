# Changelog

All notable changes to libdaisy_nim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
