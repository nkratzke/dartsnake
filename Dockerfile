# Install a dart container for demonstration purposes.
#
# This file is hosted on github. Therefore you can start it in docker like this:
# > docker build -t snakedart github.com/nkratzke/snakedart
# > docker run -p 8080:3000 -d snakedart

FROM stackbrew/ubuntu:13.10
MAINTAINER Nane Kratzke <nane@nkode.io>

# Install Dart SDK. Do not touch this until you know what you are doing.
# We do not install darteditor nor dartium because this is a server container.
# See: http://askubuntu.com/questions/377233/how-to-install-google-dart-in-ubuntu
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties
RUN apt-add-repository ppa:hachre/dart
RUN apt-get -y update
RUN apt-get install -y dartsdk

# Install the snakedart app. 
# Comment in necessary parts of your dart package necessary to run "pub build"
# and necessary for your working app.
# Please check the following links to learn more about pub and build dart apps
# automatically.
# - https://www.dartlang.org/tools/pub/
# - https://www.dartlang.org/tools/pub/package-layout.html
# - https://www.dartlang.org/tools/pub/transformers
ADD pubspec.yaml  /container/pubspec.yaml

# comment in if you need assets for working app
# ADD asset       /container/asset

# comment in if you need benchmarks to run pub build
# ADD benchmark   /container/benchmark

# comment in if you need docs to run pub build
# ADD doc         /container/doc

# comment in if you need examples to run pub build
# ADD example     /container/example

# comment in if you need test to run pub build
# ADD test        /container/test

# comment in if you need tool to run pub build      
# ADD tool        /container/tool

# comment in if you need lib to run pub build
ADD lib         /container/lib

ADD bin          /container/bin       

# comment out if you do not need web for working app
ADD web          /container/web

# Build the app. Do not touch this.
WORKDIR /container
RUN pub build

# Expose port 3000.
EXPOSE 3000

# Entrypoint. Whenever the container is started the following command is executed in your container.
# In most cases it simply starts your app.
WORKDIR /container/bin
ENTRYPOINT ["dart"]

# Change this to your starting dart.
CMD ["main.dart"]