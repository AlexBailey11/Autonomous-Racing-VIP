#!/bin/bash
# =============================================
# F1tenth gym setup script
# Run this once after first launching the container:  ~/setup_gym.sh
# It installs f1tenth_gym from the mounted workspace and patches numba.
# =============================================

set -e

GYM_PATH="$HOME/ros2_ws/f1tenth_gym/gym"

# =====
# Check that the workspace is mounted and f1tenth_gym exists
# =====
if [ ! -d "$GYM_PATH" ]; then
    echo "ERROR: f1tenth_gym not found at $GYM_PATH"
    echo "Make sure the workspace is mounted and the path is correct."
    exit 1
fi

# =====
# Install f1tenth_gym from source in editable mode
# =====
echo "Installing f1tenth_gym from $GYM_PATH ..."
pip install -e "$GYM_PATH"

# =====
# Patch numba to disable the broken coverage integration
# The custom numba 0.64.0 used by f1tenth_gym references coverage.types
# which does not exist in available coverage versions
# =====
NUMBA_COVERAGE="$HOME/.local/lib/python3.10/site-packages/numba/misc/coverage_support.py"

if [ -f "$NUMBA_COVERAGE" ]; then
    echo "Patching numba coverage support..."
    sed -i 's/coverage_available = True/coverage_available = False/' "$NUMBA_COVERAGE"
    echo "Numba patched successfully."
else
    echo "WARNING: numba coverage_support.py not found at expected path, skipping patch."
fi

# =====
# Verify everything imports correctly
# =====
echo "Verifying imports..."
python3 -c "import numba; print('numba ok:', numba.__version__)"
python3 -c "import gym; print('gym ok:', gym.__version__)"

echo ""
echo "Setup complete. You can now run your launch files."