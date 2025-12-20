FROM ruby:3.3.2

ENV LANG=C.UTF-8

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
