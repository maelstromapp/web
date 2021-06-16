---
layout: default.liquid
title: Frequently Asked Questions
---

### General

**What is Maelstrom?**

> Maelstrom is a HTTP router and load balancer that automatically starts and stops Docker containers
in response to request activity. It consists of a daemon (maelstromd) and a command line management
tool (maelctl).  There is also a HTTP based dashboard that provides a web interface to view
the current state of the cluster.

**Why should I use it?**

> Maelstrom simplifies deploying and scaling systems composed of multiple services. If your system
is a single application (e.g. a single Rails app) then Maelstrom is probably the wrong solution,
as you can simply push the Rails app to each server behind a load balancer and call it a day.
But if you have a system composed of a number of different services then Maelstrom may be a good fit.
With Maelstrom you don't need to decide which servers should run which service or how many instances
of a service need to be running. Simply define your min/max limits and target concurrency per service
and let Maelstrom scale and load balance requests across the cluster.

**Who wrote it?**

> Maelstrom was written by [James Cooper](https://github.com/coopernurse/)

**Should I trust it in production?**

> I (James) have been running Maelstrom on a production system since Feb 2020.
This system runs in AWS and runs 10-20 million requests per day through
maelstromd. The cluster runs via an autoscaling group that scales between 5 and
35 virtual machines. Your mileage may vary, but you won't be the first user to
put it into production.

**What were the design inspirations for Maelstrom?**

> Maelstrom is often compared to Kubernetes or Docker Swarm, but the
design is more similar to Google App Engine. Maelstrom, like App Engine,
is HTTP centric. All containers must expose a HTTP endpoint and all event
sources (cron, queues, etc) trigger HTTP routes.  Maelstrom is also a good fit
for problems you might solve with "function as a service" solutions like
AWS Lambda, as it supports automatic activation of containers based on request
activity.

**What can I not do with Maelstrom?**

> Maelstrom is only designed to manage HTTP services. You cannot use Maelstrom to
run stateful services like MySQL or Redis.

### Operations

**What are the system requirements?**

> Each Maelstrom node must be a Linux host or virtual machine running Docker.

**What ports need to be open between peers?**

> TCP 8374. This is the default "private" port used by maelstromd to
communicate between peers. Load balanced requests and internal JSON-RPC
requests are sent via this port.

**Where do maelstromd logs go?**

> By default, maelstromd logs to STDOUT using the [logxi](https://github.com/mgutz/logxi)
library. Each log line is a JSON object, but can optionally be configured to output plain text.
See the [env var](/docs/appendix/maelstromd_env_vars.html) reference for examples of
how to configure logging.

### Application Development

**How do I make a request from Service A to Service B?**

> To make a request to another Maelstrom component, use the HTTP endpoint provided via the
MAELSTROM_PRIVATE_URL environment variable. This variable is set automatically on each
container that Maelstrom starts. Set a MAELSTROM-COMPONENT HTTP header on the request with the
value set to the name of the component you wish to reach. This request will route through the
local Maelstrom daemon and will be proxied to the target component, potentially running on
another node in the cluster.  If the component is not currently running the request will block
until a container is started. If multiple instances of the component are running, requests are
load balanced across the running instances.

**How do I do database schema migration?**

> There are no built in facilities for this in Maelstrom. If your migrations apply relatively
quickly you could have the component apply migrations each time it starts. This will delay
container startup while migrations synchronize, but avoids the need for other deployment code.
Long running migrations may need to be performed out of band using another tool.

**How do I write long running processes?**

> Since all Maelstrom requests have a fixed deadline (usually 60 seconds or less),
long running tasks must be written so they can be run incrementally. Have the job
save its execution state to a lightweight storage system (e.g. Redis) and either use a
Maelstrom cron to periodically fire the job, or use an external queue (SQS) to store each
batch of work to run.  To be clear, there are some types of jobs that require loading
massive amounts of data into RAM, and those tend to be difficult to model given Maelstrom's
execution constraints.
