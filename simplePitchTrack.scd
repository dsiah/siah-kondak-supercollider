s = FreqScope.server.boot;
FreqScope.new(400, 200, 0);


(
MIDIClient.init;
m = MIDIOut(0);
~onOrOff = false;
~pitch = 0;

SynthDef(\threshTest, {
	arg highThresh = (-22), lowThresh = (-40);
	var sig, amp,highTrig, lowTrig, onOrOff;
	sig = SoundIn.ar(0);
	amp = Amplitude.kr(sig).ampdb;
	amp = K2A.ar(amp);
	highTrig = amp >= highThresh;
	lowTrig = amp <= lowThresh;
	SendReply.ar(Impulse.ar(50), 'highTrigVal', [highTrig]);
	SendReply.ar(Impulse.ar(50), 'lowTrigVal', [lowTrig]);
}).play;

~oscr1.remove;
~oscr1 = OSCresponder(nil, 'highTrigVal', {
	|time, resp, msg|
	if( msg[3] == 1,
		{
			if( ~onOrOff,
				{},
				{
			    //"note on!".postln;
			    m.noteOn(16, ~pitch, 60);
				~onOrOff = true;}
			);
		}, {});
}).add;

~oscr2.remove;
~oscr2 = OSCresponder(nil, 'lowTrigVal', {
	|time, resp, msg|
	if( msg[3] == 1,
		{
			if( ~onOrOff,
				{
				//"note off".postln;
				~onOrOff = false;},
				{}
			);
		}, {

	});
}).add;

~oscr3.remove;
~oscr3 = OSCresponder(nil, 'pitch', {
	|time, resp, msg|
	~pitch = msg[3];
	//~pitch.postln;
}).add;

x = {
	var in, amp, hasFreq, freq, out;

	in = SoundIn.ar(0);
	freq = Pitch.kr(in, execFreq: 200, median: 11, ampThreshold: 0.1).cpsmidi.round;
	//freq.poll;
	SendReply.ar(Impulse.ar(50), 'pitch', [freq]);
}.play;

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

onsets.poll(20); // currently pretty crummy -- look into 3rd party Onset detection.

// Current Problems Amp is not a number -- its a ugen
// Also Unable to trigger if statenments every few miliseconds.

Out.ar(0,out);
}).play(s);
*/
)