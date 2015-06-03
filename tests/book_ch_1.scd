(
/*
**  Generate a Sine Oscillator that pushes the first freq
**  to the left channel and the second freq to the
**  right channel.
*/
var generator = {
	arg left, right;
	{SinOsc.ar([left, right], 0 , 0.2)}.play;
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