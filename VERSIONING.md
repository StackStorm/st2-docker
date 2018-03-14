# StackStorm Docker Image Versioning

See https://github.com/StackStorm/st2-docker/issues/78 for more information.

| Image:Tag | StackStorm Version | Description |
|-----------|--------------------|-------------|
| stackstorm:dev | 2.7dev | Latest 2.7dev, and most recent st2-docker changes from the st2-docker `master` branch. |
| stackstorm:latest | 2.6.0 (latest stable version of Stackstorm) | Changes merged to st2-docker `master` branch will result in a new image being deployed tagged 'latest'. |
| stackstorm:2.6 | 2.6.0 | Mutable. This tag is updated when there is a new 2.6.x release. |
| stackstorm:2.6.0 | 2.6.0 | Immutable, even if changes merged to st2-docker `master` branch |
| stackstorm:2.5 | 2.5.1 | Mutable. This tag is updated when there is a new 2.5.x release. |
| stackstorm:2.5.1 | 2.5.1 | Immutable, even if changes merged to st2-docker `master` branch |
| stackstorm:2.5.0 | 2.5.0 | Immutable, even if changes merged to st2-docker `master` branch |
| stackstorm:2.4 | 2.4.1 | Mutable. This tag is updated when there is a new 2.4.x release. |
| stackstorm:2.4.1 | 2.4.1 | Immutable, even if changes merged to st2-docker `master` branch |
| stackstorm:2.4.0 | 2.4.0 | Immutable, even if changes merged to st2-docker `master` branch |
