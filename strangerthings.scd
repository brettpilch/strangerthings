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

SynthDef(\strangekick, {
	arg freq=100, atk=0.00001, rel=0.2, curve=(-4), amp=0.2, out=0, fxout=0, fxamp=0.0;
	var sig, sig2, noisig, noisenv, env;
	sig = LFCub.ar(EnvGen.kr(Env([freq, freq, freq / 2], [atk, rel], curve: [curve, curve])));
	sig2 = LFCub.ar(EnvGen.kr(Env([freq * 2, freq * 2, freq], [atk, rel], curve: [curve, curve])));
	noisig = BPF.ar(PinkNoise.ar(0.7), 800, 1);
	noisenv = EnvGen.kr(Env.perc(atk, rel / 10, curve: curve));
	noisig = noisig * noisenv;
	sig = sig + sig2;
	env = EnvGen.kr(Env.perc(atk, rel, curve: curve), doneAction: 2);
	sig = sig * env;
	sig = sig + noisig;
	Out.ar(out, sig!2 * amp);
	Out.ar(fxout, sig!2 * fxamp);
}).add;

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

SynthDef(\strangeFilter, {
	arg in, out=0, loFreq=500, hiFreq=10000, nextLoFreq=500, endStart=400, endFinish=8000,
	riseTime=20, hiStayTime=10, fallTime=20, loStayTime=10, endRise=4,
	curve=4,
	fxout=0, fxamp=0.0, amp=1.0;
	var sig, env;
	env = EnvGen.kr(Env([loFreq, hiFreq, hiFreq, nextLoFreq, nextLoFreq, endStart, endFinish],
		[riseTime, hiStayTime, fallTime, loStayTime, 0, endRise], [curve, curve.neg, curve, curve, curve]));
	sig = LPF.ar(In.ar(in, 2), env);
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;

SynthDef(\strangeverb, {
	arg in, out=0, room=0.5, damp=0.5;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(sig[0], sig[1], 1.0, room, damp);
	Out.ar(out, sig);
}).add;

SynthDef(\strangestab, {
	arg freq=440, amp=0.2, sawamp=1.0, sinamp=0.7, blipamp=0.3, squareamp=0.5, pw=0.5,
	atk=0.01, rel=0.5, out=0, detune=0.01, cf=2.0,
	fxout=0, fxamp=0.0, nharm=4;
	var sig, sawsig, sinsig, blipsig, squaresig, env, altfreq;
	altfreq = exprand(1 - detune, 1 + detune) * freq;
	sawsig = LFSaw.ar([freq, altfreq]) * sawamp;
	sinsig = SinOsc.ar([freq, altfreq]) * sinamp;
	blipsig = Blip.ar([freq / 2, altfreq / 2], nharm) * blipamp;
	squaresig = LFPulse.ar([freq, altfreq], 0, pw) * squareamp;
	env = EnvGen.kr(Env.perc(atk,rel), doneAction:2);
	sig = (sawsig + sinsig + blipsig + squaresig) * env;
	sig = LPF.ar(sig, cf * freq);
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;

SynthDef(\strangeswell, {
	arg freq=440, amp=0.2, sawamp=1.0, sinamp=0.7, squareamp=0.5, pw=0.5,
	atk=2.0, rel=0.5,
	cfstart=0.5, cfpeak=4.0, cfend=0.5, kt=1.0, rq=1.0,
	fatk=2.0, flegato=1.0,
	out=0, detune=0.01, cf=2.0,
	fxout=0, fxamp=0.0;
	var sig, sawsig, sinsig, squaresig, env, altfreq, fenv;
	altfreq = exprand(1 - detune, 1 + detune) * freq;
	sawsig = LFSaw.ar([freq, altfreq], [0, 0]) * sawamp;
	sinsig = SinOsc.ar([freq, altfreq], [0, 0]) * sinamp;
	squaresig = LFPulse.ar([freq, altfreq], [0, 0], pw) * squareamp;
	sig = sawsig + sinsig + squaresig;
	fenv = EnvGen.kr(Env(
		[cfstart.pow(kt) * freq, cfpeak.pow(kt) * freq, cfend.pow(kt) * freq],
		[fatk,flegato * rel]
	));
	sig = BPF.ar(sig, fenv, rq);
	env = EnvGen.kr(Env.perc(atk,rel), doneAction:2);
	sig = sig * env;
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;

SynthDef(\strangesplash, {
	arg freq=440, amp=0.2, sawamp=1.0, sinamp=0.7, blipamp=0.3, nharm=4, squareamp=0.5, pw=0.5,
	noisamp=0.5, cfstart=400, cfpeak=2000, cfend=400, cfatk=0.01, cfrel=1.0, rq=1.0,
	atk=0.01, rel=1.0, out=0, detune=0.01, hpfamp=1.0, bpfamp=1.0,
	fxout=0, fxamp=0.0;
	var sig, sawsig, sinsig, blipsig, squaresig, noisig, env, fenv, altfreq;
	altfreq = exprand(1 - detune, 1 + detune) * freq;
	sawsig = LFSaw.ar([freq, altfreq]) * sawamp;
	sinsig = SinOsc.ar([freq, altfreq]) * sinamp;
	blipsig = Blip.ar([freq / 2, altfreq / 2], nharm) * blipamp;
	squaresig = LFPulse.ar([freq, altfreq], 0, pw) * squareamp;
	noisig = WhiteNoise.ar(noisamp);
	env = EnvGen.kr(Env.perc(atk,rel), doneAction:2);
	sig = (sawsig + sinsig + blipsig + squaresig + noisig);
	fenv = EnvGen.kr(Env([cfstart, cfpeak, cfend], [cfatk, cfrel], [1, (-5)]));
	sig = (HPF.ar(sig, fenv) * hpfamp) + (BPF.ar(sig, fenv, rq) * bpfamp);
	sig = sig * env;
	Out.ar(out, sig * amp);
	Out.ar(fxout, sig * fxamp);
}).add;
)

// sandbox:
(
Synth(\strangesplash, [\freq, 52.midicps, \atk, 0.01, \rel, 3.0, \blipamp, 0.0, \sinamp, 0.0, \sawamp, 0.6,
	\squareamp, 0.0, \nharm, 40, \pw, 0.2, \cfstart, 200, \cfpeak, 10000, \cfend, 200,
	\cfatk, 0.01, \cfrel, 4.0,
	\amp, 0.5, \noisamp, 0.0, \rq, 1.0, \hpfamp, 0
]);
)

(
Synth(\strangeswell, [\freq, 64.midicps, \rq, 0.1, \amp, 0.2, \detune, 0.01,
	\sawamp, 0.1, \squareamp, 0.9, \sinamp, 0.5, \pw, 0.1,
	\cfstart, 1.5, \cfpeak, 8.0, \cfend, 0.2,
	\fatk, 3.0, \atk, 3.0
]);

Synth(\strangeswell, [\freq, 60.midicps, \rq, 0.1, \amp, 0.2, \detune, 0.01,
	\sawamp, 0.1, \squareamp, 0.9, \sinamp, 0.5, \pw, 0.1,
	\cfstart, 1.5, \cfpeak, 8.0, \cfend, 0.2,
	\fatk, 3.0, \atk, 3.0
]);

Synth(\strangeswell, [\freq, 67.midicps, \rq, 0.1, \amp, 0.2, \detune, 0.01,
	\sawamp, 0.1, \squareamp, 0.9, \sinamp, 0.5, \pw, 0.1,
	\cfstart, 1.5, \cfpeak, 8.0, \cfend, 0.2,
	\fatk, 3.0, \atk, 3.0
]);

Synth(\strangeswell, [\freq, 71.midicps, \rq, 0.1, \amp, 0.2, \detune, 0.01,
	\sawamp, 0.1, \squareamp, 0.9, \sinamp, 0.5, \pw, 0.1,
	\cfstart, 1.5, \cfpeak, 8.0, \cfend, 0.2,
	\fatk, 3.0, \atk, 3.0
]);
)

(
Synth(\strangestab, [\freq, 52.midicps, \atk, 0.02, \rel, 3.0, \blipamp, 0.2, \sinamp, 0.1, \sawamp, 0.9,
	\squareamp, 0.1, \nharm, 16, \pw, 0.5, \cf, 10.0
]);
)

Synth(\strangeverb, [\in, ~reverbBus]);

Synth(\strangekick, [\fxout, ~reverbBus, \fxamp, 0.05]);

// fx busses:
(
~filterBus = Bus.audio(s, 2);
~reverbBus = Bus.audio(s, 2);
)

// time and tempo data:
(
~tempo = 175; //bpm
~quarternote = 60 / ~tempo;
~eighthnote = ~quarternote / 2;
~measure = 4 * ~quarternote;
~introtime = 3.0;
~songlength = 300.0;
)

// patterns:
(
~strangerverb = Pbind(
	\instrument, \strangeverb,
	\in, ~reverbBus,
	\room, 0.6,
	\damp, 0.6,
	\dur, ~songlength,
);

~strangerpad = Pbind(
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

~strangertwinkle = Pbind(
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

~strangerfilter = Pbind(
	\instrument, \strangeFilter,
	\in, ~filterBus,
	\loFreq, 600,
	\hiFreq, 4000,
	\nextLoFreq, 800,
	\endStart, 1000,
	\endFinish, 2500,
	\riseTime, 12 * ~measure,
	\hiStayTime, 2 * ~measure,
	\fallTime, 12 * ~measure,
	\loStayTime, 4 * ~measure,
	\endRise, 3 * ~measure,
	\fxout, ~reverbBus,
	\fxamp, 0.9,
	\amp, 1.0,
	\dur, Pseq([Rest(~introtime), ~songlength]),
);

~stranger = Pbind(
	\instrument, \strange,
	\midinote, Pseq([Rest, Pseq([48, 52, 55, 59, 60, 59, 55, 52], 30),
		Pseq([36, 40, 43, 47, 48, 47, 43, 40], 3)
	]),
	\dur, Pseq([~introtime, Pseq([~eighthnote], inf)]),
	\atk, 0.012,
	\rel, 0.5,
	\detune, 0.03,
	\sawamp, 1.0,
	\sinamp, 0.7,
	\blipamp, 0.3,
	\nharm, 4,
	\amp, 0.2,
	\out, ~filterBus
);

~strangerkick = Pbind(
	\instrument, \strangekick,
	\freq, Pseq([Rest, Pseq([75, 75, Pseq([Rest], 2)], 66), Pseq([75, 75, Pseq([Rest], 6)], 4)]),
	\rel, 0.8,
	\dur, Pseq([~introtime, Pseq([~eighthnote], inf)]),
	\amp, Pseq([Rest, Pseq([0.3, 0.2], inf)]),
	\fxout, ~reverbBus,
	\fxamp, 0.05,
);

~strangerstab = Pbind(
	\instrument, \strangestab,
	\dur, Pseq([~introtime, 4, 4, 3.5, 0.5, 3.5, 0.5, 3.0, 3/8, 3/8, 1/4 + 4, 2, 4, 3, 2])
	* Pseq([1, Pseq([~measure], inf)]),
	\midinote, Pseq([Rest, Rest, 52, 48, 50, 52, 50, 48, 50, 48, 47, Rest, 47, 52, 52]) - 12,
	\atk, 0.01,
	\rel, Pkey(\dur) ** 0.45 * 4.0,
	\blipamp, 0.0,
	\sinamp, 0.6,
	\sawamp, 0.7,
	\squareamp, 0.0,
	\nharm, 4,
	\pw, 0.5,
	\fxout, ~reverbBus,
	\fxamp, 0.2,
	\amp, Pseq([0, 0, 0.15, Pseq([0.25], 9), Pseq([0.2], 2), 0.13]),
	\cf, Pseq([10, 10, 12, 14, 14, 14, 20, 20, 14, 14, 14, 14, 12, 12, 9])
);

~strangerswell = Pbind(
	\instrument, \strangeswell,
	\dur, Pseq([~introtime, 4, 4]) * Pseq([1, Pseq([~measure], inf)]),
	\midinote, Pseq([Rest, Rest, [60, 64, 67, 71]]),
	\rq, 0.5,
	\detune, 0.02,
	\sawamp, 0.1,
	\squareamp, 0.9,
	\sinamp, 0.5,
	\pw, 0.1,
	\cfstart, 0.25,
	\cfpeak, 4.0,
	\cfend, 0.25,
	\fatk, 4 * ~measure,
	\atk, 4 * ~measure,
	\amp, 0.07,
	\fxamp, 0.25,
	\fxout, ~reverbBus
);

~strangersplash = Pbind(
	\instrument, \strangesplash,
	\dur, Pseq([~introtime, 8, 4]) * Pseq([1, Pseq([~measure], inf)]),
	\midinote, Pseq([Rest, Rest, 52]),
	\atk, 0.01,
	\rel, 3.0,
	\blipamp, 0.9,
	\sinamp, 0.0,
	\sawamp, 0.6,
	\squareamp, 0.0,
	\nharm, 40,
	\cfstart, 5000,
	\cfpeak, 15000,
	\cfend, 5000,
	\cfatk, 0.01,
	\cfrel, 4.0,
	\amp, 0.3,
	\noisamp, 0.2,
	\rq, 0.2,
	\fxamp, 0.25,
	\fxout, ~reverbBus
);

~strangeroffset = Pbind(
	\instrument, \strangesplash,
	\dur, Pseq([~introtime, 8.5, 4]) * Pseq([1, Pseq([~measure], inf)]),
	\midinote, Pseq([Rest, Rest, 52]),
	\atk, 0.03,
	\rel, 8.0,
	\blipamp, 0.0,
	\sinamp, 0.0,
	\sawamp, 0.6,
	\squareamp, 0.0,
	\nharm, 20,
	\cfstart, 200,
	\cfpeak, 10000,
	\cfend, 200,
	\cfatk, 0.03,
	\cfrel, 8.0,
	\amp, 0.2,
	\noisamp, 0.0,
	\rq, 1.0,
	\hpfamp, 0.0,
	\fxamp, 0.25,
	\fxout, ~reverbBus
);

Ppar([
	~strangerverb,
	~strangerpad,
	~strangertwinkle,
	~strangerfilter,
	~stranger,
	~strangerkick,
	~strangerstab,
	~strangerswell,
	~strangersplash,
	~strangeroffset
]).play;
)

s.quit;