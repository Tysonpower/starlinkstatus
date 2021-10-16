$IsAdmin=[Security.Principal.WindowsIdentity]::GetCurrent()
If ((New-Object Security.Principal.WindowsPrincipal $IsAdmin).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE){
    Read-Host -Prompt "You must execute this program As Administrator. Press Enter to exit."
    Exit
}schtasks /delete /tn starlinkstatus /f
Read-Host -prompt "Your Starlink Staus client has been unscheduled and will not run again until you execute schedulestarlinkstatus.exe in this folder As Administrator. Press enter to continue."