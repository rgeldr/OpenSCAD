@echo off
REM Drop-in OpenSCAD stand-in for Windows (cmd). Prints ERROR/WARNING to both streams.
set "LINE=%FAIL_LINE%"
if "%LINE%"=="" set "LINE=ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron."
echo %LINE%
echo %LINE% 1>&2
exit /b 0
