#!/bin/sh

WORKSPACE="$PWD/work/build/workspace/sources/"

tmux new-window -n builder "$PWD/ares-build-agent/run-build-agent.py" --threads 10 -I vin-build-agent
tmux new-window -n test

if [ -d "$WORKSPACE" ]; then
  for d in "$WORKSPACE"*/; do
    tmux new-window -c "$d" -n "$(basename "$d")"
  done
fi
