GUI.qt; // Set Windowing agent on OSX to QT
( var w, b, s, c, b2, time;

w = Window.new("GUI Introduction", Rect(200,200,255,100));

b2 = Button.new(w, Rect(20, 30, 50, 50)).states_([["Toggle on!"], ["Toggle off"]]);
b2.action = {
	var mx = b2.value.asBoolean;

	if (mx, { "Its on!".postln }, { "It's off :(".postln });
};

w.front;

)