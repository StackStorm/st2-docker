# StackStorm Image Versioning

An image with a version tag equal to a semver (e.g. `2.5.0`) is immutable. A version tag
equal to a two digit number (e.g. `2.5`) may or may not be mutable depending on the timeline.
A version tag equal to `latest` is always mutable.

To clear up any potential confusion regarding versioning of the `stackstorm/stackstorm` image,
we use the following table.

For sake of example, assume that `2.5.0` is the latest stable StackStorm version. The image:tag

Outstanding questions:

 - Should we be responsible for deploying security patches to images if the issue is found in the
   base OS image? What version tag should be used? Shall we use `:2.5.0-nnn`?
 - Should we consider building and versioning a "base" `stackstorm/st2-docker` image separate from
   the `stackstorm` image that contains a specific version of st2? Then discerning users can build
   the precise image they want. Consider how to test st2 dependencies on the base image. While
   flexible, this method increases maintenance burden.

| Image:Tag | StackStorm Version | Description |
|-----------|--------------------|-------------|
| stackstorm:latest | 2.5.0 (latest stable version of Stackstorm) | Changes merged to `st2-docker:master` branch will result in a new image being deployed. |
| stackstorm:2.5 | 2.5.0 | Mutable until 2.6.0 release. This tag is updated when there is a new 2.5.x or 2.5.x-nnn release. |
| stackstorm:2.5.0 | 2.5.0 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.4 | 2.4.1 | Immutable after 2.5.0 is released |
| stackstorm:2.4.1 | 2.4.1 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.4.0 | 2.4.0 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.3 | 2.3.2 | Immutable after 2.4.0 is released |
| stackstorm:2.3.2 | 2.3.2 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.3.1 | 2.3.1 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.3.0 | 2.3.0 | Immutable, even if changes merged to `st2-docker:master` |

More thought needs to be given to the `stackstorm/stackstorm-dev` image. Here are the latest
thoughts:

| Image:Tag | StackStorm Version | Description |
|-----------|--------------------|-------------|
| stackstorm-dev:latest | 2.6dev (latest unstable version of StackStorm) | Plus any changes merged to `st2-docker:master` branch. |
| stackstorm-dev:2.6-20171111 | (latest unstable version of Stackstorm at build time) | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm-dev:2.6-20171110 | (latest unstable version of Stackstorm at build time) | Immutable, even if changes merged to `st2-docker:master` |
| ... | ... | ... |

