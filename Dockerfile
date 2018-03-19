FROM phusion/passenger-ruby18

WORKDIR /home/app

ENV HOME /home/app
ENV GIT_REPO https://github.com/chefbe-dot-net/classandjazz.git
ENV GIT_BRANCH master

RUN apt-get update; \
    apt-get install --force-yes -y libxml2 libxml2-dev libxslt1-dev libxslt1.1

COPY ./scripts/docker-start.sh /usr/bin/docker-start.sh
COPY ./config/webapp.conf /etc/nginx/sites-enabled/webapp.conf
CMD ["/usr/bin/docker-start.sh"]

RUN rm /etc/nginx/sites-enabled/default && \
    rm -f /etc/service/nginx/down && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
