$ErrorActionPreference = "Continue"
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $repo
New-Item -ItemType Directory -Force -Path (Join-Path $repo "out") | Out-Null
$scad = if ($env:OPENSCAD) { $env:OPENSCAD } else { "openscad.com" }
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "py" }

function Invoke-OpenSCAD([string[]]$ScadArgs) {
    & $scad @ScadArgs
    if ($LASTEXITCODE -ne 0) { throw "openscad exited $LASTEXITCODE" }
}
function Invoke-Check([string]$Stl) {
    & $py Boxes\tests\check_overhangs.py $Stl
    if ($LASTEXITCODE -ne 0) { throw "overhang check failed: $Stl" }
}

Invoke-OpenSCAD @("--hardwarnings","-o","out\custom-dividers-test.echo","Boxes\tests\rugged-box-custom-dividers-test.scad")
$echo = Get-Content "out\custom-dividers-test.echo" -Raw
if ($echo -notmatch "custom-dividers-tests ok") { throw "assert run did not report success" }
& $py -m unittest discover -s Boxes/tests -p 'test_check_overhangs.py'
if ($LASTEXITCODE -ne 0) { throw "overhang unit tests failed" }

foreach ($p in 0, 1, 2, 3) {
    Invoke-OpenSCAD @(
        "--hardwarnings","-o","out\bottom-preset-$p.stl",
        "-D","dividerLayoutPreset=$p",
        "-D","generateBoxTop=false","-D","generateLatches=false","-D","generateHandle=false",
        "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad")
    Invoke-Check "out\bottom-preset-$p.stl"
}
foreach ($p in 0, 1, 2, 3) {
    Invoke-OpenSCAD @(
        "--hardwarnings","-o","out\lid-preset-$p.stl",
        "-D","dividerLayoutPreset=$p",
        "-D","generateBoxBottom=false","-D","generateBoxTop=true",
        "-D","generateLatches=false","-D","generateHandle=false",
        "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad")
    Invoke-Check "out\lid-preset-$p.stl"
}
Invoke-OpenSCAD @(
    "--hardwarnings","-o","out\latch.stl",
    "-D","generateBoxBottom=false","-D","generateBoxTop=false",
    "-D","generateLatches=true","-D","generateHandle=false",
    "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
    "Boxes\RuggedBoxCustomeDividersV1.0.scad")
Invoke-Check "out\latch.stl"
Invoke-OpenSCAD @(
    "--hardwarnings","-o","out\handle.stl",
    "-D","generateBoxBottom=false","-D","generateBoxTop=false",
    "-D","generateLatches=false","-D","generateHandle=true","-D","numberOfLatches=2",
    "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
    "Boxes\RuggedBoxCustomeDividersV1.0.scad")
Invoke-Check "out\handle.stl"
