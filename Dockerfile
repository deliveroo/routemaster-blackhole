FROM deliveroo/hopper-runner:1.4.0 as hopper-runner
FROM ruby:2.5.0 as production

# App home directory and app user can be injected through build params.
ARG ARG_HOME=/app
ARG ARG_USER=app

COPY --from=hopper-runner /hopper-runner /usr/bin/hopper-runner

RUN gem install bundler \
    && apt-get update \
    && apt-get install -y git \
    && apt-get clean \
    && groupadd -g 1000 -r $ARG_USER \
    && useradd -u 1000 -r -d $ARG_HOME -g $ARG_USER $ARG_USER

WORKDIR $ARG_HOME
ADD Gemfile* $ARG_HOME/
ADD .ruby-version $ARG_HOME/

RUN bundle install --jobs 8 --retry 5

ADD . $ARG_HOME
RUN chown -R $ARG_USER:$ARG_USER $ARG_HOME
USER $ARG_USER

ARG ARG_PORT=3000
ENV PORT=$ARG_PORT

ARG ARG_RACK_ENV=production
ENV RACK_ENV=$ARG_RACK_ENV

ARG ARG_PROCESS=web
ENV PROCESS=$ARG_PROCESS

EXPOSE $PORT

ENTRYPOINT ["hopper-runner"]
CMD ["bundle", "exec", "foreman start $PROCESS"]
