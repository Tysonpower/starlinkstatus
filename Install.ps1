function DownloadFromRepo{
    param(
    [string]$file
    )
    $githubfolder="https://raw.githubusercontent.com/tevslin/Starlink-Statuspage-Clients/main"
    Invoke-WebRequest -Uri $githubfolder/$file -OutFile $starlinkfolder\$file -ErrorAction Stop -Verbose
}

function SetUp-Folder{
    param([string]$FolderName)
    
    if ($(Test-Path $FolderName) -eq $true){
        "$FolderName already exists."
    }
    else{
          try {
            New-Item -Path $FolderName -ItemType Directory -ErrorAction Stop
             } 
           catch {
            throw "Could not create folder $FolderName!"
           }
        }
        
       

}


function ShowTextDialog{
    param(
    [string] $message,
    [string] $dialogtitle="",
    [string] $extrabutton="",
    [switch] $bigtext, #note this is incompatible with extrabutton
    [switch] $infoonly 
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $dialogtitle 
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #write-host "Extrabutton:$extrabutton"
    if ($extrabutton.length -gt 0){
        $xButton = New-Object System.Windows.Forms.Button
        $xButton.Location = New-Object System.Drawing.Point(15,82)
        $xButton.Size = New-Object System.Drawing.Size(270,23)
        $xButton.Text = $extrabutton
        $xButton.DialogResult = [System.Windows.Forms.DialogResult]::NO
        $form.Controls.Add($xButton)

    }

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    if ($bigtext -eq $true){$label.Size = New-Object System.Drawing.Size(260,70)}
    else {$label.Size = New-Object System.Drawing.Size(280,20)}
    $label.Text = $message
    $form.Controls.Add($label)

    if ($infoonly -eq $false){
        $textBox = New-Object System.Windows.Forms.TextBox   
        $textBox.Location = New-Object System.Drawing.Point(10,40)
        $textBox.Size = New-Object System.Drawing.Size(260,20)
        $form.Controls.Add($textBox)
        $form.Add_Shown({$textBox.Select()})
    }

    $form.Topmost = $true

    
    $result = $form.ShowDialog()

    if ($infonly -eq $true){
        $x=$result
    }
    elseif ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $x = $textBox.Text
    }
    elseif ($result -eq [System.Windows.Forms.DialogResult]::NO){
        $x='~~'
    }
    elseif ($result -eq [System.Windows.Forms.DialogResult]::CANCEL){
        Throw "Canceled by User, Rerun script to restart"
    }
    $x
}

function GetStatusPageKey{
    $keyfile=$Starlinkfolder+"\TheKey.txt"
    $key=""
    if ($(test-path $keyfile) -eq $true){ #*if there is a key file
        $key=Get-Content $keyfile -Erroraction Stop;
        write-host "API key found: $key"
    }
    else{
        while ($key.length -eq 0){
            $key=ShowTextDialog "Please enter your Starlink Statuspage API key" "API Key" "I don't have an API Key yet" 
            if ($key -eq '~~'){
                $key=""
                ShowTextDialog $messages.API "" "" -bigtext $true -infoonly $true
                Start-Process "https://starlinkstatus.space"
            }
        }       
        Out-File -InputObject $Key -FilePath $keyfile -Encoding string
        write-host "$key saved for future use"
        $key
    }
}
function GetZippedExe{
    param(
    [string]$exeURL
    )
    $zipname=$exeURL.split("/")[-1]
    $tempfile=$StarlinkFolder+"/temp.zip"
    Invoke-WebRequest -Uri $exeURL -Outfile $tempfile
    "$exeURL downloaded"
    expand-archive -path $tempfile -destinationpath $Starlinkfolder -force
    "$zipname unzipped"
    remove-item -path $tempfile
}
function GetLastNBLine{
#returns blank line if no nonblank lines
    param(
    [string[]]$thetext
    )
    $lines=@($thetext.split([Environment]::NewLine))
    $curline=-1 #start at the end
    while ($lines[$curline].length -eq 0){
        if ($curline -lt -$lines.length){break} #exit if no more lines
        $curline-=1
    }

    $lines[$curline]
}



Add-Type -AssemblyName System.Windows.Forms #get required builtins for dialog boxez
Add-Type -AssemblyName System.Drawing
$StarlinkFolder="C:\users\$env:USERNAME\documents\StarlinkScripts"


$IsAdmin=[Security.Principal.WindowsIdentity]::GetCurrent()
If ((New-Object Security.Principal.WindowsPrincipal $IsAdmin).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE){
    Read-Host -prompt "You must run Powershell As Administrator to execute Install. Press enter to continue."
    exit    
}
Setup-folder $starlinkfolder


#make sure everyone has access

$Acl = Get-ACL $starlinkfolder
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("everyone","FullControl","ContainerInherit,Objectinherit","none","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl $starlinkfolder $Acl

$env:Path ="$StarlinkFolder;$env:Path"
DownloadFromRepo messages.json
DownloadFromRepo Starlinkstatus_client.ps1
DownloadFromRepo starlinkstatusstarter.ps1

$messages= $(Get-Content $StarlinkFolder"\messages.json"|Convertfrom-Json)
unblock-file -path $Starlinkfolder\starlinkstatus_client.ps1
#unblock-file -path $Starlinkfolder\unschedulestarlinkstatus.ps1
GetZippedExe "https://github.com/tevslin/Starlink-Statuspage-Clients/raw/main/exes.zip"
GetZippedExe  "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
"testing speedtest..."
$msg=$messages.speedtest
ShowTextDialog $(invoke-expression "echo $msg") "" "" -bigtext $true -infoonly $true
start-process  -filepath speedtest.exe  -wait
"retesting speedtest..."
$isp=""
while ($isp -ne "Starlink"){
    $sd=$(speedtest.exe -f json|convertfrom-json)
    if ($sd.PSobject.Properties.match('isp').count -eq 0){ #if isp not specified
        "speedtest failure"
        $sd
        $msg=$messages.badspeedtest #must be speedtest failure
        ShowTextDialog $(invoke-expression "echo $msg") "" "" -bigtext $true -infoonly $true
    }
    else{
        $isp=$sd.ISP

        if ($isp -ne "Starlink"){
            $msg=$messages.notstarlink
            ShowTextDialog $(invoke-expression "echo $msg") "" "" -bigtext $true -infoonly $true
        }
    }
}

GetZippedEXe  "https://github.com/fullstorydev/grpcurl/releases/download/v1.8.2/grpcurl_1.8.2_windows_x86_64.zip"
$key=GetStatusPageKey
"testing Starlinkstatus client..."
$keyok=$false
while ($keyok -eq $false){

    start-process  -filepath starlinkprestart.exe -nonewwindow -wait
    $log=$(Get-Content $StarlinkFolder"\log.txt")
    $ll=GetLastNBLine($log)
    #$ll
    if ($ll -match "API Key OK"){
        "Test Succeeded"
        $keyok=$true
        #ll
    }
    elseif ($ll -match "Key not Valid"){
        $msg=$messages.invalidkey
        ShowTextDialog $(invoke-expression "echo $msg") "" "" -bigtext $true
        $ll
        "deleting bad key"
        del "$Starlinkfolder\TheKey.txt" 
        $key=GetStatusPageKey
    }
    else{
        $msg=$messages.unknownerror
        $log
        ShowTextDialog $(invoke-expression "echo $msg") "" "" -bigtext $true -infoonly $true
        exit
    }
}
$msg=$messages.scheduling
ShowTextDialog $(invoke-expression "echo $msg") "" "" -bigtext $true -infoonly $true

schedulestarlinkstatus.exe
ShowTextDialog "Install Succeeded!" "" "" -infoonly $true
    



