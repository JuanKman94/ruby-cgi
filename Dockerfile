FROM httpd:latest

ENV RBENV_ROOT /usr/local/rbenv
ENV PATH "$PATH:$RBENV_ROOT/bin"

RUN apt-get update -q \
    && apt-get remove -qqq ruby \
    && apt-get install -qqq --assume-yes git curl autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev

# install rbenv & its plugins
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT \
    && mkdir -p $RBENV_ROOT/plugins \
    && git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build

# install ruby 3
RUN eval "$(rbenv init - bash)"
RUN rbenv install 3.0.0
RUN rbenv global 3.0.0

ENV BASH_RBENV /etc/profile.d/rbenv.sh
RUN touch $BASH_RBENV
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> $BASH_RBENV
RUN echo 'export PATH="$PATH:RBENV_ROOT/bin"' >> $BASH_RBENV
RUN echo 'eval "$(rbenv init - bash)"' >> $BASH_RBENV

# configure httpd
RUN sed -i \
    -e 's/#\(LoadModule .*mod_cgi.so\)/\1/' \
    -e 's/^\(LoadModule .*mod_mpm_event.so\)/#\1/' \
    -e 's/^#\(LoadModule .*mod_mpm_prefork.so\)/\1/' \
    conf/httpd.conf

RUN echo 'Include conf/custom/httpd-auth_basic.conf' >> conf/httpd.conf
RUN mkdir /var/tmp/simplestore
RUN chown -R daemon:daemon /var/tmp/simplestore

COPY conf/custom conf/custom
