$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $repo
New-Item -ItemType Directory -Force -Path (Join-Path $repo "out") | Out-Null
$scad = if ($env:OPENSCAD) { $env:OPENSCAD } else { "openscad.com" }
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "py" }

function Invoke-OpenSCAD {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$ScadArgs
    )
    $logPath = Join-Path $repo "out\openscad-last.log"
    $merged = & $scad @ScadArgs 2>&1 | ForEach-Object { "$_" }
  $merged | Set-Content -Path $logPath -Encoding utf8
    $text = ($merged -join "`n")
    $exit = $LASTEXITCODE
    if ($null -eq $exit) { $exit = 0 }
    if ($exit -ne 0) {
        Write-Error "OpenSCAD failed ($Label): exit code $exit`n$text"
    }
    if ($text -match "(?m)^(ERROR|WARNING):") {
        Write-Error "OpenSCAD reported ERROR/WARNING ($Label):`n$text"
    }
}

function Invoke-Check {
    param([string]$Stl)
    & $py Boxes\tests\check_rugged_overhangs.py $Stl
    if ($LASTEXITCODE -ne 0) { Write-Error "overhang check failed: $Stl" }
}

try {
    Invoke-OpenSCAD "assert echo" @(
        "--hardwarnings", "-o", "out\custom-dividers-test.echo",
        "Boxes\tests\rugged-box-custom-dividers-test.scad")
    $echo = Get-Content "out\custom-dividers-test.echo" -Raw
    if ($echo -notmatch "custom-dividers-tests ok") { throw "assert run did not report success" }

    & $py -m unittest discover -s Boxes/tests -p "test_*.py"
    if ($LASTEXITCODE -ne 0) { throw "unit tests failed" }

    foreach ($p in 0, 1, 2, 3) {
        Invoke-OpenSCAD "bottom preset $p" @(
            "--hardwarnings", "-o", "out\bottom-preset-$p.stl",
            "-D", "dividerLayoutPreset=$p",
            "-D", "generateBoxTop=false", "-D", "generateLatches=false", "-D", "generateHandle=false",
            "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
            "Boxes\RuggedBoxCustomeDividersV1.0.scad")
        Invoke-Check "out\bottom-preset-$p.stl"
    }
    foreach ($p in 0, 1, 2, 3) {
        Invoke-OpenSCAD "lid preset $p" @(
            "--hardwarnings", "-o", "out\lid-preset-$p.stl",
            "-D", "dividerLayoutPreset=$p",
            "-D", "generateBoxBottom=false", "-D", "generateBoxTop=true",
            "-D", "generateLatches=false", "-D", "generateHandle=false",
            "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
            "Boxes\RuggedBoxCustomeDividersV1.0.scad")
        Invoke-Check "out\lid-preset-$p.stl"
    }
    Invoke-OpenSCAD "latch" @(
        "--hardwarnings", "-o", "out\latch.stl",
        "-D", "generateBoxBottom=false", "-D", "generateBoxTop=false",
        "-D", "generateLatches=true", "-D", "generateHandle=false",
        "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad")
    Invoke-Check "out\latch.stl"
    Invoke-OpenSCAD "handle" @(
        "--hardwarnings", "-o", "out\handle.stl",
        "-D", "generateBoxBottom=false", "-D", "generateBoxTop=false",
        "-D", "generateLatches=false", "-D", "generateHandle=true", "-D", "numberOfLatches=2",
        "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad")
    Invoke-Check "out\handle.stl"
    Invoke-OpenSCAD "closed preset 2" @(
        "--hardwarnings", "-o", "out\closed-preset-2.stl",
        "-D", "viewBoxClosed=true", "-D", "dividerLayoutPreset=2",
        "-D", "generateLatches=false", "-D", "generateHandle=false",
        "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad")
    & $py Boxes\tests\check_layout.py out\bottom-preset-0.stl out\bottom-preset-2.stl out\closed-preset-2.stl
    if ($LASTEXITCODE -ne 0) { throw "layout check failed" }
    & $py Boxes\tests\check_geometry.py out\bottom-preset-0.stl out\bottom-preset-2.stl out\lid-preset-0.stl out\lid-preset-2.stl out\latch.stl out\handle.stl out\closed-preset-2.stl
    if ($LASTEXITCODE -ne 0) { throw "geometry check failed" }

    Write-Host "render-presets ok"
}
catch {
    Write-Error "render-presets.ps1 stopped: $($_.Exception.Message)"
    exit 1
}
