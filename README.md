# Starlink Statuspage

https://starlinkstatus.space/

### About

Starlinkstatus.space is a Website that offers Statistics of Starlink Users around the World. All Data is Collected by Users that are interested in the Performance of Starlink and run either a Speedtest every 15 Minutes (or similar) over a Bash Script or use our Custom Ookla Speedtest on the Website when they want to do a Speedtest anyway.


### Repo Structure

* client - Bash Script that runs Ping and Speedtest on Stations to provide Data on a continious interval
* frontend - The Main UI of the Site, feel free to correct Spelling etc. or add new Features
* backend - Includes the API that feeds Data to the UI, not sure how much will be made Public of it here


## How to Contribute Data

To Contribute Data you need a Linux Maschine that is connected to your Starlink Connection (at best with Access to Dishy).
Perfect is a RaspberryPI 3B+ or newer with a Wired Connection, this Tutorial is based on a fresh installed RaspberryPi.

### Register a Account

Go to https://starlinkstatus.space and Register a Account by entering a Valid Email, a Username of your Choice as well as a Password you want to use and Click "Join Us". 
After a few Minutes you should get an Email with a Link to verify your Account, maybe you need to have a look in your SPAM Folder as well.
When you clicked the Link you should see a MEssage that you verified your Email successfully, if so you get a Email with your Personal API key in the next Minutes.

### Install Prerequisite Software

#### Speedtest CLI

The Client Script uses Speedtest CLI by Ookla to make Speedtests and Collect the Data if enabled.
If you already have a 3rd Party Speedtest cli installed makes sure to remove it first!
```
wget https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-armhf-linux.tgz
tar zxvf ookla-speedtest-1.0.0-armhf-linux.tgz
sudo cp speedtest /usr/bin/speedtest
```
After this "speedtest -V" should show you the Installed Version of Speedtest by Ookla. 

#### gRPCUrl

gRPCUrl is used to Communicate with Dishy and Collect Data from it if enabled.
Please follow the Instructions to install the GO SDK from Google first: https://golang.org/doc/install
```
go get github.com/fullstorydev/grpcurl/...
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
sudo cp /go/bin/grpcurl /usr/bin
```
After this "grpcurl version" should show you the Installed Version of gRPCurl.

### Install the Client

Download Our Client Script (starlinkstatus_client.sh) that collects Data and sends it to our Servers, it allows for the following flags:

* -s    Enable Speedtest (needs speedtest cli by Ookla)
* -d    Enable Dishy Data (needs gRPCurl)

It is run by a cronjob on a regular basis, follow the Comamnds below after Download.
Replace ~path/to/ with the path you saved the Script to and YOURAPIKEY with the Key you got for your Dishy after Sign Up.
This example will run the Script including a Speedtest and Data from yur Dishy every 15 Minutes.
```
chmod +x starlinkstatus_client.sh
crontab -e
*/15 * * * * ~/path/to/starlinkstatus_client.sh -k 'YOURAPIKEY' -s -d
```
