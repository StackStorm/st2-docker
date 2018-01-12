# StackStorm Docker Image Versioning

See https://github.com/StackStorm/st2-docker/issues/78 for more information.

| Image:Tag | StackStorm Version | Description |
|-----------|--------------------|-------------|
| stackstorm:dev | 2.6dev | Latest 2.6dev, and most recent st2-docker changes from the st2-docker:master branch.
| stackstorm:latest | 2.5.1 (latest stable version of Stackstorm) | Changes merged to `st2-docker:master` branch will result in a new image being deployed. |
| stackstorm:2.5 | 2.5.1 | Mutable. This tag is updated when there is a new 2.5.x release. |
| stackstorm:2.5.1 | 2.5.1 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.5.0 | 2.5.0 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.4 | 2.4.1 | Mutable. This tag is updated when there is a new 2.4.x release. |
| stackstorm:2.4.1 | 2.4.1 | Immutable, even if changes merged to `st2-docker:master` |
| stackstorm:2.4.0 | 2.4.0 | Immutable, even if changes merged to `st2-docker:master` |
