Dartsnake Dart
==============



Dartsnake is the Dart implementation of the famous Snake game. You can play a live version [here][].

It can be deployed as a [docker][docker] container like this:

```Shell
docker build -t snakedart github.com/nkratzke/snakedart
docker run -p 8080:3000 -d snakedart
```

To learn more about how to dockerize Dart applications check out the following links:

- [Dart meets Docker][dockerizedart]
- [Containerdart][containerdart]

### Remarks regarding docker (on non linux systems)

If docker is used on a non linux system like Mac OS X it is likely that docker uses [VirtualBox][virtualbox] under the hood. In theses cases you must configure port forwarding in virtual box. So if you are exposing port 8080 in your docker container mapping it to port 8888 for the outside world you must forward host port 8888 to docker-vm port 8888 in virtualbox. How to do this is explained [here][virtualbox-portforward].

[dartsnake-live]: http://www.nkode.io/static/dartsnake
[docker]: https://www.docker.io/
[dockerizedart]: http://www.nkode.io/2014/03/05/dockerize-dart.html
[containerdart]: https://github.com/nkratzke/containerdart
[dart]: https://www.dartlang.org/
[virtualbox]: https://www.virtualbox.org/
[virtualbox-portforward]: http://www.virtualbox.org/manual/ch06.html#natforward
