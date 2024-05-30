# StarlinkStatus with docker

Update docker-compose.yaml with the api received from [https://starlinkstatus.space/](https://starlinkstatus.space/).

```yaml docker-compose.yaml
version: '3.7'
services:
  starlinkstatus:
    build:
      context: .
    restart: always
    environment:
      - APIKEY=YOURAPIKEY           # Replace YOURAPIKEY e.g APIKEY=a1b2c3d4e5f6
      - SCHEDULE=900                # 900 secs = 15min, so when CRONJOB=false this will run every 15 min
      - DISHY=false                 # Set to true to get Dish Stats
      - SPEEDTEST=false             # Set to true to run Speedtests
      - debug=true                  # Set to true to show debug data
      - CRONJOB=false               # Set to true to run only once, especially as a scheduled job
```
Next run from your terminal

`docker compose up -d`

and you're ready :)
