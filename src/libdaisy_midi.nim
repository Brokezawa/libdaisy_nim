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

type
  MidiEvent* {.importcpp: "daisy::MidiEvent", bycopy.} = object
    mType* {.importcpp: "type".}: MidiMessageType
    channel* {.importcpp: "channel".}: cint
    data* {.importcpp: "data".}: array[2, uint8]
  
  MidiMessageType* {.importcpp: "daisy::MidiMessageType", size: sizeof(cint).} = enum
    NoteOff
    NoteOn
    PolyphonicKeyPressure
    ControlChange
    ProgramChange
    ChannelPressure
    PitchBend
    SystemCommon
    SystemRealTime

  MidiUsbTransport* {.importcpp: "daisy::MidiUsbTransport".} = object
  MidiUsbHandler* {.importcpp: "daisy::MidiHandler<daisy::MidiUsbTransport>".} = object
  MidiUsbHandlerConfig* {.importcpp: "daisy::MidiHandler<daisy::MidiUsbTransport>::Config", bycopy.} = object

# Low-level C++ interface
proc Listen(this: var MidiUsbHandler) {.importcpp: "#.Listen()".}
proc HasEvents(this: var MidiUsbHandler): bool {.importcpp: "#.HasEvents()".}
proc PopEvent(this: var MidiUsbHandler): MidiEvent {.importcpp: "#.PopEvent()".}
proc Init(this: var MidiUsbHandler, config: MidiUsbHandlerConfig) {.importcpp: "#.Init(@)".}
proc StartReceive(this: var MidiUsbHandler) {.importcpp: "#.StartReceive()".}

# C++ constructors
proc cppNewMidiHandler(): MidiUsbHandler {.importcpp: "daisy::MidiHandler<daisy::MidiUsbTransport>()", constructor.}

# Create a default config - this creates a stack-allocated config struct  
proc newMidiConfig*(): MidiUsbHandlerConfig {.importcpp: "daisy::MidiHandler<daisy::MidiUsbTransport>::Config()", constructor.}

{.pop.} # header

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

proc initMidi*(midi: var MidiHandler) =
  ## Initialize MIDI handler for USB MIDI
  ## 
  ## Usage:
  ## ```nim
  ## var midi: MidiHandler
  ## initMidi(midi)
  ## ```
  var cfg: MidiUsbHandlerConfig  # Default constructor
  midi.Init(cfg)
  midi.StartReceive()

proc listen*(midi: var MidiHandler) {.inline.} =
  ## Process incoming MIDI data (call this regularly in your loop)
  midi.Listen()

proc hasEvents*(midi: var MidiHandler): bool {.inline.} =
  ## Check if there are any MIDI events waiting
  result = midi.HasEvents()

proc popEvent*(midi: var MidiHandler): MidiEvent {.inline.} =
  ## Get the next MIDI event from the queue
  result = midi.PopEvent()

# MidiEvent helper properties - access C++ fields directly
proc messageType*(event: MidiEvent): MidiMessageType {.importcpp: "#.type", nodecl.}
proc channel*(event: MidiEvent): cint {.importcpp: "#.channel", nodecl.}

proc note*(event: var MidiEvent): NoteEvent {.inline.} =
  ## Parse as note event (for NoteOn/NoteOff messages)
  result.number = event.data[0]
  result.velocity = event.data[1]

proc controlChange*(event: var MidiEvent): ControlChangeEvent {.inline.} =
  ## Parse as control change event
  result.number = event.data[0]
  result.value = event.data[1]

proc pitchBend*(event: var MidiEvent): int16 {.inline.} =
  ## Parse as pitch bend (-8192 to +8191)
  let lsb = event.data[0]
  let msb = event.data[1]
  result = ((msb.int16 shl 7) or lsb.int16) - 8192

proc programChange*(event: var MidiEvent): uint8 {.inline.} =
  ## Parse as program change (0-127)
  result = event.data[0]

proc channelPressure*(event: var MidiEvent): uint8 {.inline.} =
  ## Parse as channel pressure (0-127)
  result = event.data[0]

when isMainModule:
  echo "libDaisy MIDI wrapper - Clean API"
