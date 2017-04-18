# StackStorm in Docker containers

The initial container configuration is as follows:

 - stackstorm (st2 + st2web)
 - mongo
 - rabbitmq

## Usage

If you want to build the image yourself, execute:

  ```
  make build
  ```

Otherwise, the following `docker-compose` command will download the image from docker hub.

Start the docker environment (specifying a custom ST2 user and password if the defaults are not desired):

  ```
  [ST2_USER=<user>] [ST2_PASSWORD=<password>] docker-compose up -d
  ```

To stop the docker environment, run:

  ```
  docker-compose down
  ```

## Adding a simple action

We will add a simple action that runs a local shell command:

```
mkdir -p packs.dev/examples/actions
cp -R examples/actions/actions.hello.yaml packs.dev/examples/actions
```

Use `docker exec` to connect to the `stackstorm` container:

  ```
  docker exec -it stackstorm /bin/bash
  ```

`st2ctl reload` loads the new action into StackStorm. Within the container,
run the following:

  ```
  root@aff39eda0bdd:/# st2ctl reload

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
    stdout: Hello dude!
    succeeded: true
  ```

The action takes a single parameter `name`, which as we can see above,
defaults to 'dude' if `name` is not specified. If we specify a value for
`name`, then as expected, the value is found in `stdout`.

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

## Adding a rule

To perform a very basic end-to-end test of StackStorm, let's create a simple rule.
Run the following from your docker host.

  ```
  mkdir packs.dev/examples/rules
  cp -R examples/rules/monitor_file.yaml packs.dev/examples/rules
  ```

We need to tell the FileWatchSensor to watch `/tmp/date.log`, enable the
`linux.FileWatchSensor` and then call `st2ctl reload`.

Use `docker exec` to connect to the `stackstorm` container:

  ```
  docker exec -it stackstorm /bin/bash
  ```

Within the container, run the following:

  ```
  echo "    - /tmp/date.log" >> /opt/stackstorm/packs/linux/config.yaml
  st2 sensor enable linux.FileWatchSensor
  st2ctl reload
  ```

When we append to `/tmp/date.log`, the sensor will inject a trigger that matches the criteria.
The `linux.file_touch` action is called, creating `/tmp/touch.log`.

Now let's append a line to the file in the container.

```
echo "hi" >> /tmp/date.log
```

The file `/tmp/touch.log` should exist with a recent timestamp. Congratulations, you have created
your first rule!

## Adding a new python action

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
