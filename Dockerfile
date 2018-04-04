FROM ruby:2.4

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install


ADD . /usr/src/app
WORKDIR /usr/src/app
CMD ["/usr/src/app/jsonld2rdf.rb"]
