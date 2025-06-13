import os
import glob
import subprocess

JAMS_DIR = r"datasets/choco/choco-main/partitions/rock-corpus/choco/jams"
JCRD_DIR = r"datasets/choco/choco-main/partitions/rock-corpus/choco/jcrd"
META_PATH = r"datasets/choco/choco-main/partitions/rock-corpus/choco/meta.csv"
PARTITION = "rock-corpus"
LOG_PATH = r"datasets/choco/choco-main/partitions/rock-corpus/choco/conversion_log.txt"

os.makedirs(JCRD_DIR, exist_ok=True)
jams_files = glob.glob(os.path.join(JAMS_DIR, '*.jams'))

for jams_path in jams_files:
    base = os.path.splitext(os.path.basename(jams_path))[0]
    jcrd_path = os.path.join(JCRD_DIR, base + '.jcrd.json')
    cmd = [
        'python', 'scripts/jams_to_jcrd.py',
        jams_path, jcrd_path,
        '--meta', META_PATH,
        '--partition', PARTITION,
        '--log', LOG_PATH
    ]
    print('Converting:', jams_path)
    subprocess.run(cmd)
print('Batch conversion complete.')
