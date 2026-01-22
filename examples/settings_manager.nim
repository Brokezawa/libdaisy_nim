## Persistent Settings Manager Example - Simplified
## =================================================
##
## Demonstrates persistent settings storage in QSPI flash.
## This is a minimal example to verify compilation.

import ../src/libdaisy
import ../src/libdaisy_qspi
import ../src/libdaisy_persistent_storage
import ../src/libdaisy_serial

useDaisyNamespace()

# Define settings struct with exportc for stable name
type
  SynthSettings {.bycopy, exportc: "SynthSettings".} = object
    gain {.exportc.}: cfloat
    frequency {.exportc.}: cfloat
    waveform {.exportc.}: uint8

# Implement == and != operators for dirty detection
{.emit: """
// Type alias for PersistentStorage state enum
typedef daisy::PersistentStorage<int>::State StorageState;

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
