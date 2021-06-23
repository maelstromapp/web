---
title: "Security"
description: "Security considerations when running maelstrom"
menu:
  docs:
    parent: "production"
weight: 550
toc: true
---

## Firewall private port

The most important security consideration is to make sure the private port (default=8374) is firewalled from the
public internet. Only peer nodes in the cluster should be able to reach this port.

The RPC server and the `maelstrom-component` header are not bound to the public port HTTP server, so that is
safe to expose publicly.

## Trusted code only

Only register code you trust in your `maelstrom.yml` projects. Since the private port is exposed to running
containers they can make RPC requests into the Maelstrom daemon. This is useful in many cases, but poses a
security risk.
