(
var a = FuncStream.new({ #[1,2,3,4,5].choose });
6.do({ a.next.postln; });
)

(
var a = Routine.new({
	10.do({ arg i; i.yield; });
});
4.do({ b.next.postln });
)


(
{ SoundIn.ar([0, 1]).poll }.play;
SystemClock.sched(5, { "hello".postln });
)