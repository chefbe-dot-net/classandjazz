FROM ruby:2.7-alpine

RUN apk add --update git make g++

RUN addgroup -S app && \
    adduser -S -D -h /home/app app -G app

WORKDIR /home/app
ENV HOME /home/app
USER app

COPY --chown=app:app Gemfile*  ${HOME}/

RUN bundle config set without 'development' && \
    bundle install --path=vendor/bundle

COPY --chown=app:app . ${HOME}

CMD bundle exec rackup -o 0.0.0.0 -p 3000

EXPOSE 3000
