# Kubernetes Deployments

There are two methods supplied here, the preferred method would be a cronjob. 

To assist with ensuring you don't consume all of your data plan, I have created two Kubernetes CronJobs:

- Every 15mins, 15,30,45 without doing a speedtest
- On the hour with a speedtest

Before you deploy you will need to update the secret value with your apikey you received from [https://starlinkstatus.space/](https://starlinkstatus.space/) in secrets.yaml

To create apikey use `echo -n "APIKEY" | base64` and copy and replace the output in secrets.yaml

If you want to only run the container constanty and it will do a speedtest every 15min (not recommended), update the replicas in `deployment/deployment.yaml` from 0 to 1.

To change any of the scripts functionality update the following variables in config.yaml in the respective folders. In **cronjob** folder the `config.yaml` has a definition to run every 2 hours, (e.g midnight, 2am, 4am etc etc ....). In **deployment** folder the `config.yaml` is used to define the environment variables. 

      - APIKEY=YOURAPIKEY           # Replace YOURAPIKEY e.g APIKEY=a1b2c3d4e5f6
      - SCHEDULE=900                # 900 secs = 15min, so when CRONJOB=false this will run every 15 min
      - DISHY=false                 # Set to true to get Dish Stats
      - SPEEDTEST=false             # Set to true to run Speedtests
      - debug=true                  # Set to true to show debug data
      - CRONJOB=false               # Set to true to run when triggered with CronJob


## Running in Kubernetes 

### Secret
> Required for either the CronJob or Deployment

`kubectl apply -f secrets.yaml`

### Running as a Cronjob

`kubectl apply -f cronjob/`

### Running as a Deployment

`kubectl apply -f deployment/`