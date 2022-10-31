<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/EMPCPlatformStarterKitsImage.png" width=350/>
	</p>
  <h3>secrets automation server by 1password(c) </h3>
  <h1>lab-service-op-connect-server</h1>
  <a href="https://circleci.com/gh/ThoughtWorks-DPS/lab-service-op-connect-server/tree/main"><img src="https://circleci.com/gh/ThoughtWorks-DPS/lab-service-op-connect-server/tree/main.svg?style=shield&circle-token=5b62dee56a1690eca5a15b8a3ca555f098c306ad"> <a href="https://app.datadoghq.com/dashboard/zdb-as4-bc7/empc-op-connect?from_ts=1652802104947&to_ts=1652888504947&live=true"><img src="https://img.shields.io/badge/DataDog-Dashboard-lightgrey"></a>
</div>
<br />

## A bit of history and context

Secrethub has been used for a couple years in the EMPC Platform Starter Kit lab work. While it does have an excellent security model, more importantly:  

- It was a saas
- Supports machine account access using a secure, easily rotated token
- Customizable, RBAC service account access permissions
- CLI interface tuned for pipeline access (shell and template injection)
- All of which means nearly no overhead to maintain and no bootstrapping required for greenfield projects

1password purchased Secrethub and began the process of integrating Secrethub functionality into the 1password SaaS. This has been an interesting process and is not yet fully complete. There are some important differences in the initial releases. It isn't clear yet whether these differences are an intermediate step or part of a new product vision.  

Currently the 1password Secrets Automation workflow service is required for using the service in a pipeline in the desired manner.  

Our secrets are maintained in the "teams" 1password SaaS storage, however you cannot pull them directly from there using any form of machine authorization flow yet. Instead, you must deploy your own instance of a combination datasync and 1password api service.  

From the 1password website interface you can generate a unique credential file used by the datasync service to enble it to pull a continuously updated copy of the cloud-stored secrets into it's runtime memory. Then, via the API service, and using a long-lived token, also generated from the cloud interface, you can interact with those secrets.  

The 1password cli (`op`) can be used to access this API, and there are available SDKs for programmatic access. The cli is currently limited to the read functions outlined below. In order to write new or changed secret info, only direct use of the api is currently supported. We have create a 1Password Secrets Automation [Write utility](https://github.com/ThoughtWorks-DPS/opw) to support storing secrets created from within infrastructure pipelines.

This repository pipeline manages a test, production, and cohorts instance of the service, running in DPS-1 and tied to the empc-lab-test, empc-lab, and cohorts vaults in the twdps.1password.com teams vault space, resprectively.  

These are live services, available on:  

https://test.op.twdpw.io  
https://op.twdps.io  
https://cohorts.op.twdps.io  

Simply specify the twdps-core-lab-team context for the 1password connect server to be accessible within any circleci pipeline.  

Using this service (for read) provides the same functionality as secrethub. Both .env files or injections into templates are supported:  

The 1password/v2 command line tool must be installed.  

If you want to experiment directly with the API, you can genereate your own token from the website.  

**as bash parameter**
```
$ op -env-file=<filename> -- /bin/bash
```
**or for injection template**  
```
$ op inject -i <template filename> -o <result filename>
```

New secret path naming structure:  
```
op://<vault>/<item>/<field>
```

E.g., in a op.env file to use with bash parameter injection:  
```
export DOCKER_LOGIN=op://empc-lab/svc-github/username
export DOCKER_PASSWORD=op://empc-lab/svc-github/access-token
export SNYK_TOKEN=op://empc-lab/svc-snyk/api-token
export COSIGN_PASSWORD=op://empc-lab/svc-cosign/passphrase
```


# Note for usage of 1Password Connect in the DI Platform Starter Kit

It is unlikely when employing the DI Platform Starter Kit at a client site, that they will be utilizing 1Password as their automated secrets manager, even though more than 1000,000 major business have purchased 1password for their general, employee-facing password manager. Given their growing success this may change in the future. Our continued use of 1password is based on their stated commitment to continue to provide the high-value capabilities previously available in Secrethub. Should they change this roadmap we would likely adopt a different solution.

# development

![basic architecture](https://github.com/ThoughtWorks-DPS/lab-service-op-connect-server/blob/main/doc/op-architecture.png)

Bootstrap-style pipeline:  

- Based on a fargate ecs deployment, alb front end, acm certificates
- terraform-cloud for state
- assumes no secrets mgmt service, just circleci pipeline ENV vars (including base64 version of the 1password-credential.json)

When setting up a new instance, you must first create the new vault in twdps.1password.com and then either connect it to an existing integration or define a new integration. Integrations will generate api-access tokens for the vault, and configuration.json files used by the ECS secrets server instance to communicate with 1password.com. After obtaining the new token and credentials.json, place these into the empc-lab vault, along with a base64 encoded version of the credentials.json file. And add the token and base64 version of credentials,json to the pipeline ENV variables.  
