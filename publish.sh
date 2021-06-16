#!/bin/bash

hugo
rsync -avz public/ root@maelstromapp.com:/opt/web/sites/maelstromapp.com/
