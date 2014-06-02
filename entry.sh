#!/bin/sh
set -e

service nginx start

[ "$1" ] && exec "$@"
