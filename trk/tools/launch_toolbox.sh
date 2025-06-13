#!/usr/bin/env bash
# Launch the JCRD Toolbox GUI using the project virtual environment

# Determine project root (assumes this script lives in project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$SCRIPT_DIR/.venv"
PYTHON="$VENV/bin/python"

# Auto-create the virtual environment if missing
if [ ! -d "$VENV" ]; then
  echo "Virtual environment not found, creating at $VENV"
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --upgrade pip
  "$VENV/bin/pip" install -r "$SCRIPT_DIR/requirements.txt"
fi

# Check Python executable
if [ ! -x "$PYTHON" ]; then
  echo "Error: Python not found at $PYTHON"
  echo "Run 'python -m venv .venv' and install requirements first."
  exit 1
fi

# Run the GUI
exec "$PYTHON" "$SCRIPT_DIR/gui/jcrd_toolbox_gui_real.py" "$@"
