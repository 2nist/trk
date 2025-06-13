#!/usr/bin/env python3
"""
batch_convert_choco.py - Batch convert ChoCo dataset JAMS files to JCRD format
"""

import os
import glob
import subprocess
import json
import sys
import jsonschema
import argparse
import traceback
import datetime

def load_schema(schema_path):
    """Load and return the JSON schema"""
    with open(schema_path, "r", encoding="utf-8") as f:
        return json.load(f)

def validate_jcrd(jcrd_path, schema):
    """Validate a JCRD file against the schema"""
    with open(jcrd_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    try:
        jsonschema.validate(instance=data, schema=schema)
        return True, None
    except jsonschema.exceptions.ValidationError as e:
        return False, str(e)

def main():
    parser = argparse.ArgumentParser(description="Batch convert ChoCo dataset JAMS files to JCRD format")
    parser.add_argument("input_dir", help="Directory containing JAMS files or subdirectories with JAMS files")
    parser.add_argument("output_dir", help="Directory to save converted JCRD files")
    parser.add_argument("--schema", help="Path to JCRD schema file", default="../jcrd.schema.json")
    parser.add_argument("--recursive", action="store_true", help="Search recursively for JAMS files")
    parser.add_argument("--limit", type=int, default=0, help="Limit number of files to process (0=all)")
    parser.add_argument("--log", help="Path to log file", default="batch_conversion_log.txt")
    parser.add_argument("--meta", help="Path to meta.csv for enrichment", required=False)
    parser.add_argument("--partition", help="Partition name (e.g., rock-corpus)", required=False)
    args = parser.parse_args()
    
    # Create output directory if it doesn't exist
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)
    
    # Find all JAMS files
    pattern = os.path.join(args.input_dir, "**/*.jams" if args.recursive else "*.jams")
    jams_files = glob.glob(pattern, recursive=args.recursive)
    
    if not jams_files:
        print(f"No JAMS files found in {args.input_dir}")
        return
    
    # Apply limit if specified
    if args.limit > 0 and args.limit < len(jams_files):
        jams_files = jams_files[:args.limit]
    
    print(f"Found {len(jams_files)} JAMS files")
    
    # Load schema for validation
    try:
        schema = load_schema(args.schema)
        print(f"Success! Loaded schema from {args.schema}")
    except Exception as e:
        print(f"Error loading schema: {e}")
        schema = None
    
    # Setup counters and log
    success = 0
    failed = 0
    validation_failed = 0
    
    with open(args.log, "w", encoding="utf-8") as log:
        log.write(f"Batch conversion started at {datetime.datetime.now().isoformat()}\n")
        log.write(f"Input directory: {args.input_dir}\n")
        log.write(f"Output directory: {args.output_dir}\n\n")
        
        for jams_path in jams_files:
            # Generate output path for directory structure
            rel_path = os.path.relpath(jams_path, args.input_dir)
            output_dir = os.path.join(args.output_dir, os.path.dirname(rel_path))
            
            # Create the output directory if it doesn't exist
            if not os.path.exists(output_dir):
                os.makedirs(output_dir, exist_ok=True)
                
            print(f"Converting {jams_path}")
            log.write(f"Processing {jams_path}...\n")
            
            # Build command with optional arguments
            cmd = ["python", "jams_to_jcrd.py", jams_path, "--out-dir", output_dir]
            
            if args.meta:
                cmd.extend(["--meta", args.meta])
            if args.partition:
                cmd.extend(["--partition", args.partition])
            
            try:
                # Run the converter script
                result = subprocess.run(cmd, capture_output=True, text=True)
                
                if result.returncode == 0:
                    # Get the output file path from the console output
                    output_file = None
                    for line in result.stdout.splitlines():
                        if "Saved JCRD to:" in line:
                            output_file = line.split("Saved JCRD to:", 1)[1].strip()
                            break
                    
                    if output_file and os.path.exists(output_file):
                        # Validate against schema if available
                        if schema:
                            valid, error = validate_jcrd(output_file, schema)
                            
                            if valid:
                                success += 1
                                log.write(f"SUCCESS: {jams_path} -> {output_file}\n")
                                print(f"Success! Converted and validated: {output_file}")
                            else:
                                validation_failed += 1
                                log.write(f"VALIDATION FAILED: {output_file} | Error: {error}\n")
                                print(f"Validation failed: {output_file}")
                                # Include validation error details
                                log.write(f"Validation error details:\n{error}\n\n")
                        else:
                            # No schema validation
                            success += 1
                            log.write(f"SUCCESS (not validated): {jams_path} -> {output_file}\n")
                            print(f"Success! Converted (not validated): {output_file}")
                    else:
                        failed += 1
                        log.write(f"FAILED: {jams_path} | Output file not created\n")
                        print(f"Failed: Output file not created")
                else:
                    failed += 1
                    log_msg = f"FAILED: {jams_path} | {result.stderr.strip()}\n"
                    log.write(log_msg)
                    print(log_msg.strip())
            except Exception as e:
                failed += 1
                log_msg = f"ERROR: {jams_path} | {str(e)}\n"
                log.write(log_msg)
                log.write(f"Traceback:\n{traceback.format_exc()}\n\n")
                print(log_msg.strip())
        
        # Write summary
        summary = f"\nSummary:\n- Total: {len(jams_files)}\n- Success: {success}\n- Failed: {failed}\n- Validation failed: {validation_failed}\n"
        log.write(summary)
        print(summary)

if __name__ == "__main__":
    main()
