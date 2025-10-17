## libDaisy Nim Wrapper - C++ Interop Macros
##
## This module contains the compile-time macro system for automatic C++ type generation.
## It provides two macros:
## - useDaisyNamespace() - Include all typedefs (recommended)
## - useDaisyModules(...) - Selective inclusion of specific modules
##
## Users should import this module indirectly through libdaisy.nim

import macros

# ============================================================================
# Type Definition Lists - Organized by Module
# ============================================================================

# Core typedefs - always included
const coreTypedefs* = [
  "GPIO::Mode GPIOMode",
  "GPIO::Pull GPIOPull",
  "GPIO::Speed GPIOSpeed",
  "SaiHandle::Config::SampleRate SampleRate",
  "DaisySeed::BoardVersion BoardVersion"
]

# Controls module typedefs (switches, encoders)
const controlsTypedefs* = [
  "Switch::Type SwitchType",
  "Switch::Polarity SwitchPolarity",
  "GPIO::Pull SwitchPull"
]

# ADC module typedefs
const adcTypedefs* = [
  "AdcChannelConfig AdcChannelConfig",
  "AdcHandle::OverSampling OverSampling",
  "AdcChannelConfig::ConversionSpeed ConversionSpeed",
  "AdcChannelConfig::MuxPin MuxPin"
]

# I2C module typedefs
const i2cTypedefs* = [
  "I2CHandle::Config I2CConfig",
  "I2CHandle::Config::Speed I2CSpeed",
  "I2CHandle::Config::Peripheral I2CPeripheral",
  "I2CHandle::Config::Mode I2CMode",
  "I2CHandle::Result I2CResult"
]

# SPI module typedefs
const spiTypedefs* = [
  "SpiHandle::Config SpiConfig",
  "SpiHandle::Config::Peripheral SpiPeripheral",
  "SpiHandle::Config::Mode SpiMode",
  "SpiHandle::Config::ClockPolarity SpiClockPolarity",
  "SpiHandle::Config::ClockPhase SpiClockPhase",
  "SpiHandle::Config::Direction SpiDirection",
  "SpiHandle::Config::NSS SpiNSS",
  "SpiHandle::Config::BaudPrescaler SpiBaudPrescaler",
  "SpiHandle::Result SpiResult"
]

# SDRAM module typedefs
const sdramTypedefs* = [
  "SdramHandle::Result SdramResult"
]

# USB module typedefs
const usbTypedefs* = [
  "UsbHandle::Result UsbResult",
  "UsbHandle::UsbPeriph UsbPeriph"
]

# All typedefs combined (for full inclusion)
const daisyTypedefsList* = @coreTypedefs & @controlsTypedefs & @adcTypedefs & 
                           @i2cTypedefs & @spiTypedefs & @sdramTypedefs & @usbTypedefs

# ============================================================================
# C++ Header Includes
# ============================================================================

# Helper to get headers for a specific module
proc getModuleHeaders*(moduleName: string): string =
  ## Returns the C++ header includes needed for a specific module
  case moduleName
  of "core":
    """#include "daisy_seed.h"
"""
  of "controls":
    """#include "hid/switch.h"
#include "hid/encoder.h"
"""
  of "adc":
    """#include "per/adc.h"
"""
  of "i2c":
    """#include "per/i2c.h"
"""
  of "spi":
    """#include "per/spi.h"
"""
  of "serial":
    """#include "per/uart.h"
#include "hid/logger.h"
"""
  of "sdram":
    """#include "dev/sdram.h"
"""
  of "usb":
    """#include "hid/usb.h"
"""
  else: ""

# All headers combined (for full inclusion)
const daisyHeaders* = """
#include "daisy_seed.h"
#include "hid/switch.h"
#include "hid/encoder.h"
#include "hid/usb.h"
#include "dev/sdram.h"
#include "per/i2c.h"
#include "per/spi.h"
#include "per/uart.h"
#include "per/adc.h"
"""

# ============================================================================
# Helper Functions
# ============================================================================

# SDRAM helper function as C++ code
const sdramHelperFunction* = """
inline void clearSdramBss() {
    extern uint32_t _ssdram_bss;
    extern uint32_t _esdram_bss;
    uint32_t* start = &_ssdram_bss;
    uint32_t* end = &_esdram_bss;
    while(start < end) {
        *start++ = 0;
    }
}
"""

proc buildTypedefsString*(typedefs: openArray[string]): string =
  ## Helper to build typedef emit string from a list of typedefs
  result = ""
  for typedef in typedefs:
    result.add("typedef ")
    result.add(typedef)
    result.add(";\n")

# ============================================================================
# Public Macros
# ============================================================================

macro useDaisyNamespace*(): untyped =
  ## Automatically generates all necessary C++ emit statements for Daisy types.
  ## This macro runs at compile time and injects the required C++ code.
  ##
  ## **This is the recommended approach for most projects.**
  ##
  ## Includes:
  ## - All C++ headers for libDaisy modules
  ## - Namespace declaration (using namespace daisy;)
  ## - All 26 type aliases
  ## - Helper functions (clearSdramBss)
  ##
  ## Usage:
  ## ```nim
  ## import libdaisy
  ## useDaisyNamespace()  # One line - includes everything!
  ##
  ## proc main() =
  ##   var daisy = initDaisy()
  ##   # ... use any libDaisy features
  ## ```
  ##
  ## **Compile-time code generation** - Zero runtime cost!
  
  result = newStmtList()
  
  # 1. Emit header includes in INCLUDESECTION
  let includesEmit = newNimNode(nnkPragma)
  includesEmit.add(
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("emit"),
      newLit("/*INCLUDESECTION*/\n" & daisyHeaders)
    )
  )
  result.add(includesEmit)
  
  # 2. Emit namespace declaration
  let namespaceEmit = newNimNode(nnkPragma)
  namespaceEmit.add(
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("emit"),
      newLit("using namespace daisy;")
    )
  )
  result.add(namespaceEmit)
  
  # 3. Build and emit typedef section
  var typedefsStr = "/*TYPESECTION*/\nusing namespace daisy;\n"
  for typedef in daisyTypedefsList:
    typedefsStr.add("typedef ")
    typedefsStr.add(typedef)
    typedefsStr.add(";\n")
  
  let typedefsEmit = newNimNode(nnkPragma)
  typedefsEmit.add(
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("emit"),
      newLit(typedefsStr)
    )
  )
  result.add(typedefsEmit)
  
  # 4. Emit helper functions
  let helpersEmit = newNimNode(nnkPragma)
  helpersEmit.add(
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("emit"),
      newLit(sdramHelperFunction)
    )
  )
  result.add(helpersEmit)

macro useDaisyModules*(modules: varargs[untyped]): untyped =
  ## Selective inclusion - only includes typedefs for specified modules.
  ## This is more efficient than including everything.
  ##
  ## **Use this for minimal projects or when you want to reduce generated code size.**
  ##
  ## Available modules:
  ## - `core` - Always included automatically (GPIO, SampleRate, BoardVersion)
  ## - `controls` - Switches, encoders (Switch types)
  ## - `adc` - ADC types (AdcChannelConfig, OverSampling, etc.)
  ## - `i2c` - I2C types (Speed, Peripheral, Mode)
  ## - `spi` - SPI types (Peripheral, Mode, ClockPolarity, etc.)
  ## - `serial` - UART types
  ## - `sdram` - SDRAM types (Result, helper functions)
  ## - `usb` - USB types (Result, UsbPeriph)
  ##
  ## Usage:
  ## ```nim
  ## import libdaisy, libdaisy_i2c, libdaisy_spi
  ## useDaisyModules(i2c, spi)  # Only I2C and SPI typedefs
  ##
  ## proc main() =
  ##   var daisy = initDaisy()
  ##   var i2c = initI2C(...)
  ##   var spi = initSPI(...)
  ##   # ...
  ## ```
  ##
  ## **Generates minimal C++ code at compile time** - Only what you need!
  
  result = newStmtList()
  
  # Collect which modules to include
  var includeControls = false
  var includeAdc = false
  var includeI2c = false
  var includeSpi = false
  var includeSerial = false
  var includeSdram = false
  var includeUsb = false
  
  # Parse module arguments
  for module in modules:
    let moduleName = $module
    case moduleName
    of "controls": includeControls = true
    of "adc": includeAdc = true
    of "i2c": includeI2c = true
    of "spi": includeSpi = true
    of "serial": includeSerial = true
    of "sdram": includeSdram = true
    of "usb": includeUsb = true
    of "core": discard  # Always included
    else:
      error("Unknown module: " & moduleName & 
            ". Available: core, controls, adc, i2c, spi, serial, sdram, usb")
  
  # Build headers string
  var headersStr = "/*INCLUDESECTION*/\n"
  headersStr.add(getModuleHeaders("core"))
  if includeControls: headersStr.add(getModuleHeaders("controls"))
  if includeAdc: headersStr.add(getModuleHeaders("adc"))
  if includeI2c: headersStr.add(getModuleHeaders("i2c"))
  if includeSpi: headersStr.add(getModuleHeaders("spi"))
  if includeSerial: headersStr.add(getModuleHeaders("serial"))
  if includeSdram: headersStr.add(getModuleHeaders("sdram"))
  if includeUsb: headersStr.add(getModuleHeaders("usb"))
  
  # 1. Emit header includes
  let includesEmit = newNimNode(nnkPragma)
  includesEmit.add(
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("emit"),
      newLit(headersStr)
    )
  )
  result.add(includesEmit)
  
  # 2. Emit namespace
  let namespaceEmit = newNimNode(nnkPragma)
  namespaceEmit.add(
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("emit"),
      newLit("using namespace daisy;")
    )
  )
  result.add(namespaceEmit)
  
  # 3. Build typedefs string
  var typedefsStr = "/*TYPESECTION*/\nusing namespace daisy;\n"
  # Core is always included
  typedefsStr.add(buildTypedefsString(coreTypedefs))
  if includeControls: typedefsStr.add(buildTypedefsString(controlsTypedefs))
  if includeAdc: typedefsStr.add(buildTypedefsString(adcTypedefs))
  if includeI2c: typedefsStr.add(buildTypedefsString(i2cTypedefs))
  if includeSpi: typedefsStr.add(buildTypedefsString(spiTypedefs))
  if includeSdram: typedefsStr.add(buildTypedefsString(sdramTypedefs))
  if includeUsb: typedefsStr.add(buildTypedefsString(usbTypedefs))
  
  let typedefsEmit = newNimNode(nnkPragma)
  typedefsEmit.add(
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("emit"),
      newLit(typedefsStr)
    )
  )
  result.add(typedefsEmit)
  
  # 4. Emit helper functions if sdram is included
  if includeSdram:
    let helpersEmit = newNimNode(nnkPragma)
    helpersEmit.add(
      newNimNode(nnkExprColonExpr).add(
        newIdentNode("emit"),
        newLit(sdramHelperFunction)
      )
    )
    result.add(helpersEmit)
