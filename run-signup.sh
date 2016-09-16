#!/bin/bash

if [ -d /home/git/key-signup ]; then
    su git -c "/usr/bin/nohup /home/git/key-signup/subscribe.py &"
fi

exec "$@"
