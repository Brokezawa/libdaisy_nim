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

# PWM module typedefs
const pwmTypedefs* = [
  "PWMHandle PwmHandle",
  "PWMHandle::Config PwmConfig",
  "PWMHandle::Config::Peripheral PwmPeripheral",
  "PWMHandle::Result PwmResult",
  "PWMHandle::Channel PwmChannel",
  "PWMHandle::Channel::Config PwmChannelConfig",
  "PWMHandle::Channel::Config::Polarity PwmPolarity"
]

# OLED module typedefs
const oledTypedefs* = [
  "SSD130xI2CTransport SSD130xI2CTransport",
  "SSD130xI2CTransport::Config SSD130xI2CTransportConfig",
  "SSD130x4WireSpiTransport SSD130x4WireSpiTransport",
  "SSD130x4WireSpiTransport::Config SSD130x4WireSpiTransportConfig",
  "SSD130xI2c128x64Driver OledDisplay128x64I2c",
  "SSD130xI2c128x32Driver OledDisplay128x32I2c",
  "SSD130xI2c64x48Driver OledDisplay64x48I2c",
  "SSD130xI2c64x32Driver OledDisplay64x32I2c",
  "SSD130x4WireSpi128x64Driver OledDisplay128x64Spi",
  "SSD130x4WireSpi128x32Driver OledDisplay128x32Spi",
  "SSD130x4WireSpi64x48Driver OledDisplay64x48Spi",
  "SSD130x4WireSpi64x32Driver OledDisplay64x32Spi",
  "SSD130xI2c128x64Driver::Config OledDisplayI2cConfig",
  "SSD130x4WireSpi128x64Driver::Config OledDisplaySpiConfig"
]

# I2C module typedefs
const i2cTypedefs* = [
  "I2CHandle I2CHandle",
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

# SDMMC module typedefs
const sdmmcTypedefs* = [
  "SdmmcHandler::Result SdmmcResult",
  "SdmmcHandler::BusWidth SdmmcBusWidth",
  "SdmmcHandler::Speed SdmmcSpeed",
  "SdmmcHandler::Config SdmmcConfig",
  "SdmmcHandler SdmmcHandler",
  "FatFSInterface::Result FatFSResult",
  "FatFSInterface::Config::Media FatFSMedia",
  "FatFSInterface::Config FatFSConfig",
  "FatFSInterface FatFSInterface"
]

# Codec module typedefs
const codec_ak4556Typedefs* : seq[string] = @[]
const codec_wm8731Typedefs* = [
  "Wm8731::Result Wm8731Result",
  "Wm8731::Config Wm8731Config",
  "Wm8731::Config::Format Wm8731Format",
  "Wm8731::Config::WordLength Wm8731WordLength"
]
const codec_pcm3060Typedefs* = [
  "Pcm3060::Result Pcm3060Result"
]

# LCD module typedefs
const lcd_hd44780Typedefs* = [
  "LcdHD44780::Config LcdHD44780Config"
]

# OLED fonts module typedefs
const oled_fontsTypedefs* = [
  "FontDef FontDef"
]

# All typedefs combined (for full inclusion)
const daisyTypedefsList* = @coreTypedefs & @controlsTypedefs & @adcTypedefs & @pwmTypedefs &
                           @oledTypedefs & @i2cTypedefs & @spiTypedefs & @sdramTypedefs & @usbTypedefs & @sdmmcTypedefs &
                           @codec_wm8731Typedefs & @codec_pcm3060Typedefs & @lcd_hd44780Typedefs & @oled_fontsTypedefs

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
  of "pwm":
    """#include "per/pwm.h"
"""
  of "oled":
    """#include "dev/oled_ssd130x.h"
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
  of "codec_ak4556":
    """#include "dev/codec_ak4556.h"
"""
  of "codec_wm8731":
    """#include "dev/codec_wm8731.h"
"""
  of "codec_pcm3060":
    """#include "dev/codec_pcm3060.h"
"""
  of "lcd_hd44780":
    """#include "dev/lcd_hd44780.h"
"""
  of "oled_fonts":
    """#include "util/oled_fonts.h"
"""
  of "icm20948":
    """#include "dev/icm20948.h"
"""
  of "apds9960":
    """#include "dev/apds9960.h"
"""
  of "dps310":
    """#include "dev/dps310.h"
"""
  of "tlv493d":
    """#include "dev/tlv493d.h"
"""
  of "mpr121":
    """#include "dev/mpr121.h"
"""
  of "neotrellis":
    """#include "dev/neotrellis.h"
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
#include "per/pwm.h"
#include "dev/oled_ssd130x.h"
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
  ## - `pwm` - PWM types (PwmPeripheral, PwmChannel, etc.)
  ## - `oled` - OLED display types (OledDisplay128x64I2c, etc.)
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
  var includePwm = false
  var includeOled = false
  var includeI2c = false
  var includeSpi = false
  var includeSerial = false
  var includeSdram = false
  var includeUsb = false
  var includeCodecAk4556 = false
  var includeCodecWm8731 = false
  var includeCodecPcm3060 = false
  var includeLcdHd44780 = false
  var includeOledFonts = false
  var includeIcm20948 = false
  var includeApds9960 = false
  var includeDps310 = false
  var includeTlv493d = false
  var includeMpr121 = false
  var includeNeotrellis = false
  
  # Parse module arguments
  for module in modules:
    let moduleName = $module
    case moduleName
    of "controls": includeControls = true
    of "adc": includeAdc = true
    of "pwm": includePwm = true
    of "oled": includeOled = true
    of "i2c": includeI2c = true
    of "spi": includeSpi = true
    of "serial": includeSerial = true
    of "sdram": includeSdram = true
    of "usb": includeUsb = true
    of "codec_ak4556": includeCodecAk4556 = true
    of "codec_wm8731": includeCodecWm8731 = true
    of "codec_pcm3060": includeCodecPcm3060 = true
    of "lcd_hd44780": includeLcdHd44780 = true
    of "oled_fonts": includeOledFonts = true
    of "icm20948": includeIcm20948 = true
    of "apds9960": includeApds9960 = true
    of "dps310": includeDps310 = true
    of "tlv493d": includeTlv493d = true
    of "mpr121": includeMpr121 = true
    of "neotrellis": includeNeotrellis = true
    of "core": discard  # Always included
    else:
      error("Unknown module: " & moduleName & 
            ". Available: core, controls, adc, pwm, oled, i2c, spi, serial, sdram, usb, " &
            "codec_ak4556, codec_wm8731, codec_pcm3060, lcd_hd44780, oled_fonts, " &
            "icm20948, apds9960, dps310, tlv493d, mpr121, neotrellis")
  
  # Build headers string
  var headersStr = "/*INCLUDESECTION*/\n"
  headersStr.add(getModuleHeaders("core"))
  if includeControls: headersStr.add(getModuleHeaders("controls"))
  if includeAdc: headersStr.add(getModuleHeaders("adc"))
  if includePwm: headersStr.add(getModuleHeaders("pwm"))
  if includeOled: headersStr.add(getModuleHeaders("oled"))
  if includeI2c: headersStr.add(getModuleHeaders("i2c"))
  if includeSpi: headersStr.add(getModuleHeaders("spi"))
  if includeSerial: headersStr.add(getModuleHeaders("serial"))
  if includeSdram: headersStr.add(getModuleHeaders("sdram"))
  if includeUsb: headersStr.add(getModuleHeaders("usb"))
  if includeCodecAk4556: headersStr.add(getModuleHeaders("codec_ak4556"))
  if includeCodecWm8731: headersStr.add(getModuleHeaders("codec_wm8731"))
  if includeCodecPcm3060: headersStr.add(getModuleHeaders("codec_pcm3060"))
  if includeLcdHd44780: headersStr.add(getModuleHeaders("lcd_hd44780"))
  if includeOledFonts: headersStr.add(getModuleHeaders("oled_fonts"))
  if includeIcm20948: headersStr.add(getModuleHeaders("icm20948"))
  if includeApds9960: headersStr.add(getModuleHeaders("apds9960"))
  if includeDps310: headersStr.add(getModuleHeaders("dps310"))
  if includeTlv493d: headersStr.add(getModuleHeaders("tlv493d"))
  if includeMpr121: headersStr.add(getModuleHeaders("mpr121"))
  if includeNeotrellis: headersStr.add(getModuleHeaders("neotrellis"))
  
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
  if includePwm: typedefsStr.add(buildTypedefsString(pwmTypedefs))
  if includeOled: typedefsStr.add(buildTypedefsString(oledTypedefs))
  if includeI2c: typedefsStr.add(buildTypedefsString(i2cTypedefs))
  if includeSpi: typedefsStr.add(buildTypedefsString(spiTypedefs))
  if includeSdram: typedefsStr.add(buildTypedefsString(sdramTypedefs))
  if includeUsb: typedefsStr.add(buildTypedefsString(usbTypedefs))
  if includeCodecWm8731: typedefsStr.add(buildTypedefsString(codec_wm8731Typedefs))
  if includeCodecPcm3060: typedefsStr.add(buildTypedefsString(codec_pcm3060Typedefs))
  if includeLcdHd44780: typedefsStr.add(buildTypedefsString(lcd_hd44780Typedefs))
  if includeOledFonts: typedefsStr.add(buildTypedefsString(oled_fontsTypedefs))
  
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

# ============================================================================
# Module-Specific Include Macros
# ============================================================================

macro emitDacIncludes*(): untyped =
  ## Emit DAC header includes when useDac is defined
  when defined(useDac):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "per/dac.h"
""".}
  else:
    result = newStmtList()

macro emitWavFormatIncludes*(): untyped =
  ## Emit WAV format header includes when useWavFormat is defined
  when defined(useWavFormat):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/wav_format.h"
""".}
  else:
    result = newStmtList()

macro emitPatchIncludes*(): untyped =
  ## Emit Daisy Patch header includes when usePatch is defined
  when defined(usePatch):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "daisy_patch.h"
""".}
  else:
    result = newStmtList()

macro emitRNGIncludes*(): untyped =
  ## Emit RNG header includes when useRNG is defined
  when defined(useRNG):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "per/rng.h"
""".}
  else:
    result = newStmtList()

macro emitTimerIncludes*(): untyped =
  ## Emit Timer header includes when useTimer is defined
  when defined(useTimer):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "per/tim.h"
""".}
  else:
    result = newStmtList()

macro emitColorIncludes*(): untyped =
  ## Emit Color header includes when useColor is defined
  when defined(useColor):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/color.h"
""".}
  else:
    result = newStmtList()

macro emitGateInIncludes*(): untyped =
  ## Emit GateIn header includes when useGateIn is defined
  when defined(useGateIn):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "hid/gatein.h"
""".}
  else:
    result = newStmtList()

macro emitLedIncludes*(): untyped =
  ## Emit Led header includes when useLed is defined
  when defined(useLed):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "hid/led.h"
""".}
  else:
    result = newStmtList()

macro emitRgbLedIncludes*(): untyped =
  ## Emit RgbLed header includes when useRgbLed is defined
  when defined(useRgbLed):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "hid/rgb_led.h"
""".}
  else:
    result = newStmtList()

macro emitSwitchIncludes*(): untyped =
  ## Emit Switch header includes when useSwitch is defined
  when defined(useSwitch):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "hid/switch.h"
""".}
  else:
    result = newStmtList()

macro emitSwitch3Includes*(): untyped =
  ## Emit Switch3 header includes when useSwitch3 is defined
  when defined(useSwitch3):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "hid/switch3.h"
""".}
  else:
    result = newStmtList()

macro emitUniqueIdIncludes*(): untyped =
  ## Emit UniqueId header includes when useUniqueId is defined
  when defined(useUniqueId):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/unique_id.h"
""".}
  else:
    result = newStmtList()

macro emitCpuLoadIncludes*(): untyped =
  ## Emit CpuLoadMeter header includes when useCpuLoad is defined
  when defined(useCpuLoad):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/CpuLoadMeter.h"
""".}
  else:
    result = newStmtList()

macro emitParameterIncludes*(): untyped =
  ## Emit Parameter header includes when useParameter is defined
  when defined(useParameter):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "hid/parameter.h"
""".}
  else:
    result = newStmtList()

macro emitMappedValueIncludes*(): untyped =
  ## Emit MappedValue header includes when useMappedValue is defined
  when defined(useMappedValue):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/MappedValue.h"
""".}
  else:
    result = newStmtList()

macro emitWavParserIncludes*(): untyped =
  ## Emit WavParser header includes when useWavParser is defined
  when defined(useWavParser):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/WavParser.h"
#include "util/FileReader.h"
""".}
  else:
    result = newStmtList()

macro emitWavPlayerIncludes*(): untyped =
  ## Emit WavPlayer header includes when useWavPlayer is defined
  when defined(useWavPlayer):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/WavPlayer.h"
""".}
  else:
    result = newStmtList()

macro emitWavWriterIncludes*(): untyped =
  ## Emit WavWriter header includes when useWavWriter is defined
  when defined(useWavWriter):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/WavWriter.h"
""".}
  else:
    result = newStmtList()

macro emitWaveTableLoaderIncludes*(): untyped =
  ## Emit WaveTableLoader header includes when useWaveTableLoader is defined
  when defined(useWaveTableLoader):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "util/WaveTableLoader.h"
""".}
  else:
    result = newStmtList()

macro emitQSPIIncludes*(): untyped =
  ## Emit QSPI header includes when useQSPI is defined
  when defined(useQSPI):
    result = quote do:
      {.emit: """/*INCLUDESECTION*/
#include "per/qspi.h"
""".}
  else:
    result = newStmtList()
