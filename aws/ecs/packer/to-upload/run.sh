#!/bin/bash

set -eu

LOGGER_TAG=""

is_container_running() {
    [ "$(docker inspect -f '{{.State.Running}}' $1 2> /dev/null)" = true ]
}

succeed_or_die() {
    if ! OUT=$($@ 2>&1); then
	echo "error: '$@' failed: $OUT" | logger -p local0.error -t $LOGGER_TAG
	exit 1
    fi
    echo $OUT
}

run_scope() {
    while true; do
	# verify that scope is not running
	while is_container_running weavescope; do sleep 2; done
	# launch scope
	ARGS=""
	if [ -e /etc/weave/scope.config ]; then
	    . /etc/weave/scope.config
	fi
	if [ -n "${SERVICE_TOKEN+x}" ]; then
	    ARGS="$ARGS --service-token=$SERVICE_TOKEN"
	fi
	PEERS=$(succeed_or_die /etc/weave/peers.sh)
	ARGS="$ARGS 127.0.0.1 $PEERS"
	succeed_or_die scope launch $ARGS
    done
}

run_weave() {
  while true; do
      # verify that weave is not running
      while is_container_running weaveproxy && is_container_running weave; do sleep 2; done
      # launch weave
      PEERS=$(succeed_or_die /etc/weave/peers.sh)
      if ! is_container_running weave; then
	  succeed_or_die weave launch-router $PEERS
      fi
      if ! is_container_running weaveproxy; then
	  succeed_or_die weave launch-proxy --hostname-from-label 'com.amazonaws.ecs.container-name'
      fi
  done
}

case $1 in
    weave)
	LOGGER_TAG="weave_runner"
        run_weave
        ;;
    scope)
	LOGGER_TAG="weave_scope_runner"
        run_scope
	;;
esac
