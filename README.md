# Starlink Statuspage

https://starlinkstatus.space/

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/C0C67UDEB)

The current version of the .sh Script is 1.3 — please update if still us an older version.

## Upgrade to Version 1.3
When upgrading from version 1.2x to 1.3 you need to change your cron to only start the script on reboot. After Upgrading please restart your compute to activate the script with the new cron.

`@reboot ~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d`

If you used a different speedtest interval before, you now need to set it with the -i flag in seconds. 

`@reboot ~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d -i 300`

## WARNING
This will use quite a lot of traffic! If you are NOT on a unlimited plan you should increase the interval of the speedtests.
Each test can use up to ~500Mb of Data, so a test every 15min could use up to 48gb/Day!

### About

Starlinkstatus.space is a website that offers statistics from Starlink users worldwide. All data is collected by users that are interested in the performance of Starlink, and who run frequent speed tests as well as collect latency measurements with our script.

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
wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-armhf.tgz
tar zxvf ookla-speedtest-1.2.0-linux-armhf.tgz
sudo cp speedtest /usr/bin/speedtest
speedtest --accept-license --accept-gdpr
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

Download our Client Script (starlinkstatus_client.sh) which will collect latency measurements every 15 seconds and make a speedtest every 15 minutes.

The following flags are allowed:
```   
-k | --key        API Key for starlinkstatus.space
-s | --speedtest  Enable Speedtest Data, requires speedtest.net cli
-d | --dishy      Enable Dishy Data, requires gprcurl
-i | --interval   Interval for speedtest in seconds (default 15 min / 900s)
-o | --once       Run only once (simulates old version)
-h | --help       Show this Message
```

## Linux/Mac
The script is run by a cronjob on reboot; follow the commands below after the download to set it up.
Replace `~path/to/` with the script's location, and YOURAPIKEY with the key you recieved.
This example will run the script, including a Speedtest and data from your Dishy, every 15 minutes.
```
chmod +x starlinkstatus_client.sh
crontab -e
@reboot ~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d
```
### Data Saver / speedtest interval
This example will run speedtests every 8 hours / 28800 seconds (3 times in total per day), the latency measurements will continue as usual.
```
chmod +x starlinkstatus_client.sh
crontab -e
@reboot ~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d -i 28800
```
## Windows (not recommended)
To run the script every 15 minutes in WSL on Windows, open the "task scheduler" and create a new task.
- Add a trigger on system start, repeat every 15 minutes for an unlimited time
- Add a action to start a program, enter the path to wsl.exe (`C:\Windows\System32\wsl.exe`) and add the argument `~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d`

Save the task—you can test it by selecting it and clicking the "run task" button to the right of the task scheduler.
