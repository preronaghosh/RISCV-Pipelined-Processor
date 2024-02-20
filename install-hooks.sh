#!/bin/bash
chmod +x $(readlink -f $(dirname $0))/.githooks/pre-push
ln -s $(readlink -f $(dirname $0))/.githooks/pre-push .git/hooks
