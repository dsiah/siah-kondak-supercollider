(

GUI.qt;          // Platform independent GUI system
MIDIClient.init; // initialize the MIDIClient on Server
m = MIDIOut(0);  // use first MIDI Device (IAC BUS 1)
ServerOptions.postln;

~onOrOff     = false;
~pitch       = 0;
~changePitch = 0;
~lastPitch   = 0;
~resolution  = 7;
~currentRes  = 0;
~currentDir  = thisProcess.nowExecutingPath.dirname; // seemingly platform independent (Check TODO)

/*
    * * * * * * * * * * *
   * - - - - - - - - - - *
  * -       GUI         - *
  * -       CODE        - *
   *  - - - - - - - - -  *
    * * * * * * * * * * *
*/

Window.closeAll; // Remove once development and debugging is complete (TODO)

~gooey = {
	arg x_pos = (100), y_pos = (75), width = (500), height = (500);
	var w, deviceBtn, configBtn, loadConfigBtn, saveBtn, tab_width, tab_height, tab_x, tab_y,
	levelSlider, resolutionSlider, midis, audios, deviceView, configView, stageBounds,
	audioInBtn, midiOutBtn, highThreshBox, lowThreshBox, resBox, volumeSlider;

	tab_width   = 150;
	tab_height  = 30;
	tab_x       = 100;
	tab_y       = 20;
	stageBounds = Rect(0, y_pos + (y_pos / 6), width, height - (height / 3));

	w             = Window("Pitch Tracker", Rect(x_pos, y_pos, width, height), false);
	deviceBtn     = Button(w, Rect(tab_x, 20,  tab_width, tab_height)).states_([["Device"], ["Device Options"]]);
	loadConfigBtn = Button(w, Rect(tab_x, 450, tab_width, tab_height)).states_([["Load Config File"]]);
	saveBtn       = Button(w, Rect(tab_x + tab_width + 15, 450, tab_width, tab_height)).states_([["Save"]]);
	configBtn     = Button(w, Rect(tab_x + tab_width + 15, 20,  tab_width, tab_height))
	.states_([["Config"], ["Configuration Options"]]);

	deviceView = CompositeView(w, stageBounds).background_(Color.fromHexString("#FFFFFF"));
	configView = CompositeView(w, stageBounds).background_(Color.fromHexString("#FFFFFF"));

	// Device View Elements
	StaticText(deviceView, Rect(tab_x, tab_x - 20, 300, 30)).string_("Audio Input Device");
	StaticText(deviceView, Rect(tab_x, tab_x + 50, 300, 30)).string_("MIDI Output Device");
	audioInBtn   = PopUpMenu(deviceView, Rect(tab_x, tab_x, 300, 30));
	midiOutBtn   = PopUpMenu(deviceView, Rect(tab_x, tab_x + 70, 300, 30));

	StaticText(w, Rect(tab_x, tab_x + 200, 300, 40)).string_("Input Volume");
	volumeSlider = LevelIndicator(w, Rect(tab_x, tab_x + 225, 300, 30));

	// Config View Elements
	StaticText(configView, Rect(tab_x, tab_x - 20, 300, 30)).string_("Levels");
	StaticText(configView, Rect(tab_x - 50, tab_x + 50, 300, 30)).string_("Resolution");
	StaticText(configView, Rect(tab_x - 50, tab_x - 25, 30, 30)).string_("Low");
	StaticText(configView, Rect(width - 75, tab_x - 25, 30, 30)).string_("High");
	lowThreshBox     = NumberBox(configView, Rect(tab_x - 50, tab_x, 30, 30));
	highThreshBox    = NumberBox(configView, Rect(width - 75, tab_x, 30, 30));
	resBox           = NumberBox(configView, Rect(width - 125, tab_x + 70, 30, 30));
	levelSlider      = RangeSlider(configView, Rect(tab_x, tab_x, 300, 30));
	resolutionSlider = Slider(configView, Rect(tab_x - 50, tab_x + 70, 300, 30));

	// Attaching actions to Buttons
	deviceBtn.action = {
		arg view, char;

		deviceBtn.value = 1;
		configBtn.value = 0;

		deviceView.visible = true;
		configView.visible = false;
	};

	configBtn.action = {
		arg view, char;

		configBtn.value = 1;
		deviceBtn.value = 0;

		configView.visible = true;
		deviceView.visible = false;
	};

	saveBtn.action = {
		f = File(~currentDir +/+ "configure.txt", "w");

		f.write(resBox.value        + "\n");
		f.write(lowThreshBox.value  + "\n");
		f.write(highThreshBox.value + "\n");
		f.write(audioInBtn.value    + "\n");
		f.write(midiOutBtn.value    + "\n");

		f.close;
	};

	loadConfigBtn.action = {
		arg view, char, f, data;

		f = File(~currentDir +/+ "configure.txt", "r");
		if (f.isOpen, {
			5.do({ f.getLine.asInt.postln; });
		});

		f.close;
	};

	resolutionSlider.action = {
		var val;

		val = ControlSpec(0, 100, \linear, 1.00).map(resolutionSlider.value);
		resBox.value_(val);
	};

	resBox.action = {
		var val;

		val = resBox.value / 100;
		resolutionSlider.value = val;
	};

	audioInBtn.action = {
		audioInBtn.value.postln;
	};

	// initialization parameters
	midis = [];
	MIDIClient.destinations.do({
		arg item, arr;

		midis.add(item.device);
	});
	midiOutBtn.items_(midis);
	audioInBtn.items_(ServerOptions.inDevices);

	~oscr5.remove;
	~oscr5 = OSCresponder(nil, 'amp', {
		|time, resp, msg, vol|

		vol = msg[3];
		{ volumeSlider.value = vol }.defer;
	}).add;

	levelSlider.setSpan(-100, 0);
	deviceBtn.value    = 1;
	deviceView.visible = true;
	configView.visible = false;

	w.background_(Color.fromHexString("#C0D1FF"));
	w.front.alwaysOnTop_(true);

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
	SendReply.ar(Impulse.ar(30), 'amp', [Amplitude.kr(sig)]);
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
			m.noteOff(16, ~lastPitch, 0);
			m.noteOn(16, ~pitch, 60);
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
		m.noteOff(16, ~lastPitch, 0);
		m.noteOn(16, ~pitch, 60);
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
		m.noteOff(16, ~lastPitch, 0);
		~onOrOff = false;
	});
}).add;

)