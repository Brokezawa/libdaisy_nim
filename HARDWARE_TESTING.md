# Hardware Testing Guide

## Overview

This guide explains how to test libdaisy_nim features with and without hardware. Given that the maintainer has limited hardware (Daisy Seed + SDRAM + few peripherals), **community testing is essential** for complete validation.

---

## Testing Categories

### 1. Compilation Testing (No Hardware Required) ✅

**Everyone can do this!**

Compilation testing verifies that code:
- Compiles without errors
- Links correctly
- Generates valid ARM binaries
- Has no warnings (in most cases)

#### How to Run Compilation Tests:

```bash
cd examples
./test_all.sh
```

**Expected output:**
```
========================================
SUMMARY:
  Passed: 27
  Failed: 0
========================================
```

#### What This Tests:
- ✅ Nim → C++ code generation
- ✅ C++ template instantiation
- ✅ Header includes and dependencies
- ✅ Linker script and memory layout
- ✅ Type safety and API correctness

#### What This Does NOT Test:
- ❌ Runtime behavior
- ❌ Hardware interactions
- ❌ Peripheral functionality
- ❌ Real-world use cases

**Compilation testing is required for all PRs**, but it's only the first step.

---

### 2. Basic Hardware Testing (Seed Only) ⚙️

**Maintainer can do this**

Tests that work with just a Daisy Seed (no extra peripherals):

| Feature | Example | What to Test |
|---------|---------|--------------|
| **LED** | `blink.nim` | LED blinks at expected rate |
| **GPIO** | `button_led.nim` | Button press controls LED |
| **Audio** | `audio_passthrough.nim` | Input → output, no glitches |
| **SDRAM** | `sdram_test.nim` | Memory read/write, no corruption |
| **USB Serial** | `usb_serial.nim` | USB CDC communication |
| **RNG** | `peripherals_basic.nim` | Random values generated |
| **Timer** | `timer_advanced.nim` | Callbacks fire at correct intervals |

#### Testing Procedure (Seed Only):

1. Flash example: `make program-dfu`
2. Observe LED/behavior
3. If USB serial: monitor with `screen /dev/tty.usbmodem* 115200`
4. Verify expected behavior
5. Report results

---

### 3. Extended Hardware Testing (Peripherals Required) 🔌

**Community testing needed!**

Tests that require external hardware:

#### I2C Devices:
| Device | Example | Required Hardware |
|--------|---------|-------------------|
| **OLED Display** | `oled_basic.nim` | SSD1306 OLED (I2C) |
| **IMU Sensor** | `imu_demo.nim` | ICM20948 or similar |
| **Touch Sensor** | `touch_input.nim` | MPR121 capacitive touch |
| **Gesture Sensor** | `gesture_sensor.nim` | APDS9960 |

#### SPI Devices:
| Device | Example | Required Hardware |
|--------|---------|-------------------|
| **OLED Display** | `oled_spi.nim` | SSD1306 OLED (SPI) |
| **SD Card** | `wav_player.nim` | microSD card + files |
| **LED Strips** | `led_drivers.nim` | DotStar or NeoPixel strip |

#### Analog/Control:
| Feature | Example | Required Hardware |
|---------|---------|-------------------|
| **ADC** | `adc_multichannel.nim` | Potentiometers or CV sources |
| **DAC** | `dac_simple.nim` | Oscilloscope or multimeter |
| **PWM** | `pwm_led.nim` | LED + resistor |
| **Encoder** | `encoder.nim` | Rotary encoder |

#### Audio:
| Feature | Example | Required Hardware |
|---------|---------|-------------------|
| **WAV Playback** | `wav_player.nim` | SD card + WAV files + speakers |
| **Sampling** | `sampler.nim` | SD card + audio samples |
| **Recording** | `wav_recorder.nim` | SD card + audio source |

---

### 4. Board-Specific Testing (Special Hardware) 🎛️

**Community testing critical!**

Maintainer only has Daisy Seed. **Community testing required** for:

| Board | Examples | What to Test |
|-------|----------|--------------|
| **Daisy Patch** | `patch_simple.nim`, `patch_effect.nim` | Knobs, gates, OLED, encoder, MIDI |
| **Daisy Pod** | `pod_synth.nim`, `pod_effect.nim` | Encoder, buttons, knobs, RGB LEDs, MIDI |
| **Daisy Field** | `field_keyboard.nim` | Touch keyboard, 8 knobs, CV inputs, gates |
| **Daisy PatchSM** | `patch_sm_cv.nim` | 8 CV in, 2 CV out, gates |
| **Daisy Petal** | `petal_overdrive.nim` | 8 knobs, buttons, footswitches, encoder |
| **Daisy Versio** | `versio_reverb.nim` | 7 CV inputs, 6 pots, audio |
| **Daisy Legio** | `legio_utility.nim` | 4 CV inputs, 4 pots, OLED |

---

## How to Report Test Results

### GitHub Issue Format

When testing hardware, create or comment on the relevant issue with this template:

**Issue Title**: `[Hardware Test] Module Name - Board Name`

**Example**: `[Hardware Test] OLED Display - Daisy Seed`

**Template**:

```markdown
## Hardware Test Report

### Test Information
- **Module**: libdaisy_oled.nim
- **Example**: oled_basic.nim
- **Board**: Daisy Seed
- **Tester**: @YourGitHubUsername
- **Date**: 2026-01-21

### Hardware Setup
- **Board**: Daisy Seed (version/revision if known)
- **Peripherals**: 
  - SSD1306 OLED 128x64 (I2C address 0x3C)
  - Connected to: SDA=B9, SCL=B8, Power=3.3V
- **Connections**: (Photo/diagram if possible)
- **Power**: USB

### Test Procedure
1. Compiled example: `make TARGET=oled_basic`
2. Flashed via: DFU
3. Expected behavior: Display "Hello World" and draw shapes
4. Actual behavior: ✅ Worked as expected / ❌ Issue found

### Results
- ✅ **PASS** - Feature works as documented
- ⚠️ **PASS with notes** - Works but has minor issues
- ❌ **FAIL** - Does not work

### Detailed Notes
- OLED initialized correctly
- Text displayed clearly
- Graphics primitives working (lines, circles, rectangles)
- No flickering or corruption
- Frame rate appears smooth

### Issues Found (if any)
None

### Photos/Videos
[Attach if possible]

### Additional Comments
Excellent example, very easy to use!

### System Information
- **OS**: macOS 14.2
- **Nim Version**: 2.0.2
- **ARM Toolchain**: arm-none-eabi-gcc 12.2.1
- **libDaisy Version**: Latest main branch
```

---

## Testing Priority Levels

### 🔴 **HIGH PRIORITY** - Needs Testing ASAP
Features that block releases or are commonly used:
- Audio I/O (all boards)
- File I/O (WAV playback/recording)
- USB functionality
- Core peripherals (I2C, SPI, UART)
- Board-specific features (Patch, Pod, Field)

### 🟡 **MEDIUM PRIORITY** - Needs Testing Eventually
Useful features that aren't critical:
- Display drivers (OLED, LCD)
- Sensors (IMU, gesture, touch)
- LED drivers (NeoPixel, DotStar)
- I/O expanders

### 🟢 **LOW PRIORITY** - Nice to Have
Specialized features:
- Specific codec configurations
- Advanced sensor features
- Uncommon peripherals

---

## Community Testing Program

### How to Participate

1. **Check GitHub Issues** for `needs-hardware-testing` label
2. **Find tests** that match your hardware
3. **Run the test** following the example
4. **Report results** using the template above
5. **Get credited** in release notes!

### Testing Workflow

```
1. Find issue tagged "needs-hardware-testing"
   ↓
2. Comment: "I can test this with [your hardware]"
   ↓
3. Maintainer confirms and provides any special instructions
   ↓
4. Run test and gather results
   ↓
5. Post test report in issue comments
   ↓
6. Maintainer reviews and either:
   - Closes issue (if PASS)
   - Fixes bugs (if FAIL)
   - Requests more info (if unclear)
   ↓
7. You get credit in release notes! 🎉
```

### What Makes a Good Test Report?

✅ **Complete information** (hardware, connections, results)  
✅ **Clear pass/fail** status  
✅ **Photos/videos** when helpful  
✅ **Detailed notes** on unexpected behavior  
✅ **Reproducible** - others can verify  

❌ **Vague** - "didn't work"  
❌ **Missing details** - which board? which peripheral?  
❌ **No test procedure** - what did you try?  

---

## Testing by Milestone

Each milestone has specific hardware testing needs:

### v0.4.0 - Simple Peripherals
**Testable without extra hardware:**
- ✅ RNG (Seed only)
- ✅ Timer (Seed only)
- ✅ LED control (Seed only)

**Needs external hardware:**
- ⚙️ GateIn (Eurorack gate source)
- ⚙️ Switch3 (3-position switch)
- ⚙️ RgbLed (RGB LED)

### v0.5.0 - Data Structures
**Testable without extra hardware:**
- ✅ All examples compile
- ✅ Memory usage verification (profiling)

**Needs testing:**
- ⚙️ Real-world use cases in projects

### v0.6.0 - File I/O ⭐
**Critical - needs extensive testing:**
- ⚙️ SD card playback (various WAV formats)
- ⚙️ SD card recording (quality, reliability)
- ⚙️ Sampler functionality (multi-sample)
- ⚙️ Looper functionality (record/playback sync)
- ⚙️ Wavetable loading (various sizes)
- ⚙️ QSPI flash storage (speed, reliability)

### v0.7.0 - Codecs & Displays
**Needs codec testing:**
- ⚙️ Different Seed versions (1.0, 1.1, 2.0)
- ⚙️ Audio quality comparison

**Needs display testing:**
- ⚙️ LCD (16x2, 20x4)
- ⚙️ Graphics library on various displays

### v0.8.0 - Sensors
**Needs sensor hardware:**
- ⚙️ ICM20948 IMU
- ⚙️ APDS9960 gesture
- ⚙️ DPS310 pressure
- ⚙️ TLV493D magnetic
- ⚙️ MPR121 touch
- ⚙️ NeoTrellis button pad

### v0.9.0 - LED Drivers & I/O
**Needs LED/I/O hardware:**
- ⚙️ PCA9685 PWM driver
- ⚙️ DotStar LED strip
- ⚙️ NeoPixel LED strip
- ⚙️ MCP23017 I/O expander
- ⚙️ Shift registers (74HC595, 74HC4021)
- ⚙️ MAX11300 (advanced)

### v0.10.0 - Storage
**Needs flash testing:**
- ⚙️ Different Seed versions (flash chip variants)
- ⚙️ Settings persistence across power cycles
- ⚙️ Wear leveling validation

### v0.11.0 - Boards (Pod & Field) ⭐⭐
**CRITICAL - needs board owners:**
- ⚙️ **Daisy Pod** complete testing
- ⚙️ **Daisy Field** complete testing
- ⚙️ Enhanced **Daisy Patch** testing

### v0.12.0 - Boards (PatchSM, Petal, Versio, Legio) ⭐⭐
**CRITICAL - needs board owners:**
- ⚙️ **Daisy PatchSM** complete testing
- ⚙️ **Daisy Petal** complete testing
- ⚙️ **Daisy Versio** complete testing
- ⚙️ **Daisy Legio** complete testing

### v0.13.0 - System Features
**Needs specialized testing:**
- ⚙️ V/Oct calibration (precision testing with Eurorack gear)
- ⚙️ Performance benchmarking
- ⚙️ System utilities validation

### v0.14.0 - UI Framework
**Needs extensive UI testing:**
- ⚙️ Menu system on various displays
- ⚙️ UI on different boards (encoder behavior)
- ⚙️ Real-world application testing

### v1.0.0-rc1 & v1.0.0
**Comprehensive regression testing:**
- ⚙️ **All** boards retested
- ⚙️ **All** peripherals verified
- ⚙️ Real-world project validation

---

## Hardware Testing Matrix

### Board Coverage Needed:

| Board | Maintainer | Community | Status |
|-------|------------|-----------|--------|
| **Seed** | ✅ Yes | ✅ Additional | Available |
| **Patch** | ❌ No | ⚙️ **Needed** | Limited |
| **Pod** | ❌ No | ⚙️ **Needed** | Not yet |
| **Field** | ❌ No | ⚙️ **Needed** | Not yet |
| **PatchSM** | ❌ No | ⚙️ **Needed** | Not yet |
| **Petal** | ❌ No | ⚙️ **Needed** | Not yet |
| **Versio** | ❌ No | ⚙️ **Needed** | Not yet |
| **Legio** | ❌ No | ⚙️ **Needed** | Not yet |

### Peripheral Coverage Needed:

| Peripheral Type | Maintainer | Community |
|----------------|------------|-----------|
| **OLED Display** | ⚙️ Limited | ⚙️ Multiple types needed |
| **LCD Display** | ❌ No | ⚙️ **Needed** |
| **IMU Sensor** | ❌ No | ⚙️ **Needed** |
| **Touch Sensor** | ❌ No | ⚙️ **Needed** |
| **LED Strips** | ❌ No | ⚙️ **Needed** |
| **I/O Expanders** | ❌ No | ⚙️ **Needed** |
| **SD Card** | ✅ Yes | ✅ Additional formats |
| **QSPI Flash** | ✅ Yes | ✅ Additional |
| **Audio Codecs** | ✅ Limited | ⚙️ Various Seed versions |

---

## Testing Best Practices

### Before Testing:

1. **Read the example documentation** in code comments
2. **Understand expected behavior** from API reference
3. **Check hardware connections** (wrong wiring = false failure)
4. **Use fresh build** (`make clean && make`)
5. **Test known-good hardware** first (eliminate variables)

### During Testing:

1. **Take notes** as you test (don't rely on memory)
2. **Try edge cases** (not just happy path)
3. **Monitor for issues**:
   - Audio glitches
   - Display corruption
   - Timing problems
   - Memory leaks (long-running tests)
   - USB disconnects
4. **Photograph setup** (helps debugging)

### Reporting:

1. **Be specific** - "OLED flickers at 60 FPS" not "display broken"
2. **Include context** - wiring, power source, environment
3. **Separate issues** - one issue per bug found
4. **Suggest fixes** if you have ideas (but not required)
5. **Be patient** - maintainer may request more info

---

## Common Testing Pitfalls

### ❌ **False Negatives** (reporting failure when it works)

**Cause**: Wrong hardware connections, wrong expectations, corrupted build

**Prevention**:
- Double-check wiring against example comments
- Read expected behavior carefully
- Try `make clean && make`
- Test with known-good hardware first

### ❌ **False Positives** (reporting success when it's broken)

**Cause**: Not testing thoroughly, missing edge cases

**Prevention**:
- Test for longer than 10 seconds
- Try multiple inputs/configurations
- Check for glitches/corruption
- Verify accuracy (e.g., timing with oscilloscope)

### ❌ **Incomplete Reports**

**Cause**: Forgetting details, rushing

**Prevention**:
- Use the template above
- Take photos during testing
- Save terminal output
- Test immediately after setup (while fresh)

---

## Automated Testing (Future)

### Planned Improvements:

1. **CI/CD Pipeline**:
   - Automated compilation tests on GitHub Actions
   - Cross-platform build verification
   - Binary size tracking

2. **Hardware-in-the-Loop**:
   - Automated flashing to test boards
   - Scripted test sequences
   - Oscilloscope/logic analyzer validation

3. **Performance Benchmarks**:
   - Automated latency measurements
   - Memory usage tracking
   - Regression detection

---

## Recognition

### Contributors Will Be:

- ✨ **Credited in release notes** by GitHub username
- ✨ **Listed in CONTRIBUTORS.md** (if you agree)
- ✨ **Thanked in announcement posts**
- ✨ **Part of the community** building this project!

### Hall of Fame (Coming Soon)

When v1.0.0 ships, we'll create a CONTRIBUTORS.md highlighting everyone who helped with hardware testing.

---

## FAQ

### Q: I don't have Daisy hardware, can I still help?
**A:** Yes! Compilation testing and code review are valuable. You can also help with documentation.

### Q: I have hardware but I'm a beginner, can I test?
**A:** Absolutely! Just follow the examples and report what you see. Honest feedback from all skill levels helps.

### Q: What if I find a bug?
**A:** Great! Report it using the template. Include as much detail as possible. You're helping make the library better.

### Q: My hardware is custom/unusual, should I still test?
**A:** Yes! Edge cases and unusual configurations are important to discover.

### Q: How long should I test for?
**A:** For basic features, 5-10 minutes. For audio/stability, run overnight if possible. Real-world projects are the best test.

### Q: Can I test beta/unreleased features?
**A:** Yes! Check the `dev` branch for upcoming features. Early testing is super helpful.

### Q: I tested something 6 months ago, should I retest?
**A:** If there have been changes to that module, yes please! Otherwise, your previous test is still valid.

### Q: What if the example doesn't compile?
**A:** Report it! That's a bug. Include the compilation error in your report.

---

## Contact

**Questions about hardware testing?**
- Open a GitHub Discussion
- Comment on the relevant issue
- Ask in Electro-Smith forum

**Want to coordinate testing efforts?**
- Join the community discussions
- Check the project board for testing tasks

---

## Summary

**Hardware testing is community-driven.**

Without your help:
- ❌ Board support can't be verified
- ❌ Peripheral drivers remain untested
- ❌ Real-world use cases unknown
- ❌ Bugs stay hidden

With your help:
- ✅ Complete board validation
- ✅ Verified peripheral support
- ✅ Reliable, tested library
- ✅ v1.0.0 confidence!

**Thank you for testing!** 🎉

---

**Document Version**: 1.0  
**Created**: January 21, 2026  
**Related**: See [ROADMAP.md](ROADMAP.md) for testing requirements per milestone
