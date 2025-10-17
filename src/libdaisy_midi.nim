## MIDI support for libDaisy Nim wrapper
##
## This module provides MIDI functionality for the Daisy Audio Platform.
##
## Example - USB MIDI input:
## ```nim
## import libdaisy, libdaisy_midi, libdaisy_serial
## 
## var daisy = initDaisy()
## var midi = initMidi(INPUT_MODE_USB_INTERNAL)
## 
## startLog()
## printLine("MIDI Input Started")
## 
## while true:
##   midi.listen()
##   
##   while midi.hasEvents:
##     let event = midi.popEvent()
##     
##     case event.messageType
##     of NoteOn:
##       let note = event.note
##       print("Note On: ")
##       print(note.number)
##       print(" Vel: ")
##       printLine(note.velocity)
##     
##     of NoteOff:
##       let note = event.note
##       print("Note Off: ")
##       printLine(note.number)
##     
##     of ControlChange:
##       let cc = event.controlChange
##       print("CC ")
##       print(cc.number)
##       print(": ")
##       printLine(cc.value)
##     
##     else: discard
##   
##   daisy.delay(1)
## ```

# Import libdaisy which provides the macro system
import libdaisy

# Use the macro system for this module's compilation unit
useDaisyNamespace()  # MIDI needs various types

{.push header: "daisy_seed.h".}
{.push importcpp.}

type
  MidiEvent* {.importcpp: "daisy::MidiEvent".} = object
  
  MidiMessageType* {.importcpp: "daisy::MidiMessageType", size: sizeof(cint).} = enum
    NoteOff = 0x80
    NoteOn = 0x90
    PolyphonicKeyPressure = 0xA0
    ControlChange = 0xB0
    ProgramChange = 0xC0
    ChannelPressure = 0xD0
    PitchBend = 0xE0
    SystemCommon = 0xF0
    SystemRealTime = 0xF8

  MidiUsbTransport* {.importcpp: "daisy::MidiUsbTransport".} = object
  MidiUsbHandler* {.importcpp: "daisy::MidiHandler<daisy::MidiUsbTransport>".} = object

# Low-level C++ interface - removed unused procs

{.pop.} # importcpp
{.pop.} # header

# C++ constructor
proc cppNewMidiHandler(): MidiUsbHandler {.importcpp: "daisy::MidiHandler<daisy::MidiUsbTransport>()", constructor, header: "daisy_seed.h".}

# Create alias for simpler use
type MidiHandler* = MidiUsbHandler

# =============================================================================
# High-Level Nim-Friendly API
# =============================================================================

type
  NoteEvent* = object
    number*: uint8
    velocity*: uint8
  
  ControlChangeEvent* = object
    number*: uint8
    value*: uint8

template initMidi*(midi: var MidiHandler) =
  ## Initialize MIDI handler for USB MIDI
  ## 
  ## Usage:
  ## ```nim
  ## var midi: MidiHandler
  ## initMidi(midi)
  ## ```
  {.emit: ["{ daisy::MidiHandler<daisy::MidiUsbTransport>::Config cfg; "].}
  {.emit: ["  ", midi, ".Init(cfg); "].}
  {.emit: ["  ", midi, ".StartReceive(); }"].}

proc listen*(midi: var MidiHandler) =
  ## Process incoming MIDI data (call this regularly in your loop)
  {.emit: [midi, ".Listen();"].}

proc hasEvents*(midi: var MidiHandler): bool =
  ## Check if there are any MIDI events waiting
  {.emit: [result, " = ", midi, ".HasEvents();"].}

proc popEvent*(midi: var MidiHandler): MidiEvent =
  ## Get the next MIDI event from the queue
  {.emit: [result, " = ", midi, ".PopEvent();"].}

# MidiEvent helper properties
proc messageType*(event: var MidiEvent): MidiMessageType =
  ## Get the MIDI message type
  {.emit: [result, " = ", event, ".type;"].}

proc channel*(event: var MidiEvent): uint8 =
  ## Get the MIDI channel (0-15)
  {.emit: [result, " = ", event, ".channel;"].}

proc note*(event: var MidiEvent): NoteEvent =
  ## Parse as note event (for NoteOn/NoteOff messages)
  {.emit: [result.number, " = ", event, ".data[0];"].}
  {.emit: [result.velocity, " = ", event, ".data[1];"].}

proc controlChange*(event: var MidiEvent): ControlChangeEvent =
  ## Parse as control change event
  {.emit: [result.number, " = ", event, ".data[0];"].}
  {.emit: [result.value, " = ", event, ".data[1];"].}

proc pitchBend*(event: var MidiEvent): int16 =
  ## Parse as pitch bend (-8192 to +8191)
  var lsb, msb: uint8
  {.emit: [lsb, " = ", event, ".data[0];"].}
  {.emit: [msb, " = ", event, ".data[1];"].}
  result = ((msb.int16 shl 7) or lsb.int16) - 8192

proc programChange*(event: var MidiEvent): uint8 =
  ## Parse as program change (0-127)
  {.emit: [result, " = ", event, ".data[0];"].}

proc channelPressure*(event: var MidiEvent): uint8 =
  ## Parse as channel pressure (0-127)
  {.emit: [result, " = ", event, ".data[0];"].}

when isMainModule:
  echo "libDaisy MIDI wrapper - Clean API"
