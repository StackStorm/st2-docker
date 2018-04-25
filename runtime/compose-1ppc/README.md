# StackStorm 1ppc: One Process Per Container

**What's this?**

StackStorm Docker image that runs one st2 service per container.

**Why we need this?**

> Each container should have only one concern

*Quote from [Best practices for writing Dockerfiles](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)*

## Getting started

A sample `docker-compose.yml` file is located under `runtime/compose-1ppc` directory.
Follow the instruction below to setup a running StackStorm instance which consists of
containers that each are running individual st2 service.

1. Generate .env files

```
(cd ../../ && make env)
cp -r ../../conf .
```

2. Start containers

```
docker-compose up -d
```

Now you can access StackStorm Web UI.

3. Register initial content

```
docker-compose exec st2actionrunner \
  st2-register-content --config-file /etc/st2/st2.conf \
    --register-all --register-setup-virtualenvs
```

Note: `/opt/stackstorm/virtualenvs` directory needs to be mounted as a shared volume on
the container that you run the above command.

4. Run simple action

```
docker-compose exec st2client st2 run core.local cmd=date
```

5. Install examples

```
docker-compose exec st2client st2 pack install https://github.com/shusugmt/st2-pack-examples
```

6. Run mistral example

```
docker-compose exec st2client st2 run examples.mistral_examples
```

**FAQ**

- Q: Fails to run mistral actions
- A: Restart `mistrap-api` or `mistral-server` container once by `docker-compose up -d --force-recreate mistral-api`
    - This is caused by the conflict of `mistral-db-manage` command being invoked by both `mistral-api` and
      `mistral-server`. When you first run `docker-compose up -d` the command runs in both containers almost at the
      same time and simply fails to load the required content into database. Restarting one of them will re-run
      the command again and populate postgres with a proper data.
- Q: I can login to the Web UI but when I click any link, I'm redirected back to login page
- A: Check you docker host clock

### Scaling out

```
docker-compose up --scale st2actionrunner=3 -d
```

## Additional environment variables in 1ppc

| Parameter | Description |
|-----------|-------------|
| `ST2WEB_DNS_RESOLVER` | *(Optional)* Hostname or address of the DNS resolver that nginx running in st2web container will use. Default is `127.0.0.1` which is suitable for sidecar pattern in Kubernetes. |

### Sharing Content

See [official document](https://docs.stackstorm.com/reference/ha.html#sharing-content) for details.

- `/opt/stackstorm/packs`
    - st2api
    - st2actionrunner
    - st2sensorcontainer
- `/opt/stackstorm/virtualenvs`
    - st2actionrunner
    - st2sensorcontainer


### Running st2chatops

Add following service entry to `docker-compose.yml`

```
  st2chatops:
    <<: *base
    environment:
      - ST2_SERVICE=st2chatops
      - HUBOT_ADAPTER=slack
      - HUBOT_SLACK_TOKEN=xoxb-CHANGE-ME-PLEASE
      - ST2_API_KEY=CHANGE-ME-PLEASE
```

See official docs and `/opt/stackstorm/chatops/st2chatops.env` for chatops configuration details.


### Notes

- Currently all inter-service connections are done via plain http, which might be a problem in
  production setup.
