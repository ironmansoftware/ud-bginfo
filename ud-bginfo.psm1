function New-UDProgressMetric {
    param($Total, $Value, $Metric, $Label, [Switch]$HighIsGood)

    $Percent = [Math]::Round(($Value / $Total) * 100)
    New-UDElement -Tag "h5" -Content { $Label }

    New-UDElement -Tag "div" -Attributes @{ className = "row" } -Content {
        New-UDElement -Tag "span" -Attributes @{ className = "grey-text lighten-1" } -Content { "$Percent% - $($Value.ToString('N')) of $($Total.ToString('N')) $Metric" }
    } 

    if ($HighIsGood) {
        if ($Percent -lt 20) {
            $Color = 'red'
        }
        elseif ($Percent -gt 25 -and $Percent -lt 75) {
            $Color = 'yellow'
        } else {
            $Color = 'green'
        }
    
    } else {
        if ($Percent -lt 50) {
            $Color = 'green'
        }
        elseif ($Percent -gt 50 -and $Percent -lt 75) {
            $Color = 'yellow'
        } else {
            $Color = 'red'
        }
    
    }


    New-UDElement -Tag "div" -Attributes @{ className = 'progress grey' } -Content {
        New-UDElement -Tag "div" -Attributes @{ className = "determinate $color"; style = @{ width = "$Percent%"} }
    }    
}

function New-UDProgress {
    param($Percent, $Label)

    New-UDElement -Tag "h5" -Content { $Label }

    if ($Percent -lt 50) {
        $Color = 'green'
    }
    elseif ($Percent -gt 50 -and $Percent -lt 75) {
        $Color = 'yellow'
    } else {
        $Color = 'red'
    }

    New-UDElement -Tag "div" -Attributes @{ className = "row" } -Content {
        New-UDElement -Tag "span" -Attributes @{ className = "grey-text lighten-1" } -Content { "$Percent%" }
    } 

    New-UDElement -Tag "div" -Attributes @{ className = 'progress grey' } -Content {
        New-UDElement -Tag "div" -Attributes @{ className = "determinate $color"; style = @{ width = "$Percent%"} }
    }    
}

function ConvertTo-Fahrenheit {
    param($Value)

    (($value /10 -273.15) *1.8 +32)
}

function New-HardwareCard {
    $CPU = Get-WMIObject -Class Win32_Processor
    $drives = Get-WMIObject -Class win32_diskdrive


    New-UDCard -Title "Hardware" -Content {
        New-UDLayout -Columns 1 -Content {
            New-UDElement -Tag "div" -Content {
                "  CPU: $($CPU.Name)"
            }
            foreach($drive in $drives) {
                New-UDElement -Tag "div" -Content {
                    "  Drive: $($drive.caption)"
                }
            }
        }
    }
}

function New-OverviewCard {
    $OS = Get-WMIObject -Class Win32_OperatingSystem
    
    
    New-UDCard -Title "$Env:ComputerName Overview" -Content {
        New-UDLayout -Columns 1 -Content {
            New-UDElement -Tag "div" -Content {
                "  Boot Time: $($OS.ConvertToDateTime($OS.LastBootupTime))"
            }
            New-UDElement -Tag "div" -Content {
                "  OS: $($OS.Caption)"
            }
            New-UDElement -Tag "div" -Content {
                "  Logon Server: $Env:LOGONSERVER"
            }
            New-UDElement -Tag "div" -Content {
                "  User Domain: $Env:USERDOMAIN"
            }
            New-UDElement -Tag "div" -Content {
                "  Username: $Env:USERNAME"
            }
        }
    }
}

function New-NetworkCard {
    $EnabledAdapters = (Get-wmiObject Win32_networkAdapterConfiguration | ?{$_.IPEnabled})
    $DefaultGateway = $EnabledAdapters.DefaultIPGateway | Where-Object { -not [String]::IsNullOrEmpty($_)}
    $DHCPServer = $EnabledAdapters.DHCPServer | Where-Object { -not [String]::IsNullOrEmpty($_)}
    $IPAddress = $EnabledAdapters.IPAddress | Where-Object { -not [String]::IsNullOrEmpty($_)}
    $DNSServer = $EnabledAdapters.DNSServerSearchOrder | Where-Object { -not [String]::IsNullOrEmpty($_)}

    New-UDCard -Title "Network" -Content {
        New-UDLayout -Columns 1 -Content {
            New-UDElement -Tag "div" -Content {
                $IPAddress = [String]::Join(', ', $IPAddress)
                "  IP Address: $IPAddress "
            }
            New-UDElement -Tag "div" -Content {
                $DefaultGateway = [String]::Join(', ', $DefaultGateway)
                "  Default Gateway: $DefaultGateway"
            }
            New-UDElement -Tag "div" -Content {
                "  DHCP Server: $DHCPServer"
            }
            New-UDElement -Tag "div" -Content {
                $DNSServer = [String]::Join(', ', $DNSServer)
                "  DNS Server: $DNSServer"
            }
        }
    }
}

function New-StorageCard {
    $Disks = Get-WMIObject -Class Win32_LogicalDisk

    New-UDCard -Title 'Storage' -Content {
        foreach($disk in $disks) {
            New-UDElement -Tag "row" -Content {
                New-UDProgressMetric -Value ($Disk.FreeSpace /1GB) -Total ($Disk.Size / 1GB) -Metric "GBs" -Label "$($Disk.DeviceID) - Free Space" -HighIsGood
            }
        }
    }
}

function New-Resource {
    $OperatingSystem = Get-WMIObject -Class Win32_OperatingSystem
    $CPU = Get-WMIObject -Class Win32_Processor
    

    New-UDCard -Title "Host" -Content {
        New-UDElement -tag "h4" -Content {
            "System Information"
        }
        New-UDElement -tag "div" -Attributes @{ className = "row"} -Content {
            New-UDElement -Tag "i" -Attributes @{ className = "fa fa-windows"}
            "    "
            $OperatingSystem.Caption 
        }
        New-UDElement -Tag "div" -Attributes @{ className = "row"} -Content {
            New-UDProgressMetric -Value ($OperatingSystem.FreePhysicalMemory /1MB) -Total ($OperatingSystem.TotalVisibleMemorySize / 1MB) -Metric "GBs" -Label "Memory"
        }
        New-UDElement -Tag "div" -Attributes @{ className = "row"} -Content {
            New-UDProgress -Percent $CPU.LoadPercentage -Label "CPU Usage"
        }

        
    }
}
