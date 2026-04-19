#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-jupyter-extended:latest}"

echo "=== Jupyter & Python ==="

docker run --rm "${IMAGE}" /bin/bash -lc "/opt/conda/bin/python3 --version"
docker run --rm "${IMAGE}" /bin/bash -lc "/opt/conda/bin/jupyter lab --version"

# Create a minimal Python notebook, execute it, and verify output
docker run --rm "${IMAGE}" /bin/bash -lc '
NB=$(mktemp /tmp/test_py.XXXX.ipynb)
cat > "$NB" << "NOTEBOOK"
{
 "cells": [{"cell_type": "code", "metadata": {}, "execution_count": null, "id": "0",
  "source": ["print(42)"],
  "outputs": []}],
 "metadata": {"kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}},
 "nbformat": 4, "nbformat_minor": 5
}
NOTEBOOK
/opt/conda/bin/jupyter nbconvert --to notebook --execute "$NB" -o _out 2>/dev/null
python3 -c "
import json
with open(\"_out.ipynb\") as f:
    nb = json.load(f)
cell = nb[\"cells\"][0]
outputs = cell.get(\"outputs\", [])
text = \"\".join(o.get(\"text\", \"\") for o in outputs if \"text\" in o)
assert \"42\" in text, f\"Expected 42 in output, got {text}\"
print(\"python3: OK\")
"
rm -f "$NB" "_out.ipynb"
'
