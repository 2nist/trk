#!/usr/bin/env python3
"""
Beatles JCRD Visual Analyzer

This script provides a detailed visual analysis of Beatles JCRD files without requiring ImGui.
It uses ASCII art to create a visual representation of the song structure.
"""

import os
import json
import sys
import math
from pathlib import Path
from datetime import timedelta

def format_time(seconds):
    """Format seconds to MM:SS format"""
    return str(timedelta(seconds=seconds)).split('.')[0][-5:]

def format_time_exact(seconds):
    """Format seconds to MM:SS.ms format"""
    minutes = int(seconds // 60)
    seconds_part = int(seconds % 60)
    ms = int((seconds % 1) * 1000)
    return f"{minutes:02d}:{seconds_part:02d}.{ms:03d}"

class JCRDVisualAnalyzer:
    def __init__(self, jcrd_data, file_name):
        self.data = jcrd_data
        self.file_name = file_name
        self.metadata = jcrd_data.get('metadata', {})
        self.sections = jcrd_data.get('sections', [])
        
        # Find total song duration based on sections
        if self.sections:
            last_section = self.sections[-1]
            self.song_duration = last_section.get('end_time', 0)
        else:
            self.song_duration = 0
            
        # Process chord progressions
        self.process_chord_progression()
    
    def process_chord_progression(self):
        """Process chord progressions from sections"""
        self.chord_progression = []
        
        for section in self.sections:
            chords = section.get('chords', [])
            for chord in chords:
                start_time = chord.get('start_time', 0)
                end_time = chord.get('end_time', 0)
                chord_name = chord.get('chord', 'N')
                
                self.chord_progression.append({
                    'time': start_time,
                    'end_time': end_time,
                    'chord': chord_name,
                    'section': section.get('name', 'Unknown')
                })
        
        # Sort by time
        self.chord_progression.sort(key=lambda x: x['time'])
    
    def generate_header(self):
        """Generate the song header information"""
        output = []
        output.append("=" * 80)
        output.append(f"FILE: {self.file_name}")
        output.append("=" * 80)
        output.append(f"Title:       {self.metadata.get('title', 'Unknown')}")
        output.append(f"Artist:      {self.metadata.get('artist', 'Unknown')}")
        output.append(f"Album:       {self.metadata.get('album', 'Unknown')}")
        output.append(f"Key:         {self.metadata.get('key', 'Unknown')}")
        output.append(f"Tempo:       {self.metadata.get('tempo', 'Unknown')} BPM")
        output.append(f"Time Sig:    {self.metadata.get('time_signature', '4/4')}")
        output.append(f"Tags:        {', '.join(self.metadata.get('tags', ['None']))}")
        output.append(f"Source:      {self.metadata.get('source', 'Unknown')}")
        output.append(f"Duration:    {format_time(self.song_duration)}")
        output.append(f"Sections:    {len(self.sections)}")
        output.append(f"Chords:      {len(self.chord_progression)}")
        output.append("=" * 80)
        return "\n".join(output)
    
    def generate_section_overview(self):
        """Generate a section overview"""
        if not self.sections:
            return "NO SECTIONS FOUND"
            
        output = []
        output.append("\nSECTION OVERVIEW")
        output.append("-" * 80)
        output.append(f"{'#':<3} {'Section':<12} {'Start':<8} {'End':<8} {'Duration':<8} {'Chords':<6} {'Notes'}")
        output.append("-" * 80)
        
        for i, section in enumerate(self.sections):
            name = section.get('name', 'Unknown')
            start = section.get('start_time', 0)
            end = section.get('end_time', 0)
            duration = end - start
            chords = section.get('chords', [])
            
            output.append(f"{i+1:<3} {name:<12} {format_time(start):<8} {format_time(end):<8} " +
                         f"{duration:.2f}s{' ':<3} {len(chords):<6} ")
        
        return "\n".join(output)
    
    def generate_chord_progression(self):
        """Generate chord progression display"""
        if not self.chord_progression:
            return "NO CHORD PROGRESSION FOUND"
            
        output = []
        output.append("\nCHORD PROGRESSION")
        output.append("-" * 80)
        output.append(f"{'#':<3} {'Time':<10} {'Chord':<6} {'Duration':<8} {'Section':<15}")
        output.append("-" * 80)
        
        current_section = None
        
        for i, chord in enumerate(self.chord_progression):
            time = chord.get('time', 0)
            end_time = chord.get('end_time', 0)
            chord_name = chord.get('chord', 'N')
            duration = end_time - time
            section = chord.get('section', 'Unknown')
            
            # Add section header if changed
            if section != current_section:
                output.append(f"--- {section} " + "-" * (75 - len(section)))
                current_section = section
            
            output.append(f"{i+1:<3} {format_time_exact(time):<10} {chord_name:<6} {duration:.2f}s{' ':<3} {section:<15}")
        
        return "\n".join(output)
    
    def generate_visual_timeline(self):
        """Generate visual timeline of sections and chords"""
        if not self.sections:
            return "NO SECTIONS FOR TIMELINE"
            
        # Parameters
        timeline_width = 70
        total_duration = self.song_duration
        
        output = []
        output.append("\nVISUAL TIMELINE")
        output.append("-" * 80)
        
        # Generate time markers
        markers = []
        for i in range(6):
            time_point = total_duration * (i / 5)
            position = int((time_point / total_duration) * timeline_width)
            markers.append((position, format_time(time_point)))
            
        marker_line = " " * timeline_width
        marker_time = " " * timeline_width
        for pos, time_str in markers:
            # Ensure we don't go out of bounds
            if pos < timeline_width:
                marker_line = marker_line[:pos] + "|" + marker_line[pos+1:]
                
                # Center the time string around the marker
                time_start = max(0, pos - len(time_str) // 2)
                time_end = min(timeline_width, time_start + len(time_str))
                marker_time = marker_time[:time_start] + time_str[:time_end-time_start] + marker_time[time_end:]
            
        output.append(marker_line)
        output.append(marker_time)
        output.append("-" * timeline_width)
        
        # Generate section timeline
        for i, section in enumerate(self.sections):
            name = section.get('name', '???')
            start = section.get('start_time', 0)
            end = section.get('end_time', 0)
            
            # Calculate positions in the timeline
            start_pos = int((start / total_duration) * timeline_width)
            end_pos = int((end / total_duration) * timeline_width)
            
            # Create timeline visual
            section_line = " " * timeline_width
            if start_pos < timeline_width and end_pos > 0:
                # Adjust if out of bounds
                display_start = max(0, start_pos)
                display_end = min(timeline_width, end_pos)
                
                # Create the section bar
                for j in range(display_start, display_end):
                    section_line = section_line[:j] + "=" + section_line[j+1:]
                
                # Add section label if there's room
                label = f" {name} "
                label_len = len(label)
                
                if display_end - display_start > label_len + 2:
                    # Center the label in the section
                    label_start = display_start + (display_end - display_start - label_len) // 2
                    section_line = section_line[:label_start] + label + section_line[label_start+label_len:]
            
            output.append(section_line)
        
        # Add chord markers below the sections
        output.append("-" * timeline_width)
        chord_line = " " * timeline_width
        
        for chord in self.chord_progression:
            time = chord.get('time', 0)
            pos = int((time / total_duration) * timeline_width)
            
            if 0 <= pos < timeline_width:
                chord_line = chord_line[:pos] + "^" + chord_line[pos+1:]
        
        output.append(chord_line)
        
        return "\n".join(output)
    
    def generate_report(self):
        """Generate the complete report"""
        parts = [
            self.generate_header(),
            self.generate_section_overview(),
            self.generate_chord_progression(),
            self.generate_visual_timeline()
        ]
        
        return "\n".join(parts)

def analyze_jcrd_file(file_path):
    """Analyze a JCRD file and return the report"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            jcrd_data = json.load(f)
        
        analyzer = JCRDVisualAnalyzer(jcrd_data, os.path.basename(file_path))
        return analyzer.generate_report()
    except Exception as e:
        return f"Error analyzing {file_path}: {str(e)}"

def main():
    """Main function to analyze Beatles JCRD files"""
    # Find the script directory and project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    beatles_dir = os.path.join(project_root, "data", "jcrd_library", "beatles")
    
    if not os.path.exists(beatles_dir):
        print(f"Beatles directory not found: {beatles_dir}")
        return 1
    
    # Get list of Beatles JCRD files
    jcrd_files = [f for f in os.listdir(beatles_dir) if f.endswith(".jcrd.json")]
    
    if not jcrd_files:
        print(f"No JCRD files found in the Beatles directory.")
        return 1
    
    print(f"Found {len(jcrd_files)} Beatles JCRD files.\n")
    
    # Check if a specific file is requested
    if len(sys.argv) > 1:
        file_name = sys.argv[1]
        if not file_name.endswith('.jcrd.json'):
            file_name += '.jcrd.json'
        
        file_path = os.path.join(beatles_dir, file_name)
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            return 1
        
        report = analyze_jcrd_file(file_path)
        print(report)
        return 0
    
    # Process all files
    for file_name in jcrd_files:
        file_path = os.path.join(beatles_dir, file_name)
        report = analyze_jcrd_file(file_path)
        print(report)
        print("\n" + "=" * 80 + "\n")
    
    return 0

if __name__ == "__main__":
    print("\n=== Beatles JCRD Visual Analyzer ===\n")
    result = main()
    print("\n=== Analysis Complete ===\n")
    sys.exit(result)
