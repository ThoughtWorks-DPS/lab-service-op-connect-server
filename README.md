<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/EMPCPlatformStarterKitsImage.png" width=350/>
	</p>
  <h3>secrets automation Connect Server by 1password(c) </h3>
</div>
<br />

# ARCHIVED. As of April 2024 we are no longer maintaining this refernce code for using 1password Connect. 1password still does provide Connect Server support for customers who need or want to provide local (performant) cache response time for secrets access.

The 1password Secrets Automation Connect Server service is an option for serving 1password Vault values from a local cache service. This provides a highly performant option should direct cloud access using Service Accounts be insufficient.  

From the 1password website interface you can generate a unique credential file used by the datasync service to enble it to pull a continuously updated copy of the cloud-stored secrets into it's runtime memory. Then, via the API service, and using a long-lived token, also generated from the cloud interface, you can interact with those secrets.  

The 1password cli (`op`) can be used to access this API, and there are available SDKs for programmatic access.

This repository was previously used by TW EMPC NA to maintain a test and production instance of the service, and we continue to make this example available for past client or anyone interested in learning more about the automated, ECS-based management of 1password Connect servers.

These services for formerly available on:  

https://test.op.twdpw.io  
https://op.twdps.io  

# development

![basic architecture](https://github.com/ThoughtWorks-DPS/lab-service-op-connect-server/blob/main/doc/op-architecture.png)

Bootstrap-style pipeline:  

- Based on a fargate ecs deployment, alb front end, acm certificates
- terraform-cloud for state, circleci for pipeline
- assumes no secrets mgmt service, just circleci pipeline ENV vars (including base64 version of the 1password-credential.json)

When setting up a new instance, you must first create a vault in <your-team-name>.1password.com and then either connect it to an existing integration or define a new integration. Integrations will generate api-access tokens for the vault, and configuration.json files used by the ECS secrets server instance to communicate with 1password.com. After obtaining the new token and credentials.json add the token and a base64 version of credentials,json to the pipeline ENV variables.  

Note: it can take a couple minutes for the new ecs tasks to come up and therefore the pipeline test can run prior to the services being available resulting in a test failure. Simply re-run from failed to get a successful test once the services are active. Introduce a delay to prevent the race-condition.
