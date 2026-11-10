$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $repo
New-Item -ItemType Directory -Force -Path (Join-Path $repo "out") | Out-Null
$scad = if ($env:OPENSCAD) { $env:OPENSCAD } else { "openscad.com" }
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "py" }
$summary = New-Object System.Collections.Generic.List[string]

function Test-OpenSCADLog([string]$Text) {
    if ([string]::IsNullOrEmpty($Text)) { return }
    if ($Text -match "(?m)(\s|^)(ERROR|WARNING):") {
        $hits = [regex]::Matches($Text, "(?m)^.*(ERROR|WARNING):.*$") | ForEach-Object { $_.Value.Trim() }
        throw "OpenSCAD output contains ERROR/WARNING:`n$($hits -join "`n")"
    }
}

function Invoke-OpenSCAD {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$ScadArgs,
        [switch]$Quiet
    )
    $logPath = Join-Path $repo "out\openscad-last.log"
    $argList = @("--hardwarnings")
    if ($Quiet) { $argList += "-q" }
    $argList += $ScadArgs

    # Use Start-Process (works on Windows PowerShell 5.1). The PS7-only
    # ProcessStartInfo string-collection API is null on .NET Framework.
    $outDir = Join-Path $repo "out"
    $stdoutFile = Join-Path $outDir ("_openscad-out-{0}.log" -f [guid]::NewGuid().ToString())
    $stderrFile = Join-Path $outDir ("_openscad-err-{0}.log" -f [guid]::NewGuid().ToString())
    try {
        $proc = Start-Process -FilePath $scad -ArgumentList $argList -PassThru -Wait -NoNewWindow `
            -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
        $stdout = ""
        $stderr = ""
        if (Test-Path -LiteralPath $stdoutFile) {
            $stdout = Get-Content -LiteralPath $stdoutFile -Raw -ErrorAction SilentlyContinue
        }
        if (Test-Path -LiteralPath $stderrFile) {
            $stderr = Get-Content -LiteralPath $stderrFile -Raw -ErrorAction SilentlyContinue
        }
        if ($null -eq $stdout) { $stdout = "" }
        if ($null -eq $stderr) { $stderr = "" }
        $text = ($stdout + "`n" + $stderr).Trim()
        Set-Content -Path $logPath -Value $text -Encoding utf8
        if ($proc.ExitCode -ne 0) {
            throw "OpenSCAD failed ($Label): exit $($proc.ExitCode)`n$text"
        }
        Test-OpenSCADLog $text
    }
    finally {
        Remove-Item -LiteralPath $stdoutFile, $stderrFile -Force -ErrorAction SilentlyContinue
    }

    $stl = $null
    for ($i = 0; $i -lt $ScadArgs.Count - 1; $i++) {
        if ($ScadArgs[$i] -eq "-o") { $stl = $ScadArgs[$i + 1] }
    }
    if ($stl -and $stl.ToLower().EndsWith(".stl")) {
        $tris = & $py -c "import sys; sys.path.insert(0,'Boxes/tests'); from check_overhangs import load_triangles; print(len(load_triangles(r'$stl')))"
        if ($LASTEXITCODE -ne 0) { throw "triangle count failed for $stl" }
        [void]$summary.Add("OK $Label ($stl, $tris triangles)")
    } else {
        [void]$summary.Add("OK $Label")
    }
    Write-Host "  $Label ... ok"
}

function Invoke-Check([string]$Stl, [switch]$Rugged) {
    if ($Rugged) {
        & $py Boxes\tests\check_rugged_overhangs.py $Stl
    } else {
        & $py Boxes\tests\check_overhangs.py $Stl
    }
    if ($LASTEXITCODE -ne 0) { throw "overhang check failed: $Stl" }
}

try {
    Write-Host "render-presets: OPENSCAD=$scad"
    Invoke-OpenSCAD "assert echo" @(
        "-o", "out\custom-dividers-test.echo",
        "Boxes\tests\rugged-box-custom-dividers-test.scad")
    $echoPath = Join-Path $repo "out\custom-dividers-test.echo"
    $echo = ""
    if (Test-Path -LiteralPath $echoPath) {
        $echo = Get-Content -LiteralPath $echoPath -Raw -ErrorAction SilentlyContinue
    }
    if ($null -eq $echo) { $echo = "" }
    if ($echo -notmatch "custom-dividers-tests ok") { throw "assert run did not report success" }

    if (-not $env:RENDER_PRESETS_SKIP_UNITTEST) {
        & $py -m unittest discover -s Boxes/tests -p "test_*.py"
        if ($LASTEXITCODE -ne 0) { throw "unit tests failed" }
    }

    foreach ($p in 0, 1, 2, 3) {
        Invoke-OpenSCAD "bottom preset $p" @(
            "-o", "out\bottom-preset-$p.stl",
            "-D", "dividerLayoutPreset=$p",
            "-D", "generateBoxTop=false", "-D", "generateLatches=false", "-D", "generateHandle=false",
            "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
            "Boxes\RuggedBoxCustomeDividersV1.0.scad") -Quiet
        Invoke-Check "out\bottom-preset-$p.stl" -Rugged
    }
    foreach ($p in 0, 1, 2, 3) {
        Invoke-OpenSCAD "lid preset $p" @(
            "-o", "out\lid-preset-$p.stl",
            "-D", "dividerLayoutPreset=$p",
            "-D", "generateBoxBottom=false", "-D", "generateBoxTop=true",
            "-D", "generateLatches=false", "-D", "generateHandle=false",
            "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
            "Boxes\RuggedBoxCustomeDividersV1.0.scad") -Quiet
        Invoke-Check "out\lid-preset-$p.stl" -Rugged
    }
    Invoke-OpenSCAD "latch" @(
        "-o", "out\latch.stl",
        "-D", "generateBoxBottom=false", "-D", "generateBoxTop=false",
        "-D", "generateLatches=true", "-D", "generateHandle=false",
        "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad") -Quiet
    Invoke-Check "out\latch.stl"
    Invoke-OpenSCAD "handle" @(
        "-o", "out\handle.stl",
        "-D", "generateBoxBottom=false", "-D", "generateBoxTop=false",
        "-D", "generateLatches=false", "-D", "generateHandle=true", "-D", "numberOfLatches=2",
        "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad") -Quiet
    Invoke-Check "out\handle.stl"
    Invoke-OpenSCAD "closed preset 2" @(
        "-o", "out\closed-preset-2.stl",
        "-D", "viewBoxClosed=true", "-D", "dividerLayoutPreset=2",
        "-D", "generateLatches=false", "-D", "generateHandle=false",
        "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad") -Quiet
    & $py Boxes\tests\check_layout.py out\bottom-preset-0.stl out\bottom-preset-2.stl out\closed-preset-2.stl
    if ($LASTEXITCODE -ne 0) { throw "layout check failed" }
    & $py Boxes\tests\check_geometry.py out\bottom-preset-0.stl out\bottom-preset-2.stl out\lid-preset-0.stl out\lid-preset-2.stl out\latch.stl out\handle.stl out\closed-preset-2.stl
    if ($LASTEXITCODE -ne 0) { throw "geometry check failed" }

    Write-Host ""
    Write-Host "Summary:"
    foreach ($line in $summary) { Write-Host "  $line" }
    Write-Host "layout checks ok"
    Write-Host "geometry checks ok"
    Write-Host "render-presets ok"
}
catch {
    $err = $_
    $msg = $err.Exception.Message
    $pos = if ($err.InvocationInfo) { $err.InvocationInfo.PositionMessage } else { "" }
    $stack = if ($err.ScriptStackTrace) { $err.ScriptStackTrace } else { $err.Exception.StackTrace }
    $fqid = if ($err.FullyQualifiedErrorId) { $err.FullyQualifiedErrorId } else { "" }
    Write-Error @"
render-presets.ps1 stopped: $msg
${pos}
Script stack trace:
${stack}
${fqid}
"@
    exit 1
}
