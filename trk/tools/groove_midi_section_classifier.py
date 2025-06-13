"""
Groove MIDI Song Section Classifier

This script analyzes MIDI drum patterns to suggest their suitability for
different song sections (verse, chorus, bridge, etc.) based on their
characteristics and repeating patterns.

It implements:
1. Supermaximal Repeats algorithm for identifying core patterns
2. Energy/complexity metrics for section suitability assessment
3. Confidence scoring to help users evaluate suggestions
4. Pattern similarity comparison for contextual recommendations

This is a user-guided tool that provides intelligent suggestions but leaves
creative decisions to the user. All classifications are presented as options
with explanations, not as automated decisions.
"""

import os
import sys
import json
import numpy as np
import pretty_midi
import argparse
import logging
from pathlib import Path
from collections import defaultdict, Counter
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from suffix_trees import STree

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger("groove_midi_section_classifier")

# Define path constants
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MIDI_DIR = os.path.join(REPO_ROOT, "data", "midi", "groove_midi")
METADATA_DIR = os.path.join(REPO_ROOT, "data", "metadata", "groove_midi")
SECTION_MODEL_DIR = os.path.join(REPO_ROOT, "data", "models", "section_classifier")

# Song section characteristics
SECTION_CHARACTERISTICS = {
    "verse": {
        "description": "Typically steady and supportive, medium energy",
        "energy_range": (0.3, 0.6),
        "complexity_range": (0.2, 0.6),
        "density_range": (0.3, 0.6),
        "variation_range": (0.2, 0.5),
        "weight": 1.0
    },
    "chorus": {
        "description": "Usually more energetic and memorable than verses",
        "energy_range": (0.6, 1.0),
        "complexity_range": (0.4, 0.8),
        "density_range": (0.5, 0.9),
        "variation_range": (0.1, 0.4),  # Often more repetitive
        "weight": 1.0
    },
    "bridge": {
        "description": "Often contrasting with verse and chorus, may be experimental",
        "energy_range": (0.4, 0.8),
        "complexity_range": (0.6, 1.0),
        "density_range": (0.4, 0.8),
        "variation_range": (0.6, 1.0),  # Usually different
        "weight": 0.8
    },
    "intro": {
        "description": "Sets up the song, often simpler or building",
        "energy_range": (0.2, 0.7),
        "complexity_range": (0.2, 0.6),
        "density_range": (0.2, 0.6),
        "variation_range": (0.3, 0.7),
        "weight": 0.7
    },
    "outro": {
        "description": "Concludes the song, may fade or simplify",
        "energy_range": (0.3, 0.9),
        "complexity_range": (0.3, 0.7),
        "density_range": (0.3, 0.8),
        "variation_range": (0.3, 0.7),
        "weight": 0.7
    },
    "transition": {
        "description": "Connects sections, often with fills or breaks",
        "energy_range": (0.5, 0.9),
        "complexity_range": (0.6, 1.0),
        "density_range": (0.5, 0.9),
        "variation_range": (0.7, 1.0),
        "weight": 0.6
    }
}

class GrooveSectionClassifier:
    def __init__(self, midi_file):
        """Initialize the classifier with a MIDI file."""
        self.midi_file = midi_file
        self.midi_data = None
        self.drum_notes = []
        self.features = {}
        self.section_scores = {}
        self.pattern_sequences = []
        
        try:
            self.midi_data = pretty_midi.PrettyMIDI(midi_file)
            self._extract_drum_notes()
        except Exception as e:
            logger.error(f"Error loading MIDI file {midi_file}: {e}")
            raise
    
    def _extract_drum_notes(self):
        """Extract drum notes from the MIDI file."""
        for instrument in self.midi_data.instruments:
            if instrument.is_drum:
                self.drum_notes.extend(instrument.notes)
        
        # Sort notes by start time
        self.drum_notes.sort(key=lambda x: x.start)
    
    def extract_features(self):
        """Extract features from the drum pattern for classification."""
        if not self.drum_notes:
            logger.warning("No drum notes found in the MIDI file")
            return {}
        
        # Extract basic statistics
        total_notes = len(self.drum_notes)
        duration = self.midi_data.get_end_time()
        
        # Note density (notes per second)
        density = total_notes / duration if duration > 0 else 0
        
        # Velocity statistics
        velocities = [note.velocity for note in self.drum_notes]
        mean_velocity = np.mean(velocities)
        velocity_std = np.std(velocities)
        
        # Note distribution by pitch
        pitches = Counter([note.pitch for note in self.drum_notes])
        unique_pitches = len(pitches)
        
        # Group notes by time (quantized to 16th notes)
        tempo_changes = self.midi_data.get_tempo_changes()
        if len(tempo_changes[0]) > 0:
            tempo = tempo_changes[1][0]
        else:
            tempo = 120  # Default tempo
        
        # Calculate 16th note duration in seconds
        beat_duration = 60 / tempo
        sixteenth_duration = beat_duration / 4
        
        # Quantize notes to 16th note grid
        grid_notes = defaultdict(list)
        for note in self.drum_notes:
            # Round to nearest 16th note
            grid_pos = round(note.start / sixteenth_duration)
            grid_notes[grid_pos].append(note.pitch)
        
        # Calculate pattern complexity metrics
        complexity = len(grid_notes) / (duration / sixteenth_duration) if duration > 0 else 0
        
        # Analyze kick and snare patterns for predictability
        kick_positions = [pos for pos, pitches in grid_notes.items() if any(p in [35, 36] for p in pitches)]
        snare_positions = [pos for pos, pitches in grid_notes.items() if any(p in [38, 40] for p in pitches)]
        
        # Calculate pattern regularity (higher = more regular)
        kick_regularity = self._calculate_regularity(kick_positions)
        snare_regularity = self._calculate_regularity(snare_positions)
        
        # Calculate the pattern variation using Supermaximal Repeats
        pattern_variation = self._calculate_pattern_variation(grid_notes)
        
        # Energy calculation based on velocity, density and complexity
        energy = (mean_velocity / 127) * 0.5 + (density / 10) * 0.3 + complexity * 0.2
        energy = min(1.0, energy)  # Cap at 1.0
        
        # Store all features
        self.features = {
            "total_notes": total_notes,
            "duration": duration,
            "density": density,
            "mean_velocity": mean_velocity,
            "velocity_std": velocity_std,
            "unique_pitches": unique_pitches,
            "complexity": complexity,
            "kick_regularity": kick_regularity,
            "snare_regularity": snare_regularity,
            "pattern_variation": pattern_variation,
            "energy": energy,
            "normalized_density": min(1.0, density / 10),  # Normalize density to 0-1 range
            "normalized_complexity": complexity,  # Already 0-1
            "normalized_variation": pattern_variation  # Already 0-1
        }
        
        return self.features
    
    def _calculate_regularity(self, positions):
        """Calculate the regularity of note positions (higher = more regular)."""
        if len(positions) <= 1:
            return 0.0
        
        # Calculate intervals between consecutive positions
        intervals = [positions[i+1] - positions[i] for i in range(len(positions) - 1)]
        
        # If all intervals are the same, it's perfectly regular
        if all(i == intervals[0] for i in intervals):
            return 1.0
        
        # Count the frequency of each interval
        interval_counts = Counter(intervals)
        most_common_interval, most_common_count = interval_counts.most_common(1)[0]
        
        # Calculate regularity as the proportion of the most common interval
        return most_common_count / len(intervals)
    
    def _calculate_pattern_variation(self, grid_notes):
        """
        Calculate pattern variation using Supermaximal Repeats.
        
        Lower values indicate more repetitive patterns (common in choruses).
        Higher values indicate more varied patterns (common in bridges, transitions).
        """
        if not grid_notes:
            return 0.0
        
        # Convert the grid notes to a string representation for pattern analysis
        max_pos = max(grid_notes.keys())
        pattern_string = ""
        
        for i in range(max_pos + 1):
            if i in grid_notes:
                # Create a symbol for this combination of notes
                pitches = sorted(grid_notes[i])
                symbol = chr(65 + (sum(pitches) % 26))  # Convert to a letter A-Z
                pattern_string += symbol
            else:
                pattern_string += "-"  # Rest
        
        # Use suffix tree to find repeats
        if len(pattern_string) > 0:
            st = STree.STree(pattern_string)
            repeats = st.maximal_repeats()
            
            # Filter to significant repeats (at least 4 characters)
            significant_repeats = [r for r in repeats if len(r) >= 4]
            
            # Calculate the coverage of the pattern by repeats
            if significant_repeats:
                repeat_coverage = sum(len(r) * pattern_string.count(r) for r in significant_repeats)
                repeat_coverage = min(repeat_coverage / len(pattern_string), 1.0)
                
                # Invert so higher values = more variation
                return 1.0 - repeat_coverage
        
        return 0.5  # Default middle value if we can't calculate
    
    def classify_sections(self):
        """
        Classify the pattern for suitability for different song sections.
        Returns scores for each section type.
        """
        if not self.features:
            self.extract_features()
        
        scores = {}
        
        # For each section type, calculate how well this pattern matches
        for section, characteristics in SECTION_CHARACTERISTICS.items():
            # Calculate score based on feature ranges
            energy_score = self._range_score(
                self.features["energy"], 
                characteristics["energy_range"][0], 
                characteristics["energy_range"][1]
            )
            
            complexity_score = self._range_score(
                self.features["normalized_complexity"], 
                characteristics["complexity_range"][0], 
                characteristics["complexity_range"][1]
            )
            
            density_score = self._range_score(
                self.features["normalized_density"], 
                characteristics["density_range"][0], 
                characteristics["density_range"][1]
            )
            
            variation_score = self._range_score(
                self.features["normalized_variation"], 
                characteristics["variation_range"][0], 
                characteristics["variation_range"][1]
            )
            
            # Combined weighted score
            section_score = (
                energy_score * 0.3 +
                complexity_score * 0.25 +
                density_score * 0.25 +
                variation_score * 0.2
            ) * characteristics["weight"]
            
            scores[section] = {
                "score": section_score,
                "components": {
                    "energy": energy_score,
                    "complexity": complexity_score,
                    "density": density_score,
                    "variation": variation_score
                },
                "confidence": self._calculate_confidence(section_score)
            }
        
        self.section_scores = scores
        return scores
    
    def _range_score(self, value, min_val, max_val):
        """Calculate how well a value fits within a range, with 1.0 being perfect."""
        if min_val <= value <= max_val:
            # Within range gets a high score
            # The closer to the center, the higher the score
            center = (min_val + max_val) / 2
            distance_from_center = abs(value - center)
            range_radius = (max_val - min_val) / 2
            
            # Score is higher when closer to center
            return 1.0 - (distance_from_center / range_radius) * 0.5
        else:
            # Outside range gets a lower score based on distance
            if value < min_val:
                distance = min_val - value
            else:
                distance = value - max_val
                
            # Score decreases with distance from range
            return max(0.0, 1.0 - distance)
    
    def _calculate_confidence(self, score):
        """Calculate a confidence level for the classification."""
        # Simple confidence calculation based on score
        if score > 0.8:
            return "high"
        elif score > 0.6:
            return "medium"
        else:
            return "low"
    
    def get_top_section_recommendations(self, n=3):
        """Get the top n section recommendations for this pattern."""
        if not self.section_scores:
            self.classify_sections()
        
        # Sort sections by score
        sorted_sections = sorted(
            self.section_scores.items(), 
            key=lambda x: x[1]["score"], 
            reverse=True
        )
        
        return sorted_sections[:n]
    
    def get_classification_report(self):
        """Generate a full classification report for the pattern."""
        if not self.section_scores:
            self.classify_sections()
        
        # Get top recommendations
        top_recommendations = self.get_top_section_recommendations()
        
        report = {
            "file": os.path.basename(self.midi_file),
            "features": self.features,
            "section_scores": self.section_scores,
            "top_recommendations": [
                {
                    "section": section,
                    "score": data["score"],
                    "confidence": data["confidence"]
                }
                for section, data in top_recommendations
            ],
            "best_match": top_recommendations[0][0] if top_recommendations else None
        }
        
        return report

def main():
    parser = argparse.ArgumentParser(description="Groove MIDI Song Section Classifier")
    parser.add_argument("--input", help="Input MIDI file or directory")
    parser.add_argument("--output", default=os.path.join(METADATA_DIR, "section_classifications"),
                      help="Output directory for classification results")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")
    parser.add_argument("--batch", action="store_true", help="Process all MIDI files in the dataset")
    
    args = parser.parse_args()
    
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    # Create output directory
    os.makedirs(args.output, exist_ok=True)
    
    # Determine input files
    input_files = []
    
    if args.batch or not args.input:
        # Process all files in the MIDI directory
        for root, _, files in os.walk(MIDI_DIR):
            for file in files:
                if file.endswith(".mid") or file.endswith(".midi"):
                    input_files.append(os.path.join(root, file))
    elif os.path.isdir(args.input):
        # Process all files in the specified directory
        for file in os.listdir(args.input):
            if file.endswith(".mid") or file.endswith(".midi"):
                input_files.append(os.path.join(args.input, file))
    elif os.path.isfile(args.input):
        # Process a single file
        input_files.append(args.input)
    
    logger.info(f"Found {len(input_files)} MIDI files to process")
    
    all_results = {}
    
    # Process each file
    for midi_file in input_files:
        try:
            classifier = GrooveSectionClassifier(midi_file)
            classifier.extract_features()
            classifier.classify_sections()
            
            # Get report
            report = classifier.get_classification_report()
            file_id = os.path.splitext(os.path.basename(midi_file))[0]
            
            # Save individual report
            output_file = os.path.join(args.output, f"{file_id}_section.json")
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            
            # Store results for summary
            all_results[file_id] = {
                "file": os.path.basename(midi_file),
                "best_match": report["best_match"],
                "top_recommendations": report["top_recommendations"]
            }
            
            # Print summary
            top_sections = ", ".join([f"{rec['section']} ({rec['score']:.2f})" 
                                    for rec in report["top_recommendations"]])
            logger.info(f"Classified {os.path.basename(midi_file)}: {top_sections}")
            
        except Exception as e:
            logger.error(f"Error processing {midi_file}: {e}")
    
    # Save summary of all results
    summary_file = os.path.join(args.output, "section_classification_summary.json")
    with open(summary_file, 'w') as f:
        json.dump(all_results, f, indent=2)
    
    logger.info(f"Processing complete. Results saved to {args.output}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
