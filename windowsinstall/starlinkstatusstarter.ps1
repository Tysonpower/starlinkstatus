$StarlinkFolder="C:\users\$env:USERNAME\documents\StarlinkScripts"
$key=Get-Content $Starlinkfolder\thekey.txt
Invoke-Expression("$StarlinkFolder\Starlinkstatus_client.ps1  -s  -k  $key -d") | Out-File -FilePath $StarlinkFolder\log.txt
#Get-Date|Out-File -FilePath c:\Users\tevsl\Documents\PSDev\glop.txt

