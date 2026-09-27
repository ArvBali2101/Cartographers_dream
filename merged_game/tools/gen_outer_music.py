"""Original horror layers. Reuses the teammate's synthesis/reverb helpers.
Only writes two new WAV assets; never regenerates their existing soundtrack.
"""
from pathlib import Path
import wave
import numpy as np
import gen_music as music

ROOT = Path(__file__).resolve().parents[1]
RATE = music.SR
SECONDS = 24
t = np.arange(RATE * SECONDS) / RATE
rng = np.random.default_rng(410)

def output(name, signal):
    left = music.reverb(signal, 4.5, 0.6, 1900)
    right = music.reverb(np.roll(signal, int(RATE * .043)), 3.7, .65, 1500)
    stereo = np.stack((left, right), axis=1)
    # Tiny wrap crossfade avoids a hard boundary without a gap in the drone.
    count = int(RATE * .18)
    ramp = np.linspace(0, 1, count)[:, None]
    stereo[:count] = stereo[-count:] * (1-ramp) + stereo[:count] * ramp
    stereo *= 10 ** (-15/20) / max(np.abs(stereo).max(), 1e-9)
    path = ROOT / 'assets/music' / (name + '.wav')
    with wave.open(str(path), 'wb') as handle:
        handle.setnchannels(2)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        handle.writeframes((stereo * 32767).astype('<i2').tobytes())
    print(f'{path.name}: stereo {RATE}Hz, {SECONDS}s, peak {np.abs(stereo).max():.4f}')

drone = np.zeros_like(t)
for frequency, gain in [(43,.6),(65,.25),(91,.13),(130,.12),(137,.08)]:
    breath = .65 + .35 * np.sin(2*np.pi*t/12 + frequency)
    drone += np.sin(2*np.pi*frequency*t + .3*np.sin(2*np.pi*t/24))*gain*breath
noise = music.bandpass(rng.standard_normal(len(t)), 250, 1600)
drone += noise * .045 * (.5 + .5*np.sin(2*np.pi*t/8))
output('outer_gods_drone', drone)

pulse = np.zeros_like(t)
for index, start in enumerate([1.0,3.6,7.1,11.6,15.0,19.8,22.1]):
    duration = 1.2
    local = np.arange(int(RATE*duration))/RATE
    hit = np.sin(2*np.pi*(52-index)*local) * np.exp(-local*4.5)
    hit += .12*music.bandpass(rng.standard_normal(len(local)),450,2200)*np.exp(-local*6)
    music.add(pulse, hit, start)
for frequency in [311,329,466]:
    pulse += np.sin(2*np.pi*frequency*t)*.045*(.5+.5*np.sin(2*np.pi*t/24+frequency))
output('outer_gods_pulse',pulse)
