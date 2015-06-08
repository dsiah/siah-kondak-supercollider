// s = FreqScope.server.boot;
// ~w1 = FreqScope.new(800, 400, 0);
// ~w2 = FreqScope.new(800, 400, 8);

(

MIDIClient.init; // initialize the MIDIClient on Server
m = MIDIOut(0); // use first MIDI Device (IAC BUS 1)

~onOrOff = false; // keep track of note being (or not being) played
~pitch = 0;
~changePitch = 0;
~lastPitch = 0;
~resolution = 27;
~currentRes = 0;


x = {
	var in, hasFreq, freq, out, tart, changeFreq;


	in = SoundIn.ar(0); // pipe sound to in

	/*
	Pipe in to Pitch
	calculate the MIDI number of the input sound
	median: remove outliers, 11 in this case takes the median of last 11 frames
	*/
	tart = Tartini.kr(in);
	//freq = Pitch.kr(in, execFreq: 200, median: 21, ampThreshold: 0.1).cpsmidi.round;
	freq = Median.kr(15, tart).cpsmidi.round;
	// Send the Pitch to global variable ~pitch
	changeFreq = DelayN.kr(Median.kr(23, tart).cpsmidi.round, delaytime: 0.05);
	SendReply.ar(Impulse.ar(200), 'pitch', [freq]);
	SendReply.ar(Impulse.ar(200), 'changePitch', [changeFreq]);
}.play;

SynthDef(\threshTest, {
	// above the high triggers the noteOn
	// below the low releases the note (noteOff triggered)
	arg highThresh = (-22), lowThresh = (-40);
	var sig, amp, highTrig, lowTrig, in;

	in = SoundIn.ar(0);
	sig = DelayN.ar(in, delaytime: 0.05);
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



~oscr4.remove; // in case oscr"/Users/muddCS15/Downloads/um132-2mx/"3 needs to be reset to avoid overwriting
~oscr4 = OSCresponder(nil, 'pitch', {
	|time, resp, msg|
<<<<<<< Updated upstream

=======
	~currentRes = ~currentRes -1;
>>>>>>> Stashed changes
	if( msg[3] == ~pitch,
		{},
		{
			~pitch = msg[3]; // save pitch to global variable ~pitch
		}
	);

}).add;

~oscr3.remove; // in case oscr"/Users/muddCS15/Downloads/um132-2mx/"3 needs to be reset to avoid overwriting
~oscr3 = OSCresponder(nil, 'changePitch', {
	|time, resp, msg|
	if( msg[3] == ~changePitch,
		{},
		{
			~changePitch = msg[3]; // save pitch to global variable ~pitch
			if (~currentRes <= 0,
				{
					if( ~onOrOff,
						{
							if ( ~lastPitch == ~changePitch,
								{},
								{
									if( ~lastPitch == ~pitch,
										{},
										{
											"note on slur, pitch ".post;
											~pitch.postln;
											~lastPitch.postln;
											m.noteOn(16, ~pitch, 60);
											~lastPitch = ~pitch;
											~currentRes = ~resolution;
										}
									);


								}
							);
						},
						{

						}
					);
				},
				{}
			);

		}
	);

}).add;

~oscr1.remove;
~oscr1 = OSCresponder(nil, 'highTrigVal', {
	|time, resp, msg|

	if( msg[3] == 1,
		{
			if( ~onOrOff,
<<<<<<< Updated upstream
				{}, {
					"note on, pitch ".post;
					~pitch.postln;
					m.noteOn(16, ~pitch, 60);
					~onOrOff = true
			});
		}, {});
=======
				{},
				{
					if (~currentRes <= 0,
						{
							"note on, pitch ".post;
							~pitch.postln;
							m.noteOn(16, ~pitch, 60);
							~lastPitch = ~pitch;
							~onOrOff = true;
							~currentRes = ~resolution;
						},
						{}
					);
				}
			);
	}, {});
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
=======


/*
SynthDef("pitchFollow1", {
var in, amp, freq, hasFreq, out, midi, b, onsets, chain;

b               = Buffer.alloc(s, 1024);
in              = Mix.new(SoundIn.ar([0,1]));
# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.07, median: 7, execFreq: 200, peakThreshold: 0.75, median: 5);
chain           = FFT(b, in);
onsets          = Onsets.kr(chain, 0.4, \phase); // poor right nows
amp             = Amplitude.kr(in, 0.05, 0.05);
midi            = freq.cpsmidi.round;
out             = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));

6.do({
out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2);
});
onsets.poll(20);
Out.ar(0,out);
}).play(s);
*/
>>>>>>> Stashed changes
)