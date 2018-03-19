#!/usr/bin/env sh

cd $HOME

if [ ! -d .git ]; then
  git clone $GIT_REPO /tmp/app
  mv /tmp/app/.git /tmp/app/* /tmp/app/.* .
  rm -rf /tmp/app
fi

# Fetch changes and switch to the correct branch
echo "Updating folder, using branch $GIT_BRANCH"
git remote update
git fetch
git checkout $GIT_BRANCH
git reset --hard origin/$GIT_BRANCH

bundle install

chown app.app $HOME -R

# Delegate the rest to passenger's start script
/sbin/my_init
