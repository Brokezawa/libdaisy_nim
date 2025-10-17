# Contributing to libdaisy_nim

Thank you for your interest in contributing! This guide will help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Wrapper Development Guide](#wrapper-development-guide)
- [Testing Requirements](#testing-requirements)
- [Code Style Guidelines](#code-style-guidelines)
- [Documentation Standards](#documentation-standards)
- [Submitting Changes](#submitting-changes)
- [Areas Needing Help](#areas-needing-help)

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to learn and build cool things together!

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- [ ] Nim 2.0 or later installed
- [ ] ARM toolchain (`arm-none-eabi-gcc`)
- [ ] libDaisy built and working
- [ ] Daisy Seed hardware (recommended for testing)
- [ ] Git and GitHub account

### Fork and Clone

```bash
# Fork the repository on GitHub first

# Clone your fork
git clone https://github.com/YOUR_USERNAME/libdaisy_nim
cd libdaisy_nim

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL/libdaisy_nim
```

## Development Setup

### 1. Build libDaisy

```bash
cd /path/to/libDaisy
make
```

### 2. Test Current Examples

```bash
cd /path/to/libdaisy_nim/examples
./test_all_clean.sh
```

All examples should compile successfully.

### 3. Create a Branch

```bash
git checkout -b feature/my-new-feature
# or
git checkout -b fix/bug-description
```

## How to Contribute

### Types of Contributions

**1. New Peripheral Wrappers**
- Wrap a libDaisy peripheral (ADC, DAC, PWM, etc.)
- See "Wrapper Development Guide" below

**2. New Examples**
- Demonstrate a feature or use case
- Follow existing example structure

**3. Bug Fixes**
- Fix compilation errors
- Fix runtime issues
- Improve error handling

**4. Documentation**
- Improve existing docs
- Add API documentation
- Create tutorials

**5. Testing**
- Add test cases
- Test on real hardware
- Report bugs

## Wrapper Development Guide

### Understanding the Pattern

All wrappers follow this structure:

**1. Type Definitions** (in module)

```nim
type
  MyPeripheral* {.importcpp: "daisy::MyPeripheral", 
                  header: "per/myperipheral.h".} = object
    ## Brief description
    
  MyConfig* {.importcpp: "daisy::MyPeripheral::Config".} = object
    ## Configuration structure
    field1*: cint
    field2*: bool
```

**2. Constants and Enums**

```nim
type
  MyMode* = enum
    MODE_A = 0
    MODE_B = 1
    MODE_C = 2
```

**3. Procedures**

```nim
proc init*(this: var MyPeripheral, config: MyConfig): bool 
  {.importcpp: "#.Init(#)".} =
  ## Initialize the peripheral
  ## 
  ## **Parameters:**
  ## - `config` - Configuration structure
  ## 
  ## **Returns:** true on success
  discard

proc read*(this: var MyPeripheral): cint 
  {.importcpp: "#.Read()".} =
  ## Read from peripheral
  ## 
  ## **Returns:** Read value
  discard
```

**4. Macro for Includes**

In `libdaisy_macros.nim`, add:

```nim
macro emitMyPeripheralIncludes*(): untyped =
  when defined(useMyPeripheral):
    result = quote do:
      {.emit: """
      #include "per/myperipheral.h"
      """.}
  else:
    result = newStmtList()
```

**5. Module Setup**

At top of your module file:

```nim
import libdaisy_macros

{.define: useMyPeripheral.}
emitMyPeripheralIncludes()
```

### Step-by-Step: Adding a New Peripheral

Let's wrap the DAC as an example:

**Step 1: Study the C++ Interface**

Look at `libDaisy/src/per/dac.h`:

```cpp
namespace daisy {
class DacHandle {
public:
    enum Channel { CHN_1, CHN_2, CHN_BOTH };
    
    struct Config {
        Channel chn;
        Mode mode;
    };
    
    void Init(Config config);
    void WriteValue(Channel channel, uint16_t value);
};
}
```

**Step 2: Create Nim Types**

```nim
# In src/libdaisy_dac.nim
import libdaisy_macros

type
  DacChannel* = enum
    DAC_CHN_1 = 0
    DAC_CHN_2 = 1
    DAC_CHN_BOTH = 2
  
  DacHandle* {.importcpp: "daisy::DacHandle",
                header: "per/dac.h".} = object
  
  DacConfig* {.importcpp: "daisy::DacHandle::Config".} = object
    chn*: DacChannel
```

**Step 3: Add Procedures**

```nim
proc init*(this: var DacHandle, config: DacConfig) 
  {.importcpp: "#.Init(#)".} =
  ## Initialize DAC
  discard

proc writeValue*(this: var DacHandle, channel: DacChannel, value: uint16) 
  {.importcpp: "#.WriteValue(#, #)".} =
  ## Write value to DAC channel
  discard
```

**Step 4: Add Macro**

In `src/libdaisy_macros.nim`:

```nim
macro emitDacIncludes*(): untyped =
  when defined(useDAC):
    result = quote do:
      {.emit: """
      #include "per/dac.h"
      """.}
  else:
    result = newStmtList()
```

**Step 5: Use Macro in Module**

At top of `libdaisy_dac.nim`:

```nim
{.define: useDAC.}
emitDacIncludes()
```

**Step 6: Create Example**

Create `examples/dac_simple_clean.nim`:

```nim
import ../src/libdaisy
import ../src/libdaisy_dac

var hw = newDaisySeed()
var dac: DacHandle

proc main() =
  hw.init()
  
  var dacCfg: DacConfig
  dacCfg.chn = DAC_CHN_1
  dac.init(dacCfg)
  
  var value: uint16 = 0
  while true:
    dac.writeValue(DAC_CHN_1, value)
    value = (value + 100) mod 4096
    hw.delayMs(10)

when isMainModule:
  main()
```

**Step 7: Test**

```bash
cd examples
# Update Makefile TARGET
sed -i 's/TARGET = .*/TARGET = dac_simple_clean/' Makefile
make
# Test on hardware
make program-dfu
```

**Step 8: Document**

Add to `API_REFERENCE.md`:

```markdown
### DAC (libdaisy_dac.nim)

Digital to Analog Converter for CV outputs.

**Types:**
- `DacHandle` - DAC controller
- `DacChannel` - Channel selection (CHN_1, CHN_2, CHN_BOTH)
- `DacConfig` - Configuration structure

**Functions:**
- `init(dac, config)` - Initialize DAC
- `writeValue(dac, channel, value)` - Write 12-bit value (0-4095)

**Example:** See `examples/dac_simple_clean.nim`
```

### Common Pitfalls

**1. Forgetting the Macro**

If you forget `emitDacIncludes()`, you'll get:
```
Error: undeclared identifier: 'DacHandle'
```

**Solution:** Add the macro call at module top.

**2. Wrong C++ Signature**

If the `importcpp` pattern is wrong:
```nim
# WRONG
proc init*(this: var DacHandle) {.importcpp: "Init".}

# RIGHT
proc init*(this: var DacHandle) {.importcpp: "#.Init()".}
```

The `#` is crucial - it represents the object.

**3. Type Mismatches**

Ensure Nim types match C++ types:
- `cint` → `int`
- `cfloat` → `float`
- `uint16` → `uint16_t`
- `bool` → `bool`

**4. Missing Exports**

Remember the `*` for public symbols:
```nim
# WRONG (not exported)
proc init(this: var DacHandle)

# RIGHT (exported)
proc init*(this: var DacHandle)
```

## Testing Requirements

### Compilation Tests

All examples must compile:

```bash
cd examples
./test_all_clean.sh
```

Expected output:
```
========================================
SUMMARY:
  Passed: 14
  Failed: 0
========================================
```

### Hardware Tests

If you have hardware, test your feature:

1. **Does it compile?**
2. **Does it upload?**
3. **Does it work as expected?**
4. **Are there any errors or warnings?**

Document test results in your PR.

### Regression Tests

Ensure you haven't broken existing functionality:

```bash
# Test that existing examples still compile
./test_all_clean.sh

# Try 2-3 existing examples on hardware
make TARGET=blink_clean program-dfu
make TARGET=i2c_scanner_clean program-dfu
```

## Code Style Guidelines

### Naming Conventions

```nim
# Types: PascalCase with * for export
type DaisySeed* = object

# Enums: PascalCase
type PinMode* = enum
  INPUT
  OUTPUT
  ANALOG

# Procedures: camelCase with * for export
proc setLed*(hw: var DaisySeed, state: bool)

# Constants: UPPER_SNAKE_CASE
const MAX_BUFFER_SIZE* = 1024

# Variables: camelCase
var myValue = 42
```

### Code Organization

**Module Structure:**

```nim
## Module documentation
## 
## Detailed description of what this module does.

# 1. Imports
import libdaisy_macros

# 2. Type definitions
type
  MyType* = object

# 3. Constants
const MY_CONST* = 42

# 4. Macro calls
{.define: useMyFeature.}
emitMyFeatureIncludes()

# 5. Procedures
proc myProc*() = discard
```

### Documentation Comments

Use `##` for documentation:

```nim
proc importantFunction*(param: int): bool =
  ## Brief one-line description
  ## 
  ## More detailed explanation if needed.
  ## Multiple paragraphs okay.
  ## 
  ## **Parameters:**
  ## - `param` - Description of parameter
  ## 
  ## **Returns:** Description of return value
  ## 
  ## **Example:**
  ## ```nim
  ## if importantFunction(42):
  ##   echo "Success!"
  ## ```
  result = true
```

### Formatting

- **Indentation:** 2 spaces (Nim standard)
- **Line length:** 80-100 characters preferred
- **Blank lines:** One between procedures, two between sections

```nim
# Good
proc foo*() =
  let x = 42
  echo x

proc bar*() =
  let y = 24
  echo y


# Section separator
const CONSTANT = 1
```

## Documentation Standards

### What to Document

**1. Module-Level**

Every `.nim` file should start with:

```nim
## ModuleName
## ==========
## 
## Brief description of module purpose.
##
## Detailed explanation of what it wraps, how to use it.
## 
## **Example:**
## ```nim
## import src/mymodule
## 
## var obj = newMyObject()
## obj.doSomething()
## ```
```

**2. Type Definitions**

```nim
type
  MyType* = object
    ## Description of what this type represents
    ##
    ## **Fields:**
    ## - `field1` - Description
    field1*: int
```

**3. Procedures**

All public procs need documentation (see above).

**4. Examples**

Every new feature needs an example in `examples/`.

**5. API Reference**

Add entry to `API_REFERENCE.md` for new modules/features.

## Submitting Changes

### Before Submitting

Checklist:

- [ ] Code compiles without errors
- [ ] All existing examples still compile
- [ ] New feature has an example
- [ ] Code is documented
- [ ] API_REFERENCE.md updated (if needed)
- [ ] Tested on hardware (if possible)
- [ ] Commit messages are clear

### Commit Messages

Use clear, descriptive commit messages:

```bash
# Good
git commit -m "Add DAC wrapper with example"
git commit -m "Fix I2C timeout handling"
git commit -m "Update SPI documentation"

# Bad  
git commit -m "stuff"
git commit -m "wip"
git commit -m "fix"
```

Format:
```
Short summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain what changed and why.

- Bullet points okay
- For multiple changes

Fixes #123  # Reference issue if applicable
```

### Pull Request Process

1. **Push to your fork**
```bash
git push origin feature/my-new-feature
```

2. **Create PR on GitHub**
- Go to original repository
- Click "New Pull Request"
- Select your fork and branch
- Fill in description

3. **PR Description Template**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Other (describe)

## Testing
- [ ] All examples compile
- [ ] Tested on hardware (describe results)
- [ ] Added new example for feature

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No breaking changes to existing API
- [ ] Commits are clean and clear

## Additional Notes
Any other information...
```

4. **Respond to Reviews**
- Be open to feedback
- Make requested changes
- Push updates to same branch

5. **Merge**
- Maintainer will merge when approved
- Your contribution is now part of the project!

## Areas Needing Help

### High Priority

**1. ADC Wrapper**
- **Files:** `src/per/adc.h`
- **Difficulty:** Medium
- **Impact:** High (needed for CV inputs, knobs)
- **Status:** Not started

**2. PWM Wrapper**
- **Files:** `src/per/pwm.h`
- **Difficulty:** Low
- **Impact:** Medium (LED dimming, motor control)
- **Status:** Not started

**3. OLED Display Driver**
- **Files:** `src/dev/oled_ssd130x.h`
- **Difficulty:** Medium
- **Impact:** High (visual feedback)
- **Status:** Not started

### Medium Priority

**4. DAC Wrapper**
- **Files:** `src/per/dac.h`
- **Difficulty:** Low
- **Impact:** Medium (CV outputs)
- **Status:** Not started

**5. WavPlayer Utility**
- **Files:** `src/util/wavplayer.h`
- **Difficulty:** Medium
- **Impact:** High (audio playback)
- **Status:** Not started

**6. More Board Support**
- **Files:** `src/daisy_patch.h`, etc.
- **Difficulty:** Low to Medium
- **Impact:** Medium (community value)
- **Status:** Daisy Patch partially documented

### Low Priority (But Welcome!)

**7. Additional Device Drivers**
- IMU, codecs, sensors, etc.
- See TECHNICAL_REPORT.md for full list

**8. UI Framework Wrapper**
- Menu system
- Button/Pot monitoring

**9. More Examples**
- Complex audio processing
- Multi-peripheral integration
- Real-world applications

**10. Documentation**
- Tutorials
- API reference expansion
- Example explanations

## Getting Help

**Questions?**
- Open a GitHub Discussion
- Comment on relevant issue
- Ask in Electro-Smith forum

**Stuck?**
- Look at existing wrappers for patterns
- Check TECHNICAL_REPORT.md for details
- Ask for help - we're friendly!

**Found a Bug?**
- Open an issue with details
- Include code to reproduce
- Mention your setup (OS, Nim version, etc.)

## Recognition

Contributors will be:
- Listed in project documentation
- Credited in release notes
- Part of the community!

Thank you for contributing to libdaisy_nim! 🎉

---

**Ready to start?** Pick an item from "Areas Needing Help" and open an issue to claim it!
