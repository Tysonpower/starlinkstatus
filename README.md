# Starlink Statuspage

https://starlinkstatus.space/

Current version of the .sh Script is 1.2 - please update if you have any issues.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/C0C67UDEB)

### About

Starlinkstatus.space is a Website that offers Statistics of Starlink Users around the World. All Data is Collected by Users that are interested in the Performance of Starlink and run either a Speedtest every 15 Minutes (or similar) over a Bash Script or use our Custom Ookla Speedtest on the Website when they want to do a Speedtest anyway.

## How to Contribute Data

To Contribute Data you need a Computer (Linux, Mac or Windows) that is connected to your Starlink Connection (at best with Access to Dishy).
Perfect is a RaspberryPI 3B+ or newer with a Wired Connection, this Tutorial is based on a fresh installed RaspberryPi.

Windows Users should use the Automatic Installer by @tevslin:
https://github.com/Tysonpower/starlinkstatus/blob/main/windowsinstall/NativeWindowsREADME.md

If you want to use WSL2 you need to follow Microsofts WSL2 installation and continue on the WSL2 Ubuntu console afterwards.
https://docs.microsoft.com/en-us/windows/wsl/install

### Register a Account

Go to https://starlinkstatus.space and Register a Account by entering a Valid Email, a Username of your Choice as well as a Password you want to use and Click "Join Us". 
After a few Minutes you should get an Email with a Link to verify your Account, maybe you need to have a look in your SPAM Folder as well.
When you clicked the Link you should see a MEssage that you verified your Email successfully, if so you get a Email with your Personal API key in the next Minutes.

### Install Prerequisite Software

#### Speedtest CLI

The Client Script uses Speedtest CLI by Ookla to make Speedtests and Collect the Data if enabled.
If you already have a 3rd Party Speedtest cli installed makes sure to remove it first!
See ooklas tutorial for your Platform: https://www.speedtest.net/de/apps/cli

Use these Commands when you use a RaspberryPi:
```
wget https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-armhf-linux.tgz
tar zxvf ookla-speedtest-1.0.0-armhf-linux.tgz
sudo cp speedtest /usr/bin/speedtest
speedtest --accept-license
```
After this "speedtest -V" should show you the Installed Version of Speedtest by Ookla.

#### gRPCUrl

gRPCUrl is used to Communicate with Dishy and Collect Data from it if enabled.
Please follow the Instructions to install the GO SDK from Google first: https://golang.org/doc/install
```
go get github.com/fullstorydev/grpcurl/...
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
sudo cp ./go/bin/grpcurl /usr/bin
```
After this "grpcurl version" should show you the Installed Version of gRPCurl.

### Install the Client

Download Our Client Script (starlinkstatus_client.sh) that collects Data and sends it to our Servers, it allows for the following flags:

* -s    Enable Speedtest (needs speedtest cli by Ookla)
* -d    Enable Dishy Data (needs gRPCurl)
* -w    Use WSL1 mode for old wsl installations on Windows

Note: Since new Dishy Firmware Blocks some APIs a "Permission Denied" Error can be seen in the Log when -d is used, as long as it says "Saved" at the end of the Output all is fine.

## Linux/Mac
It is run by a cronjob on a regular basis, follow the Comamnds below after Download.
Replace ~path/to/ with the path you saved the Script to and YOURAPIKEY with the Key you got for your Dishy after Sign Up.
This example will run the Script including a Speedtest and Data from yur Dishy every 15 Minutes.
```
chmod +x starlinkstatus_client.sh
crontab -e
*/15 * * * * ~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d
```

## Windows
To run the script every 15min in WSL on Windows you open the "task scheduler" and create a new task.
- Add a trigger on system start, repeat every 15min for an unlimited time
- Add a Action to start a program, enter the path to wsl.exe (C:\Windows\System32\wsl.exe) and add the argument `~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d`

Save the task, if you like you can test it by selecting it and clicking the run task button to the right in the task scheduler.
