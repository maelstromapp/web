---
title: "Remove Project"
description: "How to remove a project"
menu:
  docs:
    parent: "getting_started"
weight: 220
toc: true
---

Removing a project is as simple as:

```
$ /usr/local/bin/maelctl project rm hello-mael
Project removed: hello-mael
```

Or via docker:

```
docker exec maelstromd maelctl project rm hello-mael
```

This removes all components and event sources contained in the project file.
