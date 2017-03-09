# StackStorm in Docker containers

The initial container configuration is as follows:

 - st2-upstart (st2 + st2web + sshd)
 - mongo
 - rabbitmq

## Usage

To install the SSH keys before the docker environment is brought up the first time, run:

  ```
  make setup
  ```

To start the docker environment, run:

  ```
  docker-compose up
  ```

In another terminal, run:

  ```
  ssh -i ~/.ssh/id_busybee root@localhost
  st2ctl reload
  st2-self-check
  ```

The `./packs` directory is mounted into the `st2-upstart` container at `/opt/stackstorm/packs`.

To overwrite `./packs` with the packs provided by st2, run:

  ```
  rm -rf /opt/stackstorm/packs/*
  cp -R /opt/stackstorm/packs.pkg/* /opt/stackstorm/packs
  ```

To stop the docker environment, run:

  ```
  docker-compose down
  ```

# Adding a new action

As an example of how to create a new action, let's add a new action called `echo_action`.

First, on the host, we create the metadata file `./packs/packs/actions/my_echo_action.yaml`:

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

Then, add the action script at `./packs/packs/actions/my_echo_action.py`.

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

When you rename, or create a new action, you must run `st2ctl reload`. Next, run `st2 run packs.echo_action message=working`.
You should see output similar to the following:

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
