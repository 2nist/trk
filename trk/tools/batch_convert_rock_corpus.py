import os
import subprocess

har_dir = os.path.join("datasets", "rock_corpus", "rock_corpus", "rock_corpus_v2-1", "rs200_harmony")
out_dir = os.path.abspath(".")
script = os.path.abspath("rock_corpus_har_to_jcrd.py")

for fname in os.listdir(har_dir):
    if fname.endswith(".har"):
        har_path = os.path.join(har_dir, fname)
        jcrd_path = os.path.join(out_dir, fname.replace(".har", ".jcrd"))
        print(f"Converting {fname} -> {os.path.basename(jcrd_path)}")
        subprocess.run(["python", script, har_path, jcrd_path])
