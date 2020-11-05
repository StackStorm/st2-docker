# Changelog

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
