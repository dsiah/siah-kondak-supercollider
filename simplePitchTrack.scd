// s = FreqScope.server.boot;
// ~w1 = FreqScope.new(800, 400, 0);
// ~w2 = FreqScope.new(800, 400, 8);

(

MIDIClient.init; // initialize the MIDIClient on Server
m = MIDIOut(0); // use first MIDI Device (IAC BUS 1)

~onOrOff = false; // keep track of note being (or not being) played
~pitch = 0;

x = {
	var in, hasFreq, freq, out;

	in = SoundIn.ar(0); // pipe sound to in

	/*
	   Pipe in to Pitch
	   calculate the MIDI number of the input sound
	   median: remove outliers, 11 in this case takes the median of last 11 frames
	*/

	//freq = Pitch.kr(in, execFreq: 200, median: 21, ampThreshold: 0.1).cpsmidi.round;
	freq = Tartini.kr(in).cpsmidi.round;
	// Send the Pitch to global variable ~pitch
	SendReply.ar(Impulse.ar(200), 'pitch', [freq]);
}.play;

SynthDef(\threshTest, {
	// above the high triggers the noteOn
	// below the low releases the note (noteOff triggered)
	arg highThresh = (-22), lowThresh = (-40);
	var sig, amp, highTrig, lowTrig, in;

	in = SoundIn.ar(0);
	sig = DelayN.ar(in, delaytime: 0.02);
	// take signal and applies Amplitude => returns the Amplitude in Decibals
	amp = Amplitude.kr(sig).ampdb;
	amp = K2A.ar(amp); // to improve resolution of amplitude tracking control -> audio rate

	highTrig = amp >= highThresh; // check and create booleans
	lowTrig = amp <= lowThresh;

	SendReply.ar(Impulse.ar(50), 'highTrigVal', [highTrig]); // Respective triggers for noteOn
	SendReply.ar(Impulse.ar(50), 'lowTrigVal', [lowTrig]);   // and noteOff
}).play;


/*
   OSC Responder (event emitters) for OSC messages
   serve the purpose of dispatching anonymous functions
*/

~oscr3.remove; // in case oscr"/Users/muddCS15/Downloads/um132-2mx/"3 needs to be reset to avoid overwriting
~oscr3 = OSCresponder(nil, 'pitch', {
	|time, resp, msg|

	if( msg[3] == ~pitch,
		{},
		{
			~pitch = msg[3]; // save pitch to global variable ~pitch
			"note on, pitch ".post;
			~pitch.postln;
			m.noteOn(16, ~pitch, 60);
		}
	);
}).add;

~oscr1.remove;
~oscr1 = OSCresponder(nil, 'highTrigVal', {
	|time, resp, msg|

	if( msg[3] == 1,
		{
			if( ~onOrOff,
				{}, {
					"note on, pitch ".post;
					~pitch.postln;
					m.noteOn(16, ~pitch, 60);
					~onOrOff = true
			});
		}, {});
}).add;

~oscr2.remove;
~oscr2 = OSCresponder(nil, 'lowTrigVal', {
	|time, resp, msg|

	if( msg[3] == 1,{
		if( ~onOrOff, {
			"note off".postln;
			m.allNotesOff(16);
			~onOrOff = false;
		}, {});
	}, {});
}).add;

)