$VERSION = '0.7w'
$StarlinkFolder="C:\users\$env:USERNAME\documents\StarlinkScripts"
$env:Path ="$StarlinkFolder;$env:Path"

function myhelp 
{
    "Usage: starlinkstatus.ps -k APIKEY"
    "-k | -key        API Key for starlinkstatus.space"
    "-s | -speedtest  Enable Speedtest Data, requires speedtest.net cli"
    "-d | -dishy      Enable Dishy Data, requires gprcurl"
    "-v | -verbose    More output"
    "-h | -help       Show this Message"
}

function pingservers
{
    $SERVERS=($(Invoke-WebRequest -Uri  'https://starlinkstatus.space/api/getservers' -Method GET).Content).Split(' ')
    $jsonstring='{'
    $cnt=$SERVERS.Count
    if ($v -eq $true) {Write-Information "Starting Ping Test. Servers: $cnt ...." -InformationAction Continue}
    Foreach ($server in $SERVERS)
    {
        $pingres=@($(ping $server)).Split([Environment]::NewLine)[-1].split()[-1]
        $pingres=$pingres.substring(0,$pingres.length-2)
        if ($v -eq $true) {Write-Information "ping to $server : $pingres" -InformationAction Continue}
        $jsonstring+="""$server"":$pingres ,"
              
    }
    $jsonstring=$jsonstring.substring(0,$jsonstring.length-1)
    return "$jsonstring}"
}

$argi=0
$speedtest=$false
$verbose=$false
$dishy=$false
$v=$false
$apikey=""

$parms=$args.split()
#$parms
while ($argi -lt $parms.length)
{
    switch($parms[$argi]){
    
        {@("-k","-key") -contains $_} {$apikey=$parms[$argi+1];$argi+=1}
        {@("-s","-speedtest") -contains $_}{$speedtest=$true}
        {@("-d","-dishy") -contains $_} {$dishy=$true}
        {@("-v","-verbose") -contains $_} {$v=$true}
        {@("-h","-help") -contains $_} {myhelp;exit}
        default {$parm=$parms[$argi];"unrecognized parameter $parm ignored"}
    }
    $argi+=1
}

if ($apikey.length -eq 0)
{
    "an API Key (-k) is a required parameter"
    exit
}

# Main Script _________________________________________________________________________

"Version: $VERSION"
Get-Date

if ($v -eq $true) {"API Key: $apikey"}
$APIURL="https://starlinkstatus.space/api/postresult"
$pingjsn=pingservers
$dishstatus='{}'
$dishcontext='{}'
if ($dishy=$true)
{
    Try 
    {
        $dishstatus=$(grpcurl -plaintext -emit-defaults -d '{\"getStatus\":{}}' 192.168.100.1:9200 SpaceX.API.Device.Device/Handle)
    }
    Catch
    {
        if ($_.Exception.Message.substring(0,7) -eq "The term")
            {Write-Warning "grpcurl not found. Exiting"; exit}
         write-error $_.ExceptionMessage
         exit  
    }

    Try
    {
        #$dishcontext=$(grpcurl -plaintext -emit-defaults -d '{\"dishGetContext\":{}}' 192.168.100.1:9200 SpaceX.API.Device.Device/Handle)
    }
    Catch
    {write-warning: "Continuing without DishContext"}
}
$geojsn=$(Invoke-WebRequest -Uri  'http://ip-api.com/json' -Method GET).Content
if ($speedtest=$true)
{
    Try{speedtest -V|Out-Null } Catch {Write-Warning "speedtest cli not found. Exiting," ; exit} 
    $sd=$(speedtest -f json)
}

$jsondata="{""key"":""$apikey"",""geo"":$geojsn,""ping"":$pingjsn,""speed"":$sd,""dishyStatus"":$dishstatus,""dishyContext"":$dishContext}"
if ($v -eq $true)
    {$jsondata|ConvertFrom-Json|ConvertTo-Json}
#$jsondata|ConvertFrom-Json|ConvertTo-Json
$(Invoke-WebRequest -Uri $APIURL -Method POST -Body $jsondata -ContentType "application/json; charset=utf-8").content

