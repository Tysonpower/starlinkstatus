$StarlinkFolder="C:\users\$env:USERNAME\documents\StarlinkScripts"
$key=Get-Content $Starlinkfolder\thekey.txt
powershell.exe -noprofile -executionpolicy bypass -file "$StarlinkFolder\Starlinkstatusstarter.ps1" 
