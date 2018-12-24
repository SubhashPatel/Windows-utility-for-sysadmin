#     This script checks the cpu usage of the define processor on the define computer
# Parameters:
#     1) strComputer (string)  - Hostname or IP address of the computer you want to monitor
#     2) strCpu (string)  - Either "cpu0" or "cpu2" or ...
#     3) numMaxCpuUsage (number)   - Limit, in %
#     4) strAltCredentials (string, optional) - Alternate credentials
# Usage:
#     Cpu.ps1 "" "" % " | <>"
# Sample:
#     Cpu.ps1 "localhost" "cpu0" 50
#################################################################################

param
(
[string]$strComputer,
[string]$strCpu,
[int]$numMaxCpuUsage,
[string]$strAltCredentials
)

cls

if( [string]$strComputer -eq "" -or [string]$strCpu -eq "" -or $numMaxCpuUsage -eq "" )
{
  $res = "UNCERTAIN: Invalid number of parameters - Usage: .\cpu.ps1   Max_Cpu_Percent [alt-credentials]"
  echo $res
  exit
}

# Create cpu object
if( [string]$strAltCredentials -eq ""  )
{
  $colCpu = Get-WmiObject -ComputerName $strComputer -Class Win32_Processor
}
else
{
  $objNmCredentials = new-object -comobject ActiveXperts.NMServerCredentials
  $strLogin = $objNmCredentials.GetLogin( $strAltCredentials )
  $strPassword = $objNmCredentials.GetPassword( $strAltCredentials )
  $strPasswordSecure =ConvertTo-SecureString -string $strPassword -AsPlainText -Force
  $objCredentials = new-object -typename System.Management.Automation.PSCredential $strLogin, $strPasswordSecure
  $colCpu = Get-WmiObject -ComputerName $strComputer -Class Win32_Processor -Credential $objCredentials 
}
if($colCpu -eq $null )
{
  $res = "UNCERTAIN: Unable to connect. Please make sure that PowerShell and WMI are both installed on the monitered system. Also check your credentials"
  echo $res
  exit
}

foreach($objCpu in $colCpu) 
{
  if( $objCpu.DeviceID -eq $strCpu )
  {
    if( $objCpu.LoadPercentage -gt $numMaxCpuUsage )
    {
      $res = "ERROR: CPU usage=[" + $objCpu.LoadPercentage + "%], maximum allowed=[" + $numMaxCpuUsage + "%] DATA:" + $objCpu.LoadPercentage
    }
    else
    {
      $res = "SUCCESS: CPU usage=[" + $objCpu.LoadPercentage + "%], maximum allowed=[" + $numMaxCpuUsage + "%] DATA:" + $objCpu.LoadPercentage
    }
    
    echo $res
    exit
  }
}

$res = "UNCERTAIN: Unable to query [" + $strCpu + "] on computer [" + $strComputer + "]"
echo $res
exit
