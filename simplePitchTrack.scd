(

x = {
	var in, amp, hasFreq, freq, out;
	in = SoundIn.ar(0);
	amp  = Amplitude.ar(in);
	freq = Pitch.kr(in).cpsmidi.round;
	// freq.poll;
	SinOsc.ar(freq[0].midicps) * amp;
}.play;

)

s = FreqScope.server.boot;
FreqScope.new(400, 200, 0);

(
SynthDef("pitchFollow1",{
    var in, amp, freq, hasFreq, out, midi;
    in = Mix.new(SoundIn.ar([0,1]));
    amp = Amplitude.kr(in, 0.05, 0.05);
    # freq, hasFreq = Pitch.kr(in, ampThreshold: 0.07, median: 7, execFreq: 200, peakThreshold: 0.75, median: 5);
	midi = freq.cpsmidi.round;
	midi.poll;
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    out = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));
    6.do({
        out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2);
    });
	// freq.poll;

    Out.ar(0,out)
}).play(s);
)
