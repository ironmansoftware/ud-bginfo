Get-UDDashboard | Stop-UDDashboard

Import-Module (Join-Path $PSScriptRoot 'ud-bginfo.psm1') -Force

$LoadModule = "Import-Module $PSScriptRoot\ud-bginfo.psm1"
$Content =  {
    New-UDRow -Columns {
        New-UDColumn -Size 6 -Content {
            New-OverviewCard
        }
        New-UDColumn -Size 6 -Content {
            New-StorageCard
        } 
    } -AutoRefresh -RefreshInterval 60
    New-UDRow -Columns {
        New-UDColumn -Size 6 -Content {
            New-HardwareCard
        }
        New-UDColumn -Size 6 -Content {
            New-NetworkCard
        } 
    } -AutoRefresh -RefreshInterval 60
}


$Dashboard = New-UDDashboard -Title "$env:ComputerName - BGINFO" -Content $Content -EndpointInitializationScript ([ScriptBlock]::Create($LoadModule))

Start-UDDashboard -Port 10000 -Dashboard $Dashboard