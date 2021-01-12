#!/bin/sh

setup-ngxblocker -x -z -e conf

nginx -g "daemon off;"
