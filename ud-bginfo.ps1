Get-UDDashboard | Stop-UDDashboard

Import-Module (Join-Path $PSScriptRoot 'ud-bginfo.psm1') -Force

$Content =  {
    New-UDRow -Endpoint {
        New-UDColumn -Size 6 -Content {
            New-OverviewCard
        }
        New-UDColumn -Size 6 -Content {
            New-StorageCard
        } 
    } -AutoRefresh -RefreshInterval 60
    New-UDRow -Endpoint {
        New-UDColumn -Size 6 -Content {
            New-HardwareCard
        }
        New-UDColumn -Size 6 -Content {
            New-NetworkCard
        } 
    } -AutoRefresh -RefreshInterval 60
}

$EndpointInitialization = New-UDEndpointInitialization -Module "$PSScriptRoot\ud-bginfo.psm1"


$Dashboard = New-UDDashboard -Title "$env:ComputerName - BGINFO" -Content $Content -EndpointInitialization $EndpointInitialization

Start-UDDashboard -Port 10000 -Dashboard $Dashboard