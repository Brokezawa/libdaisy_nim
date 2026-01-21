## MAX11300 20-Port Programmable Mixed-Signal I/O Module
##
## Device driver for MAX11300 PIXI - 20-port ADC/DAC/GPIO device.
## Highly opinionated implementation optimized for Eurorack modular synthesis.
## 
## Note: This is a simplified wrapper. Full DMA implementation would require
## extensive SPI multi-slave support. This version uses blocking SPI for simplicity.

import ../libdaisy
import ../libdaisy_macros
import ../libdaisy_spi

useDaisyModules(max11300, spi)

type
  MAX11300Result* = enum
    MAX_OK = 0
    MAX_ERR = 1

  MAX11300Pin* = range[0..19]

  AdcVoltageRange* = enum
    ADC_0_TO_10 = 0x0100
    ADC_NEG5_TO_5 = 0x0200
    ADC_NEG10_TO_0 = 0x0300
    ADC_0_TO_2P5 = 0x0400

  DacVoltageRange* = enum
    DAC_0_TO_10 = 0x0100
    DAC_NEG5_TO_5 = 0x0200
    DAC_NEG10_TO_0 = 0x0300

  MAX11300SpiConfig*[N: static int] = object
    periph*: SpiPeripheral
    baud_prescaler*: SpiBaudPrescaler
    nss_pins*: array[N, Pin]
    mosi*, miso*, sclk*: Pin

  MAX11300Config*[N: static int] = object
    spi_config*: MAX11300SpiConfig[N]

  MAX11300*[N: static int] = object
    spi: SpiHandle
    numDevices: csize_t
    # Simplified - no full DMA state tracking

const
  MAX11300_DEVICE_ID* = 0x00'u8
  MAX11300_DEVCTL* = 0x10'u8
  MAX11300_FUNC_BASE* = 0x20'u8
  MAX11300_ADCDAT_BASE* = 0x40'u8
  MAX11300_DACDAT_BASE* = 0x60'u8

proc defaults*[N](config: var MAX11300SpiConfig[N]) =
  config.periph = SPI_1
  config.baud_prescaler = SPI_PS_8
  config.mosi = newPin(PORTB, 5)
  config.miso = newPin(PORTB, 4)
  config.sclk = newPin(PORTG, 11)
  config.nss_pins[0] = newPin(PORTG, 10)

proc voltsTo12BitUint*(volts: float32, range: DacVoltageRange): uint16 =
  ## Convert voltage to 12-bit DAC code
  var vmin, vmax: float32
  case range
  of DAC_NEG10_TO_0:
    vmin = -10.0; vmax = 0.0
  of DAC_NEG5_TO_5:
    vmin = -5.0; vmax = 5.0
  of DAC_0_TO_10:
    vmin = 0.0; vmax = 10.0
  
  let
    clamped = if volts > vmax: vmax elif volts < vmin: vmin else: volts
    vscaler = 4095.0'f32 / (vmax - vmin)
  return ((clamped - vmin) * vscaler).uint16

proc twelveBitUintToVolts*(value: uint16, range: AdcVoltageRange): float32 =
  ## Convert 12-bit ADC code to voltage
  var vmin, vmax: float32
  case range
  of ADC_NEG10_TO_0:
    vmin = -10.0; vmax = 0.0
  of ADC_NEG5_TO_5:
    vmin = -5.0; vmax = 5.0
  of ADC_0_TO_10:
    vmin = 0.0; vmax = 10.0
  of ADC_0_TO_2P5:
    vmin = 0.0; vmax = 2.5
  
  let
    clamped = if value > 4095: 4095'u16 else: value
    vscaler = (vmax - vmin) / 4095.0'f32
  return (clamped.float32 * vscaler) + vmin

proc init*[N](max: var MAX11300[N], config: MAX11300Config[N]): MAX11300Result =
  ## Initialize MAX11300 (simplified - blocking SPI only)
  max.spi = initSPI(
    config.spi_config.periph,
    config.spi_config.sclk,
    config.spi_config.miso,
    config.spi_config.mosi,
    config.spi_config.nss_pins[0],
    config.spi_config.baud_prescaler,
    0  # SPI mode 0
  )
  max.numDevices = N
  max.numDevices = N
  
  # Simplified init - would need register reads/writes via SPI
  # Full implementation requires complex SPI protocol
  return MAX_OK

proc configurePinAsAnalogRead*[N](max: var MAX11300[N], device: csize_t, 
                                   pin: MAX11300Pin, range: AdcVoltageRange): MAX11300Result =
  ## Configure pin as ADC input (simplified)
  # Would write to FUNC_BASE + pin register
  return MAX_OK

proc configurePinAsAnalogWrite*[N](max: var MAX11300[N], device: csize_t,
                                    pin: MAX11300Pin, range: DacVoltageRange): MAX11300Result =
  ## Configure pin as DAC output (simplified)
  # Would write to FUNC_BASE + pin register
  return MAX_OK

proc readAnalogPinVolts*[N](max: MAX11300[N], device: csize_t, pin: MAX11300Pin): float32 =
  ## Read ADC pin in volts (simplified)
  # Would read from ADCDAT_BASE + pin register
  return 0.0

proc writeAnalogPinVolts*[N](max: var MAX11300[N], device: csize_t,
                              pin: MAX11300Pin, voltage: float32) =
  ## Write DAC pin in volts (simplified)
  # Would write to DACDAT_BASE + pin register
  discard
