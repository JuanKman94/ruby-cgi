FROM httpd:latest

RUN apt-get update -q
RUN apt-get install -qqq --assume-yes --no-install-recommends ruby

RUN sed -i \
    -e 's/#\(LoadModule .*mod_cgi.so\)/\1/' \
    -e 's/^\(LoadModule .*mod_mpm_event.so\)/#\1/' \
    -e 's/^#\(LoadModule .*mod_mpm_prefork.so\)/\1/' \
    conf/httpd.conf

RUN echo 'Include conf/custom/httpd-auth_basic.conf' >> conf/httpd.conf

COPY conf/custom conf/custom
