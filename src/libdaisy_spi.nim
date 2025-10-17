## SPI (Serial Peripheral Interface) support for libDaisy Nim wrapper
##
## This module provides SPI communication support for the Daisy Audio Platform.
##
## Example - Simple SPI master:
## ```nim
## import libdaisy, libdaisy_spi
## 
## var daisy = initDaisy()
## var spi = initSPI(SPI_1, D8(), D9(), D10())
## 
## # Write bytes
## discard spi.write([0x01'u8, 0x02, 0x03, 0x04])
## 
## # Read bytes
## let (result, data) = spi.read(4)
## 
## # Full-duplex transfer
## let (res2, rxData) = spi.transfer([0xAA'u8, 0xBB, 0xCC])
## ```
##
## Example - SPI with register access:
## ```nim
## # Write to register
## discard spi.writeRegister(0x20, 0xFF)
## 
## # Read from register
## let (result, value) = spi.readRegister(0x21)
## ```

# Import libdaisy which provides the macro system
import libdaisy

# Use the macro system for this module's compilation unit
useDaisyModules(spi)

{.push header: "daisy_seed.h".}
{.push importcpp.}

type
  # SPI Implementation (opaque)
  SpiHandleImpl* {.importcpp: "daisy::SpiHandle::Impl".} = object

  # SPI Configuration enums
  SpiPeripheral* {.importcpp: "daisy::SpiHandle::Config::Peripheral", size: sizeof(cint).} = enum
    SPI_1 = 0
    SPI_2
    SPI_3
    SPI_4
    SPI_5
    SPI_6

  SpiMode* {.importcpp: "daisy::SpiHandle::Config::Mode", size: sizeof(cint).} = enum
    SPI_MASTER = 0
    SPI_SLAVE

  SpiDirection* {.importcpp: "daisy::SpiHandle::Config::Direction", size: sizeof(cint).} = enum
    SPI_TWO_LINES = 0          ## Full duplex
    SPI_TWO_LINES_TX_ONLY      ## Half duplex transmit only
    SPI_TWO_LINES_RX_ONLY      ## Half duplex receive only
    SPI_ONE_LINE               ## Single wire bidirectional

  SpiClockPolarity* {.importcpp: "daisy::SpiHandle::Config::ClockPolarity", size: sizeof(cint).} = enum
    SPI_CLOCK_POL_LOW = 0      ## Clock idle state is low
    SPI_CLOCK_POL_HIGH         ## Clock idle state is high

  SpiClockPhase* {.importcpp: "daisy::SpiHandle::Config::ClockPhase", size: sizeof(cint).} = enum
    SPI_CLOCK_PHASE_1 = 0      ## Data sampled on first edge
    SPI_CLOCK_PHASE_2          ## Data sampled on second edge

  SpiNSS* {.importcpp: "daisy::SpiHandle::Config::NSS", size: sizeof(cint).} = enum
    SPI_NSS_SOFT = 0           ## Software NSS management
    SPI_NSS_HARD_INPUT         ## Hardware NSS input
    SPI_NSS_HARD_OUTPUT        ## Hardware NSS output

  SpiBaudPrescaler* {.importcpp: "daisy::SpiHandle::Config::BaudPrescaler", size: sizeof(cint).} = enum
    SPI_PS_2 = 0               ## Clock / 2
    SPI_PS_4                   ## Clock / 4
    SPI_PS_8                   ## Clock / 8
    SPI_PS_16                  ## Clock / 16
    SPI_PS_32                  ## Clock / 32
    SPI_PS_64                  ## Clock / 64
    SPI_PS_128                 ## Clock / 128
    SPI_PS_256                 ## Clock / 256

  SpiResult* {.importcpp: "daisy::SpiHandle::Result", size: sizeof(cint).} = enum
    SPI_OK = 0
    SPI_ERR

  SpiDmaDirection* {.importcpp: "daisy::SpiHandle::DmaDirection", size: sizeof(cint).} = enum
    SPI_DMA_RX = 0             ## DMA receive only
    SPI_DMA_TX                 ## DMA transmit only
    SPI_DMA_RX_TX              ## DMA receive and transmit

  # Pin configuration structure
  SpiPinConfig* {.importcpp: "daisy::SpiHandle::Config::pin_config", bycopy.} = object
    sclk* {.importc: "sclk".}: Pin
    miso* {.importc: "miso".}: Pin
    mosi* {.importc: "mosi".}: Pin
    nss* {.importc: "nss".}: Pin

  # SPI Configuration structure
  SpiConfig* {.importcpp: "daisy::SpiHandle::Config", bycopy.} = object
    periph* {.importc: "periph".}: SpiPeripheral
    mode* {.importc: "mode".}: SpiMode
    direction* {.importc: "direction".}: SpiDirection
    datasize* {.importc: "datasize".}: culong
    clock_polarity* {.importc: "clock_polarity".}: SpiClockPolarity
    clock_phase* {.importc: "clock_phase".}: SpiClockPhase
    nss* {.importc: "nss".}: SpiNSS
    baud_prescaler* {.importc: "baud_prescaler".}: SpiBaudPrescaler
    pin_config* {.importc: "pin_config".}: SpiPinConfig

  # SPI callback function pointers
  SpiStartCallbackFunctionPtr* = proc(context: pointer) {.cdecl.}
  SpiEndCallbackFunctionPtr* = proc(context: pointer, result: SpiResult) {.cdecl.}

  # Main SPI Handle
  SpiHandle* {.importcpp: "daisy::SpiHandle".} = object
    pimpl {.importc: "pimpl_".}: ptr SpiHandleImpl

# Low-level C++ interface
proc cppInit(this: var SpiHandle, config: SpiConfig): SpiResult {.importcpp: "#.Init(@)".}
proc cppGetConfig(this: SpiHandle): SpiConfig {.importcpp: "#.GetConfig()".}

proc cppBlockingTransmit(this: var SpiHandle, buff: ptr uint8, size: csize_t, 
                        timeout: uint32 = 100): SpiResult {.importcpp: "#.BlockingTransmit(@)".}

proc cppBlockingReceive(this: var SpiHandle, buffer: ptr uint8, size: uint16, 
                       timeout: uint32): SpiResult {.importcpp: "#.BlockingReceive(@)".}

proc cppBlockingTransmitAndReceive(this: var SpiHandle, tx_buff: ptr uint8, rx_buff: ptr uint8, 
                                  size: csize_t, timeout: uint32 = 100): SpiResult {.importcpp: "#.BlockingTransmitAndReceive(@)".}

proc cppDmaTransmit(this: var SpiHandle, buff: ptr uint8, size: csize_t, 
                   start_callback: SpiStartCallbackFunctionPtr, 
                   end_callback: SpiEndCallbackFunctionPtr, 
                   callback_context: pointer): SpiResult {.importcpp: "#.DmaTransmit(@)".}

proc cppDmaReceive(this: var SpiHandle, buff: ptr uint8, size: csize_t, 
                  start_callback: SpiStartCallbackFunctionPtr, 
                  end_callback: SpiEndCallbackFunctionPtr, 
                  callback_context: pointer): SpiResult {.importcpp: "#.DmaReceive(@)".}

proc cppDmaTransmitAndReceive(this: var SpiHandle, tx_buff: ptr uint8, rx_buff: ptr uint8, size: csize_t, 
                             start_callback: SpiStartCallbackFunctionPtr, 
                             end_callback: SpiEndCallbackFunctionPtr, 
                             callback_context: pointer): SpiResult {.importcpp: "#.DmaTransmitAndReceive(@)".}

proc cppCheckError(this: var SpiHandle): cint {.importcpp: "#.CheckError()".}

{.pop.} # importcpp
{.pop.} # header

# Nim-friendly constructors and helpers
proc cppNewSpiHandle(): SpiHandle {.importcpp: "daisy::SpiHandle()", constructor, header: "daisy_seed.h".}

# =============================================================================
# High-Level Nim-Friendly API
# =============================================================================

proc initSPI*(peripheral: SpiPeripheral, sclkPin, misoPin, mosiPin: Pin,
              nssPin: Pin = Pin(), speed: SpiBaudPrescaler = SPI_PS_8,
              mode: int = 0): SpiHandle =
  ## Initialize SPI interface
  ## 
  ## Parameters:
  ##   peripheral: SPI_1, SPI_2, SPI_3, SPI_4, SPI_5, or SPI_6
  ##   sclkPin: Clock pin (e.g., D8())
  ##   misoPin: Master In Slave Out pin
  ##   mosiPin: Master Out Slave In pin
  ##   nssPin: Chip select pin (optional, use Pin() for software CS)
  ##   speed: Clock prescaler (SPI_PS_2 to SPI_PS_256)
  ##   mode: SPI mode 0-3 (sets clock polarity and phase)
  ## 
  ## Example:
  ## ```nim
  ## var spi = initSPI(SPI_1, D8(), D9(), D10())
  ## ```
  result = cppNewSpiHandle()
  var config: SpiConfig
  config.periph = peripheral
  config.mode = SPI_MASTER
  config.direction = SPI_TWO_LINES
  config.datasize = 8
  config.nss = if nssPin.port == PORTX: SPI_NSS_SOFT else: SPI_NSS_HARD_OUTPUT
  config.baud_prescaler = speed
  config.pin_config.sclk = sclkPin
  config.pin_config.miso = misoPin
  config.pin_config.mosi = mosiPin
  config.pin_config.nss = nssPin
  
  # Set SPI mode
  case mode
  of 0:
    config.clock_polarity = SPI_CLOCK_POL_LOW
    config.clock_phase = SPI_CLOCK_PHASE_1
  of 1:
    config.clock_polarity = SPI_CLOCK_POL_LOW
    config.clock_phase = SPI_CLOCK_PHASE_2
  of 2:
    config.clock_polarity = SPI_CLOCK_POL_HIGH
    config.clock_phase = SPI_CLOCK_PHASE_1
  of 3:
    config.clock_polarity = SPI_CLOCK_POL_HIGH
    config.clock_phase = SPI_CLOCK_PHASE_2
  else: discard
  
  {.emit: [result, ".Init(", config, ");"].}

proc transfer*(spi: var SpiHandle, txData: openArray[uint8], 
               timeout: uint32 = 100): tuple[result: SpiResult, rxData: seq[uint8]] =
  ## Full-duplex transfer (transmit and receive simultaneously)
  result.rxData = newSeq[uint8](len(txData))
  var txBuffer = @txData
  if txBuffer.len > 0:
    var txPtr = addr txBuffer[0]
    var rxPtr = addr result.rxData[0]
    {.emit: [result.result, " = ", spi, ".BlockingTransmitAndReceive(", txPtr, ", ", rxPtr, ", ", csize_t(len(txData)), ", ", timeout, ");"].}
  else:
    result.result = SPI_OK

proc write*(spi: var SpiHandle, data: openArray[uint8], timeout: uint32 = 100): SpiResult =
  ## Write data via SPI
  var buffer = @data
  if buffer.len > 0:
    var bufPtr = addr buffer[0]
    {.emit: [result, " = ", spi, ".BlockingTransmit(", bufPtr, ", ", csize_t(len(data)), ", ", timeout, ");"].}
  else:
    result = SPI_OK

proc read*(spi: var SpiHandle, count: int, timeout: uint32 = 100): tuple[result: SpiResult, data: seq[uint8]] =
  ## Read data via SPI
  result.data = newSeq[uint8](count)
  if count > 0:
    var dataPtr = addr result.data[0]
    {.emit: [result.result, " = ", spi, ".BlockingReceive(", dataPtr, ", ", uint16(count), ", ", timeout, ");"].}
  else:
    result.result = SPI_OK

proc writeByte*(spi: var SpiHandle, data: uint8, timeout: uint32 = 100): SpiResult =
  ## Write a single byte
  var b = data
  {.emit: [result, " = ", spi, ".BlockingTransmit(&", b, ", 1, ", timeout, ");"].}

proc readByte*(spi: var SpiHandle, timeout: uint32 = 100): tuple[result: SpiResult, data: uint8] =
  ## Read a single byte
  result.data = 0
  {.emit: [result.result, " = ", spi, ".BlockingReceive(&", result.data, ", 1, ", timeout, ");"].}

proc transferByte*(spi: var SpiHandle, txByte: uint8, timeout: uint32 = 100): tuple[result: SpiResult, rxByte: uint8] =
  ## Transfer a single byte (full duplex)
  var tx = txByte
  result.rxByte = 0
  {.emit: [result.result, " = ", spi, ".BlockingTransmitAndReceive(&", tx, ", &", result.rxByte, ", 1, ", timeout, ");"].}

proc writeRegister*(spi: var SpiHandle, regAddr: uint8, value: uint8, 
                    timeout: uint32 = 100): SpiResult =
  ## Write to a register (common SPI device pattern)
  var data: array[2, uint8] = [regAddr, value]
  result = spi.cppBlockingTransmit(addr data[0], 2, timeout)

proc readRegister*(spi: var SpiHandle, regAddr: uint8, 
                   timeout: uint32 = 100): tuple[result: SpiResult, value: uint8] =
  ## Read from a register
  var txData: array[2, uint8] = [regAddr, 0x00]
  var rxData: array[2, uint8]
  result.result = spi.cppBlockingTransmitAndReceive(addr txData[0], addr rxData[0], 2, timeout)
  result.value = rxData[1]

proc readRegisters*(spi: var SpiHandle, regAddr: uint8, count: int,
                    timeout: uint32 = 100): tuple[result: SpiResult, data: seq[uint8]] =
  ## Read multiple bytes from consecutive registers
  result.data = newSeq[uint8](count + 1)
  var txData = newSeq[uint8](count + 1)
  txData[0] = regAddr
  
  if count > 0:
    result.result = spi.cppBlockingTransmitAndReceive(
      addr txData[0], 
      addr result.data[0], 
      csize_t(count + 1), 
      timeout
    )
    
    # Remove the first byte (echo of register address)
    if result.result == SPI_OK:
      result.data.delete(0)
  else:
    result.result = SPI_OK

# Common SPI modes
const
  SPI_MODE_0* = (SPI_CLOCK_POL_LOW, SPI_CLOCK_PHASE_1)   ## CPOL=0, CPHA=0
  SPI_MODE_1* = (SPI_CLOCK_POL_LOW, SPI_CLOCK_PHASE_2)   ## CPOL=0, CPHA=1
  SPI_MODE_2* = (SPI_CLOCK_POL_HIGH, SPI_CLOCK_PHASE_1)  ## CPOL=1, CPHA=0
  SPI_MODE_3* = (SPI_CLOCK_POL_HIGH, SPI_CLOCK_PHASE_2)  ## CPOL=1, CPHA=1

when isMainModule:
  echo "libDaisy SPI wrapper - Clean API"
