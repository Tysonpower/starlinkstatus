function CompileIfChanged{
    param(
    [string]$filen
    )

$f1=$gitfolder+"\"+$filen+".ps1"

$f2=$gitfolder+"\"+$filen+".exe"

$dateA =(Get-Item $f1).LastWriteTime
$dateB= (Get-Item $f2).LastWriteTime


if ($dateA -ge $dateB) {
  invoke-expression "invoke-ps2exe -inputfile '$f1' -outputfile '$f2'"
  write-host "$filen  compiled."
  return $true
  }
else {
  return $false
  }

}
$cexe=$false #asume not compressing exe
$gitFolder="C:\users\$env:USERNAME\documents\github\starlinkstatus"

$cexe=$cexe -or $(CompileIfChanged("schedulestarlinkstatus"))
$cexe=$cexe -or $(CompileIfChanged("unschedulestarlinkstatus"))
$cexe=$cexe -or $(CompileIfChanged("starlinkprestart"))
if ($cexe){compress-archive -path $gitFolder\*starlink*.exe -DestinationPath $gitFolder\exes.zip -Force} #compress if any changed

