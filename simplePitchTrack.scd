(

GUI.qt;          // Platform independent GUI system
MIDIClient.init; // initialize the MIDIClient on Server
m = MIDIOut(0);  // use first MIDI Device (IAC BUS 1)

~onOrOff = false; // Track note being (or not being) played
~pitch = 0;
~changePitch = 0;
~lastPitch = 0;
~resolution = 27; // Delay of frames between notes -- (Hacky should be fixed)
~currentRes = 0;

/* * * * * * * * * * * *
 *        GUI          *
 *        CODE         *
 * * * * * * * * * * * */

~gooey = Window.new("Pitch Tracker", Rect(500,500,500,500));
~gooey.front;

SynthDef(\freqTrack, {
	arg threshold = (0.93), median = (15), framesize = (2048), overlap = (1024), delayTime = (0.10);
	var freq, in, tart, changeFreq;

	/*

	  FreqTrack: Pipe in to Pitch
	  calculates the MIDI number of the input sound
	  median: remove outliers, 11 in this case takes the median of last 11 frames,
	  framesize:
	  overlap:
	  delayTime:

	*/

	in = SoundIn.ar(0);
	tart = Tartini.kr(in, threshold, framesize, 0, overlap);
	freq = Median.kr(15, tart).cpsmidi.round;
	changeFreq = DelayN.kr(Median.kr(23, tart).cpsmidi.round, delaytime: delayTime);

	SendReply.ar(Impulse.ar(200), 'pitch', [freq]);
	SendReply.ar(Impulse.ar(200), 'changePitch', [changeFreq]);
}).play;

SynthDef(\threshTest, {
	arg highThresh = (-22), lowThresh = (-40), delayTime = (0.05);
	var amp, highTrig, lowTrig, in, sig;

	in = SoundIn.ar(0);
	sig = DelayN.ar(in, delaytime: delayTime);
	amp = Amplitude.kr(sig).ampdb; // return Amplitude to to Decibals
	amp = K2A.ar(amp);             // to improve resolution of amplitude tracking control -> audio rate

	highTrig = amp >= highThresh;
	lowTrig = amp <= lowThresh;

	SendReply.ar(Impulse.ar(50), 'highTrigVal', [highTrig]); // Respective triggers for noteOn
	SendReply.ar(Impulse.ar(50), 'lowTrigVal', [lowTrig]);   // and noteOff
}).play;

/*

  OSC Responder (event emitters) for OSC messages
  serve the purpose of dispatching anonymous functions

*/

~oscr4.remove;
~oscr4 = OSCresponder(nil, 'pitch', {
	|time, resp, msg|

	~currentRes = ~currentRes -1;
	if(not(msg[3] == ~pitch), {
		~pitch = msg[3]; // save pitch to global variable ~pitch
	});

}).add;

~oscr3.remove;
~oscr3 = OSCresponder(nil, 'changePitch', {
	|time, resp, msg|

	~changePitch = msg[3];
	if ((~currentRes <= 0) && ~onOrOff && not(~lastPitch == ~changePitch) && not(~lastPitch == ~pitch), {
		"note on slur, pitch ".post;
		~pitch.postln;
		~lastPitch.postln;
		m.noteOn(16, ~pitch, 60);
		~lastPitch = ~pitch;
		~currentRes = ~resolution;
	});

}).add;

~oscr1.remove;
~oscr1 = OSCresponder(nil, 'highTrigVal', {
	|time, resp, msg|

	if((msg[3] == 1) && not(~onOrOff) && (~currentRes <= 0), {
		"note on, pitch ".post;
		~pitch.postln;
		m.noteOn(16, ~pitch, 60);
		~lastPitch = ~pitch;
		~onOrOff = true;
		~currentRes = ~resolution;
	});

}).add;

~oscr2.remove;
~oscr2 = OSCresponder(nil, 'lowTrigVal', {
	|time, resp, msg|

	if((msg[3] == 1) && (~onOrOff) , {
		"note off".postln;
		m.allNotesOff(16);
		~onOrOff = false;
	});
}).add;

)