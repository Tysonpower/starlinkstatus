# Starlink Statuspage

https://starlinkstatus.space/

The current version of the .sh Script is 1.2—please update if you have any issues.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/C0C67UDEB)

## WARNING
This will use quite a lot of traffic! With the new Datacaps you maybe want to increase the time between test to 1h or more!
Each test can use up to ~500Mb of Data, so a test every 15min could use up to 48gb/Day!

### About

Starlinkstatus.space is a website that offers statistics from Starlink users worldwide. All data is collected by users that are interested in the performance of Starlink, and who run frequent speed tests with a script, or use our custom Ookla speedtest.

## How to Contribute Data

To contribute data you need a computer (Linux, Mac, or Windows) that is connected to your Starlink network (at best with access to Dishy).
A good setup is a Raspberry PI 3B+ or newer with a wired connection; this tutorial is based on a fresh installation of one.
 
Windows Users should use the Automatic Installer by @tevslin:
https://github.com/Tysonpower/starlinkstatus/blob/main/windowsinstall/NativeWindowsREADME.md

If you want to use WSL2 you need to follow Microsofts WSL2 installation and continue on the WSL2 Ubuntu console afterwards.
https://docs.microsoft.com/en-us/windows/wsl/install

### Register a Account

Go to https://starlinkstatus.space and register an account by entering your email, username, and choosing a password. 
You'll recieve an email with instructions (you may need to check your Spam folder). After verifying, you'll get a second email with your API key.

### Install Prerequisite Software

#### Speedtest CLI

The Client script uses the Speedtest CLI by Ookla to run tests and optionally collect the data.
If you already have a Third-Party Speedtest CLI installed, remove it first.
See Ookla's tutorial for your platform: https://www.speedtest.net/de/apps/cli

For a Raspberry Pi, use the following:
```
wget https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-armhf-linux.tgz
tar zxvf ookla-speedtest-1.0.0-armhf-linux.tgz
sudo cp speedtest /usr/bin/speedtest
speedtest --accept-license
```
Run `speedtest -V` to check the version.

#### gRPCUrl

gRPCUrl is used to communicate with Dishy and optionally collect data.
Please install the GO SDK from Google first: https://golang.org/doc/install
```
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
sudo cp ./go/bin/grpcurl /usr/bin
```
Run `grpcurl version` to check the version.

### Install the Client

Download our Client Script (starlinkstatus_client.sh), which allows for the following flags:

* -s    Enable Speedtest (needs speedtest cli by Ookla)
* -d    Enable Dishy Data (needs gRPCurl)
* -w    Use WSL1 mode for old wsl installations on Windows

Note: Since new versions of the Dishy firmware block some APIs, a "Permission Denied" error can be seen in the log when -d is used. As long as it says "Saved" at the end of the output, all is fine.

## Linux/Mac
The script is run by a cronjob on a regular basis; follow the commands below after the download to set it up.
Replace `~path/to/` with the script's location, and YOURAPIKEY with the key you recieved.
This example will run the script, including a Speedtest and data from your Dishy, every 8 hours.
```
chmod +x starlinkstatus_client.sh
crontab -e
0 */8 * * * ~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d
```

## Windows
To run the script every 15 minutes in WSL on Windows, open the "task scheduler" and create a new task.
- Add a trigger on system start, repeat every 15 minutes for an unlimited time
- Add a action to start a program, enter the path to wsl.exe (`C:\Windows\System32\wsl.exe`) and add the argument `~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d`

Save the task—you can test it by selecting it and clicking the "run task" button to the right of the task scheduler.
