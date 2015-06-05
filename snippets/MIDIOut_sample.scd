MIDIClient.init;

MIDIIn.connect;
m = MIDIOut(0, MIDIClient.destinations.at(0).uid);

m.noteOn(16, 60, 60);  // turn on MIDI Signal
m.bend(16, 6000);      // bending a MIDI Signal
m.noteOff(16, 60, 60); // turn off a MIDI Signal