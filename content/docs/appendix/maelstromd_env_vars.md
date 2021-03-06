---
title: "maelstromd Environment Variables"
description: "Configuring maelstromd via environment variables"
menu:
  docs:
    parent: "appendix"
weight: 600
toc: true
---

* `maelstromd` configuration is done via environment variables.
* All variables (except LOGXI vars) are prefixed with `MAEL_`.
* All variables are upper case
* Variables are bound to the `Config` struct in [config.go](https://github.com/maelstromapp/maelstrom/blob/master/pkg/config/config.go#L59) using [envconfig](https://github.com/kelseyhightower/envconfig)

## Logging

`maelstromd` uses [mgutz/logxi](https://github.com/mgutz/logxi) for logging, which has a set of environment variables
that control the logging format. Please read the logxi docs for more details.

| Variable         | Description                                  | Example
|------------------|----------------------------------------------|-----------------------------------|
| LOGXI            | Sets log levels                              | `LOGXI=*=DBG`
| LOGXI_FORMAT     | Sets format for logger                       | `LOGXI_FORMAT=text`
| LOGXI_COLORS     | Color schema for log levels                  | `LOGXI_COLORS=TRC,DBG,WRN=yellow,INF=green,ERR=red`

## HTTP

| Variable                    | Description                                                               | Required? | Default |
|-----------------------------|---------------------------------------------------------------------------|-----------|---------|
| MAEL_PUBLIC_PORT            | HTTP port to bind to for external HTTP reqs                               | No        | 80      |
| MAEL_PUBLIC_HTTPS_PORT      | HTTP port to bind to for external HTTPS reqs                              | No        | 443     |
| MAEL_PRIVATE_PORT           | HTTP port to bind to for internal HTTP reqs (node to node and RPC calls)  | No        | 8374    |
| MAEL_PRIVATE_TLS_DIR        | Directory containing .key and .crt TLS keys for private port              | No        | None    |
| MAEL_HTTP_READ_TIMEOUT      | Max duration (seconds) for reading the request (including body)           | No        | 300     |
| MAEL_HTTP_WRITE_TIMEOUT     | Duration (seconds) before timing out writes of the response               | No        | 310     |
| MAEL_HTTP_IDLE_TIMEOUT      | Max time to wait (seconds) for next req when keep-alives are enabled      | No        | 310     |

## Database

| Variable                        | Description                                  | Required? | Default |
|---------------------------------|----------------------------------------------|-----------|---------|
| MAEL_SQL_DRIVER                 | sql db driver to use (sqlite3, mysql)        | Yes       | None    |
| MAEL_SQL_DSN                    | DSN for maelstrom sql db                     | Yes       | None    |

#### Example DSNs:

| Driver   | Project                                                       | Example DSN
|----------|---------------------------------------------------------------|----------------------
| sqlite3  | [go-sqlite3](https://github.com/mattn/go-sqlite3)             | `file:test.db?cache=shared&mode=memory`
| mysql    | [go-sql-driver/mysql](https://github.com/go-sql-driver/mysql) | `user:passwd@(hostname:3306)/mael`
| postgres | [lib/pq](https://godoc.org/github.com/lib/pq)                 | `postgres://user:passwd@host:port/mael`

## Refresh Intervals

| Variable                        | Description                                  | Required? | Default |
|---------------------------------|----------------------------------------------|-----------|---------|
| MAEL_CRON_REFRESH_SECONDS       | Interval to reload cron rules from db        | No        | 60      |

## System Resources

| Variable                        | Description                                           | Required? | Default
|---------------------------------|-------------------------------------------------------|-----------|---------------------
| MAEL_TOTAL_MEMORY               | Memory (MiB) to make available to containers          | No        | System total memory
| MAEL_DOCKER_PRUNE_MINUTES       | Interval to run the docker image pruner               | No        | 0 (off)
| MAEL_DOCKER_PRUNE_UNREG_IMAGES  | If true, remove images not associated with components | No        | false
| MAEL_DOCKER_PRUNE_UNREG_KEEP    | Comma separated list of image tags to never delete    | No        | None

Read more about [Docker image pruning](../production/prune.html)

## System Management

| Variable                             | Description                                             | Required? | Default
|--------------------------------------|---------------------------------------------------------|-----------|-----------
| MAEL_INSTANCE_ID                     | ID of instance with VM provider (e.g. EC2 instance id)  | No <sup>[1](#awslifecycle)</sup> | None
| MAEL_NODE_LIVENESS_SECONDS           | If a node doesn't report status within this interval it will be removed from the cluster | No        | 300
| MAEL_SHUTDOWN_PAUSE_SECONDS          | Seconds to pause before stopping containers at shutdown | No        | 0
| MAEL_TERMINATE_COMMAND               | Command to run if instance terminated. Only invoked if AWS lifecycle termination runs, not if SIGTERM/SIGINT received.      | No        | None
| MAEL_AWS_TERMINATE_QUEUE_URL         | SQS queue URL for lifecycle hook termination queue      | No <sup>[1](#awslifecycle)</sup> | None
| MAEL_AWS_TERMINATE_MAX_AGE_SECONDS   | SQS messages older than this many seconds will be automatically deleted. This prevents stale messages from getting stuck in the queue. | No        | 600
| MAEL_AWS_SPOT_TERMINATE_POLL_SECONDS | If > 0, maelstromd will poll EC2 metadata endpoint checking for spot termination requests. If action=stop or terminate, maelstromd will shutdown gracefully. Value of setting sets the polling interval in seconds. | No        | 0

<a name="awslifecycle">1</a>: Required for AWS Auto Scale Lifecycle Hook support

## Debugging

| Variable                        | Description                                   | Required? | Default |
|---------------------------------|-----------------------------------------------|-----------|---------|
| MAEL_LOG_GC_SECONDS             | If set, print GC stats every x seconds        | No        | None    |
| MAEL_CPU_PROFILE_FILENAME       | If set, write Go profiling info to this file  | No        | None    |
| MAEL_PPROF                      | If true, expose pprof HTTP routes             | No        | false   |

`pprof` routes are bound to the internal gateway port.  For example, to get a heap profile, set `MAEL_PPROF=true` and
request the `/_mael/pprof/heap` endpoint:

```
curl -sK -v http://localhost:8374/_mael/pprof/heap > heap.out
```
