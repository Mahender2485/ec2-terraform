How to configure webhooks for auto trigger of job from github
=============================================================
1) select the repo that needs auto trigger
2) click on settings
3) select webhook on the left pane
4) add webhook
5) add your jenkins url in the payload url
	- If you are running your jenkins in docker container
	- Make sure the port forwarding is enabled on 8080
	- login into ngrok(create an account if you don't have already)
	- get the auth token
	- login in to the linux server/vm where docker container is running(jenkins)
	- ngrok config add-authtoken <token copied from above step>
	- ngrok http 8080
	- copy the url from the screen and open ngrok running
6) updatet the payload url accordingly (https://ngrokurl/github-webhook/
7) Content type: application/json
8) Events: Just the push event
9) Active: Enabled

Jenkins Configuration
=======================

1) Open pipeline
2) Click Configure
3) Under Build Triggers, check Github hook trigger for GITScm polling
4) Click Save
