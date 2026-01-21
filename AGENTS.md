# AGENTS.md - Guide for AI Coding Agents

This document provides essential information for AI coding agents working on **libdaisy_nim**, 
a Nim wrapper for the libDaisy embedded audio platform (ARM Cortex-M7).

## Project Overview

- **Language**: Nim 2.0+ (cross-compiles to C++ for ARM Cortex-M7)
- **Target**: Daisy Seed hardware (STM32H750, bare metal)
- **Build System**: Makefile + nim.cfg
- **Memory Management**: ARC (Automatic Reference Counting)
- **Architecture**: FFI wrapper using `importcpp` pragmas

## Build Commands

### Primary Build Flow

**Location**: All build commands run from `examples/` directory

```bash
# Build current target (set TARGET in Makefile line 9)
make

# Clean build artifacts
make clean

# Flash to hardware via DFU (USB)
make program-dfu

# Flash to hardware via ST-Link
make program-stlink

# Build for different target (option 1 - edit Makefile)
# Edit examples/Makefile line 9: TARGET = your_example_name

# Build for different target (option 2 - sed command)
sed -i "s/^TARGET = .*/TARGET = your_example/" Makefile && make
```

### Testing Commands

```bash
# Compile all examples (compilation test suite)
cd examples
./test_all.sh

# Expected output: "Passed: N, Failed: 0"
```

### Running a Single Test

**No unit test framework exists.** Testing is example-based:

```bash
# To test a single example:
cd examples
sed -i "s/^TARGET = .*/TARGET = example_name/" Makefile
make clean && make

# If you have hardware:
make program-dfu  # Flash and test manually
```

### Build Artifacts

- **Build directory**: `examples/build/`
- **Generated files**: `.elf`, `.bin`, `.hex`, `.map`
- **Nim intermediate**: `build/*.cpp`, `build/*.o`

## Code Style Guidelines

### Naming Conventions

```nim
# Types: PascalCase with * for export
type DaisySeed* = object
type AdcHandle* = object

# Enums: UPPER_SNAKE_CASE or PascalCase for values
type PinMode* = enum
  INPUT = 0
  OUTPUT
  ANALOG

# Procedures: camelCase with * for export
proc setLed*(hw: var DaisySeed, state: bool)
proc initAdc*(channels: ptr AdcChannelConfig, count: csize_t): AdcHandle

# Constants: UPPER_SNAKE_CASE
const MAX_BUFFER_SIZE* = 1024
const DEFAULT_SAMPLE_RATE* = 48000

# Variables: camelCase
var ledState = false
var adcValue: float32
```

### Import Order

```nim
# 1. Standard library imports (if any)
# 2. libdaisy imports
import libdaisy
import libdaisy_macros
import libdaisy_adc
import libdaisy_i2c

# 3. Macro invocations (must come after imports)
useDaisyNamespace()      # For main application files
useDaisyModules(adc)     # For wrapper modules
```

### Type Definitions

Use `importcpp` pragma for C++ types:

```nim
type
  DaisySeed* {.importcpp: "daisy::DaisySeed",
               header: "daisy_seed.h".} = object
    ## Hardware abstraction for Daisy Seed board

  I2CHandle* {.importcpp: "daisy::I2CHandle".} = object
    ## I2C peripheral controller
```

### Procedure Wrappers

**Pattern**: Use `#` placeholder for `this` pointer:

```nim
proc init*(this: var DaisySeed) {.importcpp: "#.Init()".}
  ## Initialize Daisy Seed hardware

proc setLed*(this: var DaisySeed, state: bool) {.importcpp: "#.SetLed(#)".}
  ## Set onboard LED state

proc writeValue*(this: var DacHandle, channel: DacChannel, value: uint16) 
  {.importcpp: "#.WriteValue(#, #)".}
  ## Write 12-bit value to DAC channel
```

**Critical**: Each `#` represents an argument in order (this, arg1, arg2...)

### Documentation Comments

All public APIs MUST have `##` documentation:

```nim
proc importantFunction*(param: int): bool =
  ## Brief one-line description of what this does
  ## 
  ## More detailed explanation if needed. Can be multiple paragraphs.
  ## 
  ## **Parameters:**
  ## - `param` - Description of the parameter
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

### Module Structure (Wrapper Files)

**Standard pattern** for all `src/libdaisy_*.nim` files:

```nim
## ModuleName
## ==========
## 
## Brief description of what this module wraps.
## Include usage examples in module documentation.

# 1. Imports
import libdaisy
import libdaisy_macros

# 2. Macro invocations
useDaisyModules(feature_name)

# 3. Pragma blocks (optional)
{.push header: "daisy_seed.h".}
{.push importcpp.}

# 4. Type definitions
type
  MyType* = object

# 5. Constants
const MY_CONST* = 42

# 6. Procedures
proc myProc*() = discard

# 7. Close pragma blocks
{.pop.}
{.pop.}
```

### Formatting Rules

- **Indentation**: 2 spaces (Nim standard, NOT tabs)
- **Line length**: 80-100 characters preferred
- **Blank lines**: 
  - One blank line between procedures
  - Two blank lines between major sections
- **No linting tools**: No nimpretty config, manual formatting

### Error Handling

```nim
# Most C++ functions return void or bool
# Check bool returns:
if not peripheral.init(config):
  # Handle initialization failure
  discard

# For embedded: minimize exceptions, prefer result codes
# Use {.push raises: [].} if needed for no-exception code
```

### Type Mappings (C++ ↔ Nim)

```nim
# C++ Type          → Nim Type
# int               → cint
# float             → cfloat
# uint16_t          → uint16
# uint32_t          → uint32
# bool              → bool
# size_t            → csize_t
# enum              → enum with size pragma
```

### Pragma Usage Patterns

```nim
# Import C++ class
{.importcpp: "daisy::ClassName".}

# Import enum with size specification
{.importcpp: "daisy::EnumName", size: sizeof(cint).}

# Import C++ method (# = this pointer)
{.importcpp: "#.MethodName()".}

# Import C++ method with arguments
{.importcpp: "#.MethodName(#, #)".}

# Emit C++ code directly
{.emit: """
#include "header.h"
using namespace daisy;
""".}
```

## Adding New Wrappers

### Step-by-Step Process

1. **Study C++ interface** in `libDaisy/src/per/peripheral.h` or `libDaisy/src/dev/device.h`
2. **Create module** `src/libdaisy_peripheral.nim` or `src/dev/device_name.nim`
3. **Add types** using `importcpp` pragma
4. **Add procedures** with correct `importcpp` patterns
5. **Add macro support** to `src/libdaisy_macros.nim` for includes and typedefs
6. **Create example** in `examples/peripheral_test.nim`
7. **Document example in EXAMPLES.md** (see "Contributing New Examples" below)
8. **Test compilation** with `./test_all.sh`
9. **Document API** in module comments and `API_REFERENCE.md`

See CONTRIBUTING.md lines 99-317 for detailed tutorial.

### Common Pitfalls

```nim
# ❌ WRONG - Missing # for this pointer
proc init*(this: var DaisySeed) {.importcpp: "Init()".}

# ✅ CORRECT
proc init*(this: var DaisySeed) {.importcpp: "#.Init()".}

# ❌ WRONG - Not exported
proc setLed(this: var DaisySeed, state: bool)

# ✅ CORRECT - * exports symbol
proc setLed*(this: var DaisySeed, state: bool)

# ❌ WRONG - Wrong type mapping
proc getValue*(): int  # Should be cint for C++ int

# ✅ CORRECT
proc getValue*(): cint
```

## File Organization

```
libdaisy_nim/
├── src/                    # Wrapper modules (DO edit these)
│   ├── libdaisy.nim        # Core module
│   ├── libdaisy_*.nim      # Peripheral modules
│   └── libdaisy_macros.nim # Compile-time macro system
├── examples/               # Example programs (DO edit/add these)
│   ├── Makefile            # Build system (edit TARGET line 9)
│   ├── nim.cfg             # Nim compiler config (rarely edit)
│   ├── test_all.sh         # Test script (DO NOT edit)
│   └── *.nim               # Example programs
├── libDaisy/               # C++ library (DO NOT edit - submodule)
└── Documentation           # .md files (DO edit when adding features)
```

## Important Configuration Files

- **examples/Makefile**: Set `TARGET` variable (line 9) to select example
- **examples/nim.cfg**: Cross-compilation settings for ARM (rarely touch)
- **libdaisy_nim.nimble**: Package metadata (version, dependencies)

## No Cursor/Copilot Rules Found

No `.cursorrules`, `.cursor/rules/`, or `.github/copilot-instructions.md` files exist.

## Key Project Constraints

1. **Embedded target**: Code runs on bare metal (no OS, limited resources)
2. **Cross-compilation**: Always compiling for ARM, not host machine
3. **Zero-cost abstraction**: Nim wrappers must have no runtime overhead
4. **No exceptions**: Use `--mm:arc` and avoid exception-heavy code
5. **Hardware required**: Many features can't be fully tested without hardware

## Example Application Pattern

```nim
## Example description
import ../src/libdaisy
import ../src/libdaisy_peripheral  # If using specific peripheral

useDaisyNamespace()

proc main() =
  var daisy = initDaisy()
  # Setup code
  
  while true:
    # Main loop
    daisy.delay(100)

when isMainModule:
  main()
```

## References for Agents

- **CONTRIBUTING.md** (709 lines): Comprehensive wrapper development guide
- **API_REFERENCE.md**: Complete API documentation for all modules
- **TECHNICAL_REPORT.md**: Architecture and implementation details
- **examples/**: 27 working examples showing all features
