## libdaisy_patch
## ===============
##
## Nim wrapper for Electro-Smith Daisy Patch development board.
##
## The Daisy Patch is a complete Eurorack-format module featuring:
## - 4 CV/Knob inputs (with gate inputs)
## - OLED display (128x64)
## - Rotary encoder
## - MIDI I/O
## - Gate inputs/outputs
## - Audio I/O with AK4556 codec
##
## **Example:**
## ```nim
## import src/libdaisy_patch
##
## var patch: DaisyPatch
## 
## proc audioCallback(input, output: ptr ptr cfloat, size: csize_t) {.cdecl.} =
##   for i in 0..<size:
##     output[0][i] = input[0][i]  # Passthrough
##     output[1][i] = input[1][i]
##
## proc main() =
##   patch.init()
##   patch.startAudio(audioCallback)
##   
##   while true:
##     patch.processAllControls()
##     let knob1 = patch.getKnobValue(CTRL_1)
##     patch.delayMs(10)
## ```

import libdaisy_macros
import libdaisy
import hid/controls
import dev/oled

type
  PatchCtrl* = enum
    ## Control identifiers for CV/Knob inputs
    CTRL_1 = 0    ## Control 1
    CTRL_2 = 1    ## Control 2
    CTRL_3 = 2    ## Control 3
    CTRL_4 = 3    ## Control 4
    CTRL_LAST = 4 ## Sentinel value

  PatchGateInput* = enum
    ## Gate input identifiers
    GATE_IN_1 = 0     ## Gate input 1
    GATE_IN_2 = 1     ## Gate input 2
    GATE_IN_LAST = 2  ## Sentinel value

  AnalogControl* {.importcpp: "daisy::AnalogControl",
                   header: "hid/ctrl.h".} = object
    ## Analog control (knob/CV input) wrapper

  GateIn* {.importcpp: "daisy::GateIn",
            header: "hid/gatein.h".} = object
    ## Gate input wrapper

  MidiUartTransport* {.importcpp: "daisy::MidiUartTransport",
                       header: "hid/midi.h".} = object
    ## MIDI UART transport

  MidiUartHandler* {.importcpp: "daisy::MidiHandler<daisy::MidiUartTransport>",
                     header: "hid/midi.h".} = object
    ## MIDI UART handler

  Ak4556* {.importcpp: "daisy::Ak4556",
            header: "per/ak4556.h".} = object
    ## AK4556 codec (used by Patch for additional audio channels)

  DaisyPatch* {.importcpp: "daisy::DaisyPatch",
                 header: "daisy_patch.h".} = object
    ## Daisy Patch board handle
    seed*: DaisySeed                           ## Underlying Seed board
    codec*: Ak4556                             ## Secondary AK4556 codec
    encoder*: Encoder                          ## Rotary encoder
    controls*: array[4, AnalogControl]         ## Four CV/Knob controls
    gate_input*: array[2, GateIn]              ## Two gate inputs
    midi*: MidiUartHandler                     ## MIDI handler
    display*: OledDisplay128x64Spi             ## OLED display
    gate_output*: GPIO                         ## Gate output

emitPatchIncludes()

proc init*(this: var DaisyPatch, boost: bool = false)
  {.importcpp: "#.Init(#)".} =
  ## Initialize the Daisy Patch board
  ##
  ## **Parameters:**
  ## - `boost` - Enable CPU boost mode (480MHz vs 400MHz)
  discard

proc delayMs*(this: var DaisyPatch, del: csize_t)
  {.importcpp: "#.DelayMs(#)".} =
  ## Wait for specified milliseconds
  ##
  ## **Parameters:**
  ## - `del` - Delay time in milliseconds
  discard

proc startAudio*(this: var DaisyPatch, cb: AudioCallback)
  {.importcpp: "#.StartAudio(#)".} =
  ## Start audio processing with callback
  ##
  ## **Parameters:**
  ## - `cb` - Audio callback function
  discard

proc changeAudioCallback*(this: var DaisyPatch, cb: AudioCallback)
  {.importcpp: "#.ChangeAudioCallback(#)".} =
  ## Switch to a different audio callback
  ##
  ## **Parameters:**
  ## - `cb` - New audio callback function
  discard

proc stopAudio*(this: var DaisyPatch)
  {.importcpp: "#.StopAudio()".} =
  ## Stop audio processing
  discard

proc setAudioSampleRate*(this: var DaisyPatch, samplerate: SampleRate)
  {.importcpp: "#.SetAudioSampleRate(#)".} =
  ## Set audio sample rate
  ##
  ## Call before startAudio().
  ##
  ## **Parameters:**
  ## - `samplerate` - Target sample rate
  discard

proc audioSampleRate*(this: var DaisyPatch): cfloat
  {.importcpp: "#.AudioSampleRate()".} =
  ## Get current audio sample rate
  ##
  ## **Returns:** Sample rate in Hz
  discard

proc setAudioBlockSize*(this: var DaisyPatch, size: csize_t)
  {.importcpp: "#.SetAudioBlockSize(#)".} =
  ## Set audio block size
  ##
  ## Call before startAudio(). Defaults to 48 samples.
  ##
  ## **Parameters:**
  ## - `size` - Block size in samples per channel
  discard

proc audioBlockSize*(this: var DaisyPatch): csize_t
  {.importcpp: "#.AudioBlockSize()".} =
  ## Get audio block size
  ##
  ## **Returns:** Block size in samples per channel
  discard

proc audioCallbackRate*(this: var DaisyPatch): cfloat
  {.importcpp: "#.AudioCallbackRate()".} =
  ## Get audio callback rate
  ##
  ## **Returns:** Callback rate in Hz
  discard

proc startAdc*(this: var DaisyPatch)
  {.importcpp: "#.StartAdc()".} =
  ## Start analog-to-digital conversion for controls
  discard

proc stopAdc*(this: var DaisyPatch)
  {.importcpp: "#.StopAdc()".} =
  ## Stop analog-to-digital conversion
  discard

proc processAnalogControls*(this: var DaisyPatch)
  {.importcpp: "#.ProcessAnalogControls()".} =
  ## Process analog control inputs
  ##
  ## Call regularly (e.g., in main loop) for smooth control reads.
  discard

proc processDigitalControls*(this: var DaisyPatch)
  {.importcpp: "#.ProcessDigitalControls()".} =
  ## Process digital control inputs (encoder)
  ##
  ## Call regularly (e.g., in main loop).
  discard

proc processAllControls*(this: var DaisyPatch)
  {.importcpp: "#.ProcessAllControls()".} =
  ## Process both analog and digital controls
  ##
  ## Convenience method. Call regularly (e.g., in main loop).
  discard

proc getKnobValue*(this: var DaisyPatch, k: PatchCtrl): cfloat
  {.importcpp: "#.GetKnobValue(#)".} =
  ## Get value for a control knob
  ##
  ## **Parameters:**
  ## - `k` - Control identifier (CTRL_1 to CTRL_4)
  ##
  ## **Returns:** Value from 0.0 to 1.0
  discard

proc displayControls*(this: var DaisyPatch, invert: bool = true)
  {.importcpp: "#.DisplayControls(#)".} =
  ## Display control values on OLED
  ##
  ## Helper function for debugging/visualization.
  ##
  ## **Parameters:**
  ## - `invert` - Invert display colors
  discard
