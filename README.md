# StackStorm in Docker containers

The initial container configuration is as follows:

 - st2-upstart (st2 + st2web + sshd)
 - mongo
 - rabbitmq

## Usage

Build the st2-upstart image:

  ```
  cd st2-upstart
  docker build -t st2-upstart:latest .
  ```

Start the docker environment:

  ```
  docker-compose up
  ```

Install the SSH keys locally, and setup ST2 user (this only needs to be run once per `docker-compose up`):

*NOTE: The default values for `ST2USER` and `ST2PASSWORD` are `st2admin` and `Ch@ngeMe`
respectively. You only need to specify these variables if you do not want to use the default
values.*

  ```
  make setup ST2USER=st2admin ST2PASSWORD=Ch@ngeMe
  ```

Use either `ssh` or `docker exec` to connect to the st2-upstart container:

  ```
  ssh -i ~/.ssh/id_busybee root@localhost
  ```

  ```
  docker exec -it st2docker_st2-upstart_1 /bin/bash
  ```

Once connected to the st2-upstart container, verify that `st2-self-check` passes successfully.

*NOTE: For now, the mistral tests will fail because st2mistral is not yet configured.*

  ```
  st2ctl reload
  . ~/st2.vars
  st2-self-check
  ```

*NOTE: The `./packs` directory is mounted into the `st2-upstart` container at `/opt/stackstorm/packs`.*

To overwrite `./packs` with the packs provided by st2, run:

  ```
  rm -rf /opt/stackstorm/packs/*
  cp -R /opt/stackstorm/packs.pkg/* /opt/stackstorm/packs
  ```

To stop the docker environment, run:

  ```
  docker-compose down
  ```

## Adding a new action

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

When you rename, or create a new action, you must run `st2ctl reload` inside the st2-upstart
container (usually named `st2docker_st2-upstart_1`). Next, run:

  ```
  st2 run packs.echo_action message=working
  ```

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

Congratulations! You have successfully added your first action!
