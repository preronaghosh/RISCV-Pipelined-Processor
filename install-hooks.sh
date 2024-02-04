#!/bin/bash
ln -s $(readlink -f $(dirname $0))/.githooks/pre-push .git/hooks
