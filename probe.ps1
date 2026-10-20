$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -ne 'Desktop' -or $PSVersionTable.PSVersion.Major -ne 5) { throw 'PowerShell Desktop 5.1 required' }
$target = Start-Process -FilePath (Join-Path $env:WINDIR 'System32\notepad.exe') -PassThru
try {
    Start-Sleep -Milliseconds 500
    $command = '[Console]::WriteLine((@{ bitness = [IntPtr]::Size * 8; path = (Get-Process -Id ' + $target.Id + ').Path } | ConvertTo-Json -Compress))'
    $results = @()
    foreach ($shellPath in @('System32\WindowsPowerShell\v1.0\powershell.exe', 'SysWOW64\WindowsPowerShell\v1.0\powershell.exe')) {
        $actualShell = Join-Path $env:WINDIR $shellPath
        $json = & $actualShell -NoProfile -ExecutionPolicy Bypass -Command $command
        if ($LASTEXITCODE -ne 0) { throw 'Process path probe failed' }
        $results += ($json | ConvertFrom-Json)
    }
    New-Item -ItemType Directory -Force evidence | Out-Null
    @{ powershellVersion = $PSVersionTable.PSVersion.ToString(); osVersion = [Environment]::OSVersion.Version.ToString(); probes = $results } | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 evidence\architecture-probe.json
    $results | Format-Table | Out-String | Write-Host
} finally {
    $target.Refresh()
    if (-not $target.HasExited) { $target.Kill(); $target.WaitForExit(5000) | Out-Null }
}
