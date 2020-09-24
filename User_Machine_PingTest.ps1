#Start-Transcript
################# Import Module #####################
$moduleArm = Get-Module AzureRm
if (!$moduleArm)
{
    $Error.Clear()
    Import-Module -Name AzureRm -ErrorAction SilentlyContinue
    if ($Error.Count -ne 0)
    {
        Install-Module -Name AzureRm -AllowClobber -Force
        Import-Module -Name AzureRm -ErrorAction SilentlyContinue
    }
}
################# End Import Module #################
################# Connection String #####################
$MID = $Env:Computername
$connectionString = 'DefaultEndpointsProtocol=https;AccountName=atpsecuritycenter;AccountKey=S83lAOzTJ//s1k0BnQ59iIIKDZzQ2LPDeyhPI2gmCY56tu1ArF0l7TVVpWYLx2WH+7MJ0rLi9Ws6FhwCeGa90Q==;EndpointSuffix=core.windows.net'
$containerName = "user-machine-ping-test"

$date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'Pacific Standard Time').ToString("MM-dd-yyyy_hh-mm")
################# End Connection String #####################
while ($MID.Length -eq 0)
{
    $MID = Read-Host "Please enter your MID"
}

$json1 = Test-Connection -ComputerName bing.com -Count 1000 | Select @{l = 'MID'; e={ $MID }},  @{l = 'PingTimeGen'; e={ [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( `
    	 (Get-Date), 'Pacific Standard Time').ToString("MM/dd/yyyy hh:mm:ss.ff") }}, PSComputerName, IPV4Address,IPV6Address, buffersize, ResponseTime | Convertto-Json
$file = "$($env:USERPROFILE)\Desktop\$Mid"+"_$date"+ "_TestConnectionResults.json"
$json1 | Out-File $file -Force
if($json1)
{
    $clientContext = New-AzureStorageContext -ConnectionString $connectionString
    Get-Item -Path $file | Set-AzureStorageBlobContent -Context $clientContext -Container $containerName
    Remove-Item -Path $file
}
#Stop-Transcript