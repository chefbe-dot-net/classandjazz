FROM chefbe/classandjazz:base

RUN cd /home/app && \
    git remote update && git reset --hard origin/master && \
    bundle install && \
    chown app.app $HOME -R

