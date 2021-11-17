$StarlinkFolder="C:\users\$env:USERNAME\documents\StarlinkScripts"

$IsAdmin=[Security.Principal.WindowsIdentity]::GetCurrent()
If ((New-Object Security.Principal.WindowsPrincipal $IsAdmin).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE){
    Read-Host -Prompt "You must execute this program As Administrator. Press Enter to exit."
    Exit
}

schtasks /create /sc minute /mo 15 /tn starlinkstatus /tr "$StarlinkFolder\starlinkprestart.exe" /f #create the task
$xml=(schtasks /query /xml /TN starlinkstatus) #get the xml for the task
$xml=$xml -replace "<Settings>","<Settings> <ExecutionTimeLimit>PT10M</ExecutionTimeLimit>" #add new parameters
$xml=$xml -replace "IgnoreNew","StopExisting" #and change the multiple instance action
$xml |Out-File temp.xml
schtasks /delete /tn starlinkstatus /f #delete the old instance
schtasks /Create /XML temp.xml /tn starlinkstatus /f #recreate with modified xml
del temp.xml
