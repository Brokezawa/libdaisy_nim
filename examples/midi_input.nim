## MIDI Input Example
import panicoverride
## 
## Receiving MIDI messages and reacting to notes

import ../src/libdaisy
import ../src/hid/midi
import ../src/per/uart
useDaisyNamespace()


proc main() =
  var daisy = initDaisy()
  var midi: MidiHandler
  initMidi(midi)
  
  startLog()
  printLine("MIDI Input Example")
  printLine("Play notes to see events")
  printLine()
  
  var ledState = false
  
  while true:
    midi.listen()
    
    while midi.hasEvents:
      var event = midi.popEvent()
      
      case event.messageType
      of NoteOn:
        let note = event.note
        if note.velocity > 0:
          ledState = true
          print("Note On:  ")
          print(int(note.number))
          print(" Vel: ")
          printLine(int(note.velocity))
      
      of NoteOff:
        ledState = false
        let note = event.note
        print("Note Off: ")
        printLine(int(note.number))
      
      of ControlChange:
        let cc = event.controlChange
        print("CC ")
        print(int(cc.number))
        print(": ")
        printLine(int(cc.value))
      
      of PitchBend:
        let bend = event.pitchBend
        print("Pitch Bend: ")
        printLine(int(bend))
      
      else: discard
    
    daisy.setLed(ledState)
    daisy.delay(1)

when isMainModule:
  main()
