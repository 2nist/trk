"""
Improved section detection for JCRD format using patterns found in McGill Billboard dataset.
- Leverages common 4/4 time patterns (4, 8, 16, 32, 64 beats)
- Analyzes chord density for section type detection
- Includes confidence scoring for timing boundaries
"""


def detect_sections(pm, min_beats_per_section=16):
    """
    Detect musical sections based on chord patterns and common song structure rules.
    Uses knowledge of typical 4/4 time patterns (4, 8, 16, 32, 64 beats) and chord changes.

    Args:
        pm: PrettyMIDI object
        min_beats_per_section: Minimum length of a section in beats (default 16)

    Returns:
        List of section dictionaries with timing and chord information
    """
    # Get tempo in BPM
    tempo = (
        pm.get_tempo_changes()[1][0]
        if len(pm.get_tempo_changes()[1]) > 0
        else 120
    )
    ms_per_beat = 60000 / tempo
    min_section_ms = min_beats_per_section * ms_per_beat

    # Extract chords and timing
    chord_list = []  # (start_ms, chord_name) tuples
    current_time = 0
    last_chord = None

    while current_time < pm.get_end_time() * 1000:  # Convert to ms
        # Find all notes in current beat
        notes_in_beat = []
        for instrument in pm.instruments:
            for note in instrument.notes:
                note_start_ms = note.start * 1000
                if current_time <= note_start_ms < current_time + ms_per_beat:
                    notes_in_beat.append(note)

        # Get chord name
        chord_name = detect_chord(notes_in_beat)
        if chord_name != last_chord:  # Only record chord changes
            chord_list.append((int(current_time), chord_name))
            last_chord = chord_name

        current_time += ms_per_beat

    sections = []
    window = []
    cur_section_start = 0
    cur_section_chords = []

    def add_section(start_ms, end_ms, chords):
        """Helper to add a section with proper metadata"""
        duration = end_ms - start_ms
        beats = duration / ms_per_beat
        unique_chords = len(set(chords))
        chord_density = unique_chords / beats

        # Determine section type based on length and chord density
        if beats <= 8:  # 2 bars or less
            section_type = "Transition"
        elif beats <= 16:  # 4 bars
            if chord_density > 0.25:  # Lots of chord changes
                section_type = "Bridge"
            else:
                section_type = "Interlude"
        elif beats <= 32:  # 8 bars
            if chord_density < 0.15:  # Simple chord progression
                section_type = "Chorus"
            else:
                section_type = "Verse"
        else:  # > 8 bars
            section_type = "Extended" + (
                "Chorus" if chord_density < 0.15 else "Verse"
            )

        sections.append(
            {
                "start_ms": int(start_ms),
                "duration_ms": int(duration),
                "chords": chords,
                "sectionType": section_type,
                "sectionFunction": get_section_function(section_type),
                "timing_confidence": (
                    "high" if (beats % 4) < 0.1 else "medium"
                ),
                "sectionLabel": f"{section_type.lower()}_{len(sections) + 1}",
                "sectionLetter": chr(65 + len(sections)),
            }
        )

    # Analyze chord sequence for section boundaries
    for i, (time_ms, chord) in enumerate(chord_list):
        cur_section_chords.append(chord)

        # Check for section boundary conditions
        duration = time_ms - cur_section_start
        if duration >= min_section_ms:  # Minimum section length reached
            next_boundary = None
            for j in range(i + 1, len(chord_list)):
                next_time = chord_list[j][0]
                next_duration = next_time - time_ms
                if (
                    next_duration >= min_section_ms
                ):  # Found next potential boundary
                    next_boundary = next_time
                    break

            if next_boundary:  # Valid section found
                add_section(
                    cur_section_start, next_boundary, cur_section_chords
                )
                cur_section_start = next_boundary
                cur_section_chords = []

    # Handle final section
    if cur_section_chords:
        add_section(cur_section_start, chord_list[-1][0], cur_section_chords)

    return sections


def get_section_function(section_type):
    """Map section types to their typical musical functions"""
    function_map = {
        "Verse": "MainTheme",
        "Chorus": "Hook",
        "ExtendedChorus": "Hook",
        "ExtendedVerse": "MainTheme",
        "Bridge": "Development",
        "Transition": "Transition",
        "Interlude": "Development",
    }
    return function_map.get(section_type, "Other")


def detect_chord(notes):
    """
    Identify chord from a set of notes using common chord patterns
    """
    pitch_classes = sorted(set(n.pitch % 12 for n in notes))
    if not pitch_classes:
        return "N.C."  # No chord

    # Define common chord shapes (as pitch class sets)
    major_triads = {
        (0, 4, 7): "C",
        (1, 5, 8): "C#",
        (2, 6, 9): "D",
        (3, 7, 10): "D#",
        (4, 8, 11): "E",
        (5, 9, 0): "F",
        (6, 10, 1): "F#",
        (7, 11, 2): "G",
        (8, 0, 3): "G#",
        (9, 1, 4): "A",
        (10, 2, 5): "A#",
        (11, 3, 6): "B",
    }
    minor_triads = {
        (0, 3, 7): "Cm",
        (1, 4, 8): "C#m",
        (2, 5, 9): "Dm",
        (3, 6, 10): "D#m",
        (4, 7, 11): "Em",
        (5, 8, 0): "Fm",
        (6, 9, 1): "F#m",
        (7, 10, 2): "Gm",
        (8, 11, 3): "G#m",
        (9, 0, 4): "Am",
        (10, 1, 5): "A#m",
        (11, 2, 6): "Bm",
    }

    # Try to match with known chord shapes
    for shape, name in major_triads.items():
        if all(pc in pitch_classes for pc in shape):
            return name
    for shape, name in minor_triads.items():
        if all(pc in pitch_classes for pc in shape):
            return name

    # If no match, return pitch classes
    return "+".join(str(pc) for pc in pitch_classes)
