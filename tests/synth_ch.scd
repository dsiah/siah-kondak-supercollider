s.boot;

( // Define synths on the server
SynthDef.new(\sineTest, {
	arg freq = 440;
	var amp, sig;
	amp = 0.3;
	sig = SinOsc.ar(440, pi);
	Out.ar(0, sig * 0.5); // use the left channel and send the signal
}).add; // add the synth to the server

SynthDef.new(\pulseTest, {
	arg fund = 40, maxPartial = 4, ampHz = 4, width = 0.5;
	var freq1, freq2, sig1, sig2, amp1, amp2;

	// initialize Amplitudes using a LFPulse
	amp1 = LFPulse.kr(ampHz, 0, 0.5) * 0.75; // "1/2"  note
	amp2 = LFPulse.kr(ampHz, 0, 1.0) * 0.75; // "full" note

	// random frequency between fund and fund * maxPartial
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);

	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq1 = freq2 * LFPulse.kr(7, add:1);

	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);

	Out.ar(0, sig1);
	Out.ar(1, sig2);

}).add;
)

( // Send requests to Server once Synths are defined

var x = Synth.new(\pulseTest); // using the defined synth
x.set(\fund, 200);

)