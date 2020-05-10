# StackStorm in Docker Compose

This docker-compose is provided as a way to allow someone to "get up and running" quickly with StackStorm using Docker. It is not designed to be used in production, but rather a way to test out StackStorm and facilitate pack development.

## TL;DR

```shell
git clone git@github.com:stackstorm/st2-dockerfiles
cd st2-docker/stackstorm-compose
docker-compose up -d
docker-compose run st2api st2ctl reload --register-all  # you should only have to do this the first time
docker-compose run st2client bash  # this gives you access to the st2 command line
```

Open `http://localhost:8000` in your browser. StackStorm Username/Password by default is: st2admin/Ch@ngeMe.

## Usage

### Prerequisites

- Docker Engine 18.09+
- Docker Compose 1.12+

### Compose Configuration

The image version, exposed ports, and "packs.dev" directory is configurable with environment variables.

- **ST2_VERSION** this is the tag at the end of the docker image (ie: stackstorm/st2api:v3.3dev)
- **ST2_IMAGE_REPO** The image or path to the images. Default is "stackstorm/".  You may change this is using the Enterprise version or a private docker repository.
- **ST2_EXPOSE_HTTP**  Port to expose st2web port 80 on.  Default is `127.0.0.1:8000`, and you may want to do `0.0.0.0:8000` to expose on all interfaces.
- **ST2_PACKS_DEV** Directory to development packs, absolute or relative to docker-compose.yml. This allows you to develop packs locally. Default is `./packs.dev`. When making a number of packs, it is recommended to make a directory outside of st2-dockerfiles, with each subdirectory underneath that being an independent git repo.  Example: `ST2_PACKS_DEV=${HOME}/mypacks`, with `${HOME}/mypacks/st2-helloworld` being a git repo for the "helloworld" pack.

### Credentials

The `htpasswd` file is created with a default username of `st2admin` and a default password of `Ch@ngeMe`. This can be changed using the [htpasswd utility](https://httpd.apache.org/docs/2.4/programs/htpasswd.html).

Another file (`st2-cli.conf`) contains default credentials and is mounted into the "st2client" container. If you change credentials in htpasswd, you will probably want to change them in st2-cli.conf.  

### Further configuration

The base st2 docker images have a built-in `/etc/st2/st2.conf` configuration file. Each st2 Docker image will load:

- /etc/st2/st2.conf
- /etc/st2/st2.docker.conf (values here will override st2.conf)
- /etc/st2/st2.user.conf (values here will override st2.docker.conf)

Review `../base/files/st2.tmp.conf` and `st2.docker.conf` for currently set values, and it is recommended to place overrides in `st2.user.conf`.

### Step by step first time instructions

First, optionally set and export all the environment variables you want to change. You could make a .env file with customizations.

Example:

```shell
export ST2_PACKS_DEV=$HOME/projects/stackstorm-packs
export ST2_EXPOSE_HTTP=0.0.0.0:8000
```

Secondly make any customizations to st2.user.conf, htpasswd, and st2-cli.conf.

Example:

To enable [sharing code between actions and sensors](https://docs.stackstorm.com/reference/sharing_code_sensors_actions.html), add these two lines to st2.user.conf:

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

Fourth, if this is your first time running StackStorm in Docker Compose, you will need to force st2api to register everything.

```shell
docker-compose run st2api st2ctl reload --register-all
```

## Regular Usage

To run st2 commands, you can use the st2client service:

```shell
docker-compose run st2client st2 <st2 command>
```

Example:

```shell
$ docker-compose run st2client st2 run core.echo message=hello
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

Alternatively, you could run `docker-compose run st2client bash` to be dropped into a container with st2. At that point, you can just run `st2` commands.

Example:

```shell
$ docker-compose run st2client bash
Welcome to StackStorm HA v3.3dev (Ubuntu 16.04 LTS GNU/Linux x86_64)
 * Documentation: https://docs.stackstorm.com/
 * Community: https://stackstorm.com/community-signup
 * Forum: https://forum.stackstorm.com/
 * Enterprise: https://stackstorm.com/#product

 Warning! Do not edit configs, packs or any content inplace as they will be overridden. Modify Helm values.yaml instead!
 It's recommended to use st2client container to work with StackStorm cluster.

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

Pack configs will be in /opt/stackstorm/configs/$PACKNAME, which is a docker volume shared between st2api, st2actionrunner, and st2sensorcontainer. You can use the `st2 pack config <packname>` in the st2client container in order to configure a pack.

### Use st2 pack config

```shell
$ docker-compose run st2client st2 pack config git
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
$ docker-compose run st2client st2 run packs.load packs=git register=configs
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

As mentioned above, your default `packs.dev` directory is relative to your `docker-compose.yml` file. However, if you start developing here, git will not like being inside another git directory. You will want to set `ST2_PACKS_DEV` to a directory outside of `st2-dockerfiles` and restart the docker-compose services.

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
