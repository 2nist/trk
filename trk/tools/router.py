# router.py
import sys, os

def route_file(path):
    if path.endswith(".mid"):
        os.system(f'python chordify_midi_to_jcrd.py --input "{path}"')
    elif path.endswith(".jcrd") or path.endswith(".json"):
        os.system(f'python validate_jcrd.py --input_dir "{os.path.dirname(path)}" --output_dir "fixed/"')
        os.system(f'python update_jcrd_schema.py --file "{path}"')
    elif path.endswith(".pdf"):
        # future: maybe link to OCR/metadata logic
        print(f"📄 PDF handling not implemented yet for: {path}")
    else:
        print(f"❓ Unknown file type: {path}")

if __name__ == "__main__":
    route_file(sys.argv[1])
