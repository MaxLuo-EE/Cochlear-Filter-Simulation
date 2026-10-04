# Cochlear Signal Processing in MATLAB

A MATLAB model of the human cochlea built as an individual mini-project for **ELEC3104 Digital Signal Processing** at UNSW (Term 3, 2025). The project treats the cochlea as a real-time spectrum analyser: a bank of 128 overlapping bandpass filters, followed by inner hair cell models that turn each channel's output into an energy measure. On top of that filter bank I built speech analysis and synthesis, noise reduction, pitch detection and an adaptive version of the model.

> **Status:** complete. <!-- TODO: add your final mark or feedback here only if you want to -->

## What it does

| Stage | What I built |
|-------|--------------|
| **1. Cochlear filter bank** | 128 IIR bandpass filters covering 80 Hz to 7.7 kHz at 16 kHz sampling. Centre frequencies follow the basilar membrane's frequency map, and the quality factor rises from 5 to 10 from low to high frequency. Each filter is a second-order section designed by pole-zero placement. |
| **2. FIR analysis and synthesis** | The IIR impulse responses are truncated to FIR filters (160 and 300 taps). Time-reversed synthesis filters are combined with the analysis filters to give a linear-phase bank (319 taps), which I used to reconstruct speech and music. |
| **3. Subband speech denoising** | Noisy speech is split into subbands and processed in 20 ms frames. Each band gets a gain based on its estimated signal-to-noise ratio, with noise power estimated from the first few frames, then the bands are summed back together. |
| **4. Spectrum analyser** | A short-time spectrum analyser with per-filter gain normalisation, two spatial differentiation stages to sharpen the filter responses, and two different inner hair cell models: a rectifier with a first-order low-pass filter, and a 16 ms accumulator with post-filtering. |
| **5. Pitch detection** | Fundamental frequency is estimated from the spectrum analyser's energy output, after removing the vocal tract response with 12th-order LPC. I also tested band-limited, telephone-style speech with the fundamental removed, and recovered the missing fundamental with a nonlinear stage followed by a bandpass filter. |
| **6. Adaptive cochlear model** | A second bank of resonant filters whose Q factor changes with the signal level, measured as energy over 5 ms frames. Quiet input gets a higher Q, which boosts weak components, and the original filter coefficients are left unchanged. |


## How to run

<!-- TODO: edit file names -->
Requires MATLAB with the Signal Processing Toolbox.

1. Clone the repository and open the folder in MATLAB.
2. Run auditoryInitialisation.m
3. Run desired sub-stage

## Notes

- Developed solo for coursework. Course handouts and the provided audio files are not included, as they belong to UNSW.
- Tools: MATLAB, Signal Processing Toolbox.
- Concepts: digital filter design (pole-zero placement), IIR/FIR conversion, linear-phase filtering, filter banks, LPC, pitch estimation, adaptive filtering.

## Contact

Max Luo, Electrical Engineering (Honours), UNSW Sydney
[LinkedIn](https://www.linkedin.com/in/chengji-luo-1505b3319) | [GitHub](https://github.com/MaxLuo-EE)
