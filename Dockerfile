FROM ruby:2.4.0-alpine

ENV APP /app
WORKDIR $APP

RUN apk --update add \
    tzdata \
  && rm -rf /var/cache/apk/* \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY Gemfile* $APP/

RUN bundle install --jobs=4 --path vendor/bundle

COPY . $APP

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "9292"]
