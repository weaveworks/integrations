#!/bin/bash

set -eu

LOGGER_TAG=""

is_container_running() {
    [ "$(docker inspect -f '{{.State.Running}}' $1 2> /dev/null)" = true ]
}

succeed_or_die() {
    if ! OUT=$("$@" 2>&1); then
	echo "error: '$@' failed: $OUT" | logger -p local0.error -t $LOGGER_TAG
	exit 1
    fi
    echo $OUT
}

run_scope() {
    while true; do
	# verify that scope is not running
	while is_container_running weavescope; do sleep 2; done

	# Scope startup depends on Weave Net until https://github.com/weaveworks/scope/issues/510 is fixed
	# Wait for weave-proxy to be ready (for a maximum of two minutes to avoid an
	# Upstart deadlock if Weave failed to start).
	# This checks that the container is running but also implicitly checks that it's ready to
	# receive requests since DOCKER_HOST=unix:///var/run/weave/weave.sock
	CMD='while [ "$(docker inspect -f '"'"'{{.State.Running}}'"'"' weaveproxy 2> /dev/null )" != true ]; do sleep 1; done'
	DOCKER_HOST=unix:///var/run/weave/weave.sock succeed_or_die timeout 120 bash -c "$CMD"

	# launch scope
	ARGS=""
	if [ -e /etc/weave/scope.config ]; then
	    . /etc/weave/scope.config
	fi
	if [ -n "${SERVICE_TOKEN+x}" ]; then
	    ARGS="$ARGS --service-token=$SERVICE_TOKEN"
	fi
	if [ -n "${SERVICE_ENDPOINT+x}" ]; then
	    ARGS="$ARGS $SERVICE_ENDPOINT"
	fi
	PEERS=$(succeed_or_die /etc/weave/peers.sh)
	ARGS="$ARGS 127.0.0.1 $PEERS"
	succeed_or_die scope launch $ARGS
    done
}

run_weave() {
  # Ideally we would use a pre-stop Upstart stanza for terminating Weave, but we can't
  # because it would cause ECS to stop in an unorderly manner:
  #
  # Stop Weave -> Weave pre-stop stanza -> Weave stopping event -> ECS pre-stop ...
  #  
  # The Weave pre-stop stanza would kick in before stopping ECS, which would result in
  # the ECS Upstart job supervisor dying early (it talks to the weave proxy,
  # which is gone), not allowing the ECS pre-stop stanza to kick in and stop the
  # ecs-agent
  trap 'succeed_or_die weave stop; exit 0' TERM
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
