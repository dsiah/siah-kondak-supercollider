(
/*
**  Generate a Sine Oscillator that pushes the first freq
**  to the left channel and the second freq to the
**  right channel.
*/
var generator = {
	arg left, right;
	{ SinOsc.ar([left, right], 0 , 0.2) }.play;
};

x = generator.value(523, 629); // x is global?

)

(
{
	var a, b;
	a = [SinOsc.ar(440, 0, 0.2), Saw.ar(540, 1, 0)];
	b = [SinOsc.ar(540, 0, 0.2), Saw.ar(440, 1, 0)];
	Mix([a,b]).postln;
}.play;

)


(
var n = 8;
{
	Mix.fill(n, {
		arg index;
		var freq;
		index.postln;
        freq = 440 + index;
        freq.postln;
        SinOsc.ar(freq , 0, 1 / n)
    })
}.play;
)

(

// very cool!
{ SinOsc.ar(800,
	SinOsc.ar(
		XLine.kr(1, 1000, 1),
		0, 2pi)
	, 0.25)
}.play;

)

(

z = {
	arg amp = 0.3; // defaults for args
	var sig;
	sig = LFNoise0.kr(8, 400, 600);
	SinOsc.ar(sig) * amp;
}.play;

// setting a synth's args after invocation
z.set(\amp, 0.66);

)


(
// Buffers -- server side objects
s.boot;
~b0 = Buffer.read(s, "/Users/muddCS15/Downloads/4409__pinkyfinger__piano-notes-1-octave/68437__pinkyfinger__piano-a.wav");

~b0.play;
~b0.query;

//~b0.numFrames;
// ~b0.numChannels;
// ~b0.duration;

)

(
// Fetch ALL the Samples!
~bells = Array.new;

~folder = PathName.new("/Users/muddCS15/Downloads/4409__pinkyfinger__piano-notes-1-octave/");

~folder.entries.do({
	arg path;
	~bells = ~bells.add(Buffer.read(s, path.fullPath));
});

~bells[1].play;

)