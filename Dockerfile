FROM registry.gitlab.tpwd.de/cmmc-systems/ruby-nginx/ruby-3.0.0

RUN apk add dcron

RUN mkdir -p /unicorn
RUN mkdir -p /app
WORKDIR /app

# nginx default
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

COPY . .

RUN bundle install --without development test

ENTRYPOINT ["/app/docker/entrypoint.sh"]

CMD ["sh", "-c", "nginx-debug ; bundle exec unicorn -c config/unicorn.rb"]
