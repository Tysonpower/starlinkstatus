$StarlinkFolder="C:\users\$env:USERNAME\documents\StarlinkScripts"

$env:Path ="$StarlinkFolder;$env:Path"
speedtest.exe -f json|out-file -FilePath $Starlinkfolder"\stoutput.json"
#$stresult= $(Get-Content $StarlinkFolder"\stoutput.json"|Convertfrom-Json)
#$stresult