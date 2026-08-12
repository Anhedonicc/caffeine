# caffeine.ps1 — keep your computer awake while this terminal is open.
# Windows only. Uses SetThreadExecutionState via P/Invoke.

$ErrorActionPreference = "Stop"

$sig = @"
using System;
using System.Runtime.InteropServices;
public static class Caffeine {
    [FlagsAttribute]
    public enum EXECUTION_STATE : uint {
        ES_AWAYMODE_REQUIRED = 0x00000040,
        ES_CONTINUOUS        = 0x80000000,
        ES_DISPLAY_REQUIRED  = 0x00000002,
        ES_SYSTEM_REQUIRED   = 0x00000001
    }
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);
}
"@

Add-Type -TypeDefinition $sig -Language CSharp | Out-Null

function Set-Awake {
    param([bool]$On)
    if ($On) {
        $flags = [Caffeine+EXECUTION_STATE]::ES_CONTINUOUS -bor `
                 [Caffeine+EXECUTION_STATE]::ES_SYSTEM_REQUIRED -bor `
                 [Caffeine+EXECUTION_STATE]::ES_DISPLAY_REQUIRED
    } else {
        $flags = [Caffeine+EXECUTION_STATE]::ES_CONTINUOUS
    }
    [void][Caffeine]::SetThreadExecutionState($flags)
}

function Format-Elapsed {
    param([int]$Seconds)
    $h = [math]::Floor($Seconds / 3600)
    $m = [math]::Floor(($Seconds % 3600) / 60)
    $s = $Seconds % 60
    return "{0}h {1}m {2}s" -f $h, $m, $s
}

Set-Awake -On $true

$start = Get-Date

try {
    while ($true) {
        $elapsed = [int]((Get-Date) - $start).TotalSeconds
        $line = "`rcaffeine  {0}  [Ctrl+C] to stop.   " -f (Format-Elapsed $elapsed)
        [Console]::Write($line)
        Start-Sleep -Seconds 1
    }
}
finally {
    Set-Awake -On $false
    [Console]::WriteLine()
}
