#!/usr/bin/env python3
"""
simple_validate.py - Simple validation script for JCRD files against the schema
"""

import json
import jsonschema
import sys

def main():
    if len(sys.argv) != 3:
        print("Usage: simple_validate.py <schema_path> <jcrd_path>")
        return 1
        
    schema_path = sys.argv[1]
    jcrd_path = sys.argv[2]
    
    try:
        with open(schema_path, 'r', encoding='utf-8') as f:
            schema = json.load(f)
            
        with open(jcrd_path, 'r', encoding='utf-8') as f:
            jcrd = json.load(f)
            
        jsonschema.validate(instance=jcrd, schema=schema)
        print(f"Validation successful! {jcrd_path} is a valid JCRD file.")
        return 0
    except Exception as e:
        print(f"Validation failed: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
