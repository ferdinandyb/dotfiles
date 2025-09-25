import subprocess
import sys
from pathlib import Path

def get_git_root():
    try:
        result = subprocess.check_output(["git", "rev-parse", "--show-toplevel"],
                                       stderr=subprocess.DEVNULL,
                                       universal_newlines=True)
        return Path(result.strip())
    except subprocess.CalledProcessError:
        return Path.cwd()

def add_to_path(path):
    git_root = get_git_root()
    full_path = git_root / path
    if full_path.exists() and str(full_path) not in sys.path:
        sys.path.insert(0, str(full_path))
