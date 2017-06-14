# StackStorm 1ppc: One Process Per Container

**What's this?**

StackStorm Docker image that runs one st2 service per container.

**Why we need this?**

> Each container should have only one concern

*Quote from [Best practices for writing Dockerfiles](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)*

## Getting started

A sample `docker-compose.yml` file is located under `examples/stackstorm-1ppc` directory. Follow the instruction below to setup a running StackStorm instance which consists of containers that each are running individual st2 service.

1. Build `stackstorm/stackstorm-1ppc:latest` image

Since 1ppc image is not officially released yet, you need to build the image by yourself.

```
(cd ../../images/stackstorm-1ppc \
  && docker build -t stackstorm/stackstorm-1ppc:latest .)
```

Alternatively, you can use prebuilt image available at [shusugmt/stackstorm-1ppc](https://hub.docker.com/r/shusugmt/stackstorm-1ppc/). To do so simply replace `stackstorm:stackstorm-1ppc` with `shusugmt/stackstorm-1ppc` in `docker-compose.yml`.

```
sed -i -e 's/stackstorm\/stackstorm\-1ppc/shusugmt\/stackstorm\-1ppc/g' docker-compose.yml

# for BSD sed (Mac)
sed -i '' -e 's/stackstorm\/stackstorm\-1ppc/shusugmt\/stackstorm\-1ppc/g' docker-compose.yml
```

2. Generate .env files

```
(cd ../../ && make env)
cp -r ../../conf .
```

3. Start containers

```
docker-compose up -d
```

Now you can access StackStorm Web UI.

4. Register initial content

```
docker-compose exec st2actionrunner \
  st2-register-content --config-file /etc/st2/st2.conf \
    --register-all --register-setup-virtualenvs
```

Note: `/opt/stackstorm/virtualenvs` directory needs to be mounted as a shared volume on the container that you run the above command.

5. Run simple action

```
docker-compose exec st2client st2 run core.local cmd=date
```

6. Install examples

```
docker-compose exec st2client st2 pack install https://github.com/shusugmt/st2-pack-examples
```

7. Run mistral example

```
docker-compose exec st2client st2 run examples.mistral_examples
```


**FAQ**

- Q: Fails to run mistral actions
- A: Restart `mistrap-api` or `mistral-server` container once by `docker-compose up -d --force-recreate mistral-api`
    - This is caused by the conflict of `mistral-db-manage` command being invoked by both `mistral-api` and `mistral-server`. When you first run `docker-compose up -d` the command runs in both containers almost at the same time and simply fails to load the required content into database. Restarting one of them will re-run the command again and populate postgres with a proper data.
- Q: I can login to the Web UI but when I click any link, I'm redirected back to login page
- A: Check you docker host clock

### Scaling out

```
docker-compose scale st2actionrunner=3
```

### Sharing Content

See [official document](https://docs.stackstorm.com/reference/ha.html#sharing-content) for details.

- `/opt/stackstorm/packs`
    - st2api
    - st2actionrunner
    - st2sensorcontainer
- `/opt/stackstorm/virtualenvs`
    - st2actionrunner
    - st2sensorcontainer

## For developers

### Policies

- Use `stackstorm:stackstorm` as a base image to avoid code duplication
- Try to make changes minimal as possible so that it can be easily integrated into one *universal* image in the future

### Notes

- In `/etc/nginx/nginx.conf` some hostnames are hardcoded and cannot set via environment variables
    - `proxy_pass` directive for `st2auth`, `st2api` and `st2stream`
    - `resolver` directive
- Currently all inter-service connections are done via plain http, which might be a problem in production setup
