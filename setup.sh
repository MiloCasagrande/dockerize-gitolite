#!/bin/bash

cd /home/git

if [ -d ./.ssh ]; then
    chown -R git:git ./.ssh
fi

# If we have a repositories/ directory make sure the owner its correct.
if [ -d ./repositories ]; then
    chown -R git:git ./repositories
fi

if [ ! -d ./.gitolite ]; then
    # First run, need to pass the admin key.
    if [ -n "$SSH_KEY" ]; then
        echo "$SSH_KEY" > /tmp/admin.pub

        su git -c "/usr/local/bin/gitolite setup -pk /tmp/admin.pub"

        rm /tmp/admin.pub
    else
        # Move the bind mounted admin repo or gitolite will overwrite it.
        if [ -d ./repositories/gitolite-admin.git ]; then
            mv ./repositories/gitolite-admin.git /tmp/gitolite-admin-tmp.git
        fi

        su git -c "/usr/local/bin/gitolite setup -a dummy-admin"

        # Re-enable the old and correct admin repo.
        if [ -d ./repositories/gitolite-admin.git ]; then
            rm  -rf ./repositories/gitolite-admin.git
            mv /tmp/gitolite-admin-tmp.git ./repositories/gitolite-admin.git
        fi

        # Setup the correct authorized_keys based on gitolite-admin.
        su git -c "cd /home/git/repositories/gitolite-admin.git && GL_LIBDIR=$(/usr/local/bin/gitolite query-rc GL_LIBDIR) hooks/post-update refs/heads/master"
    fi
else
    su git -c "/usr/local/bin/gitolite setup"
fi

# Execute what remains.
exec $*
