# rock_corpus_har_to_jcrd.py
import json
import sys
import os
import re

def parse_har_content(lines):
    """Parses the content of a .har file."""
    parsed_data = {
        "title": None,
        "key": None,
        "patterns": {},
        "song_structure_raw": None,
        "comments": []
    }

    # Regex for pattern/structure lines.
    # Name (alphanumeric + underscore) followed by ':', then content.
    # Or, a specific 'S:' (case-insensitive) for song structure.
    line_parser_re = re.compile(r"^(?P<name>[A-Za-z0-9_]+):\s*(?P<content>.*)$")
    s_line_re = re.compile(r"^[Ss]:\s*(?P<content>.*)$")

    for line_num, line_content in enumerate(lines):
        line = line_content.strip()
        if not line:
            continue

        if line.startswith("%"):
            parsed_data["comments"].append(line)
            if parsed_data["title"] is None:
                title_candidate = line.lstrip("%").strip()
                if title_candidate:
                     parsed_data["title"] = title_candidate
            continue

        s_match = s_line_re.match(line)
        if s_match:
            content = s_match.group("content")
            parsed_data["song_structure_raw"] = content
            # Corrected regex for key matching
            key_match = re.search(r"\[([A-Ga-g][#b]?)\]", content)
            if key_match:
                parsed_data["key"] = key_match.group(1)
            # print(f"DEBUG (parse_har_content): Matched S line: {line}, Key: {parsed_data['key']}") # DEBUG
            continue 

        match = line_parser_re.match(line)
        if match:
            name = match.group("name")
            content = match.group("content")
            
            # This is a pattern definition
            # print(f"DEBUG (parse_har_content): Matched Pattern line: Name: {name}, Content: {content}") # DEBUG
            parsed_data["patterns"][name] = [
                [c.strip() for c in measure_content.split('%')[0].strip().split()]
                for measure_content in content.split("|") if measure_content.strip()
            ]
            continue
        
        # Fallback for title if not found in comments and line is simple
        if not parsed_data["title"] and ":" not in line and "$" not in line and "*" not in line and not line.startswith("%"):
             if line.strip(): 
                parsed_data["title"] = line.strip()

    print(f"DEBUG (parse_har_content): Parsed Data: {parsed_data}")
    return parsed_data

def load_timing_data(tim_path):
    """Loads beat timings from a .tim file."""
    beats = []
    if not os.path.exists(tim_path):
        print(f"Warning: Timing file {tim_path} not found.")
        return beats
    try:
        with open(tim_path, 'r', encoding='utf-8') as f: 
            for line_num, line_content in enumerate(f):
                line_content = line_content.strip()
                if not line_content: continue 

                # Expecting tab-separated values: time\tbeat_label
                parts = line_content.split('\t') # Corrected: use '\t' for tab character
                if len(parts) >= 1: 
                    try:
                        time = float(parts[0])
                        beat_label_info = parts[1] if len(parts) > 1 else str(line_num + 1)
                        beats.append({"time": time, "label": beat_label_info}) 
                    except ValueError:
                        print(f"Warning: Could not parse time float in {tim_path} (line {line_num+1}): '{line_content}'")
                else:
                    print(f"Warning: Not enough parts in line in {tim_path} (line {line_num+1}): '{line_content}'")

    except Exception as e:
        print(f"Error reading timing file {tim_path}: {e}")
    
    beats.sort(key=lambda x: x["time"]) 
    
    jcrd_beats = []
    for i, b in enumerate(beats):
        jcrd_beats.append({"time": round(b["time"], 3), "beat": i + 1})
    
    print(f"DEBUG (load_timing_data): Loaded JCRD Beats (count: {len(jcrd_beats)}): {jcrd_beats[:5]}...")
    return jcrd_beats


def expand_song_structure(raw_structure, patterns):
    def expand_chord_tokens(tokens, patterns, depth=0, max_depth=10):
        # Recursively expand tokens (chord symbols or pattern references)
        if depth > max_depth:
            print(f"Warning: Max recursion depth reached while expanding tokens: {tokens}")
            return []
        expanded = []
        for token in tokens:
            # Handle pattern repetition, e.g., $BP*4
            rep_match = re.match(r"\$?([A-Za-z0-9_]+)\*([0-9]+)", token)
            if rep_match:
                pat_name = rep_match.group(1)
                rep_count = int(rep_match.group(2))
                if pat_name in patterns:
                    for _ in range(rep_count):
                        for measure in patterns[pat_name]:
                            expanded.extend(expand_chord_tokens(measure, patterns, depth+1, max_depth))
                else:
                    print(f"Warning: Pattern '{pat_name}' not found for repetition in token '{token}'")
                continue
            # Handle simple pattern reference, e.g., $BP
            simple_pat_match = re.match(r"\$([A-Za-z0-9_]+)", token)
            if simple_pat_match:
                pat_name = simple_pat_match.group(1)
                if pat_name in patterns:
                    for measure in patterns[pat_name]:
                        expanded.extend(expand_chord_tokens(measure, patterns, depth+1, max_depth))
                else:
                    print(f"Warning: Pattern '{pat_name}' not found in token '{token}'")
                continue
            # Otherwise, treat as a chord symbol
            expanded.append(token)
        return expanded

    """
    Expands the raw song structure string, replacing pattern references and repetitions.
    Returns a list of sections, each with a label and a flat list of chord symbols.
    """
    expanded_sections = []
    if not raw_structure:
        print("DEBUG (expand_song_structure): Raw structure is empty or None.")
        return expanded_sections

    # Remove key signature like [F] for parsing structure
    # Corrected regex for stripping key
    # Remove key signature like [F] for parsing structure
    structure_to_parse = re.sub(r"\[([A-Ga-g][#b]?)\]", "", raw_structure).strip()
    print(f"DEBUG (expand_song_structure): Structure to parse (no key): '{structure_to_parse}'")
    
    # Split by one or more whitespace characters
    parts = re.split(r'\s+', structure_to_parse)
    print(f"DEBUG (expand_song_structure): Structure parts: {parts}")

    for part in parts:
        if not part:
            continue
        # Remove leading $ for label
        label = part.lstrip('$')
        # Expand this part as tokens (could be a pattern or a chord or a pattern with repetition)
        expanded_chords = expand_chord_tokens([part], patterns)
        if expanded_chords:
            expanded_sections.append({
                "label": label,
                "measures_flat": expanded_chords
            })
    print(f"DEBUG (expand_song_structure): Expanded Sections (count: {len(expanded_sections)}): {expanded_sections[:2]}...")
    return expanded_sections

def convert_har_to_jcrd(har_path, jcrd_path):
    har_filename = os.path.basename(har_path)
    base_name = os.path.splitext(har_filename)[0]

    try:
        with open(har_path, 'r', encoding='utf-8') as f:
            har_lines = f.readlines()
    except Exception as e:
        print(f"Error reading .har file {har_path}: {e}")
        return

    parsed_data = parse_har_content(har_lines)
    
    tim_filename_base = base_name.replace("_dt", "").replace("_tdc", "")
    
    tim_path_standard = os.path.join(os.path.dirname(os.path.dirname(har_path)), "timing_data", tim_filename_base + ".tim")
    tim_path_sibling = os.path.join(os.path.dirname(har_path), tim_filename_base + ".tim")
    tim_path_sibling_orig_base = os.path.join(os.path.dirname(har_path), base_name + ".tim")

    tim_path_to_use = None
    if os.path.exists(tim_path_standard):
        tim_path_to_use = tim_path_standard
    elif os.path.exists(tim_path_sibling):
        tim_path_to_use = tim_path_sibling
    elif os.path.exists(tim_path_sibling_orig_base):
        tim_path_to_use = tim_path_sibling_orig_base
    else:
        print(f"Warning: No .tim file found for {har_filename}. Tried:")
        print(f"  - Standard: {tim_path_standard}")
        print(f"  - Sibling (base): {tim_path_sibling}")
        print(f"  - Sibling (orig): {tim_path_sibling_orig_base}")


    jcrd_beats = []
    if tim_path_to_use:
        print(f"Using timing file: {tim_path_to_use}")
        jcrd_beats = load_timing_data(tim_path_to_use)
    else:
        print("Proceeding without timing data.") 
    
    expanded_structure = expand_song_structure(parsed_data["song_structure_raw"], parsed_data["patterns"])

    jcrd_output = {
        "metadata": {
            "title": parsed_data.get("title") or base_name,
            "artist": "Unknown", 
            "key": parsed_data.get("key") or "",
            "tempo": 120, 
            "source_format": "Rock Corpus Harmony (.har)",
            "source_file": har_filename
        },
        "chords": [],
        "beats": jcrd_beats,
        "sections": []
    }

    final_tempo = 120 
    time_per_chord = 1.0 # Default: 1 second per chord, assumes 1 chord per beat at 60bpm if no timing.

    if jcrd_beats:
        if len(jcrd_beats) > 1:
            first_beat_event_time = jcrd_beats[0]["time"]
            last_beat_event_time = jcrd_beats[-1]["time"]
            # Beat numbers are now 1-indexed sequential from load_timing_data
            num_beats_span = (jcrd_beats[-1]["beat"] - jcrd_beats[0]["beat"])

            song_duration_from_beats = last_beat_event_time - first_beat_event_time
            
            if song_duration_from_beats > 0 and num_beats_span > 0:
                final_tempo = round((num_beats_span / song_duration_from_beats) * 60)
            
            total_chords_in_song = sum(len(s["measures_flat"]) for s in expanded_structure if "measures_flat" in s)
            if total_chords_in_song > 0 and song_duration_from_beats > 0:
                time_per_chord = song_duration_from_beats / total_chords_in_song
            elif final_tempo > 0 and total_chords_in_song > 0 : 
                time_per_chord = (60.0 / final_tempo) 
        
    jcrd_output["metadata"]["tempo"] = final_tempo if final_tempo > 0 else 120
    if time_per_chord <= 0: # Ensure positive duration
        time_per_chord = 1.0


    current_time = 0.0
    if jcrd_beats: # Start song at the first beat time if available
        current_time = jcrd_beats[0]["time"] 

    all_jcrd_chords = []
    for section_info in expanded_structure:
        section_label = section_info["label"]
        chords_in_section = section_info.get("measures_flat", [])

        if not chords_in_section:
            continue # Skip sections that ended up with no chords

        section_start_time = current_time
        
        for chord_symbol in chords_in_section:
            # Map common "no chord" indications to "N"
            if not chord_symbol or chord_symbol.lower() in ['n', 'n.c.', 'nc', 'none', 'x', 'x:']: # Added 'x:'
                 actual_chord_to_store = "N"
            else:
                actual_chord_to_store = chord_symbol.replace(":","") # Remove colons from chords like G:maj
            
            if not actual_chord_to_store.strip(): # Skip empty symbols
                continue

            all_jcrd_chords.append({
                "time": round(current_time, 3),
                "duration": round(time_per_chord, 3), # All chords get same duration for now
                "chord": actual_chord_to_store 
            })
            current_time += time_per_chord # Advance time by the fixed duration
        
        section_end_time = current_time
        if section_end_time > section_start_time: # Only add section if it has content
            jcrd_output["sections"].append({
                "time": round(section_start_time, 3),
                "duration": round(section_end_time - section_start_time, 3),
                "label": section_label
            })

    jcrd_output["chords"] = all_jcrd_chords
    
    print(f"DEBUG (convert_har_to_jcrd): Final JCRD Chords (count: {len(all_jcrd_chords)}): {all_jcrd_chords[:5]}...")
    print(f"DEBUG (convert_har_to_jcrd): Final JCRD Sections (count: {len(jcrd_output['sections'])}): {jcrd_output['sections'][:2]}...")

    try:
        with open(jcrd_path, 'w', encoding='utf-8') as f: 
            json.dump(jcrd_output, f, indent=2)
        print(f"Successfully converted '{har_path}' to '{jcrd_path}'")
    except Exception as e:
        print(f"Error writing .jcrd file {jcrd_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python rock_corpus_har_to_jcrd.py <input_har_file> <output_jcrd_file>")
        sys.exit(1)
    
    input_har_path = sys.argv[1]
    output_jcrd_path = sys.argv[2]
    
    if not os.path.exists(input_har_path):
        print(f"Error: Input file '{input_har_path}' not found.")
        sys.exit(1)
        
    convert_har_to_jcrd(input_har_path, output_jcrd_path)
