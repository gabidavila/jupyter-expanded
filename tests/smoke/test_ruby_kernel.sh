#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-jupyter-extended:latest}"

echo "=== Ruby Kernel ==="

# Verify Ruby kernel is registered
docker run --rm "${IMAGE}" /bin/bash -lc "/opt/conda/bin/jupyter kernelspec list | grep ruby3"

# Create a minimal Ruby notebook, execute it, and verify output
docker run --rm "${IMAGE}" /bin/bash -lc '
NB=$(mktemp /tmp/test_rb.XXXX.ipynb)
cat > "$NB" << "NOTEBOOK"
{
 "cells": [{"cell_type": "code", "metadata": {}, "execution_count": null, "id": "0",
  "source": ["puts 42"],
  "outputs": []}],
 "metadata": {"kernelspec": {"display_name": "Ruby", "language": "ruby", "name": "ruby3"}},
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
# Ruby iruby outputs go into stream messages
text = \"\".join(o.get(\"text\", \"\") for o in outputs if o.get(\"stream\") == \"stdout\")
if not text:
    text = \"\".join(o.get(\"text\", \"\") for o in outputs if \"text\" in o)
assert \"42\" in text, f\"Expected 42 in output, got {outputs}\"
print(\"ruby3: OK\")
"
rm -f "$NB" "_out.ipynb"
'
