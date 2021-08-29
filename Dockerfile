FROM httpd:latest

RUN apt-get update -qqq \
    && apt-get install --assume-yes --no-install-recommends -qqq ruby
RUN gem install bundler

# configure httpd
RUN sed -i \
    -e 's/#\(LoadModule .*mod_cgi.so\)/\1/' \
    -e 's/^\(LoadModule .*mod_mpm_event.so\)/#\1/' \
    -e 's/^#\(LoadModule .*mod_mpm_prefork.so\)/\1/' \
    conf/httpd.conf

RUN echo 'Include conf/custom/httpd-auth_basic.conf' >> conf/httpd.conf

# setup simple store directory
RUN mkdir /var/tmp/simplestore
RUN chown -R daemon:daemon /var/tmp/simplestore

# build & install gem
WORKDIR /tmp/build
COPY Gemfile Gemfile.lock Rakefile simple_store_response.gemspec /tmp/build
ADD lib/ /tmp/build/lib
RUN bundle install --without="development test"
RUN bundle exec rake install

WORKDIR /usr/local/apache2
COPY conf/custom conf/custom

# clean files
RUN rm -fr /tmp/build
