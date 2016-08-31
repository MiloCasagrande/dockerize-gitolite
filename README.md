Dockerize Gitolite
==================

Run sshd and gitolite in a container.

This is a custom image that requires some special gitolite triggers to be
available and that share states through a Redis database.

Run
---

First, start a [Redis](https://hub.docker.com/_/redis/) container:

    docker run -d -t --name redis-server redis

And link that to the gitolite container.

On the first run, the gitolite container needs an ssh key passed in order to
setup the gitolite-admin key:

    docker run -d -t -p 22:22 --link redis-server:redis -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" milocasagrande/dockerize-gitolite

On subsequent run, it will use the gitolite-admin repository created before:

    docker run -d -t -p 22:22 --link redis-server:redis milocasagrande/dockerize-gitolite

By default, the Redis host is set to `redis` in the gitolite triggers, you can
override that by passing an environment variable named `REDIS_HOST`.

Other environment variables that can be passed are:

* `REDIS_PORT`
* `REDIS_PASSWORD`

Volumes
-------

At least one volume is necessary, and should be bind to `/home/git/repositories`.
