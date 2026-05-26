param(
  [string]$ModulesRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) "modules"),

  [string]$TestFile = "tests\live.tftest.hcl",

  [string[]]$Module,

  [switch]$SkipInit,

  [switch]$NoColor
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
  throw "terraform was not found in PATH."
}

$resolvedModulesRoot = (Resolve-Path -LiteralPath $ModulesRoot).Path
$terraformTestFilter = $TestFile -replace "/", "\"

if ($Module -and $Module.Count -gt 0) {
  $modules = @(
    $Module |
      ForEach-Object { Get-Item -LiteralPath (Join-Path $resolvedModulesRoot $_) } |
      Where-Object { $_.PSIsContainer }
  )
}
else {
  $modules = @(Get-ChildItem -LiteralPath $resolvedModulesRoot -Directory | Sort-Object Name)
}

$modulesWithTests = @(
  $modules |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName $TestFile) } |
    Sort-Object Name
)

if ($modulesWithTests.Count -eq 0) {
  Write-Host "No modules found with $TestFile under $resolvedModulesRoot."
  exit 0
}

$results = New-Object System.Collections.Generic.List[object]
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($moduleInfo in $modulesWithTests) {
  $moduleTimer = [System.Diagnostics.Stopwatch]::StartNew()
  Write-Host ""
  Write-Host "============================================================" -ForegroundColor Cyan
  Write-Host "terraform test :: $($moduleInfo.Name)" -ForegroundColor Cyan
  Write-Host "Path: $($moduleInfo.FullName)"

  Push-Location -LiteralPath $moduleInfo.FullName
  try {
    $initExitCode = 0

    if (-not $SkipInit) {
      $initArgs = @("init", "-backend=false", "-input=false")
      if ($NoColor) {
        $initArgs += "-no-color"
      }

      & terraform @initArgs
      $initExitCode = $LASTEXITCODE
    }

    if ($initExitCode -ne 0) {
      $results.Add([pscustomobject]@{
        Module     = $moduleInfo.Name
        Status     = "InitFailed"
        PassedRuns = 0
        FailedRuns = 0
        ExitCode   = $initExitCode
        Seconds    = [math]::Round($moduleTimer.Elapsed.TotalSeconds, 2)
      })
      continue
    }

    $testArgs = @("test", "-filter=$terraformTestFilter")
    if ($NoColor) {
      $testArgs += "-no-color"
    }

    $testOutput = @(& terraform @testArgs 2>&1)
    $testExitCode = $LASTEXITCODE
    $testOutput | ForEach-Object { Write-Host $_ }

    $passedRuns = 0
    $failedRuns = 0
    $testSummaryLine = @($testOutput | Where-Object { $_ -match "(Success|Failure)! \d+ passed, \d+ failed" } | Select-Object -Last 1)
    if ($testSummaryLine.Count -gt 0 -and $testSummaryLine[0] -match "(\d+) passed, (\d+) failed") {
      $passedRuns = [int]$matches[1]
      $failedRuns = [int]$matches[2]
    }

    $results.Add([pscustomobject]@{
      Module     = $moduleInfo.Name
      Status     = if ($testExitCode -eq 0) { "Passed" } else { "Failed" }
      PassedRuns = $passedRuns
      FailedRuns = $failedRuns
      ExitCode   = $testExitCode
      Seconds    = [math]::Round($moduleTimer.Elapsed.TotalSeconds, 2)
    })
  }
  finally {
    Pop-Location
  }
}

$stopwatch.Stop()
$failures = @($results | Where-Object { $_.ExitCode -ne 0 })
$passedModules = @($results | Where-Object { $_.Status -eq "Passed" })
$failedModules = @($results | Where-Object { $_.Status -eq "Failed" })
$initFailedModules = @($results | Where-Object { $_.Status -eq "InitFailed" })
$totalPassedRuns = ($results | Measure-Object -Property PassedRuns -Sum).Sum
$totalFailedRuns = ($results | Measure-Object -Property FailedRuns -Sum).Sum

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Terraform module test summary" -ForegroundColor Cyan
$results | Format-Table -AutoSize
Write-Host ("Modules discovered: {0}" -f $modulesWithTests.Count)
Write-Host ("Modules passed:     {0}" -f $passedModules.Count)
Write-Host ("Modules failed:     {0}" -f $failedModules.Count)
Write-Host ("Init failed:        {0}" -f $initFailedModules.Count)
Write-Host ("Test runs passed:   {0}" -f $totalPassedRuns)
Write-Host ("Test runs failed:   {0}" -f $totalFailedRuns)
Write-Host ("Total duration: {0:n2}s" -f $stopwatch.Elapsed.TotalSeconds)

if ($failures.Count -gt 0) {
  Write-Host ""
  Write-Host ("Failed modules: {0}" -f (($failures | Select-Object -ExpandProperty Module) -join ", ")) -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "All module tests passed." -ForegroundColor Green
