# pop909_to_jcrd.py
import json
import sys
import os
# Attempt to import mido, will fail if not installed
try:
    from mido import MidiFile
except ImportError:
    MidiFile = None # Gracefully handle if mido is not available

def get_tempo_from_mid(mid_path):
    if MidiFile is None:
        print("Mido library not installed. Cannot extract tempo. pip install mido")
        return 120 # Default tempo

    try:
        mid = MidiFile(mid_path)
        for track in mid.tracks:
            for msg in track:
                if msg.type == 'set_tempo':
                    return int(60000000 / msg.tempo) # Convert microseconds per beat to BPM
    except Exception as e:
        print(f"Could not read tempo from MIDI {mid_path}: {e}")
    return 120 # Default if not found or error

def convert_pop909_to_jcrd(pop909_song_dir, jcrd_path):
    """
    Converts a POP909 song directory to JCRD format.
    It expects the directory to contain a .mid file and a chord_midi.txt file.
    """
    song_id = os.path.basename(pop909_song_dir)
    mid_file = os.path.join(pop909_song_dir, f"{song_id}.mid")
    chord_file = os.path.join(pop909_song_dir, "chord_midi.txt")
    key_file = os.path.join(pop909_song_dir, "key_audio.txt") # Or key_midi.txt

    if not os.path.exists(mid_file):
        print(f"Error: MIDI file {mid_file} not found.")
        return
    if not os.path.exists(chord_file):
        print(f"Error: Chord file {chord_file} not found.")
        return

    # Extract tempo from MIDI
    tempo = get_tempo_from_mid(mid_file)

    # Extract key
    key = "C" # Default
    if os.path.exists(key_file):
        try:
            with open(key_file, 'r') as f:
                # Assuming key file format is simple: e.g., "C major" or just "C"
                # This part might need adjustment based on actual key file content
                key_data = f.readline().strip()
                # Basic attempt to parse key
                if ' ' in key_data:
                    key = key_data.split(' ')[0]
                else:
                    key = key_data
        except Exception as e:
            print(f"Could not read key from {key_file}: {e}")


    jcrd_chords = []
    try:
        with open(chord_file, 'r') as f:
            for line in f:
                parts = line.strip().split('\t')
                if len(parts) == 3:
                    start_time = float(parts[0])
                    end_time = float(parts[1])
                    chord_label = parts[2]
                    if chord_label == "N": # Skip "No Chord" entries for now
                        continue
                    jcrd_chords.append({
                        "time": start_time,
                        "duration": round(end_time - start_time, 6),
                        "chord": chord_label
                    })
    except Exception as e:
        print(f"Error processing chord file {chord_file}: {e}")
        return

    jcrd_content = {
        "metadata": {
            "title": f"POP909 Song {song_id}",
            "artist": "POP909",
            "key": key,
            "tempo": tempo,
            "source_format": "POP909"
        },
        "chords": jcrd_chords,
        "beats": [], # POP909 has beat_midi.txt, could be parsed here
        "sections": [] # POP909 doesn't explicitly define sections in this way
    }

    # Optionally parse beat_midi.txt for beat information
    beat_midi_file = os.path.join(pop909_song_dir, "beat_midi.txt")
    if os.path.exists(beat_midi_file):
        try:
            with open(beat_midi_file, 'r') as f:
                beat_counter = 1
                for line in f:
                    parts = line.strip().split('\t')
                    if len(parts) >= 1: # Assuming at least time is present
                        time = float(parts[0])
                        # Assuming the second column is the beat number if present, otherwise increment
                        beat_num_in_file = int(parts[1]) if len(parts) > 1 else beat_counter
                        jcrd_content["beats"].append({"time": time, "beat": beat_num_in_file})
                        beat_counter +=1 # Fallback if beat number not in file or to track overall
        except Exception as e:
            print(f"Could not parse beat file {beat_midi_file}: {e}")


    with open(jcrd_path, 'w') as f:
        json.dump(jcrd_content, f, indent=2)
    print(f"Converted POP909 song {song_id} to {jcrd_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python pop909_to_jcrd.py <path_to_pop909_song_directory> <output_jcrd_file>")
        print("Example: python pop909_to_jcrd.py ./datasets/POP909/POP909-Dataset-master/POP909/001 ./output/001.jcrd")
        sys.exit(1)
    
    input_dir = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.isdir(input_dir):
        print(f"Error: Input directory {input_dir} not found or not a directory.")
        sys.exit(1)
        
    # Ensure output directory exists
    output_dir = os.path.dirname(output_file)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
        
    convert_pop909_to_jcrd(input_dir, output_file)
