"""
Groove MIDI Component Separator

This script splits full kit MIDI patterns from the Groove MIDI Dataset
into individual components (kick, snare, hats, percussion, fills) to
enable modular groove construction in the Groove MIDI Machine.

Features:
1. Intelligent drum part identification
2. Component extraction with configurable rules
3. Fill detection based on density and pattern analysis
4. Generation of individual component files
5. Creation of metadata for the Groove Card system
"""

import os
import sys
import json
import argparse
import logging
import numpy as np
import pretty_midi
from pathlib import Path
from collections import defaultdict

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger("groove_midi_component_separator")

# Define path constants
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MIDI_DIR = os.path.join(REPO_ROOT, "data", "midi", "groove_midi")
COMPONENT_DIR = os.path.join(REPO_ROOT, "data", "midi", "groove_components")
METADATA_DIR = os.path.join(REPO_ROOT, "data", "metadata", "groove_midi")
CARD_DIR = os.path.join(REPO_ROOT, "data", "cards", "groove_midi")

# Component definitions mapping MIDI note numbers to drum types
DRUM_COMPONENTS = {
    "kick": [35, 36],                            # Kick drums
    "snare": [38, 40, 37, 31],                   # Snare and rim
    "hihat": [42, 44, 46, 26, 22],              # Hi-hat variations
    "toms": [41, 43, 45, 47, 48, 50, 58],       # All toms
    "cymbals": [49, 51, 52, 53, 55, 57, 59],    # Crash and ride cymbals
    "percussion": [39, 54, 56, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80]  # Various percussion
}

class GrooveComponentSeparator:
    def __init__(self, input_file):
        """Initialize with the path to a MIDI file to process."""
        self.input_file = input_file
        self.basename = os.path.basename(input_file)
        self.base_output_dir = os.path.dirname(input_file)
        self.midi_data = None
        self.component_notes = defaultdict(list)
        self.metadata = {
            "source_file": self.basename,
            "components": {},
            "analysis": {}
        }
        
        # Load the MIDI file
        try:
            self.midi_data = pretty_midi.PrettyMIDI(input_file)
        except Exception as e:
            logger.error(f"Error loading MIDI file {input_file}: {e}")
            raise
    
    def analyze_pattern(self):
        """Analyze the pattern to extract key characteristics."""
        if not self.midi_data:
            return False
            
        # Find the drum instrument
        drum_instrument = None
        for instrument in self.midi_data.instruments:
            if instrument.is_drum:
                drum_instrument = instrument
                break
        
        if not drum_instrument:
            logger.warning(f"No drum instrument found in {self.basename}")
            return False
        
        # Analyze note distribution
        note_counts = defaultdict(int)
        note_velocities = defaultdict(list)
        note_timings = defaultdict(list)
        
        for note in drum_instrument.notes:
            note_counts[note.pitch] += 1
            note_velocities[note.pitch].append(note.velocity)
            note_timings[note.pitch].append(note.start)
        
        # Calculate metrics
        total_notes = sum(note_counts.values())
        duration = self.midi_data.get_end_time()
        density = total_notes / duration if duration > 0 else 0
        
        # Calculate mean velocities
        mean_velocities = {pitch: np.mean(velocities) for pitch, velocities in note_velocities.items()}
        
        # Calculate velocity variance 
        velocity_variance = {}
        for pitch, velocities in note_velocities.items():
            if len(velocities) > 1:
                velocity_variance[pitch] = np.std(velocities)
            else:
                velocity_variance[pitch] = 0
        
        # Overall velocity variance
        all_velocities = [v for vlist in note_velocities.values() for v in vlist]
        overall_velocity_variance = np.std(all_velocities) if all_velocities else 0
        
        # Detect swing by analyzing 8th notes
        swing = self._detect_swing(note_timings)
        
        # Store analysis results
        self.metadata["analysis"] = {
            "total_notes": total_notes,
            "duration": duration,
            "density": density,
            "note_distribution": dict(note_counts),
            "mean_velocity": mean_velocities,
            "velocity_variance": overall_velocity_variance,
            "swing_percentage": swing,
            "subdivision": self._detect_subdivision(note_timings)
        }
        
        # Check if it's likely a fill
        self.metadata["analysis"]["is_fill"] = self._detect_fill(note_counts, density)
        
        logger.info(f"Analyzed {self.basename}: {total_notes} notes, "
                   f"density: {density:.2f}, swing: {swing:.1f}%")
        return True
    
    def _detect_swing(self, note_timings):
        """Detect swing percentage by analyzing 8th note timings."""
        # Combine all note timings to detect overall swing
        all_timings = []
        for pitch, timings in note_timings.items():
            all_timings.extend(timings)
        
        all_timings.sort()
        
        # Look for pairs of notes that should be 8th notes
        swing_ratios = []
        
        if len(all_timings) < 2:
            return 0
        
        # Get tempo to determine beat duration
        tempo_changes = self.midi_data.get_tempo_changes()
        if len(tempo_changes[0]) > 0:
            bpm = tempo_changes[1][0]
            beat_duration = 60.0 / bpm
        else:
            beat_duration = 0.5  # Default assumption
        
        # Calculate ideal 8th note duration
        eighth_note = beat_duration / 2
        
        # Look at consecutive notes to find swing patterns
        for i in range(len(all_timings) - 1):
            interval = all_timings[i+1] - all_timings[i]
            
            # If this interval is close to an 8th note
            if 0.7 * eighth_note <= interval <= 1.3 * eighth_note:
                # Check if the next interval is also close to an 8th note
                if i+2 < len(all_timings):
                    next_interval = all_timings[i+2] - all_timings[i+1]
                    if 0.7 * eighth_note <= next_interval <= 1.3 * eighth_note:
                        # Calculate swing ratio
                        ratio = interval / next_interval
                        if 0.5 <= ratio <= 2.0:  # Reasonable swing range
                            swing_ratios.append(ratio)
        
        # Convert average ratio to swing percentage
        if swing_ratios:
            avg_ratio = np.mean(swing_ratios)
            # Convert ratio to percentage where 1.0 = straight (0%), 1.5 = typical swing (50%), 2.0 = hard swing (100%)
            swing_percentage = max(0, min(100, (avg_ratio - 1.0) * 100))
            return swing_percentage
        
        return 0  # No swing detected
    
    def _detect_subdivision(self, note_timings):
        """Detect the main subdivision of the pattern."""
        # Combine all note timings
        all_timings = []
        for pitch, timings in note_timings.items():
            all_timings.extend(timings)
        
        if not all_timings:
            return "unknown"
            
        all_timings.sort()
        
        # Get tempo to determine beat duration
        tempo_changes = self.midi_data.get_tempo_changes()
        if len(tempo_changes[0]) > 0:
            bpm = tempo_changes[1][0]
            beat_duration = 60.0 / bpm
        else:
            beat_duration = 0.5  # Default assumption
        
        # Calculate intervals between consecutive notes
        intervals = [all_timings[i+1] - all_timings[i] for i in range(len(all_timings)-1)]
        
        # Skip very short intervals (likely simultaneous hits)
        intervals = [i for i in intervals if i > 0.05]
        
        if not intervals:
            return "unknown"
        
        # Calculate average interval
        avg_interval = np.mean(intervals)
        
        # Determine subdivision based on beat duration
        if avg_interval >= 0.85 * beat_duration:
            return "quarter"
        elif avg_interval >= 0.85 * beat_duration / 2:
            return "eighth"
        elif avg_interval >= 0.85 * beat_duration / 3:
            return "triplet"
        elif avg_interval >= 0.85 * beat_duration / 4:
            return "sixteenth"
        elif avg_interval >= 0.85 * beat_duration / 6:
            return "sextuplet"
        elif avg_interval >= 0.85 * beat_duration / 8:
            return "32nd"
        else:
            return "very_fast"
    
    def _detect_fill(self, note_counts, density):
        """Detect if the pattern is likely a fill based on density and tom usage."""
        # Check for high density
        if density > 8:  # More than 8 notes per second is likely a fill
            return True
        
        # Check for significant tom usage
        tom_count = sum(note_counts.get(pitch, 0) for pitch in DRUM_COMPONENTS["toms"])
        total_notes = sum(note_counts.values())
        
        if tom_count > 0 and tom_count / total_notes > 0.3:  # If toms make up >30% of notes
            return True
            
        return False
    
    def separate_components(self, output_dir=None):
        """Separate the MIDI file into component parts."""
        if not self.midi_data:
            return False
        
        if output_dir:
            self.base_output_dir = output_dir
            
        component_dir = os.path.join(self.base_output_dir, "components", os.path.splitext(self.basename)[0])
        os.makedirs(component_dir, exist_ok=True)
        
        # Find the drum instrument
        drum_instrument = None
        for instrument in self.midi_data.instruments:
            if instrument.is_drum:
                drum_instrument = instrument
                break
        
        if not drum_instrument:
            logger.warning(f"No drum instrument found in {self.basename}")
            return False
        
        # Group notes by component
        for note in drum_instrument.notes:
            component = "other"
            for comp_name, pitches in DRUM_COMPONENTS.items():
                if note.pitch in pitches:
                    component = comp_name
                    break
            self.component_notes[component].append(note)
        
        # Create separate MIDI files for each component
        for component, notes in self.component_notes.items():
            if not notes:
                continue
                
            # Create a new MIDI file for this component
            component_midi = pretty_midi.PrettyMIDI(initial_tempo=self.midi_data.get_tempo_changes()[1][0])
            
            # Create a drum instrument
            drum_program = pretty_midi.instrument_name_to_program('Drums')
            component_instrument = pretty_midi.Instrument(program=drum_program, is_drum=True)
            
            # Add all notes for this component
            for note in notes:
                component_instrument.notes.append(note)
            
            component_midi.instruments.append(component_instrument)
            
            # Save the component file
            component_file = os.path.join(component_dir, f"{component}.mid")
            component_midi.write(component_file)
            
            # Store metadata
            self.metadata["components"][component] = {
                "file": component_file,
                "note_count": len(notes),
                "pitches_used": list(set(note.pitch for note in notes))
            }
            
            logger.info(f"Created component {component} with {len(notes)} notes: {component_file}")
        
        # Special handling for fill if detected
        if self.metadata["analysis"].get("is_fill", False):
            # Create a fill component that combines toms, snare rolls, and crashes
            fill_midi = pretty_midi.PrettyMIDI(initial_tempo=self.midi_data.get_tempo_changes()[1][0])
            drum_program = pretty_midi.instrument_name_to_program('Drums')
            fill_instrument = pretty_midi.Instrument(program=drum_program, is_drum=True)
            
            fill_notes = []
            fill_notes.extend(self.component_notes["toms"])
            fill_notes.extend(self.component_notes["cymbals"])
            
            # Add snare notes with high velocity or in dense clusters (rolls)
            snare_notes = sorted(self.component_notes["snare"], key=lambda n: n.start)
            for i, note in enumerate(snare_notes):
                if note.velocity > 100:  # High velocity snares
                    fill_notes.append(note)
                elif i > 0 and i < len(snare_notes) - 1:
                    # Check if part of a roll (notes close together)
                    if (snare_notes[i].start - snare_notes[i-1].start < 0.1 or
                        snare_notes[i+1].start - snare_notes[i].start < 0.1):
                        fill_notes.append(note)
            
            # Sort notes by start time
            fill_notes.sort(key=lambda n: n.start)
            
            for note in fill_notes:
                fill_instrument.notes.append(note)
            
            fill_midi.instruments.append(fill_instrument)
            
            # Save the fill component
            fill_file = os.path.join(component_dir, "fill.mid")
            fill_midi.write(fill_file)
            
            self.metadata["components"]["fill"] = {
                "file": fill_file,
                "note_count": len(fill_notes),
                "pitches_used": list(set(note.pitch for note in fill_notes))
            }
            
            logger.info(f"Created fill component with {len(fill_notes)} notes: {fill_file}")
        
        # Save metadata
        metadata_file = os.path.join(component_dir, "metadata.json")
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(self.metadata, f, indent=2)
        
        return True
    
    def create_component_cards(self, card_dir=None):
        """Create component cards for the Groove MIDI Machine."""
        if not self.component_notes:
            logger.error("No components separated yet. Call separate_components() first.")
            return False
        
        if not card_dir:
            card_dir = CARD_DIR
        os.makedirs(card_dir, exist_ok=True)
        
        # Generate basic metadata for card creation
        base_name = os.path.splitext(self.basename)[0]
        
        # Extract style if present in filename
        style = "unknown"
        for potential_style in ["funk", "rock", "jazz", "soul", "hiphop", "latin", "afrobeat"]:
            if potential_style in base_name.lower():
                style = potential_style
                break
        
        # Extract drummer if present
        drummer = "unknown"
        if "drummer" in base_name.lower():
            drummer_match = re.search(r'drummer(\d+)', base_name.lower())
            if drummer_match:
                drummer = f"drummer{drummer_match.group(1)}"
        
        # Create cards for each component
        for component, component_data in self.metadata["components"].items():
            # Skip components with too few notes
            if component_data["note_count"] < 2:
                continue
                
            # Determine card type based on component
            if component == "fill":
                card_type = "fill.card"
            else:
                card_type = "groove_layer.card"
            
            # Create card data
            card_data = {
                "card_type": card_type,
                "source": self.basename,
                "component": component,
                "style": style,
                "drummer": drummer,
                "tempo": self.midi_data.get_tempo_changes()[1][0],
                "swing": self.metadata["analysis"].get("swing_percentage", 0),
                "subdivision": self.metadata["analysis"].get("subdivision", "unknown"),
                "density": len(component_data["pitches_used"]) / component_data["note_count"] if component_data["note_count"] > 0 else 0,
                "midi_file": component_data["file"],
                "tags": [style, component, self.metadata["analysis"].get("subdivision", "unknown")]
            }
            
            # Add intensity tag based on average velocity
            avg_velocity = np.mean([note.velocity for note in self.component_notes[component]])
            if avg_velocity > 100:
                card_data["tags"].append("hard")
                card_data["intensity"] = "hard"
            elif avg_velocity > 80:
                card_data["tags"].append("medium")
                card_data["intensity"] = "medium"
            else:
                card_data["tags"].append("light")
                card_data["intensity"] = "light"
            
            # Add feel tag based on swing
            swing = self.metadata["analysis"].get("swing_percentage", 0)
            if swing > 40:
                card_data["tags"].append("swung")
                card_data["feel"] = "swung"
            elif swing > 15:
                card_data["tags"].append("laid-back")
                card_data["feel"] = "laid-back"
            else:
                card_data["tags"].append("tight")
                card_data["feel"] = "tight"
            
            # Generate a unique ID for the card
            card_id = f"{style}_{component}_{base_name}"
            card_id = card_id.replace(" ", "_").lower()
            
            # Save the card
            component_folder = os.path.join(card_dir, component)
            os.makedirs(component_folder, exist_ok=True)
            
            card_file = os.path.join(component_folder, f"{card_id}.json")
            with open(card_file, 'w', encoding='utf-8') as f:
                json.dump(card_data, f, indent=2)
                
            logger.info(f"Created {card_type} for {component}: {card_file}")
        
        # Also create a full kit card
        card_data = {
            "card_type": "groove_kit.card",
            "source": self.basename,
            "style": style,
            "drummer": drummer,
            "tempo": self.midi_data.get_tempo_changes()[1][0],
            "swing": self.metadata["analysis"].get("swing_percentage", 0),
            "subdivision": self.metadata["analysis"].get("subdivision", "unknown"),
            "components": list(self.metadata["components"].keys()),
            "midi_file": self.input_file,
            "tags": [style, self.metadata["analysis"].get("subdivision", "unknown")]
        }
        
        # Add feel and intensity tags
        if self.metadata["analysis"].get("swing_percentage", 0) > 20:
            card_data["tags"].append("swung")
        
        if self.metadata["analysis"].get("is_fill", False):
            card_data["tags"].append("fill")
        
        # Save the full kit card
        kits_folder = os.path.join(card_dir, "kits")
        os.makedirs(kits_folder, exist_ok=True)
        
        kit_id = f"{style}_kit_{base_name}".replace(" ", "_").lower()
        card_file = os.path.join(kits_folder, f"{kit_id}.json")
        
        with open(card_file, 'w', encoding='utf-8') as f:
            json.dump(card_data, f, indent=2)
            
        logger.info(f"Created groove_kit.card: {card_file}")
        
        return True

def main():
    parser = argparse.ArgumentParser(description="Groove MIDI Component Separator")
    parser.add_argument("input", nargs="?", help="Input MIDI file or directory")
    parser.add_argument("--output", help="Output directory for components")
    parser.add_argument("--cards", help="Output directory for card files")
    parser.add_argument("--recursive", action="store_true", help="Process directories recursively")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    # Set logging level
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    # Determine input files
    input_files = []
    
    if not args.input:
        # Default to processing all files in the MIDI directory
        for root, _, files in os.walk(MIDI_DIR):
            for file in files:
                if file.endswith(".mid") or file.endswith(".midi"):
                    input_files.append(os.path.join(root, file))
    elif os.path.isdir(args.input):
        # Process a directory
        if args.recursive:
            for root, _, files in os.walk(args.input):
                for file in files:
                    if file.endswith(".mid") or file.endswith(".midi"):
                        input_files.append(os.path.join(root, file))
        else:
            for file in os.listdir(args.input):
                if file.endswith(".mid") or file.endswith(".midi"):
                    input_files.append(os.path.join(args.input, file))
    elif os.path.isfile(args.input) and (args.input.endswith(".mid") or args.input.endswith(".midi")):
        # Process a single file
        input_files.append(args.input)
    else:
        logger.error(f"Invalid input: {args.input}")
        return 1
    
    logger.info(f"Found {len(input_files)} MIDI files to process")
    
    # Process each file
    for midi_file in input_files:
        try:
            separator = GrooveComponentSeparator(midi_file)
            
            # Analyze the pattern
            if separator.analyze_pattern():
                # Separate components
                separator.separate_components(args.output)
                
                # Create cards if requested
                if args.cards or not args.output:
                    separator.create_component_cards(args.cards)
            else:
                logger.warning(f"Skipping {midi_file} - analysis failed")
                
        except Exception as e:
            logger.error(f"Error processing {midi_file}: {e}")
    
    logger.info("Processing complete!")
    return 0

if __name__ == "__main__":
    sys.exit(main())
