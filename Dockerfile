FROM ubuntu:18.04
LABEL author="Vincent Voyer <vincent@zeroload.net>"
LABEL maintainer="Serban Ghita <serbanghita@gmail.com>"

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

EXPOSE 4444

RUN apt-get -qqy update
RUN apt-get -qqy install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    sudo
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://ca.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse\n" >> /etc/apt/sources.list \
  && echo "deb http://ca.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse\n" >> /etc/apt/sources.list \
  && echo "deb http://ca.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse" >> /etc/apt/sources.list \
  && echo "deb-src http://ca.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse\n" >> /etc/apt/sources.list \
  && echo "deb-src http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse\n" >> /etc/apt/sources.list \
  && echo "deb-src http://ca.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse\n" >> /etc/apt/sources.list \
  && echo "deb-src http://ca.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse\n" >> /etc/apt/sources.list

RUN apt-get -qqy update

RUN apt install -f
RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
RUN echo 'node ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

USER root   

RUN sudo apt-get update -y && \
    sudo apt-get -y install curl
RUN sudo add-apt-repository ppa:openjdk-r/ppa
RUN sudo apt-get update
RUN apt-get -o Dpkg::Options::="--force-overwrite" --fix-broken install
RUN dpkg --configure --force-overwrite -a

RUN sudo apt-get -qqy --no-install-recommends install \
  nodejs \
  firefox \
  google-chrome-stable \
  openjdk-11-jre-headless\
  xvfb \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-scalable \
  xfonts-cyrillic


RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo "deb [arch=amd64]  http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

RUN apt-get install -y unzip xvfb libxi6 libgconf-2-4
RUN apt-get -y update
RUN apt-get -y install google-chrome-stable

RUN wget https://chromedriver.storage.googleapis.com/91.0.4472.101/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip

RUN mv chromedriver /usr/local/bin/
RUN chmod 755 /usr/local/bin/chromedriver
RUN chown node:node /usr/local/bin/chromedriver

RUN export DISPLAY=:99.0
RUN Xvfb :99 -shmem -screen 0 1366x768x16 &

WORKDIR /home/node

USER node
ENV NPM_CONFIG_PREFIX=/home/node/node_modules
ENV PATH=$PATH:/home/node/node_modules

RUN npm init -y
#RUN npm install -i ./selenium-standalone-local
RUN npm install -i selenium-standalone

#RUN sudo npm install -i --unsafe-perm=true --allow-root selenium-standalone

#USER root
#CMD ["sh", "-c", "tail -f /dev/null"]
#CMD DEBUG=selenium-standalone:* ./node_modules/.bin/selenium-standalone install && DEBUG=selenium-standalone:* ./node_modules/.bin/selenium-standalone start
CMD DEBUG=selenium-standalone:* sudo /home/node/node_modules/selenium-standalone/bin/selenium-standalone install && sudo /home/node/node_modules/selenium-standalone/bin/selenium-standalone start
