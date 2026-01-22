## Multi-Slave SPI Example - Simplified
## =====================================
##
## Demonstrates using multiple SPI devices on a single bus.
## This is a minimal example to verify compilation.

import ../src/libdaisy
import ../src/libdaisy_spi
import ../src/libdaisy_spi_multislave
import ../src/libdaisy_serial

useDaisyNamespace()

proc main() =
  # Initialize
  var daisy = initDaisy()
  startLog()
  daisy.delay(100)
  
  printLine("Multi-Slave SPI Example")
  printLine("=======================")
  
  # Configure multi-slave SPI for 3 devices
  var config = MultiSlaveSpiConfig(
    periph: SPI_1,
    direction: SPI_TWO_LINES,
    datasize: 8,
    clock_polarity: SPI_CLOCK_POL_LOW,
    clock_phase: SPI_CLOCK_PHASE_1,
    baud_prescaler: SPI_PS_16,
    num_devices: 3
  )
  
  # Configure pins
  config.pin_config.sclk = D7()
  config.pin_config.miso = D8()
  config.pin_config.mosi = D9()
  config.pin_config.nss[0] = D10()  # Device 0
  config.pin_config.nss[1] = D11()  # Device 1
  config.pin_config.nss[2] = D12()  # Device 2
  
  # Initialize
  var spi = initMultiSlaveSpi()
  print("Initializing SPI...")
  
  if spi.init(config) != SPI_OK:
    printLine(" FAILED")
    while true:
      daisy.setLed(true)
      daisy.delay(100)
      daisy.setLed(false)
      daisy.delay(100)
  
  printLine(" OK")
  
  # Send to device 0
  var txData0 = [0x01'u8, 0x02, 0x03]
  print("Sending to device 0...")
  if spi.blockingTransmit(0, txData0) == SPI_OK:
    printLine(" OK")
  else:
    printLine(" FAILED")
  
  # Send to device 1
  var txData1 = [0xAA'u8, 0xBB, 0xCC]
  print("Sending to device 1...")
  if spi.blockingTransmit(1, txData1) == SPI_OK:
    printLine(" OK")
  else:
    printLine(" FAILED")
  
  # Send to device 2
  var txData2 = [0xFF'u8, 0x00, 0xFF]
  print("Sending to device 2...")
  if spi.blockingTransmit(2, txData2) == SPI_OK:
    printLine(" OK")
  else:
    printLine(" FAILED")
  
  printLine("Example complete!")
  daisy.setLed(true)
  
  while true:
    daisy.delay(1000)

when isMainModule:
  main()
