# Changelog

## 2022-05-06
* Migrate to Ubuntu 20 / Python 3.8 based containers

## 2022-05-04
* Upgrade MongoDB `v4.0` -> `v4.4` as 4.0 has reached its EOL. (#243)
* Fix stackstorm-ssh volume mount path in docker-compose.yml st2actionrunner service (#244)

## 2021-12-02
* Removed `dns_search: .` from all services in `docker-compose.yml` per discussion in #231

## 2021-04-15
* Add BATS testing

## 2021-04-10
* Upgrade used Redis Docker image to 6.2.

## 2021-04-07
* Add rbac sample files and mount to st2api and st2client (#219)

## 2021-04-06
* Add information on how to utilize a custom config with st2web container. (#225)

## 2021-03-22
* Create counter for st2client startup script (#220)

## 2021-03-15
* Added `st2chatops` support and service startup script. (#206)

## 2021-03-13
* Switch to using `latest` tag for st2 Docker images (#222)

## 2021-02-21
* Add stackstorm-keys volume to workflowengine (#214)

## 2020-11-05
* Deprecate st2resultstracker which is obsolete since the Mistral deprecation with st2 `v3.3.0`.

## 2020-11-03
* Update st2 configuration to use redis as coordination backend. (#195)

## 2020-07-17
* Replace docker-compose with a new deployment based on [stackstorm/st2-dockerfiles](https://github.com/StackStorm/st2-dockerfiles/) images relying on `Ubuntu Bionic` and `python 3` since st2 `v3.3dev` (#192)

## 2020-05-26
* Deprecate demo all-in-one docker-compose deployment based on outdated `Ubuntu Trusty` with `python 2`, unsupported since st2 `v3.1.0` (#191)

## 2018-06-28
* Add `st2workflowengine` to `entrypoint-1ppc.sh` and `compose-1ppc/docker-compose.yml`.

## 2018-06-18
* The `TAG` environment variable is replaced by `ST2_IMAGE_TAG`.

## 2018-02-27
* Pin DB's to specific, tested versions.

## 2017-10-23
* Rename `/entrypoint.d/` to `/st2-docker/entrypoint.d/`.
