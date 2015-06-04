(

x = {
	var in, amp, hasFreq, freq, out;
	in = SoundIn.ar(0);
	amp  = Amplitude.ar(in);
	freq = Pitch.kr(in).cpsmidi.round;
	freq.poll;
	SinOsc.ar(freq[0].midicps) * amp;

}.play;

)

s = FreqScope.server.boot;
FreqScope.new(400, 200, 0);

x.free;

