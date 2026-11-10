#!/usr/bin/env bash
# Drop-in OpenSCAD stand-in. Prints a hard failure and exits 0 so callers
# must notice the text, not only the process status.
line="${FAIL_LINE:-ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron.}"
echo "$line"
echo "$line" >&2
exit 0
