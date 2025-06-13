"""
Check file type by examining the first few bytes.
"""

import os
import sys
import binascii

def get_file_type(file_path):
    """Get the type of file by examining its magic number."""
    try:
        with open(file_path, 'rb') as f:
            # Read the first 16 bytes
            header = f.read(16)
            hex_repr = binascii.hexlify(header).decode('utf-8')
            
            # Print the hex representation
            print(f"File header (hex): {hex_repr}")
            
            # Check for common file signatures
            if header.startswith(b'\x1f\x8b'):
                return "GZIP Archive"
            elif header.startswith(b'PK\x03\x04'):
                return "ZIP Archive"
            elif header.startswith(b'Rar!\x1a\x07'):
                return "RAR Archive"
            elif header.startswith(b'7z\xbc\xaf\x27\x1c'):
                return "7-Zip Archive"
            elif header.startswith(b'\x75\x73\x74\x61\x72'):  # 'ustar'
                return "TAR Archive"
            else:
                # Try to determine based on content
                if b'ustar' in header:
                    return "TAR Archive"
                return "Unknown file type"
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python check_file_type.py <file_path>")
        sys.exit(1)
        
    file_path = sys.argv[1]
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' does not exist.")
        sys.exit(1)
    
    file_type = get_file_type(file_path)
    print(f"File: {file_path}")
    print(f"Type: {file_type}")
    
    # Display file stats
    file_size = os.path.getsize(file_path)
    print(f"Size: {file_size} bytes ({file_size / 1024 / 1024:.2f} MB)")
