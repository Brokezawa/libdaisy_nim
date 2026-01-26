## Persistent Settings Manager Example
## ====================================
##
## Demonstrates persistent settings storage in QSPI flash memory.
## Shows how to create type-safe settings that survive power cycles.
##
## **Hardware Required:**
## - Daisy Seed (any version)
## - USB connection for serial output
##
## **Key Features Demonstrated:**
## - QSPI flash initialization in memory-mapped mode
## - Factory default settings
## - Dirty detection (only writes when changed)
## - Settings state tracking (UNKNOWN/FACTORY/USER)
## - Factory reset functionality
##
## **Expected Behavior:**
## - First boot: Writes factory defaults, shows "FACTORY" state
## - Subsequent boots: Loads saved settings, shows "USER" state
## - LED turns on when example completes successfully

import ../src/libdaisy
import ../src/libdaisy_qspi
import ../src/libdaisy_persistent_storage
import ../src/libdaisy_serial

useDaisyNamespace()

# =============================================================================
# Settings Type Definition
# =============================================================================

type
  SynthSettings {.bycopy, exportc: "SynthSettings".} = object
    ## Settings structure for a synthesizer
    ## 
    ## **IMPORTANT**: Settings structs for PersistentStorage must:
    ## - Use only POD (Plain Old Data) types: cfloat, cint, uint8, etc.
    ## - Avoid Nim types: string, seq, ref, ptr
    ## - Mark with {.bycopy, exportc.} for stable C++ compatibility
    ## - Mark all fields with {.exportc.}
    gain {.exportc.}: cfloat        ## Output gain (0.0 - 1.0)
    frequency {.exportc.}: cfloat   ## Base frequency in Hz
    waveform {.exportc.}: uint8     ## Waveform type (0-3)

# =============================================================================
# C++ Comparison Operators (Required for PersistentStorage)
# =============================================================================
#
# **Why this emit block is necessary:**
#
# The PersistentStorage<T> class uses C++ operator== internally to detect if
# settings have changed (dirty detection). When you call storage.save(), it
# compares the current settings against what's in flash using operator==.
#
# Nim cannot export C++ operators using {.exportcpp.} or {.exportc.} because:
# 1. Nim generates functions with Nim calling conventions (N_NIMCALL)
# 2. C++ operators require specific signatures with const& parameters
# 3. Operators must have C++ linkage, not extern "C" linkage
# 4. Nim's FFI doesn't support the exact C++ operator syntax
#
# Therefore, this small emit block is the **correct and only** solution for
# defining C++ operators that PersistentStorage can use.
#
# **Pattern to follow for your own settings:**
# 1. Compare all fields with && (logical AND)
# 2. Use const references (const SettingsType& a)
# 3. Mark as inline for performance
# 4. Define operator!= in terms of operator==
#
# **This is NOT boilerplate** - it's a necessary C++ FFI boundary.
# =============================================================================

{.emit: """
inline bool operator==(const SynthSettings& a, const SynthSettings& b) {
  return a.gain == b.gain && 
         a.frequency == b.frequency && 
         a.waveform == b.waveform;
}

inline bool operator!=(const SynthSettings& a, const SynthSettings& b) {
  return !(a == b);
}
""".}

proc main() =
  # Initialize
  var daisy = initDaisy()
  startLog()
  daisy.delay(100)
  
  printLine("Persistent Settings Example")
  printLine("===========================")
  
  # Initialize QSPI in memory-mapped mode
  var qspi: libdaisy_qspi.QSPIHandle
  var qspiConfig = libdaisy_qspi.QSPIConfig(
    device: libdaisy_qspi.QSPIDevice.IS25LP064A,
    mode: libdaisy_qspi.QSPIMode.MEMORY_MAPPED
  )
  
  print("Initializing QSPI...")
  if qspi.init(qspiConfig) != libdaisy_qspi.QSPIResult.OK:
    printLine(" FAILED")
    while true:
      daisy.setLed(true)
      daisy.delay(100)
      daisy.setLed(false)
      daisy.delay(100)
  printLine(" OK")
  
  # Create persistent storage
  var storage = newPersistentStorage[SynthSettings](qspi)
  
  # Factory defaults
  let defaults = SynthSettings(
    gain: 0.5,
    frequency: 440.0,
    waveform: 0
  )
  
  print("Initializing storage...")
  storage.init(defaults, address_offset = 0)
  printLine(" OK")
  
  # Check state
  let state = storage.getState()
  print("State: ")
  case state
  of UNKNOWN: printLine("UNKNOWN")
  of FACTORY: printLine("FACTORY")
  of USER: printLine("USER")
  
  # Modify settings
  printLine("Modifying settings...")
  var settings = storage.getSettings()
  settings.gain = 0.8
  settings.waveform = 1
  
  # Save
  print("Saving...")
  storage.save()
  printLine(" Done")
  
  # Restore defaults
  printLine("Restoring defaults...")
  storage.restoreDefaults()
  printLine("Done")
  
  printLine("Example complete!")
  daisy.setLed(true)
  
  while true:
    daisy.delay(1000)

when isMainModule:
  main()
