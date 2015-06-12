(

GUI.qt;          // Platform independent GUI system
MIDIClient.init; // initialize the MIDIClient on Server
m = MIDIOut(0);  // use first MIDI Device (IAC BUS 1)
MIDIClient.destinations[0].device;

~onOrOff     = false;
~pitch       = 0;
~changePitch = 0;
~lastPitch   = 0;
~resolution  = 7;
~currentRes  = 0;
~currentDir  = thisProcess.nowExecutingPath.dirname; // seemingly platform independent (Check TODO)
~gooeyBounds = [500, 500, 500, 500];                 // x pos, y pos, width, height


/*
    * * * * * * * * * * *
   * - - - - - - - - - - *
  * -       GUI         - *
  * -       CODE        - *
   *  - - - - - - - - -  *
    * * * * * * * * * * *
*/

~gooey = {
	arg x_pos = (100), y_pos = (75), width = (500), height = (500);
	var w, deviceBtn, configBtn, loadConfigBtn, tab_width, tab_height, tab_x, tab_y, padding;

	tab_width  = 150;
	tab_height = 30;
	tab_x      = 100;
	tab_y      = 20;
	padding    = 15;

	w             = Window.new("Pitch Tracker", Rect(x_pos, y_pos, width, height));
	deviceBtn     = Button(w, Rect(tab_x, 20,  tab_width, tab_height)).states_([["Device"], ["Device Options"]]);
	configBtn     = Button(w, Rect(tab_x + tab_width + padding, 20,  tab_width, tab_height)).states_([["Config"], ["Configuration Options"]]);
	loadConfigBtn = Button(w, Rect(125, 450, 150, 30)).states_([["Load Config File"]]);

	deviceBtn.action = {
		arg view, char;

		deviceBtn.value = 1;
		configBtn.value = 0;
	};

	configBtn.action = {
		arg view, char; // switch to Config view (TODO)

		configBtn.value = 1;
		deviceBtn.value = 0;
	};

	loadConfigBtn.action = {
		arg view, char, f;

		f = File(~currentDir +/+ "configure.txt", "w");
		f.readAllString;

		f.close;
	};

	w.front;
}.value;

SynthDef(\freqTrack, {
	arg threshold = (0.93), median = (63), framesize = (512), overlap = (256), delayTime = (0.10);
	var freq, in, tart, changeFreq;

	/*

	  FreqTrack: Pipe in to Pitch
	  calculates the MIDI number of the input sound

	*/

	in         = SoundIn.ar(0);
	tart       = Tartini.kr(in, threshold, framesize, 0, overlap);
	freq       = Median.kr(median, tart).cpsmidi.round;
	changeFreq = DelayN.kr(Median.kr(67, tart).cpsmidi.round, delaytime: delayTime);

	SendReply.ar(Impulse.ar(50), 'pitch', [freq]);
	SendReply.ar(Impulse.ar(50), 'changePitch', [changeFreq]);
}).play;

SynthDef(\threshTest, {
	arg highThresh = (-22), lowThresh = (-40), delayTime = (0.10);
	var amp, highTrig, lowTrig, in, sig;

	in  = SoundIn.ar(0);
	sig = DelayN.ar(in, delaytime: delayTime);
	amp = Amplitude.kr(sig).ampdb; // return Amplitude to to Decibals
	amp = K2A.ar(amp);             // to improve resolution of amplitude tracking control -> audio rate

	highTrig = amp >= highThresh;
	lowTrig  = amp <= lowThresh;

	SendReply.ar(Impulse.ar(50), 'highTrigVal', [highTrig]); // Respective triggers for noteOn
	SendReply.ar(Impulse.ar(50), 'lowTrigVal', [lowTrig]);   // and noteOff
}).play;

/*

  OSC Responder (event emitters) for OSC messages
  serve the purpose of dispatching anonymous functions

*/

~oscr4.remove;
~oscr4 = OSCresponder(nil, 'pitch', {
	|time, resp, msg|

	~currentRes = ~currentRes -1;
	if(not(msg[3] == ~pitch), {
		~pitch = msg[3]; // save pitch to global variable ~pitch
	});

}).add;

~oscr3.remove;
~oscr3 = OSCresponder(nil, 'changePitch', {
	|time, resp, msg|

	~changePitch = msg[3];
	if ((~currentRes <= 0) && ~onOrOff && not(~lastPitch == ~changePitch) &&
		not(~lastPitch == ~pitch) && (~pitch == ~changePitch), {
			"note on slur, pitch ".post;
			~pitch.postln;
			~lastPitch.postln;
			if(~onOrOff,
				m.noteOff(1, ~lastPitch, 60);
			);
			m.noteOn(1, ~pitch, 60);
			~lastPitch = ~pitch;
			~currentRes = ~resolution;
	});

}).add;

~oscr1.remove;
~oscr1 = OSCresponder(nil, 'highTrigVal', {
	|time, resp, msg|

	if((msg[3] == 1) && not(~onOrOff) && (~currentRes <= 0), {
		"note on, pitch ".post;
		~pitch.postln;
		m.noteOn(1, ~pitch, 60);
		~lastPitch = ~pitch;
		~onOrOff = true;
		~currentRes = ~resolution;
	});

}).add;

~oscr2.remove;
~oscr2 = OSCresponder(nil, 'lowTrigVal', {
	|time, resp, msg|

	if((msg[3] == 1) && (~onOrOff) , {
		"note off".postln;
		m.noteOff(1, ~lastPitch, 60);
		~onOrOff = false;
	});
}).add;

)