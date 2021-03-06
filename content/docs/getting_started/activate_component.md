---
title: "Activate Component"
description: "Activate component when a request is received"
menu:
  docs:
    parent: "getting_started"
weight: 160
toc: true
---

## Nothing running yet

When you ran `maelctl project put` you told **maelstrom** that:

* You want to register a component named `hello`
* This component maps to a docker image named: `docker.io/coopernurse/go-hello-http`
* This component should use a max of 128MiB of RAM
* This component should be started when a request is received via the hostname: `hello.localhost`

But we haven't requested it yet.  Try running `docker ps`.  You shouldn't see any containers running yet.

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

## Setup hostname

In our `maelstrom.yml` we used the hostname `hello.localhost`. Let's add that to `/etc/hosts` so our
computer can resolve it.

```bash
sudo bash -c "echo '127.0.0.1  hello.localhost' >> /etc/hosts"
```

Note: If you're running `dnsmasq` you may not need to perform the above step, as it sets up a wildcard
DNS entry for `*.localhost` automatically. Trying pinging `hello.localhost` first and if it doesn't resolve,
run the command above.

## Make a request

`maelstromd` is running on port 8008 (because of `MAEL_PUBLIC_PORT=8008` in `mael.env`).
If we make a request to `hello.localhost:8008` then we should get a container.

Let's try it:

```bash
$ curl http://hello.localhost:8008/env
```

After a couple of seconds you should see output like this:

```
$ curl http://hello.localhost:8008/env
MAELSTROM_COMPONENT_VERSION=1
HOSTNAME=4ab1be0128d2
SHLVL=1
HOME=/root
MAELSTROM_PRIVATE_URL=http://172.18.0.1:8374
MAELSTROM_COMPONENT_NAME=hello-mael_hello
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/app
```

And `docker ps` will show a running container:

```
$ docker ps
CONTAINER ID        IMAGE                       COMMAND                CREATED             STATUS              PORTS               NAMES
4ab1be0128d2        coopernurse/go-hello-http   "/bin/sh -c ./goapp"   57 seconds ago      Up 56 seconds       8080/tcp            confident_mayer
```
