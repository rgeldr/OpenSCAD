@echo off
setlocal DisableDelayedExpansion
if not defined FAIL_LINE set "FAIL_LINE=ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron."
echo(%FAIL_LINE%
echo(%FAIL_LINE% 1>&2
exit /b 0
