# libdaisy_nim Hardware Testing Checklist

**Version:** v0.3.0  
**Tester:** _________________  
**Date:** _________________  
**Hardware:** Daisy Seed + _________________

---

## Instructions

1. **Build and flash** each example to your Daisy Seed
2. **Observe behavior** and compare to expected results (see EXAMPLES.md)
3. **Mark status:**
   - ✅ PASS - Works exactly as expected
   - ⚠️ PARTIAL - Works but with differences
   - ❌ FAIL - Does not work or crashes
   - ⏭️ SKIP - Hardware not available
   - 🔧 ISSUE - Wrapper/example bug found

4. **Note differences** in the "Notes" column
5. **Report issues** on GitHub with this checklist attached

---

## Basic Examples (No External Hardware Required)

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | blink.nim | LED blinks at ~2Hz (500ms on/off) | |
| ⬜ | panicoverride.nim | LED blinks rapidly (SOS pattern) - intentional crash | |

---

## GPIO Examples

**Hardware needed:** Button, 10kΩ resistor, breadboard

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | button_led.nim | LED mirrors button state (instant response) | |
| ⬜ | gpio_input.nim | LED mirrors button, console shows state changes | |

---

## Audio Examples

**Hardware needed:** Audio cable, headphones/amp

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | audio_passthrough.nim | Clean audio passthrough, <3ms latency | |
| ⬜ | sine_wave.nim | Pure 440Hz sine wave on both channels | |
| ⬜ | distortion_effect.nim | Clean by default, warm overdrive when activated | |

---

## ADC Examples

**Hardware needed:** Potentiometers (10kΩ), breadboard

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | adc_simple.nim | LED brightness/console reflects pot position | |
| ⬜ | adc_multichannel.nim | 3 independent channels, console shows all values | |
| ⬜ | adc_multiplexed.nim | Scans multiple mux channels sequentially | |
| ⬜ | adc_config.nim | Custom ADC config, similar to adc_simple | |
| ⬜ | analog_knobs.nim | Smooth value changes with optional filtering | |

---

## PWM Examples

**Hardware needed:** LEDs, resistors, servo motor (optional)

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | pwm_led.nim | LED fades smoothly 0-100%, no flickering | |
| ⬜ | pwm_rgb.nim | RGB cycles rainbow smoothly (~5s/cycle) | |
| ⬜ | pwm_servo.nim | Servo sweeps 0-180° smoothly (~2s/sweep) | |

---

## Display Examples (OLED)

**Hardware needed:** SSD1306 OLED (128x64), I2C or SPI

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | oled_basic.nim | Display shows "Hello Daisy!" (crisp text) | |
| ⬜ | oled_graphics.nim | Draws shapes (rectangles, circles, lines) | |
| ⬜ | oled_spi.nim | Same as oled_basic but via SPI (faster) | |
| ⬜ | oled_visualizer.nim | Audio level meter reacts to input (10-30 FPS) | |

---

## Communication Examples

**Hardware needed:** Various (see per-example)

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | i2c_scanner.nim | Reports I2C devices 0x03-0x77 via console/LED | |
| ⬜ | spi_basic.nim | Sends/receives SPI data, verifies correctness | |
| ⬜ | usb_serial.nim | Virtual serial port, text echoes back | |
| ⬜ | midi_input.nim | LED flashes on MIDI notes, console shows data | |

---

## Control Examples

**Hardware needed:** Rotary encoder with button

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | encoder.nim | Value changes on rotation, detents accurate | |

---

## Storage Examples

**Hardware needed:** SDRAM chip (optional Daisy mod)

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | sdram_test.nim | LED blinks on success, stays on for failure | |

---

## DAC Examples

**Hardware needed:** Voltmeter or oscilloscope

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | dac_simple.nim | Voltage ramps 0-3.3V continuously (~1V/sec) | |

---

## Board-Specific Examples

**Hardware needed:** Daisy Patch board

| Status | Example | Expected Behavior | Notes |
|--------|---------|-------------------|-------|
| ⬜ | patch_simple.nim | Initializes Patch, tests controls + OLED + audio | |

---

## Summary

**Total Examples:** 27  
**Passed:** _____ / 27  
**Partial:** _____ / 27  
**Failed:** _____ / 27  
**Skipped:** _____ / 27  
**Issues Found:** _____

---

## Issues Discovered

### Issue 1: [Example Name]

**Status:** 🔧 ISSUE  
**Severity:** High / Medium / Low

**Expected:**
[What should happen]

**Actual:**
[What actually happened]

**Hardware Setup:**
[Components and wiring]

**Reproducibility:** Always / Sometimes / Rare

**Suspected Cause:** Example bug / Wrapper bug / Documentation error / User error

**Additional Notes:**

---

### Issue 2: [Example Name]

**Status:** 🔧 ISSUE  
**Severity:** High / Medium / Low

**Expected:**

**Actual:**

**Hardware Setup:**

**Reproducibility:**

**Suspected Cause:**

**Additional Notes:**

---

## Test Environment

**Operating System:** ___________________  
**Nim Version:** ___________________  
**ARM Toolchain Version:** ___________________  
**libDaisy Commit:** ___________________  
**libdaisy_nim Version:** v0.3.0  
**Daisy Seed Hardware Revision:** ___________________  
**Additional Hardware:** ___________________

---

## Additional Comments

[Any general observations, suggestions, or feedback]

---

## How to Submit This Report

1. **Save this file** with your test results
2. **Take photos/videos** of any issues (optional but helpful)
3. **Create GitHub issue** with:
   - Title: "Hardware Test Report - v0.3.0 - [Your Name]"
   - Attach this completed checklist
   - Include any photos/scope captures
   - Tag with `hardware-testing` label

4. **Or create Pull Request** to add your results to:
   - `test-results/v0.3.0/[your-name].md`

---

**Thank you for testing libdaisy_nim!** 🎉

Your contributions help make this project better for everyone.
