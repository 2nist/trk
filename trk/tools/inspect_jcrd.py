import json
import sys

# Load the JCRD file
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Title: {data['title']}")
print(f"Artist: {data['artist']}")
print(f"Total sections: {len(data['sections'])}")

# Find sections with non-N.C. chords
found = False
for i, section in enumerate(data['sections']):
    if section['chords'] and any(chord != 'N.C.' for chord in section['chords']):
        print(f"\nSection {i+1}:")
        print(f"Start: {section['start_ms']}ms")
        print(f"Duration: {section['duration_ms']}ms")
        print(f"Chords: {section['chords']}")
        found = True
        break
        
if not found:
    print("\nNo sections with non-N.C. chords found.")
