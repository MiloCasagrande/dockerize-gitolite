Dockerize Gitolite
==================

Run sshd and gitolite in a container.

Run
---

On the first run, it needs an ssh key passed in order to setup the gitolite-admin
key:

    docker run -d -t -p 22:22 -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" milocasagrande/dockerize-gitolite

On subsequent run, it will use the gitolite-admin repository created before:

    docker run -d -t -p 22:22 milocasagrande/dockerize-gitolite

Volumes
-------

At least one volume is necessary, and should be bind to **/home/git/repositories**.
