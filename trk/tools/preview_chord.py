# preview_chord.py
import sys
import pretty_midi

def play_chord(chord_name, duration=1.0, output="preview.mid"):
    midi = pretty_midi.PrettyMIDI()
    instrument = pretty_midi.Instrument(program=0)
    notes = pretty_midi.chord_name_to_chord(chord_name)

    for pitch in notes:
        instrument.notes.append(pretty_midi.Note(100, pitch, 0, duration))

    midi.instruments.append(instrument)
    midi.write(output)
    print(f"🎹 Wrote preview to {output}")

if __name__ == "__main__":
    play_chord(sys.argv[1])
