<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/dps_lab_title.png" width=350/>
	</p>
  <h3>secrets automation server by 1password(c) </h3>
  <h1>lab-service-op-connect-server</h1>
  <a href="https://circleci.com/gh/ThoughtWorks-DPS/lab-service-op-connect-server/tree/main"><img src="https://circleci.com/gh/ThoughtWorks-DPS/lab-service-op-connect-server/tree/main.svg?style=shield&circle-token=5b62dee56a1690eca5a15b8a3ca555f098c306ad"> <a href="https://app.datadoghq.com/dashboard/zdb-as4-bc7/empc-op-connect?from_ts=1652802104947&to_ts=1652888504947&live=true"><img src="https://img.shields.io/badge/DataDog-Dasboard-lightgrey"></a>
</div>
<br />

Secrethub has been used for a couple years in the DPS lab work. This is because, while it does have an excellent security model, more importantly:
- It was a saas
- Supports machine account access using a single, easily rotated token
- Easily customized service account access permissions
- CLI interface tuned for pipeline access (shell and template injection)
- All of which means nearly no overhead to maintain and no bootstrapping required for greefield projects

Last year 1password purchased Secrethub and began the process of integrating the functionality into 1password itself. This has been an interesting process and is not yet fully complete. There are some significant differences in the initial release. And it isn't clear yet whether these differences are an intermediate step or part of a new product vision.  

We do have a license for a component currently required for using the service in a pipeline in the manner we prefer.   

Our secrets live in the "teams" 1password SaaS location, however you cannot pull them directly from there using any form of machine flow yet. Instead, you must deploy your own instance of a combination datasync and 1password api service released by 1password.  

From the 1password website interface you can generate a unique credential file used by the datasync service to enble it to pull a continuously updated copy of the cloud-stored secrets into it's runtime memory. Then, via the API service, and using a long-lived token also generated from the cloud interface, you can interact with those secrets.  

The 1password cli (`op`) can be used to access this API as well as an available SDK. Though, the cli is limited to read functions outlined below. In order to write new or changed secret info, only direct use of the api is currently supported. We will obviously need to create a basic CUD cli to simplify create, update, delete from within a pipeline.  

This repository pipeline manages a test and production instance of the service tied to the empc-lab-lab and empc-lab vaults in the twdps.1password.com teams vault space, resprectively.  

These are live services, available on:  

https://sandbox.op.twdpw.digital
https://op.twdps.digital  

Simply specify the twdps-core-lab-team context for the 1password connect server to be accessible within any circleci pipeline.  

Using this service (for read) provides the same functionality as secrethub. Both .env files or injections into templates are supported:  

The 1password/v2 command line tool must be installed.  

If you want to experiment directly with the API (from your workstation), you can genereate your own token from the website.  

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

# development

Bootstrap-style pipeline:  

- Based on a fargate ecs deployment, alb front end, acm certificates
- terraform-cloud for state
- assumes no secrets mgmt service, just circleci context ENV vars (including base64 version of the 1password-credential.json)
- assumes use of existing platform-vpc
