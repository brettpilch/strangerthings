(
SynthDef(\strange, {
	arg freq=440, amp=0.2, sawamp=1.0, sinamp=0.7, blipamp=0.3, atk=0.01, rel=0.5, out=0, detune=0.01,
	fxout=0, fxamp=0.0, nharm=4;
	var sig, sawsig, sinsig, blipsig, env, altfreq;
	altfreq = exprand(1 - detune, 1 + detune) * freq;
	sawsig = Saw.ar([freq, altfreq]) * sawamp;
	sinsig = SinOsc.ar([freq, altfreq]) * sinamp;
	blipsig = Blip.ar([freq / 2, altfreq / 2], nharm) * blipamp;
	env = EnvGen.kr(Env.perc(atk,rel), doneAction:2);
	sig = (sawsig + sinsig + blipsig) * env;
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;
)

(
SynthDef(\strangekick, {
	arg freq=100, atk=0.00001, rel=0.2, curve=(-4), amp=0.2, out=0, fxout=0, fxamp=0.0;
	var sig, sig2, env;
	sig = LFCub.ar(EnvGen.kr(Env([freq, freq, freq / 2], [atk, rel], curve: [curve, curve])));
	sig2 = LFCub.ar(EnvGen.kr(Env([freq * 2, freq * 2, freq], [atk, rel], curve: [curve, curve])));
	sig = sig + sig2;
	env = EnvGen.kr(Env.perc(atk, rel, curve: curve), doneAction: 2);
	sig = sig * env;
	Out.ar(out, sig!2 * amp);
	Out.ar(fxout, sig!2 * fxamp);
}).add;
)

(
SynthDef(\strangepad, {
	arg out=0, freq=440, amp=0.4, detune=0.01, atk=2.0, sus=0.5, rel=1.0, curve=4,
	curve1=1, cfstart=400, cfpeak=2000, cfend=400, cfatk=2.0, cfsus=0.5, cfrel=1.0,
	fcurve=4, fcurve1=1, rq=0.5, fxout=0, fxamp=0.0;
	var sig, env, fenv;
	sig = Saw.ar([freq, exprand(1 - detune, 1 + detune) * freq]);
	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [curve, 1, curve1]), doneAction: 2);
	fenv = EnvGen.kr(Env([cfstart, cfpeak, cfpeak, cfend], [cfatk, cfsus, cfrel], [fcurve, 1, fcurve1]), doneAction: 2);
	sig = BLowPass4.ar(sig, fenv, rq);
	sig = sig * env;
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;
)

(
SynthDef(\strangetwinkle, {
	arg freq=440, detune=0.02, pw=0.3, atk=0.00001, rel=0.3, curve=(-4), amp=0.2, out=0,
	fxout=0, fxamp=0.0, pan=0.0, cf=1000.0, rq=1.0;
	var sig, env;
	sig = LFPulse.ar([freq, exprand(1 - detune, 1 + detune) * freq], width: pw);
	sig = BLowPass4.ar(sig, cf, rq);
	sig = Mix.ar([sig[0], sig[1]]);
	env = EnvGen.kr(Env.perc(atk, rel, curve: curve), doneAction: 2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;
)

(
SynthDef(\strangeFilter, {
	arg in, out=0, loFreq=500, hiFreq=10000, riseTime=20, fallTime=20, curve=4,
	fxout=0, fxamp=0.0, amp=1.0;
	var sig, env;
	env = EnvGen.kr(Env([loFreq, hiFreq, loFreq], [riseTime, fallTime], [curve, curve.neg]));
	sig = LPF.ar(In.ar(in, 2), env);
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;
)

(
SynthDef(\strangeverb, {
	arg in, out=0, room=0.5, damp=0.5;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(sig[0], sig[1], 1.0, room, damp);
	Out.ar(out, sig);
}).add;
)

Synth(\strangeverb, [\in, ~reverbBus]);
Synth(\strangekick, [\fxout, ~reverbBus, \fxamp, 0.9]);

(
~filterBus = Bus.audio(s, 2);
~reverbBus = Bus.audio(s, 2);
)

(
~tempo = 175; //bpm
~quarternote = 60 / ~tempo;
~eighthnote = ~quarternote / 2;
~measure = 4 * ~quarternote;
)

2000 * 1.4.pow(6);

(
Synth(\strangeverb, [\in, ~reverbBus, \room, 0.6, \damp, 0.6]);

r = Routine({
	Pdef(\strangerpad,
		Pbind(
			\instrument, \strangepad,
			\cfstart, 110,
			\cfpeak, 1000,
			\cfend, 110,
			\detune, 0.02,
			\midinote, Pseq([[48, 52, 55, 59]], 1),
			\dur, 6.0,
			\rel, 1.0,
			\cfrel, 1.0,
			\curve, 2.0,
			\fcurve, 2.0,
			\curve1, -1.0,
			\fcurve1, -1.0,
			\sus, 0.3,
			\cfsus, 0.3,
			\atk, 2.5,
			\cfatk, 2.5,
			\amp, 0.13,
			\rq, 0.3,
			\fxout, ~reverbBus,
			\fxamp, 0.4,
		);
	).play;

	Pdef(\strangertwinkle,
		Pbind(
			\instrument, \strangetwinkle,
			\dur, 0.077,
			\midinote, Pseq([96,95,91,88,84,88,91,95], inf),
			\atk, 0.01,
			\rel, 0.4,
			\pw, 0.5,
			\amp, Pseq([Pseries(2, 1, 35), Pseries(37, (-1), 6)]) / 10000.0,
			\pan, Pwhite(-0.9, 0.9, inf),
			\cf, Pseq([Pgeom(2000, 1.4, 5), Pgeom(15059.072, 1 / 1.4, 5)], inf),
			\rq, 0.4,
			\fxout, ~reverbBus,
			\fxamp, Pseq([Pseries(2, 1, 35), Pseries(37, (-1), 6)]) / 3000.0,
		);
	).play;

	3.0.wait;

	Synth(\strangeFilter, [
		\in, ~filterBus,
		\loFreq, 600,
		\hiFreq, 4000,
		\fxout, ~reverbBus,
		\fxamp, 0.9,
	]);

	Pdef(\stranger,
		Pbind(
			\instrument, \strange,
			\midinote, Pseq([48, 52, 55, 59, 60, 59, 55, 52], inf),
			\dur, ~eighthnote,
			\atk, 0.012,
			\rel, 0.5,
			\detune, 0.03,
			\sawamp, 1.0,
			\sinamp, 0.7,
			\blipamp, 0.3,
			\nharm, 4,
			\amp, 0.2,
			\out, ~filterBus
		)
	).play;

	Pdef(\strangerkick,
		Pbind(
			\instrument, \strangekick,
			\freq, Pseq([75, 75, Pseq([Rest], 2)], inf),
			\rel, 0.8,
			\dur, ~eighthnote,
			\amp, Pseq([0.25, 0.15], inf),
			\fxout, ~reverbBus,
			\fxamp, 0.1,
		)
	).play;
}).play;
)

s.quit;