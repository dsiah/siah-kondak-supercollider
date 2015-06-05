s.boot; s.plotTree;


(
// Use Xline to control envolope and frequencies of Pulse synth
x = {
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 4, doneAction: 2);
	freq = XLine.kr(880, 110, 5, doneAction: 2);
	sig = Pulse.ar(freq) * env;
}.play;

)


(
// Envelopes
x = {
	arg t_gate = 0;
	var sig, env, min;

	min = Env.new([0, 1, 0.5, 0],
		          [0.1, 0.8, 0.1],
		          [3, -3, 0]);

	env = EnvGen.kr(min, t_gate);
	sig = Pulse.ar(LFPulse.kr(8).range(800, 100)) * env;
}.play;

x.set(\t_gate, 1);
)

(
// ADSR: Attack Decay Sustain Release
x = {
	arg gate = 0; // t_gate = 0;
	var sig, env;

	env = EnvGen.kr(Env.adsr, gate);
	sig = VarSaw.ar(SinOsc.kr(16).range(500, 1000)) * env;
}.play;

x.set(\gate, 0);
)