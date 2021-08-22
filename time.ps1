param(
    [string]
    $Command
)

$start = Get-Date;
Invoke-Expression "$Command";
$end = Get-Date;
Write-Host -ForegroundColor Blue ('Total Runtime: ' + ($end - $start).TotalSeconds);
