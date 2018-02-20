#!/bin/bash

export PORT=8000
export MIX_ENV=prod
export GIT_PATH=/home/tasks1/src/task_tracker

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
	echo "Error: Must check out git repo to $GIT_PATH"
	echo "  Current directory is $PWD"
	exit 1
fi

if [ $USER !="tasks1" ]; then
	echo "Error: must run as user 'tasks1'"
	echo "  Current user is $USER"
	exit 2
fi

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
mix release --env=prod

mkdir -p ~/www
mkdir -p ~/old

NOW=`date +%s`
if [ -d ~/www/task_tracker ]; then
	echo mv ~/www/task_tracker ~/old/$NOW
	mv ~/www/task_tracker ~/old/$NOW
fi

mkdir -p ~/www/task_tracker
REL_TAR=~/src/task_tracker/_build/prod/rel/task_tracker/releases/0.0.1/task_tracker.tar.gz
(cd ~/www/task_tracker && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/tasks1/src/task_tracker/start.sh
CRONTAB

#. start.sh
