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
