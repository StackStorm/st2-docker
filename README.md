# StackStorm in Docker Compose

[![CI Build Status](https://github.com/StackStorm/st2-docker/actions/workflows/st2-docker.yml/badge.svg)](https://github.com/StackStorm/st2-docker/actions/workflows/st2-docker.yml)

This docker-compose is provided as a way to allow "get up and running" quickly with StackStorm using Docker (based on [st2-dockerfiles](https://github.com/stackstorm/st2-dockerfiles)). It is not designed to be used in production, but rather a way to test out StackStorm and facilitate pack development.
> If you need Highly Availability experience, there is Kubernetes installation available via Helm charts at https://docs.stackstorm.com/install/k8s_ha.html.

## TL;DR

```shell
docker-compose up -d
docker-compose exec st2client bash  # this gives you access to the st2 command line
```

Open `http://localhost/` in your browser. StackStorm Username/Password by default is: `st2admin/Ch@ngeMe`.

## Usage

### Prerequisites

- Docker Engine 18.09+
- Docker Compose 1.12+

### Compose Configuration

The image version, exposed ports, chatops, and "packs.dev" directory are configurable with environment variables.

- **ST2_VERSION** this is the tag at the end of the docker image (ie: stackstorm/st2api:v3.3.0)
- **ST2_IMAGE_REPO** The image or path to the images. Default is "stackstorm/".  You may change this is using the Enterprise version or a private docker repository.
- **ST2_EXPOSE_HTTP**  Port to expose st2web port 80 on.  Default is `127.0.0.1:80`, and you may want to do `0.0.0.0:80` to expose on all interfaces.
- **ST2_PACKS_DEV** Directory to development packs, absolute or relative to docker-compose.yml. This allows you to develop packs locally. Default is `./packs.dev`. When making a number of packs, it is recommended to make a directory outside of st2-docker, with each subdirectory underneath that being an independent git repo.  Example: `ST2_PACKS_DEV=${HOME}/mypacks`, with `${HOME}/mypacks/st2-helloworld` being a git repo for the "helloworld" pack.
- **ST2_CHATOPS_ENABLE** To enable chatops, set this variable to any non-zero value.  Also ensure that your environment settings are configured for your chatops adapter (see the `st2chatops` service `environment` comments/settings for more info)
- **HUBOT_ADAPTER** Chat service adapter to use (see https://docs.stackstorm.com/chatops/)
- **HUBOT_SLACK_TOKEN** If using the [Slack](https://github.com/slackapi/hubot-slack) adapter, this is your "Bot User OAuth Access Token"

### Credentials

The `files/htpasswd` file is provided with a default username of `st2admin` and a default password of `Ch@ngeMe`. This can be changed using the [htpasswd utility](https://httpd.apache.org/docs/2.4/programs/htpasswd.html).

Another file (`files/st2-cli.conf`) contains default credentials and is mounted into the "st2client" container. If you change credentials in htpasswd, you will probably want to change them in `st2-cli.conf`.

### Further configuration

The base st2 docker images have a built-in `/etc/st2/st2.conf` configuration file. Each st2 Docker image will load:

- /etc/st2/st2.conf (default [st2.conf](https://github.com/StackStorm/st2/blob/master/conf/st2.package.conf))
- /etc/st2/st2.docker.conf (values here will override st2.conf)
- /etc/st2/st2.user.conf (values here will override st2.docker.conf)

Review `st2.docker.conf` for currently set values, and it is recommended to place overrides in `st2.user.conf`.

If you want to utilize a custom config for StackStorm Web UI (st2web container), you can do that by editing
`files/config.js` file and mounting it as a volume inside the container as per example in `docker-compose.yml`.

#### Chatops configuration

Chatops settings are configured in the `environment` section for the `st2chatops` service in `docker-compose.yml`

Set `ST2_CHATOPS_ENABLE` to any non-zero value, then edit the various `HUBOT_` variables specific to your chatops adapter.
See https://github.com/StackStorm/st2chatops/blob/master/st2chatops.env for the full list of supported adapters and example ENV variables.

You will also need an st2 API key for chatops.  This should be set in `ST2_API_KEY`.

To generate an API key, see the [StackStorm documentation](https://docs.stackstorm.com/authentication.html#api-keys).

_Note:_ If you are standing up st2 for the first time, you may first need to start with chatops initially disabled so you can generate
an API key.  Once this is done, set it in `ST2_API_KEY`, enable chatops as per above and `docker-compose restart` to
restart your st2 stack.

#### RBAC Configuration

Starting with v3.4.0 RBAC is now included, but not enabled, by default. There are some default assignments, mappings, and roles
that ship with st2-docker. All the configuration files for RBAC are kept in `./files/rbac`.
Consult the [st2 RBAC documentation](https://docs.stackstorm.com/rbac.html) for further information.

To enable RBAC you can edit st2.user.conf and add the following options:
```ini
[rbac]
enable = True
backend = default
```

Any changes made to RBAC assignments, mappings, or roles have to be synced in order to take effect. Normally running `st2-apply-rbac-definitions`
will sync the files, but because all database information is not in the standard st2.conf file you need to specify the config file

To sync RBAC changes in st2client:
```shell
st2-apply-rbac-definitions --config-file /etc/st2/st2.docker.conf
````

LDAP is also a feature that is now included, but not enabled, by default. Roles to LDAP groups can be configured in `./files/rbac/mappings`.
Consult the [st2 LDAP documentation](https://docs.stackstorm.com/authentication.html#ldap) for further information


### Step by step first time instructions

First, optionally set and export all the environment variables you want to change. You could make an `.env` file with customizations.

Example:

```shell
export ST2_PACKS_DEV=$HOME/projects/stackstorm-packs
export ST2_EXPOSE_HTTP=0.0.0.0:80
export ST2_CHATOPS_ENABLE=1
export HUBOT_SLACK_TOKEN=xoxb-MY-SLACK-TOKEN
```

Secondly make any customizations to `files/st2.user.conf`, `files/htpasswd`, and `files/st2-cli.conf`.

Example:

To enable [sharing code between actions and sensors](https://docs.stackstorm.com/reference/sharing_code_sensors_actions.html), add these two lines to `files/st2.user.conf`:

```ini
[packs]
enable_common_libs = True
```

Third, start the docker environment:

```shell
docker-compose up -d
```

This will pull the required images from docker hub, and then start them.

To stop the docker environment, run:

```shell
docker-compose down
```

### Gotchas

#### Startup errors

If your system has SELinux enabled you will likely see problems with st2 startup, specifically
the `st2makesecrets` container will repeatedly restart and `docker logs` shows:

```/bin/bash: /makesecrets.sh: Permission denied```

The fix is to disable SELinux (or to put it in permissive mode).

* Disable temporarily with: `setenforce 0`
* Change to use permissive mode on the next reboot with: `sed -ie 's|^SELINUX=.*|SELINUX=permissive|' /etc/selinux/config`

#### Chatops

* Chatops has been minimally tested using the Slack hubot adapter.  Other adapter types may require some
tweaking to the environment settings for the `st2chatops` service in `docker-compose.yml`

* The git status output on the `!packs get` command doesn't appear to work fully.

* Use `docker-compose logs st2chatops` to check the chatops logs if you are having problems getting chatops to work

## Regular Usage

To run st2 commands, you can use the st2client service:

```shell
docker-compose exec st2client st2 <st2 command>
```

Example:

```shell
$ docker-compose exec st2client st2 run core.echo message=hello
.
id: 5eb30d77afe5aa8493f31187
action.ref: core.echo
context.user: st2admin
parameters:
  message: hello
status: succeeded
start_timestamp: Wed, 06 May 2020 19:18:15 UTC
end_timestamp: Wed, 06 May 2020 19:18:15 UTC
result:
  failed: false
  return_code: 0
  stderr: ''
  stdout: hello
  succeeded: true
```

Alternatively, you could run `docker-compose exec st2client bash` to be dropped into a container with st2. At that point, you can just run `st2` commands.

Example:

```shell
$ docker-compose exec st2client bash
Welcome to StackStorm v3.3.0 (Ubuntu 18.04.4 LTS GNU/Linux x86_64)
 * Documentation: https://docs.stackstorm.com/
 * Community: https://stackstorm.com/community-signup
 * Forum: https://forum.stackstorm.com/

 Here you can use StackStorm CLI. Examples:
   st2 action list --pack=core
   st2 run core.local cmd=date
   st2 run core.local_sudo cmd='apt-get update' --tail
   st2 execution list

root@aaabd11745f0:/opt/stackstorm# st2 run core.echo message="from the inside"
.
id: 5eb310f571af8f57a4582430
action.ref: core.echo
context.user: st2admin
parameters:
  message: from the inside
status: succeeded
start_timestamp: Wed, 06 May 2020 19:33:09 UTC
end_timestamp: Wed, 06 May 2020 19:33:09 UTC
result:
  failed: false
  return_code: 0
  stderr: ''
  stdout: from the inside
  succeeded: true
```

## Pack Configuration

Pack configs will be in `/opt/stackstorm/configs/$PACKNAME`, which is a docker volume shared between st2api, st2actionrunner, and st2sensorcontainer. You can use the `st2 pack config <packname>` in the st2client container in order to configure a pack.

### Use st2 pack config

```shell
$ docker-compose exec st2client st2 pack config git
repositories[0].url: https://github.com/StackStorm/st2-dockerfiles.git
repositories[0].branch [master]:
~~~ Would you like to add another item to  "repositories" array / list? [y]: n
---
Do you want to preview the config in an editor before saving? [y]: n
---
Do you want me to save it? [y]: y
+----------+--------------------------------------------------------------+
| Property | Value                                                        |
+----------+--------------------------------------------------------------+
| id       | 5eb3164f566aa824ea88f536                                     |
| pack     | git                                                          |
| values   | {                                                            |
|          |     "repositories": [                                        |
|          |         {                                                    |
|          |             "url":                                           |
|          | "https://github.com/StackStorm/st2-dockerfiles.git",         |
|          |             "branch": "master"                               |
|          |         }                                                    |
|          |     ]                                                        |
|          | }                                                            |
+----------+--------------------------------------------------------------+
```

### Copy a config file into a container

First, find the actual container name of st2api by running `docker-compose ps st2api`.

```shell
$ docker-compose ps st2api
      Name                    Command               State    Ports
--------------------------------------------------------------------
compose_st2api_1   /opt/stackstorm/st2/bin/st ...   Up      9101/tcp
```

Next, use `docker cp` to copy your file into place.

```shell
docker cp git.yaml compose_st2api_1:/opt/stackstorm/configs/git.yaml
```

## Register the pack config

If you used `docker cp` to copy the config in, you will need to manually load that configuration. The st2client service does not need access to the configs directory, as it will talk to st2api.

```shell
$ docker-compose exec st2client st2 run packs.load packs=git register=configs
.
id: 5eb3171c566aa824ea88f538
action.ref: packs.load
context.user: st2admin
parameters:
  packs:
  - git
  register: configs
status: succeeded
start_timestamp: Wed, 06 May 2020 19:59:24 UTC
end_timestamp: Wed, 06 May 2020 19:59:25 UTC
result:
  exit_code: 0
  result:
    configs: 1
  stdout: ''
```

## Local Pack Development

See [Create and Contribute a Pack](https://docs.stackstorm.com/reference/packs.html) for how to actually develop a pack.

If you are working on a development pack, you will need to register it and install the virutalenv (if it's python).

### packs.dev directory

As mentioned above, your default `packs.dev` directory is relative to your `docker-compose.yml` file. However, if you start developing here, git will not like being inside another git directory. You will want to set `ST2_PACKS_DEV` to a directory outside of `st2-docker` and restart the docker-compose services.

Example: We have a pack called helloworld in `packs.dev/helloworld`. The directory name has to match the pack name. So even if you have a git repo named "st2-helloworld", it should be cloned locally as "helloworld".

For these examples, we will be operating inside the st2client container.

### Register the pack

Register the pack by running `st2 run packs.load packs=<pack1>,<pack2> register=all`.  Alternatively you can specify different register option (like register=actions) to focus on the parts you need to (re)register.  You will be running this command a lot as you develop actions, sensors, rules and workflows.

```shell
root@aaabd11745f0:/opt/stackstorm# st2 run packs.load packs=helloworld register=all
.
id: 5eb3100f71af8f57a458241f
action.ref: packs.load
context.user: st2admin
parameters:
  packs:
  - helloworld
  register: all
status: succeeded
start_timestamp: Wed, 06 May 2020 19:29:19 UTC
end_timestamp: Wed, 06 May 2020 19:29:21 UTC
result:
  exit_code: 0
  result:
    actions: 13
    aliases: 0
    configs: 0
    policies: 0
    policy_types: 3
    rule_types: 2
    rules: 0
    runners: 15
    sensors: 0
    triggers: 0
```

### Create the Python Virtual Environment

If you are using python-runners in your locally developed pack, you will need to create the virtual environment by hand. You should typically only have to run this if you have changed your requirements.txt.

To setup the virtual environment: `st2 run packs.setup_virtualenv packs=<pack1>,<pack2>`

```shell
root@aaabd11745f0:/opt/stackstorm# st2 run packs.setup_virtualenv packs=helloworld
....
id: 5eb311f871af8f57a4582433
action.ref: packs.setup_virtualenv
context.user: st2admin
parameters:
  packs:
  - helloworld
status: succeeded
start_timestamp: Wed, 06 May 2020 19:37:28 UTC
end_timestamp: Wed, 06 May 2020 19:37:36 UTC
result:
  exit_code: 0
  result: 'Successfully set up virtualenv for the following packs: helloworld'
  stderr: 'st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Setting up virtualenv for pack "helloworld" (/opt/stackstorm/packs.dev/helloworld)
    st2.actions.python.SetupVirtualEnvironmentAction: INFO     Virtualenv path "/opt/stackstorm/virtualenvs/helloworld" doesn''t exist
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Creating virtualenv for pack "helloworld" in "/opt/stackstorm/virtualenvs/helloworld"
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Creating virtualenv in "/opt/stackstorm/virtualenvs/helloworld" using Python binary "/opt/stackstorm/st2/bin/python"
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Running command "/opt/stackstorm/st2/bin/virtualenv -p /opt/stackstorm/st2/bin/python --always-copy --no-download /opt/stackstorm/virtualenvs/helloworld" to create virtualenv.
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Installing base requirements
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Installing requirement six>=1.9.0,<2.0 with command /opt/stackstorm/virtualenvs/helloworld/bin/pip install six>=1.9.0,<2.0.
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Installing pack specific requirements from "/opt/stackstorm/packs.dev/helloworld/requirements.txt"
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Installing requirements from file /opt/stackstorm/packs.dev/helloworld/requirements.txt with command /opt/stackstorm/virtualenvs/helloworld/bin/pip install -U -r /opt/stackstorm/packs.dev/helloworld/requirements.txt.
    st2.actions.python.SetupVirtualEnvironmentAction: DEBUG    Virtualenv for pack "helloworld" successfully created in "/opt/stackstorm/virtualenvs/helloworld"
    '
  stdout: ''
```

# Remove everything

If you want to uninstall, or start from a "clean" installation, docker-compose can remove all the containers and volumes in one command.

```shell
docker-compose down --remove-orphans -v
```

# Testing

Testing st2-docker is now powered by [BATS](https://github.com/sstephenson/bats) Bash Automated Testing System.
A "sidecar" like container loads the BATS libraries and binaries into a st2client-like container to run the tests

To run the tests
```shell
docker-compose -f tests/st2tests.yaml up
```

To do a clean teardown
```shell
docker-compose -f tests/st2tests.yaml down -v
```
