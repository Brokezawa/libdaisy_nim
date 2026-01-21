# Quick Start Guide

Get your first Nim program running on Daisy Seed in under 10 minutes!

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Daisy Seed board** with USB cable
- [ ] **Nim** installed (version 2.0 or later)
- [ ] **ARM toolchain** installed (`arm-none-eabi-gcc`)
- [ ] **dfu-util** or **ST-Link** tools for flashing
- [ ] **Terminal** or command prompt

## Step 1: Install Dependencies

### Install Nim

**macOS** (using Homebrew):
```bash
brew install nim
```

**Linux** (Ubuntu/Debian):
```bash
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

**Windows**:
Download from [https://nim-lang.org/install.html](https://nim-lang.org/install.html)

Verify installation:
```bash
nim --version  # Should show 2.0 or later
```

### Install ARM Toolchain

**macOS**:
```bash
brew install --cask gcc-arm-embedded
```

**Linux** (Ubuntu/Debian):
```bash
sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi
```

**Windows**:
Download from [ARM website](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)

Verify installation:
```bash
arm-none-eabi-gcc --version
```

### Install Flash Tool

**For DFU (USB) flashing**:
```bash
# macOS
brew install dfu-util

# Linux
sudo apt-get install dfu-util

# Windows
# Download from https://dfu-util.sourceforge.net/
```

**For ST-Link flashing** (if you have ST-Link hardware):
```bash
# macOS
brew install stlink

# Linux
sudo apt-get install stlink-tools
```

## Step 2: Get libdaisy_nim

Clone this wrapper with its libDaisy submodule:

```bash
# Navigate to your projects directory
cd ~/Projects  # or wherever you keep projects

# Clone with submodules
git clone --recursive https://github.com/Brokezawa/libdaisy_nim
cd libdaisy_nim

# Your structure will be:
# ~/Projects/libdaisy_nim/
# ├── libDaisy/         # Submodule
# ├── src/              # Nim wrapper
# └── examples/         # Examples
```

## Step 3: Build libDaisy

Build the C++ libDaisy library:

```bash
# In libdaisy_nim directory
cd libDaisy

# Build it (takes 2-3 minutes)
make

# Verify build succeeded
ls build/libdaisy.a  # Should exist

# Go back to main directory
cd ..
```

## Step 4: Build Your First Example

```bash
cd libdaisy_nim/examples

# The Makefile is already configured for blink
# Just build it:
make

# You should see output ending with:
# Binary size:
#    text    data     bss     dec     hex filename
#   64468    1596   27904   93968   16f10 build/blink.elf
```

**Success!** You've compiled your first Nim program for Daisy!

## Step 5: Flash to Hardware

### Prepare Your Daisy

**For DFU (USB) mode:**
1. Hold the **BOOT** button on Daisy
2. While holding BOOT, press and release **RESET**
3. Release **BOOT**
4. Daisy is now in bootloader mode (LED might be dim or off)

### Flash the Program

```bash
# Still in examples/ directory
make program-dfu
```

You should see:
```
Flashing build/blink.bin via DFU...
dfu-util ...
Download [=========================] 100%
File downloaded successfully
```

**Your Daisy should now be blinking its LED!** 🎉

### Alternative: ST-Link

If you have an ST-Link programmer:
```bash
make program-stlink
```

## Step 6: Try Other Examples

Edit the `TARGET` in the Makefile to try different examples:

```bash
# Open Makefile and change the TARGET line:
TARGET = button_led  # or any other example

make clean
make
make program-dfu
```

Available examples (see `ls *.nim`):
- `blink.nim` - LED blink
- `button_led.nim` - Button controls LED
- `gpio_input.nim` - Read GPIO
- `audio_passthrough.nim` - Audio I/O
- `i2c_scanner.nim` - Scan I2C bus
- `spi_basic.nim` - SPI communication
- `midi_input.nim` - MIDI input
- `encoder.nim` - Rotary encoder
- `adc_simple.nim` - Analog input
- `analog_knobs.nim` - Multiple knobs
- `distortion_effect.nim` - Audio effect
- `serial_echo.nim` - UART echo
- `usb_serial.nim` - USB serial port
- `sdram_delay.nim` - Audio delay (coming soon)

Or test all examples at once:
```bash
./test_all.sh
```

## Step 7: Create Your Own Project

### Method 1: Modify an Example

```bash
cd examples
cp blink.nim my_project.nim

# Edit my_project.nim with your code

# Update Makefile TARGET
sed -i 's/TARGET = .*/TARGET = my_project/' Makefile

make
make program-dfu
```

### Method 2: Start Fresh

Create a new directory for your project:

```bash
mkdir ~/my_daisy_project
cd ~/my_daisy_project

# Copy build configuration
cp ~/Projects/libdaisy_nim/examples/Makefile .
cp ~/Projects/libdaisy_nim/examples/nim.cfg .

# Edit Makefile - set your project name
sed -i 's/TARGET = .*/TARGET = my_program/' Makefile

# Create your program
cat > my_program.nim << 'EOF'
import ../libdaisy_nim/src/libdaisy

var hw = newDaisySeed()

proc main() =
  hw.init()
  
  while true:
    hw.setLed(true)
    hw.delayMs(500)
    hw.setLed(false)
    hw.delayMs(500)

when isMainModule:
  main()
EOF

# Build and flash
make
make program-dfu
```

## Understanding the Build System

### Makefile Variables

Key variables in the Makefile:

```makefile
TARGET = blink           # Your program name (without .nim)
LIBDAISY_DIR = ../libDaisy     # Path to libDaisy (submodule)
BUILD_DIR = build              # Where outputs go
```

### Build Commands

```bash
make                 # Build TARGET.nim → build/TARGET.bin
make program-dfu     # Build and flash via USB
make program-stlink  # Build and flash via ST-Link
make clean           # Remove build directory
```

### nim.cfg

The `nim.cfg` file configures Nim for ARM cross-compilation:
- CPU architecture (ARM Cortex-M7)
- Compiler flags (optimization, warnings)
- Include paths (libDaisy headers)
- Linker settings

You usually don't need to edit this.

## Troubleshooting

### "arm-none-eabi-gcc: command not found"

ARM toolchain not installed or not in PATH.

**Fix:**
```bash
# macOS
brew install --cask gcc-arm-embedded

# Linux  
sudo apt-get install gcc-arm-none-eabi

# Then verify
arm-none-eabi-gcc --version
```

### "Cannot find libdaisy.a"

libDaisy submodule not initialized or not built.

**Fix:**
```bash
# Make sure submodule is initialized
cd ~/Projects/libdaisy_nim
git submodule update --init --recursive

# Build libDaisy
cd libDaisy
make
ls build/libdaisy.a     # Verify it exists
cd ..
```

If you're using a custom project, check that `LIBDAISY_DIR` in your Makefile points to the libDaisy directory (default is `../libDaisy` relative to your project).

### "dfu-util: Cannot open DFU device"

Daisy not in bootloader mode or USB not connected.

**Fix:**
1. Hold BOOT button
2. Press and release RESET (while holding BOOT)
3. Release BOOT
4. Try `make program-dfu` again

On Linux, you may need udev rules:
```bash
# Create udev rule
sudo cat > /etc/udev/rules.d/99-daisy.rules << 'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666"
EOF

sudo udevadm control --reload-rules
```

### "Binary size shows 0 bytes"

Build failed but error was hidden.

**Fix:**
```bash
make clean
make 2>&1 | less  # See full output
```

Look for Nim compilation errors or linker errors.

### "Error: cannot open file: src/libdaisy"

Import path incorrect.

**Fix:**
If your project is in a different location, adjust the import:
```nim
# If project is in examples/
import ../src/libdaisy

# If project is elsewhere
import /path/to/libdaisy_nim/src/libdaisy
```

Or use Nimble to install the package properly.

## Next Steps

Now that you have the basics working:

1. **Read the examples** - See `EXAMPLES.md` for detailed descriptions
2. **Learn the API** - Check `API_REFERENCE.md` for all available functions
3. **Understand internals** - Read `TECHNICAL_REPORT.md` to understand how it works
4. **Contribute** - See `CONTRIBUTING.md` if you want to help improve the wrapper

## Quick Reference

### Basic LED Blink

```nim
import src/libdaisy

var hw = newDaisySeed()

proc main() =
  hw.init()
  while true:
    hw.setLed(true)
    hw.delayMs(500)
    hw.setLed(false)
    hw.delayMs(500)

when isMainModule:
  main()
```

### Audio Passthrough

```nim
import src/libdaisy

var hw = newDaisySeed()

proc audioCallback(input: ptr ptr cfloat, output: ptr ptr cfloat, 
                   size: csize_t) {.cdecl.} =
  for i in 0..<size:
    output[0][i] = input[0][i]  # Left
    output[1][i] = input[1][i]  # Right

proc main() =
  hw.init()
  hw.startAudio(audioCallback)
  while true:
    hw.delayMs(100)

when isMainModule:
  main()
```

### GPIO Input

```nim
import src/libdaisy

var hw = newDaisySeed()

proc main() =
  hw.init()
  
  # Configure pin as input with pull-up
  var pin = hw.getPin(DPin10)
  pin.mode = PinMode.INPUT
  pin.pull = Pull.PULLUP
  pin.init()
  
  while true:
    let state = pin.read()
    hw.setLed(state)  # LED follows button
    hw.delayMs(10)

when isMainModule:
  main()
```

## Help & Support

**Need help?**
- Check the `EXAMPLES.md` file for example explanations
- Read `API_REFERENCE.md` for function documentation
- Search GitHub issues for similar problems
- Ask on the [Electro-Smith forum](https://forum.electro-smith.com/)
- Create a GitHub issue with your question

---

**Congratulations!** You're now ready to develop Daisy Seed firmware in Nim! 🎉

For more advanced topics, continue with:
- **[EXAMPLES.md](EXAMPLES.md)** - Detailed example walkthroughs
- **[API_REFERENCE.md](API_REFERENCE.md)** - Complete API documentation
- **[TECHNICAL_REPORT.md](TECHNICAL_REPORT.md)** - How the wrapper works

Happy coding! 🚀
