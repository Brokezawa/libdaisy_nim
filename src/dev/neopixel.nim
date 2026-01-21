## NeoPixel RGB LED Module - WS2812B Addressable RGB LEDs via I2C
##
## This module wraps libDaisy's NeoPixel support which uses Adafruit's Seesaw I2C bridge.
## For direct WS2812B control, use a dedicated NeoPixel controller board.

import ../libdaisy
import ../libdaisy_macros
import ../libdaisy_i2c

useDaisyModules(neopixel, i2c)

# System delay functions from libDaisy
proc delayMs*(ms: uint32) {.importcpp: "daisy::System::Delay(@)", header: "sys/system.h".}

type
  NeoPixelResult* = enum
    NEO_OK = 0
    NEO_ERR = 1

  NeoPixelType* = uint16

  NeoPixelI2CTransportConfig* = object
    periph*: I2CPeripheral
    speed*: I2CSpeed
    scl*, sda*: Pin
    address*: uint8

  NeoPixelConfig* = object
    transport_config*: NeoPixelI2CTransportConfig
    pixel_type*: NeoPixelType
    num_leds*: uint16
    output_pin*: int8

  NeoPixelI2C* = object
    i2c: I2CHandle
    config: NeoPixelConfig
    numLeds, numBytes: uint16
    pin: int8
    brightness: uint8
    rOffset, gOffset, bOffset, wOffset: uint8
    is800KHz: bool
    pixels: array[256, uint8]
    pixelType: NeoPixelType
    endTime: uint32

# Color order constants
const
  NEO_RGB* = ((0'u16 shl 6) or (0'u16 shl 4) or (1'u16 shl 2) or 2)
  NEO_GRB* = ((1'u16 shl 6) or (1'u16 shl 4) or (0'u16 shl 2) or 2)
  NEO_KHZ800* = 0x0000'u16
  NEO_KHZ400* = 0x0100'u16
  NEO_TRELLIS_ADDR* = 0x2E'u8
  
  SEESAW_NEOPIXEL_BASE* = 0x0E'u8
  SEESAW_NEOPIXEL_PIN* = 0x01'u8
  SEESAW_NEOPIXEL_SPEED* = 0x02'u8
  SEESAW_NEOPIXEL_BUF_LENGTH* = 0x03'u8
  SEESAW_NEOPIXEL_BUF* = 0x04'u8
  SEESAW_NEOPIXEL_SHOW* = 0x05'u8
  SEESAW_STATUS_BASE* = 0x00'u8
  SEESAW_STATUS_SWRST* = 0x7F'u8

proc defaults*(config: var NeoPixelI2CTransportConfig) =
  config.address = NEO_TRELLIS_ADDR
  config.periph = I2C_1
  config.speed = I2C_400KHZ
  config.scl = daisyPin(PORTB, 8)
  config.sda = daisyPin(PORTB, 9)

proc defaults*(config: var NeoPixelConfig) =
  config.transport_config.defaults()
  config.pixel_type = NEO_GRB + NEO_KHZ800
  config.num_leds = 16
  config.output_pin = 3

proc init*(neo: var NeoPixelI2C, config: NeoPixelConfig): NeoPixelResult =
  neo.config = config
  neo.pixelType = config.pixel_type
  neo.numLeds = config.num_leds
  neo.pin = config.output_pin
  
  var i2cConfig: I2CConfig
  i2cConfig.mode = I2C_MASTER
  i2cConfig.periph = config.transport_config.periph
  i2cConfig.speed = config.transport_config.speed
  i2cConfig.pin_config.scl = config.transport_config.scl
  i2cConfig.pin_config.sda = config.transport_config.sda
  neo.i2c.init(i2cConfig)
  
  # Software reset
  var buf: array[3, uint8] = [SEESAW_STATUS_BASE, SEESAW_STATUS_SWRST, 0xFF]
  discard neo.i2c.transmitBlocking(config.transport_config.address, buf, 10)
  delayMs(10)
  
  # Configure pixel type and length (simplified)
  neo.wOffset = (neo.pixelType shr 6) and 0b11
  neo.rOffset = (neo.pixelType shr 4) and 0b11
  neo.gOffset = (neo.pixelType shr 2) and 0b11
  neo.bOffset = neo.pixelType and 0b11
  neo.is800KHz = neo.pixelType < 256
  neo.numBytes = neo.numLeds * (if neo.wOffset == neo.rOffset: 3 else: 4)
  
  return NEO_OK

proc setPixelColor*(neo: var NeoPixelI2C, n: uint16, r, g, b: uint8): NeoPixelResult =
  if n >= neo.numLeds: return NEO_ERR
  # Simplified - would need full Seesaw I2C protocol
  return NEO_OK

proc show*(neo: var NeoPixelI2C) =
  # Send show command via Seesaw
  var buf: array[2, uint8] = [SEESAW_NEOPIXEL_BASE, SEESAW_NEOPIXEL_SHOW]
  discard neo.i2c.transmitBlocking(neo.config.transport_config.address, buf, 10)

{.pop.}
