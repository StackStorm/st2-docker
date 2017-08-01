# StackStorm in Docker containers

[![Circle CI Build Status](https://circleci.com/gh/StackStorm/st2-docker/tree/master.svg?style=shield)](https://circleci.com/gh/StackStorm/st2-docker)
[![Go to Docker Hub](https://img.shields.io/badge/Docker%20Hub-%E2%86%92-blue.svg)](https://hub.docker.com/r/stackstorm/stackstorm/)

The default container configuration is as follows:

 - stackstorm (st2 + st2web + st2mistral)
 - mongo
 - rabbitmq
 - postgres
 - redis

The mongo, rabbitmq, postgres and redis containers store their data
on persistent storage. Additionally, the stackstorm container persists
the contents of `/var/log`. If you do not wish to persist this data,
then remove the appropriate entries from `docker-compose.yml`.

## Usage

We use Version 3 of the compose file format, so if you want to run docker-compose, you'll need to
ensure you're running Docker Engine release 1.13.0+.

First, execute

  ```
  make env
  ```

to create the environment files used by docker-compose. You may want to change the values of the
variables as necessary, but the defaults should be okay if you are not using any off-cluster
services (e.g. mongo, redis, postgres, rabbitmq).

Below is the complete list of available options that can be used to customize your container.

| Parameter | Description |
|-----------|-------------|
| `ST2_USER`     | StackStorm account username |
| `ST2_PASSWORD` | StackStorm account password |
| `MONGO_HOST` | MongoDB server hostname |
| `MONGO_PORT` | MongoDB server port (typically `27017`) |
| `MONGO_DB`   | *(Optional)* MongoDB dbname (will use `st2` if not specified) |
| `MONGO_USER` | *(Optional)* MongoDB username (will connect without credentials if this and `MONGO_PASS` are not specified) |
| `MONGO_PASS` | *(Optional)* MongoDB password |
| `RABBITMQ_HOST`         | RabbitMQ server hostname |
| `RABBITMQ_PORT`         | RabbitMQ server port (typically `5672`) |
| `RABBITMQ_DEFAULT_USER` | RabbitMQ username |
| `RABBITMQ_DEFAULT_PASS` | RabbitMQ password |
| `POSTGRES_HOST`     | PostgreSQL server hostname |
| `POSTGRES_PORT`     | PostgreSQL server port (typically `5432`) |
| `POSTGRES_DB`       | PostgreSQL database |
| `POSTGRES_USER`     | PostgreSQL username |
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `REDIS_HOST`     | Redis server hostname |
| `REDIS_PORT`     | Redis server port |
| `REDIS_PASSWORD` | *(Optional)* Redis password |

Second, start the docker environment.

  ```
  docker-compose up -d
  ```

This will pull the required images from docker hub, and then start them.

However, if you find need to modify the stackstorm image, you will need to build it. Run:

  ```
  REPO=stable
  docker build --build-arg ST2_REPO=${REPO} stackstorm/stackstorm:${REPO}
  ```

where REPO is one of 'stable', 'unstable', 'staging-stable', 'staging-unstable'.  Otherwise,
the following `docker-compose` command will download the specified image from docker hub.

To stop the docker environment, run:

  ```
  docker-compose down
  ```

## Running custom shell scripts on boot

This container supports running arbitrary shell scripts on container boot. Any `*.sh` file located under `/entrypoint.d` directory will be executed inside the container just before starting stackstorm services.

For example, if you want to modify `/etc/st2/st2.conf` to set `system_packs_base_path` parameter, create `modify-st2-config.sh` with the follwing content:

  ```
  #/bin/bash
  crudini --set /etc/st2/st2.conf content system_packs_base_path /opt/stackstorm/custom_packs
  ```

Then bind mount it to `/entrypoint.d/modify-st2-config.sh`

- via `docker run`

  ```
  docker run -it -d --privileged \
    -v /path/to/modify-st2-config.sh:/entrypoint.d/modify-st2-config.sh \
    stackstorm/stackstorm:latest
  ```

- via `docker-compose.yml`

  ```
  services:
    stackstorm:
      image: stackstorm/stackstorm:${TAG:-latest}
       : (snip)
      volumes:
        - /path/to/modify-st2-config.sh:/entrypoint.d/modify-st2-config.sh
  ```

The above example shows just modifying st2 config but basically there is no limitation so you can do almost anything.

You can also bind mount a specific directory to `/entrypoint.d` then place scripts as much as you want. All of them will be executed as long as the file name ends with `*.sh`.

Note: scripts will be executed in alphabetical order of the file name.

## To enable/disable chatops

Chatops is installed in the `stackstorm` image, but not started by default.

To enable chatops, delete the file `/etc/init/st2chatops.override` using a script in
`/entrypoint.d`.

  ```
  #!/bin/bash

  sudo rm /etc/init/st2chatops.override
  ```

If you need to disable chatops, run the following using a script in `/entrypoint.d`:

  ```
  #!/bin/bash

  echo manual | sudo tee /etc/init/st2chatops.override
  ```

## Adding a simple action

We will add a simple action that runs a local shell command.
Run the following from your docker host.

```
mkdir -p packs.dev/examples/actions
cp examples/actions/hello.yaml packs.dev/examples/actions
```

Get a bash shell in the `stackstorm` container:

  ```
  docker exec -it stackstorm /bin/bash
  ```

Load the new action into StackStorm. Whenever you change the yaml file, you need
to run `st2ctl reload`. Within the container, run the following:

  ```
  root@aff39eda0bdd:/# st2ctl reload --register-all

  ... output trimmed ...

  ```

Now, let's run the action:

  ```
  root@aff39eda0bdd:/# st2 run examples.hello
  .
  id: 58f67dbf33a99300bdc4d618
  status: succeeded
  parameters: None
  result:
    failed: false
    return_code: 0
    stderr: ''
    stdout: Hello human!
    succeeded: true
  ```

The action takes a single parameter `name`, which as we can see above,
defaults to 'human' if `name` is not specified. If we specify a value for
`name`, then as expected, the value is found in `result.stdout`.

  ```
  root@aff39eda0bdd:/# st2 run examples.hello name=Stanley
  .
  id: 58f67dc533a99300bdc4d61b
  status: succeeded
  parameters:
    name: Stanley
  result:
    failed: false
    return_code: 0
    stderr: ''
    stdout: Hello Stanley!
    succeeded: true
  ```

Congratulations, you have created your first simple action!

### A Slight Variation: Concurrency

If you want to take advantage of concurrency, use a slight variation on the above.
On the host, run:

```
mkdir -p packs.dev/examples/policies
cp examples/actions/hello-concurrency.yaml packs.dev/examples/actions
cp examples/policies/hello-concurrency.yaml packs.dev/examples/policies
```

Inside the `stackstorm` container, run:

```
st2ctl reload --register-all
```

Open two terminals to the `stackstorm` container. In the first, type (but don't execute):

```
st2 run examples.hello-concurrency name=1
```

In the second, type:

```
st2 run examples.hello-concurrency name=2
```

Now, execute the command in the first terminal, wait 5 seconds and then execute the command in the
second terminal. After a second or so, you should see the following in the second terminal:

```
root@258b11849aa7:/# st2 run examples.hello-concurrency name=2
.
id: 590cec228964ad01567f61e3
status: delayed
parameters:
  name: 2
result: None
```

If you run `st2 execution list` before 10 seconds have elapsed, the status of the second action should
be "delayed".  Between 10 and 20 seconds, the status of the second action should be "running". After
20 seconds, the status of the second action should be "succeeded".

```
+--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
| id                       | action.ref                 | context.user | status                  | start_timestamp               | end_timestamp                 |
+--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
| 590cec068964ad01567f61dd | examples.hello-concurrency | st2admin     | succeeded (10s elapsed) | Fri, 05 May 2017 21:17:58 UTC | Fri, 05 May 2017 21:18:08 UTC |
| 590cec1f8964ad01567f61e0 | examples.hello-concurrency | st2admin     | succeeded (10s elapsed) | Fri, 05 May 2017 21:18:23 UTC | Fri, 05 May 2017 21:18:33 UTC |
| 590cec228964ad01567f61e3 | examples.hello-concurrency | st2admin     | succeeded (17s elapsed) | Fri, 05 May 2017 21:18:26 UTC | Fri, 05 May 2017 21:18:43 UTC |
+--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
```

## Adding a rule

To perform a very basic end-to-end test of StackStorm, let's create a simple rule.
Run the following from your docker host.

  ```
  mkdir packs.dev/examples/rules
  cp examples/rules/monitor_file.yaml packs.dev/examples/rules
  ```

Take a look at `monitor_file.yaml`. The `core.local` action is triggered when the
contents of `/tmp/watcher.log` change.

Use `docker exec` to connect to the `stackstorm` container:

  ```
  docker exec -it stackstorm /bin/bash
  ```

Run the following:

  ```
  st2ctl reload
  ```

When we append to `/tmp/watcher.log`, the sensor will inject a trigger and the
action will be executed. Now let's append a line to the file in the container.

```
echo "hello" >> /tmp/watcher.log
```

You should see that the action was fired:

  ```
  st2 execution list
  root@4ff11fdda3a9:/opt/stackstorm/packs.dev/examples/rules# st2 execution list
  +--------------------------+----------------+--------------+-------------------------+-------------------------------+-------------------------------+
  | id                       | action.ref     | context.user | status                  | start_timestamp               | end_timestamp                 |
  +--------------------------+----------------+--------------+-------------------------+-------------------------------+-------------------------------+
  ...
  | 590cec068964ad01567f61dd | core.local     | st2admin     | succeeded (10s elapsed) | Wed, 19 May 2017 21:17:58 UTC | Fri, 05 May 2017 21:18:08 UTC |
  +--------------------------+----------------+--------------+-------------------------+-------------------------------+-------------------------------+
  root@4ff11fdda3a9:/opt/stackstorm/packs.dev/examples/rules# st2 execution get 590cec068964ad01567f61dd
  id: 590cec068964ad01567f61dd
  status: succeeded (0s elapsed)
  parameters:
    cmd: 'echo "{''file_name'': u''watcher.log'', ''line'': u''hello'', ''file_path'': u''/tmp/watcher.log''}"'
  result:
    failed: false
    return_code: 0
    stderr: ''
    stdout: '{''file_name'': u''watcher.log'', ''line'': u''hello'', ''file_path'': u''/tmp/watcher.log''}'
    succeeded: true
  ```

Congratulations, you have created your first rule!

## Adding a python action

As an example of how to create a new action, let's add a new action called `echo_action`.

First, on the host, we create the metadata file `./packs.dev/examples/actions/my_echo_action.yaml`:

```yaml
---
name: "echo_action"
runner_type: "python-script"
description: "Print message to standard output."
enabled: true
entry_point: "my_echo_action.py"
parameters:
  message:
    type: "string"
    description: "Message to print."
    required: true
    position: 0
```

Then, add the action script at `./packs.dev/examples/actions/my_echo_action.py`.

```python
import sys

from st2actions.runners.pythonrunner import Action

class MyEchoAction(Action):
  def run(self, message):
    print(message)

    if message == 'working':
      return (True, message)
    return (False, message)
```

When you rename, or create a new action, you must run `st2ctl reload` inside the `st2`
container. Next, to initialize the virtualenv, run:

```
  st2 run packs.setup_virtualenv packs=examples
```

Then you can run your action using the following:

```
  st2 run examples.echo_action message=working
```

You should see output similar to:

```
.
id: 58c0abcff4aa45009f42dca3
status: succeeded
parameters:
  message: working
result:
  exit_code: 0
  result: working
  stderr: ''
  stdout: 'working

    '
```

Congratulations! You have successfully added your first action!

## Adding a simple mistral workflow

To add a simple mistral workflow, run the following from your docker host.

  ```
  mkdir -p packs.dev/examples/actions/workflows
  cp -R examples/actions/mistral-basic.yaml packs.dev/examples/actions/mistral-basic.yaml
  cp -R examples/actions/workflows/mistral-basic.yaml packs.dev/examples/actions/workflows/mistral-basic.yaml
  ```

Use `docker exec` to connect to the `stackstorm` container:

  ```
  docker exec -it stackstorm /bin/bash
  ```

Within the container, run the following:

  ```
  st2 action create /opt/stackstorm/packs.dev/examples/actions/mistral-basic.yaml
  st2 run examples.mistral-basic cmd=date -a
  ```

The `st2 run` command should complete successfully.  Please see
[mistral documentation](https://docs.stackstorm.com/mistral.html#basic-workflow)
for more details about this basic workflow.

Congratulations, you have created your first mistral workflow!
