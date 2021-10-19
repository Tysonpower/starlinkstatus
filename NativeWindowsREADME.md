WARNING   WARNING WARNING This is beta software, tested on very few machines and bound to have some problems. Feedback is appreciated but all use is at your own risk

# Starlink-Statuspage-Client

Almost self-installing Windows client to upload Starlink performance data to [Starlink Statuspage](https://Starlinkstatus.space).

The developers of Starlink Statuspage, \Tysonpower and \puchol, describe it this way:

"Starlinkstatus.space is a Website that offers Statistics of Starlink Users around the World. All Data is Collected by Users that are interested in the Performance of Starlink....".

They offer a client for contributing data at https://github.com/Tysonpower/starlinkstatus for Linux, Macs, and Windows Linux Subsystem (WSL) Version 2. If you are running Linux, a Mac, or are comfortable wih WLS2, you should get the client and install instructions from that repository.

The purpose of the alternative client offered here is make it possible for more people to contribute data to Starlink Statuspage and help make the site even more useful at even more locations, especially as Starlink itself emerges from Beta into full production. This client is for  is for Windows 10 users who don't want to or can't run WSL 2 and those for whom installing a WSL client may be too time consuming or technically demanding.

Neither Starlink Statuspage nor I have any official connection with Starlink nor with eachother.

## Prerequisites

This client requires a PC running Windows 10, an installed Starlink dish (dishy), and an API key from Starlink. The API Key is free, see the instructions under [Register an Account]( https://github.com/Tysonpower/starlinkstatus) for registering. You will be asked for the API key during installation of this client.

You must either be using the Starlink router or set up port-forwarding in your own router such that requests to 192.168.100.1:9200 are port-forwarded to the Starlink modem.

## Installation Instructions

1. Download and save the install script by right clicking [here](https://github.com/tevslin/starlinkstatus/raw/main/Install.ps1) and choosing `Save link as....`.
2. In the Windows command bar, start to type "Powershell".
3. In the popup, select "Powershell" (not Powershell IDE) and `Run as Administrator`. You must have administrative privileges on the machine you are using.
4. In the Powershell window, type `powershell.exe -noprofile -executionpolicy bypass -file <full path to where you downloaded the install script>/install.ps1`. By default, most Windows PC do not allow scripts to be run. This restriction is bypassed **for these scripts only** when you use 'executionpolicy bypass'. Hint: if you're not sure where you saved the install script or the proper full path to it, type `install.ps1` into the Windows command bar and choose the `Copy full path` option.
5. Respond to prompts during install. You may be asked to accept the license agreement for Okla Speedtest which is installed as part of this process. At this point you will find the license agreement in \documents\StarlinkScripts. You will be asked for your API key and will be promtped to connect through Starlink if you are connected through some other ISP at the start of the install.
6. If the install succeeds, your client will be registered with Windows Task Scheduler to run every 15 minutes. See below for how to unschedule or reschedule it.
7. The install can always be rerun if you've had to abandon it before completing.

**Install Notes** There should not be any red messages in the Powershell window during installation. One possible source of errors is that some virus blockers may be suspicious of the Powershell scripts being downloaded and block them. There is a reported conflict with Kaspersky. If this is the case, it will be necssary to turn off the virus checker temporarily in order to install. Please report any such conflicts [here](https://github.com/tevslin/starlinkstatus/issues).

## Operating Instructions

### unscheduling the client
right click "unschedulestarlinkstatus.exe" in the \StarlinksScripts folder and run it `As Administrator'.

### rescheduling the client
right click "schedulestarlinkstatus.exe" in the \StarlinkScripts folder and run it `As Administrator'.

## Uninstalling

1. delete "install.ps1" from whereever you saved it to if not done already.
2. double click "unschedulestarlinkstatus.exe" in the \StarlinkScripts folder.
3. delete the \Starlinks folder.

## Trouble Reporting

Please click [here](https://github.com/tevslin/starlinkstatus/issues) to report any issues and be as specific as possible about how to reproduce. Screenshots appreciated

## What Install.ps1 does

1. Builds a folder called \Starlink scripts in your \documents folder.
2. Downloads needed scripts and exes from this repository to the folder.
3. Downloads the Windows CLI for Ookla's speedtest to the folder.
4. Tests the CLI and gives you a chance to accept Ookla license terms.
5. Determines from speedtest whether you are actually connected throuh Starlink and gives you a chance to change your connection if not.
6. Downloads grpcurl to the folder for communicating with dishy.
7. Requests and saves your API key (unencrypted).
8. Runs the client to test end to end including the API key you provided.
9. Gives you a chance to correct the API key if you typed it in wrong.
10. Schedules the client with Windows Task Scheduler.






