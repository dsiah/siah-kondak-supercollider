// stereo through patching from input to output
(
SynthDef("help-AudioIn",{ arg out=0;
	Out.ar(out,
		AudioIn.ar([1,2])
	)
}).play;
)

(
// my very funky arg
var myfunk = {|arg1, arg2| (arg1 * arg2)};
myfunk.valueArray([1,2,3]);
)

(
//{SinOsc.ar(440,0,0.9)}.play;
var boop = {|beep| SinOsc.ar(beep)};
)