Dockerize Gitolite
==================

Run sshd and gitolite in a container.

This is a custom image that requires some special gitolite triggers to be
available and that share states through a Redis database.

Volumes
-------

One volume must me bound to `/home/git/gitolite-dir`: that dir will hold everything
that gitolite puts in its own `.gitolite` directory. This is done to persist changes
in that directory.

Another volume should be bind to `/home/git/repositories` in order to persist the
repositories created.

Run
---

First, start a [Redis](https://hub.docker.com/_/redis/) container:

    docker run -d -t --name redis-server redis

And link that to the gitolite container.

On the first run, the gitolite container needs an ssh key passed in order to
setup the gitolite-admin key:

    docker run -d -t -p 22:22 --link redis-server:redis -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -v /PATH/TO/VOLUME/:/home/git/gitolite-dir/ milocasagrande/dockerize-gitolite

On subsequent run it is not necessary to pass the ssh key, it will use the
gitolite-admin repository created before:

    docker run -d -t -p 22:22 --link -v /PATH/TO/VOLUME/:/home/git/gitolite-dir/ redis-server:redis milocasagrande/dockerize-gitolite

By default, the Redis host name is set to `redis` in the gitolite triggers.
