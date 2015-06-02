(
var genTone = {|freq| {SinOsc.ar(freq)}.play};
genTone.value(100);
genTone.free
)