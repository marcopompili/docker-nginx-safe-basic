#!/bin/sh

# start crond daemon on bg
/usr/sbin/crond

nginx -g "daemon off;"
