# Hardware Testing Guide - Daisy Boards

This guide provides step-by-step hardware testing procedures for the Daisy Pod, Patch, and Field boards using the libdaisy_nim examples.

---

## Table of Contents

- [General Setup](#general-setup)
- [Daisy Pod Testing](#daisy-pod-testing)
- [Daisy Patch Testing](#daisy-patch-testing)
- [Daisy Field Testing](#daisy-field-testing)
- [Troubleshooting](#troubleshooting)

---

## General Setup

### Prerequisites

1. **Hardware:**
   - Daisy Seed (installed in board)
   - USB cable (USB-C for programming)
   - Audio cables (3.5mm or 1/4" depending on board)
   - Headphones or monitoring system
   - Power supply (if not using USB power)

2. **Software:**
   - libdaisy_nim installed and working
   - ARM toolchain (`arm-none-eabi-gcc`)
   - `dfu-util` or `st-flash` for programming

3. **Audio Setup:**
   - Audio source (phone, computer, synth, etc.)
   - Monitoring system (headphones, speakers, mixer)
   - Appropriate cables for your board

### Flashing Examples

All examples use the same flashing procedure:

```bash
cd examples

# Option 1: Edit Makefile (line 9)
# Change: TARGET = your_example_name

# Option 2: Use sed command
sed -i "s/^TARGET = .*/TARGET = your_example/" Makefile

# Build
make clean && make

# Flash via USB DFU (recommended)
make program-dfu

# OR flash via ST-Link
make program-stlink
```

**Entering DFU Mode:**
1. Hold BOOT button on Daisy Seed
2. Press and release RESET button
3. Release BOOT button
4. LED should be off (DFU mode active)
5. Run `make program-dfu`

---

## Daisy Pod Testing

### Hardware Overview

**Controls:**
- 1x Rotary encoder with integrated button
- 2x Potentiometers (KNOB_1, KNOB_2)
- 2x Buttons (BUTTON_1, BUTTON_2)
- 2x RGB LEDs (LED_1, LED_2)
- MIDI I/O (5-pin DIN jacks)
- Audio I/O (3.5mm line level)

### Test 1: Basic I/O - `pod_simple.nim`

**Purpose:** Verify all controls and LEDs work

**Setup:**
1. Flash `pod_simple.nim`
2. No audio connections needed

**Test Procedure:**

1. **LED Test (Power-On)**
   - ✅ LED1 should pulse through rainbow colors automatically
   - ✅ LED2 should be off initially

2. **Knob 1 Test**
   - Turn KNOB_1 fully left → LED1 should be RED
   - Turn KNOB_1 to center → LED1 should be GREEN
   - Turn KNOB_1 fully right → LED1 should be BLUE
   - ✅ LED1 color changes smoothly with knob

3. **Knob 2 Test**
   - Turn KNOB_2 fully left → LED1 should be DIM
   - Turn KNOB_2 fully right → LED1 should be BRIGHT
   - ✅ LED1 brightness changes smoothly with knob

4. **Button 1 Test**
   - Press BUTTON_1 → LED2 should turn ON (white)
   - Release BUTTON_1 → LED2 should turn OFF
   - ✅ LED2 toggles with button presses

5. **Button 2 Test**
   - Press BUTTON_2 → Onboard Seed LED should toggle
   - ✅ Seed LED changes state with each press

6. **Encoder Test**
   - Turn encoder clockwise → LED2 should get BRIGHTER
   - Turn encoder counter-clockwise → LED2 should get DIMMER
   - Press encoder button → LED2 should FLASH briefly
   - ✅ Encoder rotation and button press work

**Expected Results:**
- All knobs control LED parameters smoothly
- All buttons respond immediately
- Encoder controls brightness and button triggers flash
- No audio output (this is a control test only)

---

### Test 2: Audio Synth - `pod_synth.nim`

**Purpose:** Verify audio path and synthesis

**Setup:**
1. Flash `pod_synth.nim`
2. Connect Pod OUTPUT to headphones/speakers
3. No input needed

**Test Procedure:**

1. **Basic Audio Output**
   - You should hear a SINE WAVE tone immediately
   - ✅ Audio output is present and clear

2. **Encoder: Pitch Control**
   - Turn encoder clockwise → Pitch goes UP
   - Turn encoder counter-clockwise → Pitch goes DOWN
   - ✅ Pitch changes smoothly (20Hz - 2000Hz range)

3. **KNOB_1: Waveform Selection**
   - Turn KNOB_1 fully left (0%) → SINE wave (smooth)
   - Turn KNOB_1 to 25% → TRIANGLE wave (buzzy)
   - Turn KNOB_1 to 50% → SAWTOOTH wave (bright)
   - Turn KNOB_1 to 75%+ → SQUARE wave (hollow)
   - ✅ Waveform changes audibly

4. **KNOB_2: Filter Cutoff**
   - Turn KNOB_2 fully left → DARK, muffled sound
   - Turn KNOB_2 fully right → BRIGHT, full sound
   - ✅ Tone brightness changes smoothly

5. **BUTTON_1: Note Trigger**
   - Press BUTTON_1 → New note plays
   - ✅ Button triggers note articulation

6. **BUTTON_2: Octave Shift**
   - Press BUTTON_2 → Pitch jumps to different octave
   - Press again → Cycles through octaves
   - ✅ Octave shifting works

**Expected Results:**
- Continuous tone generation
- Smooth parameter changes
- All controls affect sound as described
- No clicks, pops, or distortion at moderate volume

---

### Test 3: Multi-Effect - `pod_effect.nim`

**Purpose:** Verify audio processing and effect switching

**Setup:**
1. Flash `pod_effect.nim`
2. Connect audio source to Pod INPUT
3. Connect Pod OUTPUT to headphones/speakers
4. Play audio (music, synth, voice, etc.)

**Test Procedure:**

1. **Audio Passthrough**
   - With KNOB_2 (mix) fully left → Dry signal only
   - ✅ Input audio passes through unchanged

2. **Encoder: Effect Selection**
   - Turn encoder to cycle through effects:
     - **Delay** → Repeating echoes
     - **Tremolo** → Pulsing volume
     - **Distortion** → Gritty, saturated sound
     - **Bitcrusher** → Lo-fi, digital degradation
   - ✅ Effects change with encoder rotation
   - ✅ LED1 color indicates current effect

3. **KNOB_1: Effect Parameter**
   - For **Delay**: Controls delay time (short to long)
   - For **Tremolo**: Controls speed (slow to fast)
   - For **Distortion**: Controls drive amount
   - For **Bitcrusher**: Controls bit depth
   - ✅ Effect intensity changes smoothly

4. **KNOB_2: Wet/Dry Mix**
   - Fully left → 100% dry (original signal)
   - Center → 50/50 mix
   - Fully right → 100% wet (effect only)
   - ✅ Mix control works smoothly

5. **BUTTON_1: Bypass Toggle**
   - Press BUTTON_1 → Effect bypassed (dry signal)
   - LED2 turns OFF when bypassed
   - Press again → Effect active
   - ✅ Bypass works instantly without clicks

**Expected Results:**
- Clean audio passthrough when dry
- All effects audibly distinct
- Smooth parameter changes
- No audio dropouts when switching effects
- Bypass is click-free

---

## Daisy Patch Testing

### Hardware Overview

**Controls:**
- 4x CV/Knob inputs with normalled gate inputs
- 2x Gate inputs (3.5mm jacks)
- 1x Gate output (3.5mm jack)
- 1x Rotary encoder with button
- OLED display (128x64)
- MIDI I/O (TRS jacks)
- Audio I/O (Eurorack level, 1/8" jacks)

**Eurorack Notes:**
- Audio levels are **HOT** (±5V Eurorack standard)
- Use attenuators if monitoring with headphones
- CV inputs expect 0-5V range
- Gate I/O is 0V/+5V logic

---

### Test 1: Multi-Effect - `patch_effect.nim`

**Purpose:** Verify CV modulation and gate control

**Setup:**
1. Flash `patch_effect.nim`
2. Connect audio source to Patch INPUT
3. Connect Patch OUTPUT to Eurorack mixer or attenuator
4. **WARNING:** Do NOT connect Patch output directly to headphones (too loud)

**Test Procedure:**

1. **Audio Processing**
   - Feed audio signal into input
   - ✅ Audio passes through with effect applied

2. **Encoder: Effect Selection**
   - Turn encoder to cycle effects:
     - Delay
     - Feedback loop
     - Distortion
     - Low-pass filter
   - ✅ Effect changes with encoder rotation

3. **Encoder Button: Parameter Mode**
   - Press encoder to cycle parameter modes:
     - Effect Type Selection
     - Parameter Control
     - Mix Control
   - ✅ Mode changes with button press

4. **CV 1: Effect Parameter**
   - Turn CTRL_1 knob → Effect intensity changes
   - Patch CV source to CV1 → Parameter modulates
   - ✅ Both knob and CV input work

5. **CV 2: Wet/Dry Mix**
   - Turn CTRL_2 knob → Mix changes
   - ✅ Mix control responsive

6. **GATE_IN_1: Bypass Toggle**
   - Send gate/trigger to Gate Input 1
   - Effect should toggle on/off with each gate
   - Seed LED indicates bypass state
   - ✅ Gate input triggers bypass

**Expected Results:**
- Eurorack-level audio processing
- CV modulation works smoothly
- Gate inputs respond to triggers
- Effects sound clean without aliasing

---

### Test 2: CV Processor - `patch_cv_processor.nim`

**Purpose:** Verify CV processing utilities

**Setup:**
1. Flash `patch_cv_processor.nim`
2. Connect CV sources to CV inputs 1-4
3. Connect gate source to Gate Input 1
4. Monitor CV outputs via oscilloscope or patch to VCO

**Test Procedure:**

1. **CV1: Quantizer**
   - Send CV to CV1 input
   - Output should snap to semitone steps
   - Turn CTRL_1 to select scale (chromatic/major/minor)
   - ✅ CV quantizes to musical notes

2. **CV2: Slew Limiter**
   - Send CV to CV2 input (try square wave LFO)
   - Sharp changes should smooth out
   - Turn CTRL_2 to adjust slew rate
   - Fast = follows input, Slow = smooths heavily
   - ✅ Slew limiting works

3. **CV3: Sample & Hold**
   - Send CV to CV3 input
   - Send gates to GATE_IN_1
   - Each gate should capture current CV3 value
   - Turn CTRL_3 to scale output level
   - ✅ S&H captures values on gate triggers

4. **CV4: Gate Generator**
   - Send CV to CV4 input
   - Turn CTRL_4 to set threshold
   - Gate output fires when CV exceeds threshold
   - Connect Gate Output to LED/oscilloscope
   - ✅ Gate generation works

5. **Encoder: Display Mode**
   - Turn encoder to cycle display modes:
     - CV Values
     - Processor Status
     - Gate Status
   - ✅ Display shows different info per mode

6. **Encoder Button: Quantizer Scale**
   - Press button to cycle scales:
     - Chromatic (all notes)
     - Major scale
     - Minor scale
   - ✅ Scale selection changes quantizer behavior

7. **GATE_IN_2: Reset**
   - Send gate to Gate Input 2
   - All processors should reset to default state
   - ✅ Reset function works

**Expected Results:**
- All CV processors function correctly
- Gate I/O responds to triggers
- Display shows parameter values
- Quantizer produces musical intervals

---

## Daisy Field Testing

### Hardware Overview

**Controls:**
- 16-key capacitive touch keyboard (2 rows of 8)
- 8x Potentiometers with RGB LEDs
- 4x CV inputs (±5V)
- 2x CV outputs (0-5V via DAC)
- 2x Gate inputs
- 1x Gate output
- 2x Tactile switches with RGB LEDs
- OLED display (128x64)
- 26x RGB LEDs total (16 keyboard, 8 knobs, 2 switches)
- MIDI I/O (TRS jacks)
- Audio I/O (Eurorack level)

---

### Test 1: Keyboard Synthesizer - `field_keyboard.nim`

**Purpose:** Verify keyboard scanning and LED feedback

**Setup:**
1. Flash `field_keyboard.nim`
2. Connect Field OUTPUT to Eurorack mixer or attenuator
3. No input needed

**Test Procedure:**

1. **Keyboard Touch Detection**
   - Touch key 0 (bottom-left) → Note plays
   - Touch key 15 (top-right) → Higher note plays
   - ✅ All 16 keys respond to touch

2. **LED Feedback (if working)**
   - Touch key → Corresponding keyboard LED lights up
   - Release key → LED turns off
   - ⚠️ **Note:** LED feedback may be disabled due to C++ template issue
   - ✅ At minimum, audio responds to key presses

3. **Keyboard Scanning**
   - Press multiple keys simultaneously
   - Each key should trigger its own note
   - ✅ Polyphonic note detection works

4. **KNOB_1 to KNOB_8**
   - Turn knobs → Synth parameters change
   - (Exact mappings depend on implementation)
   - ✅ Knobs control synthesis parameters

5. **Audio Output**
   - Keys should produce audible tones
   - Different keys = different pitches
   - ✅ Synthesis engine works

**Expected Results:**
- All 16 keys respond to touch
- Polyphonic or monophonic note triggering
- Knobs control synth parameters
- Clean audio output

**Known Issues:**
- Field LED driver has C++ template type mismatch
- LED feedback may be disabled in current implementation
- Audio and keyboard detection still work correctly

---

### Test 2: CV/Gate Sequencer - `field_modular.nim`

**Purpose:** Verify CV I/O and gate generation

**Setup:**
1. Flash `field_modular.nim`
2. Connect CV sources to CV inputs 1-4
3. Connect gate source to Gate Input 1 (clock)
4. Monitor Gate Output with LED or scope
5. Connect Field audio output to Eurorack system

**Test Procedure:**

1. **CV Input Reading**
   - Patch CV to CV1-CV4 inputs
   - Values should display on OLED (if implemented)
   - Turn corresponding knobs → Offsets/scales CV
   - ✅ CV inputs read correctly

2. **Gate Input: Clock**
   - Send clock to Gate Input 1
   - Each clock pulse advances sequencer step
   - ✅ Gate input detects triggers

3. **Keyboard: Step Programming**
   - Touch keyboard keys to set step values
   - Different keys = different CV values
   - ✅ Keyboard programs sequence

4. **KNOB_1 to KNOB_8: Sequence Values**
   - Each knob sets a step value
   - 8 knobs = 8-step sequence
   - ✅ Knobs set sequence data

5. **Gate Output: Rhythm Generation**
   - Gate output should trigger on certain steps
   - Use to trigger envelopes or drums
   - ✅ Gate output generates rhythm

6. **Switch 1 & 2: Mode Select**
   - Press switches to change modes
   - (Exact behavior depends on implementation)
   - ✅ Switches change sequencer behavior

7. **OLED Display**
   - Should show sequence visualization
   - Current step indicator
   - CV values
   - ✅ Display updates with sequence

**Expected Results:**
- CV inputs read correctly
- Gate inputs detect clock/triggers
- Gate output generates rhythmic patterns
- Keyboard and knobs program sequence
- Display shows sequence state

---

## Troubleshooting

### No Audio Output

**Symptoms:** Silent or very quiet audio

**Checks:**
1. ✅ Audio cables connected correctly (check input vs output)
2. ✅ Volume on monitoring system turned up
3. ✅ Daisy Seed fully seated in board socket
4. ✅ Correct example flashed to board
5. ✅ Audio source is actually playing (for effect examples)
6. ✅ For Patch/Field: Eurorack levels are HOT - may need attenuation

**Solutions:**
- Check all cable connections
- Try a different audio source
- Verify example compiled without errors
- Check monitoring system with known-good audio source

---

### Controls Not Responding

**Symptoms:** Knobs/buttons have no effect

**Checks:**
1. ✅ Correct example flashed
2. ✅ `processAllControls()` called in main loop
3. ✅ ADC started with `startAdc()`
4. ✅ Sufficient delay in main loop (at least 1ms)

**Solutions:**
- Re-flash the example
- Check serial output for errors (if USB serial enabled)
- Try a simpler test example first (pod_simple, etc.)

---

### LEDs Not Working

**Symptoms:** LEDs dim, wrong colors, or not responding

**Pod/Patch/Field RGB LEDs:**
1. ✅ `updateLeds()` called after setting colors
2. ✅ Brightness not set too low
3. ✅ Power supply adequate (USB may not provide enough current)

**Field Keyboard/Knob LEDs:**
- ⚠️ Known issue: C++ template type mismatch
- LED driver integration incomplete in v0.11.0
- Audio and controls still work correctly

**Solutions:**
- Check power supply (try external 9V if using USB)
- Reduce number of lit LEDs
- Lower brightness values
- For Field: Wait for v0.12.0 LED driver fixes

---

### Encoder Issues

**Symptoms:** Encoder doesn't increment or button doesn't respond

**Checks:**
1. ✅ `processDigitalControls()` called in main loop
2. ✅ Using `.increment()` not direct value reads
3. ✅ Button using `.risingEdge()` or `.pressed()`

**Solutions:**
- Ensure control processing happens before value reads
- Use edge detection for button events
- Check encoder is fully pressed into socket

---

### Compilation Errors

**Symptoms:** Examples fail to compile

**Checks:**
1. ✅ libDaisy submodule initialized: `git submodule update --init`
2. ✅ libDaisy built: `cd libDaisy && make`
3. ✅ ARM toolchain installed: `arm-none-eabi-gcc --version`
4. ✅ Nim 2.0+ installed: `nim --version`

**Solutions:**
- Run `make clean` before `make`
- Check `nim.cfg` has correct paths
- Verify all imports are correct
- Try compiling a simple example first (blink.nim)

---

### DFU Programming Fails

**Symptoms:** `make program-dfu` fails or device not found

**Checks:**
1. ✅ Daisy Seed in DFU mode (BOOT + RESET procedure)
2. ✅ `dfu-util` installed: `dfu-util --version`
3. ✅ USB cable supports data (not charge-only)
4. ✅ USB permissions correct (Linux: udev rules)

**Solutions:**
- Try DFU entry procedure again
- Check `dfu-util -l` shows device
- Try different USB cable/port
- Use ST-Link instead: `make program-stlink`

---

## Example Testing Checklist

Use this checklist to verify all board examples:

### Daisy Pod
- [ ] `pod_simple.nim` - All LEDs, knobs, buttons, encoder work
- [ ] `pod_synth.nim` - Audio synthesis, pitch/waveform control
- [ ] `pod_effect.nim` - Audio processing, effect switching

### Daisy Patch  
- [ ] `patch_effect.nim` - CV modulation, gate bypass works
- [ ] `patch_cv_processor.nim` - Quantizer, slew, S&H, gate gen work

### Daisy Field
- [ ] `field_keyboard.nim` - All 16 keys respond, audio output works
- [ ] `field_modular.nim` - CV I/O, gate I/O, sequencing works

---

## Reporting Issues

If you encounter issues during testing:

1. **Check this guide** for troubleshooting steps
2. **Verify basic examples** work first (blink.nim, audio_passthrough.nim)
3. **Document the issue:**
   - Board type and hardware revision
   - Example name and version
   - Expected vs actual behavior
   - Serial output (if available)
   - Compilation output
4. **Report on GitHub:** https://github.com/electro-smith/libdaisy_nim/issues

---

## Testing Contributions

**Want to help test libdaisy_nim on hardware?**

We need community testing for:
- ✅ Daisy Pod examples
- ✅ Daisy Patch examples  
- ✅ Daisy Field examples
- ⚠️ Field LED driver functionality
- 🔧 Real-world performance and stability

See **HARDWARE_TESTING.md** for how to contribute test reports.

---

**Last Updated:** January 2026 (v0.11.0)  
**Examples Tested:** 61/61 compile successfully  
**Hardware Testing Status:** Awaiting community validation
