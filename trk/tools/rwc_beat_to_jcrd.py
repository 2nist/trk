"""
TOOLBOX:
name: Add Beat Timing to .jcrd Files
description: Enriches .jcrd files with beat timing using RWC-Popular dataset. Falls back to LibROSA beat tracking if RWC data is unavailable.
arguments:
  --directory: Folder containing .jcrd files to update (default: mcgill_jcrd/)
  --rwc_csv: Path to RWC index or beat CSV file (optional)
"""

import os
import json
import argparse
import librosa


def estimate_beats_from_audio(audio_path):
    try:
        y, sr = librosa.load(audio_path)
        tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
        beat_times = librosa.frames_to_time(beats, sr=sr)
        return [int(bt * 1000) for bt in beat_times]
    except Exception as e:
        print(f"LibROSA beat tracking failed: {e}")
        return []


def load_rwc_beats(beat_csv_path):
    rwc_beats = {}
    with open(beat_csv_path, "r") as f:
        for line in f:
            if not line.strip():
                continue
            parts = line.strip().split(",")
            track_id = parts[0]
            times = [int(float(t) * 1000) for t in parts[1:]]
            rwc_beats[track_id] = times
    return rwc_beats


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--directory",
        default="mcgill_jcrd",
        help="Directory with .jcrd files",
    )
    parser.add_argument(
        "--rwc_csv",
        default=None,
        help="Path to RWC beat CSV index (optional)",
    )
    args = parser.parse_args()

    rwc_data = {}
    if args.rwc_csv and os.path.isfile(args.rwc_csv):
        rwc_data = load_rwc_beats(args.rwc_csv)

    for fname in os.listdir(args.directory):
        if not fname.endswith(".json"):
            continue

        fpath = os.path.join(args.directory, fname)
        with open(fpath, "r") as f:
            data = json.load(f)

        beat_times = []
        track_id = fname.replace(".json", "")
        if track_id in rwc_data:
            beat_times = rwc_data[track_id]
            print(f"✅ Using RWC beats for {track_id}")
        else:
            audio_path = os.path.join("audio", track_id + ".mp3")
            if os.path.isfile(audio_path):
                beat_times = estimate_beats_from_audio(audio_path)
                if beat_times:
                    print(f"⚠️ Used LibROSA fallback for {track_id}")
            else:
                print(f"❌ No beat data or audio available for {track_id}")

        if beat_times:
            data["beat_times"] = beat_times
            with open(fpath, "w") as f:
                json.dump(data, f, indent=2)


if __name__ == "__main__":
    main()
