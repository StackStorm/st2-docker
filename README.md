# StackStorm in Docker containers

The initial container configuration is as follows:

 - st2 (st2 + st2web)
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

Use `docker exec` to connect to the st2 container:

  ```
  docker exec -it st2 /bin/bash
  ```

To stop the docker environment, run:

  ```
  docker-compose down
  ```

## Adding a new action

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
