# Cochlear Signal Processing in MATLAB

A MATLAB model of the human cochlea, built as an individual mini-project for **ELEC3104 Digital Signal Processing** at UNSW (Term 3, 2025). The cochlea is treated as a real-time spectrum analyser: a bank of 128 overlapping bandpass filters, followed by inner hair cell models that turn each channel's output into an energy measure. On top of that filter bank I built speech analysis and synthesis, noise reduction, pitch detection and an adaptive version of the model.

## What it does

| Level | Scripts | What I built |
|-------|---------|--------------|
| **2: Filter bank** | `Level21.m` to `Level26.m` | 128 IIR bandpass filters covering 80 Hz to 7.7 kHz at 16 kHz sampling, designed by pole-zero placement with Q rising from 5 to 10 across the bank. The IIR responses are converted to FIR analysis filters, combined with time-reversed synthesis filters into a linear-phase bank, and used to reconstruct speech and music and to denoise speech with per-subband gain control. |
| **3: Spectrum analyser** | `Level31.m` | A short-time spectrum analyser with per-filter gain normalisation, two spatial differentiation stages to sharpen the filter responses, and two inner hair cell models (rectifier with a low-pass filter, and a 16 ms accumulator with post-filtering). |
| **4: Pitch detection** | `Level41.m`, `Level43.m`, `Level45.m` | Fundamental frequency estimated from the spectrum analyser's energy output after removing the vocal tract response with 12th-order LPC. Also tested on telephone-band speech with the fundamental removed, recovering the missing fundamental with a nonlinear stage followed by a bandpass filter. |
| **5: Adaptive model** | `Level51.m` | A second bank of resonant filters whose Q factor follows the signal level (energy over 5 ms frames), boosting weak components while leaving the original filter coefficients unchanged. |

`auditoryInitialisation.m` and `auditoryProcessor.m` hold shared code used by the level scripts. <!-- TODO: one line on what each does -->

## Results

<!-- TODO: add 3 to 5 figures from your own runs, each with a one-line caption saying what it shows. Suggestions:
     - Magnitude responses of 10 selected analysis filters
     - IIR vs FIR response for a ~1 kHz filter (160 vs 300 taps)
     - Spectrum analyser output for a sum of sinusoids
     - Pitch track for your recording of "We were away"
     - Q factor vs input level in the adaptive model
     Put the images in a figures/ folder and link them like: ![caption](figures/name.png) -->

## How to run

Requires MATLAB with the Signal Processing Toolbox.

<!-- TODO: paste or merge the execution instructions from your current README here, for example:
1. Open the repository folder in MATLAB.
2. Run auditoryInitialisation.m first.
3. Run the Level script you want, e.g. Level21.m. -->

## Audio files

`voice.wav`, `wewereaway.wav` and `wewereawaymax.wav` are my own recordings. <!-- TODO: if you remove the course-provided files, say here that users should supply their own 16 kHz mono speech, music and noise .wav files -->

## Notes

- Developed solo for coursework.
- Tools: MATLAB, Signal Processing Toolbox.
- Concepts: digital filter design (pole-zero placement), IIR/FIR conversion, linear-phase filtering, filter banks, LPC, pitch estimation, adaptive filtering.

## Contact

Max Luo, Electrical Engineering (Honours), UNSW Sydney
[LinkedIn](https://www.linkedin.com/in/chengji-luo-1505b3319) | [GitHub](https://github.com/MaxLuo-EE)
