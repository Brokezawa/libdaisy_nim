# AGENTS.md - Guide for AI Coding Agents

This document provides essential information for AI coding agents working on **libdaisy_nim**, 
a Nim wrapper for the libDaisy embedded audio platform (ARM Cortex-M7).

## Project Philosophy: We Are a WRAPPER

**CRITICAL PRINCIPLE**: libdaisy_nim is a **WRAPPER** for the C++ libDaisy library, NOT a reimplementation.

### Default Approach: Wrap, Don't Rewrite

When adding new features, **ALWAYS** follow this decision tree:

1. ✅ **First, check if libDaisy already implements it**
   - Search `libDaisy/src/` for existing C++ classes/functions
   - If it exists in libDaisy → **wrap it with `importcpp`**
   - Do NOT reimplement functionality that already exists

2. ⚠️ **Only implement in pure Nim if:**
   - libDaisy doesn't provide the functionality at all, OR
   - The pure Nim approach is significantly simpler/cleaner, OR
   - Nim's features provide clear advantages (generics, compile-time, safety)

3. 📋 **Document your decision**
   - If choosing pure Nim over wrapping, explain why in code comments
   - Reference the architectural decision in module documentation

### Examples of Correct Approach

```nim
# ✅ CORRECT: Wrap existing libDaisy class
type
  PersistentStorage*[T] {.importcpp: "daisy::PersistentStorage<'0>",
                           header: "util/PersistentStorage.h".} = object

# ✅ CORRECT: Pure Nim for fixed-size data structures (better than C++ templates)
type
  RingBuffer*[N: static int, T] = object
    data: array[N, T]  # Nim generics are simpler than C++ templates here

# ❌ WRONG: Reimplementing libDaisy functionality
# Don't write your own PersistentStorage when libDaisy has one!
```

### How to Find Existing libDaisy Features

Before implementing ANY new module:

1. **Search libDaisy directory structure**:
   ```bash
   # Search for class/function names
   grep -r "ClassName" libDaisy/src/ --include="*.h"
   
   # List available modules
   ls libDaisy/src/per/   # Peripherals
   ls libDaisy/src/dev/   # Device drivers  
   ls libDaisy/src/hid/   # Human interface devices
   ls libDaisy/src/util/  # Utilities
   ```

2. **Check libDaisy documentation**:
   - Headers in `libDaisy/src/` contain doxygen comments
   - Read class/function descriptions before wrapping

3. **Look for C++ templates**:
   - Templates like `template<typename T> class Foo` can be wrapped with Nim generics
   - Use `importcpp: "daisy::Foo<'0>"` pattern

### Wrapper Quality Standards

When wrapping libDaisy functionality:

- ✅ Wrap ALL public methods of the C++ class
- ✅ Match C++ type signatures exactly (use C types: cint, cfloat, csize_t)
- ✅ Preserve C++ semantics (const, reference, pointer)
- ✅ Document which C++ header/class is being wrapped
- ✅ Include usage examples that match libDaisy patterns

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

# 2. Macro invocations - USE THE MACRO SYSTEM, NOT RAW EMIT!
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

### Using the Macro System (REQUIRED)

**CRITICAL**: All wrapper modules MUST use `src/libdaisy_macros.nim` for C++ headers and type definitions.

**❌ WRONG - Do NOT use raw emit blocks:**
```nim
# Don't do this!
{.emit: """
#include "per/spi.h"
using namespace daisy;
typedef SpiHandle::Result SpiResult;
typedef SpiHandle::Config SpiConfig;
""".}
```

**✅ CORRECT - Use the macro system:**
```nim
import libdaisy_macros
useDaisyModules(spi)  # Automatically includes headers and typedefs
```

### Adding Macro Support for New Modules

When wrapping a new libDaisy module, you MUST update `src/libdaisy_macros.nim`:

**Step 1: Add typedef list** (around line 15-160)
```nim
# Your module typedefs
const myModuleTypedefs* = [
  "MyClass::Result MyResult",
  "MyClass::Config MyConfig",
  "MyClass::Config::Mode MyMode"
]
```

**Step 2: Add header mapping** (in `getModuleHeaders()` around line 173)
```nim
proc getModuleHeaders*(moduleName: string): string =
  case moduleName
  # ... existing cases ...
  of "my_module":
    """#include "per/my_module.h"
"""
```

**Step 3: Add to useDaisyModules** (around line 427-500)

Add variable declaration:
```nim
var includeMyModule = false
```

Add case branch:
```nim
of "my_module": includeMyModule = true
```

Add to error message:
```nim
error("Unknown module: " & moduleName & 
      ". Available: core, controls, ..., my_module")
```

Add header inclusion:
```nim
if includeMyModule: headersStr.add(getModuleHeaders("my_module"))
```

Add typedef inclusion:
```nim
if includeMyModule: typedefsStr.add(buildTypedefsString(myModuleTypedefs))
```

**Step 4: Use in your wrapper module**
```nim
import libdaisy_macros
useDaisyModules(my_module)  # Now available!
```

### Real Example: QSPI Module

See `src/libdaisy_qspi.nim` and `src/libdaisy_macros.nim` for reference.

**In libdaisy_macros.nim:**
```nim
# Typedef list (line 104-108)
const qspiTypedefs* = [
  "QSPIHandle::Result QSPIResult",
  "QSPIHandle::Config::Mode QSPIMode",
  "QSPIHandle::Config::Device QSPIDevice"
]

# Header mapping (line 262-264)
of "qspi":
  """#include "per/qspi.h"
"""

# Variables, cases, and inclusions added to useDaisyModules
```

**In libdaisy_qspi.nim:**
```nim
import libdaisy_macros

useDaisyModules(qspi)  # ← One line replaces ~15 lines of emit code!

{.push header: "per/qspi.h".}
# ... rest of wrapper
```

### When Raw Emit IS Acceptable

**Only use `{.emit.}` blocks for:**

1. **C++ Operators** (cannot be exported from Nim)
   ```nim
   # For PersistentStorage dirty detection
   {.emit: """
   inline bool operator==(const MySettings& a, const MySettings& b) {
     return a.field1 == b.field1 && a.field2 == b.field2;
   }
   """.}
   ```
   See `examples/settings_manager.nim` for detailed explanation.

2. **Custom C++ Helper Functions** (rare cases)
   ```nim
   {.emit: """
   inline void customHelper() {
     // C++-specific logic that can't be wrapped
   }
   """.}
   ```

**Everything else MUST use the macro system.**

### Benefits of the Macro System

- ✅ **Consistency**: All modules use the same pattern
- ✅ **Maintainability**: Type definitions centralized in one file
- ✅ **Reduced Boilerplate**: ~15 lines → 1 line
- ✅ **Compile-time**: Zero runtime overhead
- ✅ **Type Safety**: Compile errors if module name is misspelled
- ✅ **Documentation**: Module dependencies are explicit

### Migration Checklist

When converting old emit-based code to macros:

- [ ] Identify all `{.emit.}` blocks with headers and typedefs
- [ ] Extract typedef list to `libdaisy_macros.nim`
- [ ] Add header mapping to `getModuleHeaders()`
- [ ] Add module support to `useDaisyModules()`
- [ ] Replace emit block with `useDaisyModules(module_name)`
- [ ] Test compilation with `make clean && make`
- [ ] Verify no typedef-related errors

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
2. **Add macro support FIRST** to `src/libdaisy_macros.nim`:
   - Add typedef list for your module's types
   - Add header mapping in `getModuleHeaders()`
   - Add module name to `useDaisyModules()` macro
   - See "Adding Macro Support for New Modules" section above
3. **Create module** `src/libdaisy_peripheral.nim` or `src/dev/device_name.nim`:
   - Import `libdaisy_macros`
   - Use `useDaisyModules(your_module)` - NO raw emit for headers!
   - Add types using `importcpp` pragma
   - Add procedures with correct `importcpp` patterns
4. **Create example** in `examples/peripheral_test.nim`
5. **Document example in EXAMPLES.md** (see "Contributing New Examples" below)
6. **Test compilation** with `./test_all.sh`
7. **Document API** in module comments and `API_REFERENCE.md`

**IMPORTANT**: Step 2 (macro support) is NOT optional. All modules must use the macro system.

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
