#!/bin/bash

cd /home/git

if [ -d ./.ssh ]; then
    chown -R git:git ./.ssh
fi

# If we have a repositories/ directory make sure the owner is correct.
if [ -d "./repositories" ]; then
    chown -R git:git ./repositories
fi

if [ -d "./gitolite-dir" ]; then
    chown -R git:git "./gitolite-dir"
fi

# First run: needs both admin key and the .gitolite dir doesn't exist.
if [ -n "$SSH_KEY" -a ! -d "./repositories/gitolite-admin.git" ]; then
    echo "$SSH_KEY" > /tmp/admin.pub

    su git -c "/usr/local/bin/gitolite setup -pk /tmp/admin.pub"

    rm /tmp/admin.pub

    # Move stuff into the bind mounted volute at ./gitolite-dir/.
    cp -ax .gitolite/* ./gitolite-dir/
    rm -rf .gitolite/
    su git -c "ln -s ./gitolite-dir/ ./.gitolite"
    chown -R git:git ./.gitolite
else
    # Move the bind mounted admin repo or gitolite will overwrite it.
    if [ -d "./repositories/gitolite-admin.git" ]; then
        mv ./repositories/gitolite-admin.git /tmp/gitolite-admin-tmp.git

        su git -c "/usr/local/bin/gitolite setup -a dummy-admin"

        # Re-enable the old and correct admin repo.
        rm  -rf ./repositories/gitolite-admin.git
        mv /tmp/gitolite-admin-tmp.git ./repositories/gitolite-admin.git

        # Setup the correct authorized_keys based on gitolite-admin.
        su git -c "cd /home/git/repositories/gitolite-admin.git && GL_LIBDIR=$(/usr/local/bin/gitolite query-rc GL_LIBDIR) hooks/post-update refs/heads/master"

        su git -c "/usr/local/bin/gitolite setup"
    fi

    # If we don't have the link, create it.
    if [ ! -h "./.gitolite" -a -d "./gitolite-dir" ]; then
        rm -rf ./.gitolite/
        su git -c "ln -s ./gitolite-dir/ ./.gitolite"
        chown -R git:git ./.gitolite
    fi
fi

# Execute what remains.
exec "$@"
