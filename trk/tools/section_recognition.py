"""
Rule-based section recognition for chord lists.
Splits a list of chords (optionally with timing) into sections based on fixed bar length or repeated patterns.
"""

def recognize_sections(chords, bars_per_section=8, beats_per_bar=4, ms_per_beat=500):
    """
    chords: list of chord labels (or dicts with timing info)
    bars_per_section: how many bars per section (default 8)
    beats_per_bar: how many beats per bar (default 4)
    ms_per_beat: milliseconds per beat (default 500, i.e., 120 bpm)
    Returns: list of sections, each a dict with chords and sectionLabel
    """
    sections = []
    chords_per_section = bars_per_section * beats_per_bar
    for i in range(0, len(chords), chords_per_section):
        section_chords = chords[i:i+chords_per_section]
        label = f"Section {len(sections)+1}"
        sections.append({
            "id": f"section_{len(sections)+1}",
            "sectionLabel": label,
            "start_ms": i * ms_per_beat,
            "duration_ms": len(section_chords) * ms_per_beat,
            "chords": section_chords,
            "romanNumerals": [],
            "tags": ["rule-based"]
        })
    return sections

# Example usage:
if __name__ == "__main__":
    chords = ["C", "G", "Am", "F"] * 8  # 32 chords
    sections = recognize_sections(chords)
    for s in sections:
        print(s["sectionLabel"], s["chords"])
