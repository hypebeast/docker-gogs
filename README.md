# docker-gogs

Docker image to run [Gogs](http://gogs.io).

## Features

TODO

## Usage

TODO

## Linking Databases

TODO

## Custom Configuration

TODO

### Env Vars

TODO: Add support for env vars

see => https://github.com/fabric8io/docker-gogs

## Settings

TODO

## Directories

Directory /home/gogs/data keeps Git repoistories and Gogs data:

```
/home/gogs/data
|-- git
|   |-- # gogs-repositories
|-- ssh
|   |-- # ssh public/private keys for Gogs
|-- log
|   |-- gogs
|       |-- # Gogs logs
    |-- supervisor
|       |-- # Supervisor logs
|-- gogs
    |-- custom
        |-- conf
    |-- data
```
