# Simple Tutorial Tour

## Adding a simple action

We will add a simple action that runs a local shell command.
Run the following from your docker host.

```
mkdir -p packs.dev/tutorial/actions
cp tutorial/actions/hello.yaml packs.dev/tutorial/actions
```

Get a bash shell in the `stackstorm` container:

  ```
  docker-compose exec stackstorm /bin/bash
  ```

Load the new action into StackStorm. Whenever you change the yaml file, you need
to run `st2ctl reload`. Within the container, run the following:

  ```
  root@aff39eda0bdd:/# st2ctl reload --register-all

  ... output trimmed ...

  ```

Now, let's run the action:

  ```
  root@aff39eda0bdd:/# st2 run tutorial.hello
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
  root@aff39eda0bdd:/# st2 run tutorial.hello name=Stanley
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
mkdir -p packs.dev/tutorial/policies
cp tutorial/actions/hello-concurrency.yaml packs.dev/tutorial/actions
cp tutorial/policies/hello-concurrency.yaml packs.dev/tutorial/policies
```

Inside the `stackstorm` container, run:

```
st2ctl reload --register-all
```

Open two terminals to the `stackstorm` container. In the first, type (but don't execute):

```
st2 run tutorial.hello-concurrency name=1
```

In the second, type:

```
st2 run tutorial.hello-concurrency name=2
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
root@ffc8bc7909c6:/# st2 execution list
+--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
| id                       | action.ref                 | context.user | status                  | start_timestamp               | end_timestamp                 |
+--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
 :
(snip)
 :
| 5a366f07a1d7aa00ecfd3cef | tutorial.hello-concurrency | st2admin     | succeeded (11s elapsed) | Sun, 17 Dec 2017 13:20:07 UTC | Sun, 17 Dec 2017 13:20:18 UTC |
| 5a366f0aa1d7aa00ecfd3cf2 | tutorial.hello-concurrency | st2admin     | succeeded (18s elapsed) | Sun, 17 Dec 2017 13:20:10 UTC | Sun, 17 Dec 2017 13:20:28 UTC |
+--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+

```

## Adding a rule

To perform a very basic end-to-end test of StackStorm, let's create a simple rule.
Run the following from your docker host.

  ```
  mkdir packs.dev/tutorial/rules
  cp tutorial/rules/monitor_file.yaml packs.dev/tutorial/rules
  ```

Take a look at `monitor_file.yaml`. The `core.local` action is triggered when the
contents of `/tmp/watcher.log` change.

Use `docker-compose exec` to connect to the `stackstorm` container:

  ```
  docker-compose exec stackstorm /bin/bash
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
  root@ffc8bc7909c6:/# st2 execution list
  +--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
  | id                       | action.ref                 | context.user | status                  | start_timestamp               | end_timestamp                 |
  +--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
   :
  (snip)
   :
  | 5a36702fa1d7aa00373b785c | core.local                 | stanley      | succeeded (0s elapsed)  | Sun, 17 Dec 2017 13:25:03 UTC | Sun, 17 Dec 2017 13:25:03 UTC |
  +--------------------------+----------------------------+--------------+-------------------------+-------------------------------+-------------------------------+
  root@ffc8bc7909c6:/# st2 execution get 5a36702fa1d7aa00373b785c
  id: 5a36702fa1d7aa00373b785c
  status: succeeded (0s elapsed)
  parameters:
    cmd: 'echo "{''file_name'': ''watcher.log'', ''line'': u''hello'', ''file_path'': ''/tmp/watcher.log''}"'
  result:
    failed: false
    return_code: 0
    stderr: ''
    stdout: '{''file_name'': ''watcher.log'', ''line'': u''hello'', ''file_path'': ''/tmp/watcher.log''}'
    succeeded: true
  ```

Congratulations, you have created your first rule!

## Adding a python action

As an example of how to create a new action, let's add a new action called `echo_action`.

First, on the host, we create the metadata file `./packs.dev/tutorial/actions/my_echo_action.yaml`:

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

Then, add the action script at `./packs.dev/tutorial/actions/my_echo_action.py`.

```python
import sys

from st2common.runners.base_action import Action

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
st2 run packs.setup_virtualenv packs=tutorial
```

Then you can run your action using the following:

```
st2 run tutorial.echo_action message=working
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
  mkdir -p packs.dev/tutorial/actions/workflows
  cp -R tutorial/actions/mistral-basic.yaml packs.dev/tutorial/actions/mistral-basic.yaml
  cp -R tutorial/actions/workflows/mistral-basic.yaml packs.dev/tutorial/actions/workflows/mistral-basic.yaml
  ```

Use `docker-compose exec` to connect to the `stackstorm` container:

  ```
  docker-compose exec stackstorm /bin/bash
  ```

Within the container, run the following:

  ```
  st2 action create /opt/stackstorm/packs.dev/tutorial/actions/mistral-basic.yaml
  st2 run examples.mistral-basic cmd=date -a
  ```

The `st2 run` command should complete successfully.  Please see
[mistral documentation](https://docs.stackstorm.com/mistral.html#basic-workflow)
for more details about this basic workflow.

Congratulations, you have created your first mistral workflow!
