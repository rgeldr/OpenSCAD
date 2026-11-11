# Windows PowerShell 5.1 and PowerShell 7. No ternary, &&, or .NET Core-only APIs.
$ErrorActionPreference = "Stop"
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSStyle.OutputRendering = "PlainText"
}
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

function ConvertTo-CommandLine([string[]]$Arguments) {
    # Start-Process on Windows PowerShell 5.1 joins an argument array without
    # quoting. Pass one already-quoted command line instead.
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($arg in $Arguments) {
        if ($null -eq $arg) { continue }
        if ($arg -match '[\s"]') {
            [void]$parts.Add('"' + ($arg -replace '"', '\"') + '"')
        } else {
            [void]$parts.Add($arg)
        }
    }
    return ($parts -join " ")
}

function Invoke-Native {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string[]]$ArgumentList
    )
    # On Windows PowerShell 5.1, $ErrorActionPreference Stop turns each native
    # stderr line into a terminating NativeCommandError. Python (unittest, the
    # checkers) writes progress to stderr even when the exit code is 0.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $raw = & $File @ArgumentList 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prev
    }
    $lines = New-Object System.Collections.Generic.List[string]
    $missing = $false
    foreach ($item in @($raw)) {
        if ($null -eq $item) { continue }
        if ($item -is [System.Management.Automation.ErrorRecord]) {
            if ($item.FullyQualifiedErrorId -like "CommandNotFoundException*") { $missing = $true }
            $text = $item.Exception.Message
            if ([string]::IsNullOrEmpty($text)) { $text = "$item" }
            [void]$lines.Add($text)
        } else {
            [void]$lines.Add("$item")
        }
    }
    if ($missing) { throw "failed to start $File" }
    if ($null -eq $code) { $code = 1 }
    return @{ Code = $code; Lines = $lines }
}

function Write-NativeLines($Lines) {
    if ($null -eq $Lines) { return }
    foreach ($line in $Lines) { Write-Host $line }
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

    # Do not use ProcessStartInfo's string-collection API: it is null on .NET Framework.
    $outDir = Join-Path $repo "out"
    $stdoutFile = Join-Path $outDir ("_openscad-out-{0}.log" -f [guid]::NewGuid().ToString())
    $stderrFile = Join-Path $outDir ("_openscad-err-{0}.log" -f [guid]::NewGuid().ToString())
    try {
        # Redirects force UseShellExecute off. CreateProcess cannot run a .cmd/.bat
        # (Windows reports "%1 is not a valid Win32 application"), so those fakes
        # go through cmd.exe. openscad.com is already a Win32 executable.
        $launchFile = $scad
        $launchArgs = $argList
        if ($scad -match '(?i)\.(cmd|bat)$') {
            $comspec = $env:ComSpec
            if ([string]::IsNullOrEmpty($comspec)) { $comspec = "cmd.exe" }
            $launchFile = $comspec
            $launchArgs = @("/d", "/c") + @($scad) + $argList
        }
        # Windows PowerShell 5.1 joins an argument array without quoting. PowerShell 7
        # passes the array through. A single prebuilt command line is one argument on PS 7.
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $startArgs = ConvertTo-CommandLine $launchArgs
        } else {
            $startArgs = $launchArgs
        }
        $proc = Start-Process -FilePath $launchFile -WorkingDirectory $repo `
            -ArgumentList $startArgs -PassThru -Wait -NoNewWindow `
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
        if ($null -eq $proc -or $null -eq $proc.ExitCode -or $proc.ExitCode -ne 0) {
            $exitCode = if ($proc) { $proc.ExitCode } else { "unknown" }
            throw "OpenSCAD failed ($Label): exit $exitCode`n$text"
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
        $pyCode = "import sys; sys.path.insert(0,'Boxes/tests'); from check_overhangs import load_triangles; print(len(load_triangles(r'$stl')))"
        $ran = Invoke-Native $py @("-c", $pyCode)
        Write-NativeLines $ran.Lines
        if ($ran.Code -ne 0) { throw "triangle count failed for $stl (exit $($ran.Code))" }
        $tris = ""
        foreach ($line in $ran.Lines) {
            if (-not [string]::IsNullOrWhiteSpace($line)) { $tris = $line.Trim() }
        }
        [void]$summary.Add("OK $Label ($stl, $tris triangles)")
    } else {
        [void]$summary.Add("OK $Label")
    }
    Write-Host "  $Label ... ok"
}

function Invoke-Check([string]$Stl, [switch]$Rugged) {
    if ($Rugged) {
        $script = "Boxes\tests\check_rugged_overhangs.py"
    } else {
        $script = "Boxes\tests\check_overhangs.py"
    }
    $ran = Invoke-Native $py @($script, "--report-only", $Stl)
    Write-NativeLines $ran.Lines
}

if ($env:RENDER_PRESETS_LIBRARY -eq "1") { return }

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

    $ran = Invoke-Native $py @("Boxes\tests\check_tool_files.py")
    Write-NativeLines $ran.Lines
    if ($ran.Code -ne 0) { throw "tool preflight failed (exit $($ran.Code))" }

    if (-not $env:RENDER_PRESETS_SKIP_UNITTEST) {
        $ran = Invoke-Native $py @("-m", "unittest", "discover", "-s", "Boxes/tests", "-p", "test_*.py")
        Write-NativeLines $ran.Lines
        if ($ran.Code -ne 0) { throw "unit tests failed (exit $($ran.Code))" }
    }

    $empty = "dividerRowHeights=[0,0,0,0,0,0]"
    $gridH = "dividerRowHeights=[1,1,1,0,0,0]"
    $gridW = "dividerRow1Widths=[1,1,1,1,0,0,0,0]"
    $off = @("-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false")
    $scadFile = @("Boxes\RuggedBoxCustomeDividersV1.0.scad")
    $bottomCommon = @("-D", "generateBoxTop=false", "-D", "generateLatches=false", "-D", "generateHandle=false")
    $lidCommon = @("-D", "generateBoxBottom=false", "-D", "generateBoxTop=true", "-D", "generateLatches=false", "-D", "generateHandle=false")

    Invoke-OpenSCAD "bottom empty" (@("-o", "out\bottom-empty.stl", "-D", $empty) + $bottomCommon + $off + $scadFile) -Quiet
    Invoke-Check "out\bottom-empty.stl" -Rugged
    Invoke-OpenSCAD "bottom screenshot" (@("-o", "out\bottom-screenshot.stl") + $bottomCommon + $off + $scadFile) -Quiet
    Invoke-Check "out\bottom-screenshot.stl" -Rugged
    Invoke-OpenSCAD "bottom 3x4" (@(
        "-o", "out\bottom-grid-3x4.stl",
        "-D", $gridH,
        "-D", $gridW,
        "-D", "dividerRow2Widths=[1,1,1,1,0,0,0,0]",
        "-D", "dividerRow3Widths=[1,1,1,1,0,0,0,0]") + $bottomCommon + $off + $scadFile) -Quiet
    Invoke-Check "out\bottom-grid-3x4.stl" -Rugged
    Invoke-OpenSCAD "lid empty" (@("-o", "out\lid-empty.stl", "-D", $empty) + $lidCommon + $off + $scadFile) -Quiet
    Invoke-Check "out\lid-empty.stl" -Rugged
    Invoke-OpenSCAD "lid screenshot" (@("-o", "out\lid-screenshot.stl") + $lidCommon + $off + $scadFile) -Quiet
    Invoke-Check "out\lid-screenshot.stl" -Rugged
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
    Invoke-OpenSCAD "closed screenshot" @(
        "-o", "out\closed-screenshot.stl",
        "-D", "viewBoxClosed=true",
        "-D", "generateLatches=false", "-D", "generateHandle=false",
        "-D", "generateGasket=false", "-D", "generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad") -Quiet
    $ran = Invoke-Native $py @("Boxes\tests\check_layout.py", "out\bottom-empty.stl", "out\bottom-screenshot.stl", "out\closed-screenshot.stl", "out\bottom-grid-3x4.stl")
    Write-NativeLines $ran.Lines
    if ($ran.Code -ne 0) { throw "layout check failed (exit $($ran.Code))" }
    $ran = Invoke-Native $py @(
        "Boxes\tests\check_geometry.py",
        "out\bottom-empty.stl", "out\bottom-screenshot.stl",
        "out\lid-empty.stl", "out\lid-screenshot.stl",
        "out\latch.stl", "out\handle.stl", "out\closed-screenshot.stl")
    Write-NativeLines $ran.Lines
    if ($ran.Code -ne 0) { throw "geometry check failed (exit $($ran.Code))" }

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
    $info = $err.InvocationInfo
    $file = ""
    $lineNo = ""
    $col = ""
    $source = ""
    $pos = ""
    if ($info) {
        $file = $info.ScriptName
        $lineNo = $info.ScriptLineNumber
        $col = $info.OffsetInLine
        if ($info.Line) { $source = $info.Line.Trim() }
        $pos = $info.PositionMessage
    }
    $stack = if ($err.ScriptStackTrace) { $err.ScriptStackTrace } else { $err.Exception.StackTrace }
    $report = @"
render-presets.ps1 stopped: $msg
Failing line ${lineNo}: ${source}
${file}:${lineNo} char:${col}
${pos}
Script stack trace:
${stack}
"@
    [Console]::Error.WriteLine($report)
    exit 1
}
