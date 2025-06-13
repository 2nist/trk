#!/usr/bin/env python3
"""
convert_all_partitions.py - Convert all ChoCo dataset partitions to JCRD format
"""

import os
import subprocess
import argparse
import time
from datetime import datetime
import sys

def main():
    parser = argparse.ArgumentParser(description="Convert all ChoCo dataset partitions to JCRD format")
    parser.add_argument("--input-root", default="../datasets/choco/choco-main/partitions", 
                        help="Root directory containing partition folders")
    parser.add_argument("--output-root", default="../jcrddatasets/choco", 
                        help="Root directory to save converted JCRD files")
    parser.add_argument("--partitions", nargs="+", default=[], 
                        help="Specific partitions to convert (if empty, convert all)")
    parser.add_argument("--skip", nargs="+", default=[], 
                        help="Partitions to skip")
    parser.add_argument("--limit", type=int, default=0, 
                        help="Limit number of files per partition (0=all)")
    args = parser.parse_args()
    
    # Ensure output directory exists
    os.makedirs(args.output_root, exist_ok=True)
    
    # Get list of partitions
    partitions = []
    if args.partitions:
        # Use only specified partitions
        partitions = args.partitions
    else:
        # Get all partitions from directory
        try:
            partitions = [d for d in os.listdir(args.input_root) 
                        if os.path.isdir(os.path.join(args.input_root, d)) 
                        and d not in args.skip]
        except Exception as e:
            print(f"Error reading partitions: {e}")
            return
    
    print(f"Found {len(partitions)} partitions to process")
    
    # Process each partition
    start_time = time.time()
    results = {"success": 0, "failed": 0, "skipped": 0, "total": 0}
    
    for partition in partitions:
        partition_start = time.time()
        input_dir = os.path.join(args.input_root, partition, "choco", "jams")
        output_dir = os.path.join(args.output_root, partition)
        
        # Skip if input directory doesn't exist
        if not os.path.isdir(input_dir):
            print(f"Skipping {partition} - input directory not found: {input_dir}")
            results["skipped"] += 1
            continue
        
        # Ensure output directory exists
        os.makedirs(output_dir, exist_ok=True)
        
        print(f"\n{'='*80}")
        print(f"Processing partition: {partition}")
        print(f"Input: {input_dir}")
        print(f"Output: {output_dir}")
        print(f"{'='*80}\n")
        
        # Build and run command
        cmd = [
            "python", "batch_convert_choco.py",
            "--recursive",
            "--partition", partition,
            "--log", f"{output_dir}_conversion.log"
        ]
        
        if args.limit > 0:
            cmd.extend(["--limit", str(args.limit)])
            
        cmd.extend([input_dir, output_dir])
        
        try:
            print(f"Running: {' '.join(cmd)}")
            process = subprocess.run(cmd, capture_output=True, text=True)
            
            if process.returncode == 0:
                # Extract statistics from output
                output = process.stdout
                print(output)
                
                # Try to parse results
                success = 0
                failed = 0
                validation_failed = 0
                total = 0
                
                for line in output.splitlines():
                    if "Success:" in line:
                        try:
                            success = int(line.split("Success:")[1].strip())
                        except:
                            pass
                    elif "Failed:" in line:
                        try:
                            failed = int(line.split("Failed:")[1].strip())
                        except:
                            pass
                    elif "Validation failed:" in line:
                        try:
                            validation_failed = int(line.split("Validation failed:")[1].strip())
                        except:
                            pass
                    elif "Total:" in line:
                        try:
                            total = int(line.split("Total:")[1].strip())
                        except:
                            pass
                
                results["success"] += success
                results["failed"] += failed + validation_failed
                results["total"] += total
                
                partition_time = time.time() - partition_start
                print(f"\nPartition {partition} completed in {partition_time:.2f} seconds")
                print(f"Success: {success}, Failed: {failed}, Validation Failed: {validation_failed}")
            else:
                error_msg = process.stderr
                print(f"Error processing partition {partition}:")
                print(error_msg)
                results["failed"] += 1
        except Exception as e:
            print(f"Exception processing partition {partition}: {e}")
            results["failed"] += 1
    
    # Print final summary
    total_time = time.time() - start_time
    print("\n" + "="*80)
    print(f"Conversion completed in {total_time:.2f} seconds ({total_time/60:.2f} minutes)")
    print(f"Total partitions: {len(partitions)}")
    print(f"Successful partitions: {len(partitions) - results['skipped'] - results['failed']}")
    print(f"Failed partitions: {results['failed']}")
    print(f"Skipped partitions: {results['skipped']}")
    print(f"Total files converted: {results['success']} / {results['total']}")
    print("="*80)

if __name__ == "__main__":
    print(f"Starting conversion at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    main()
    print(f"Completed at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
