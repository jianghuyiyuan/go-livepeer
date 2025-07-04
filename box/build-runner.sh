#!/bin/bash
set -ex

PIPELINE=${PIPELINE:-noop}

if [[ "$PIPELINE" != "noop" && "$PIPELINE" != "comfyui" && "$PIPELINE" != "streamdiffusion" ]]; then
  echo "Error: PIPELINE must be either 'noop', 'comfyui' or 'streamdiffusion'"
  exit 1
fi

# Switch to neighbour ai-runner directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/../../ai-runner/runner"

VERSION="$(bash print_version.sh)"

docker build -t livepeer/ai-runner:live-base -f docker/Dockerfile.live-base .
if [ "${PIPELINE}" = "noop" ]; then
    docker build -t livepeer/ai-runner:live-app-noop -f docker/Dockerfile.live-app-noop --build-arg VERSION=${VERSION} .
else
    docker build -t livepeer/ai-runner:live-base-${PIPELINE} -f docker/Dockerfile.live-base-${PIPELINE} .
    docker build -t livepeer/ai-runner:live-app-${PIPELINE} -f docker/Dockerfile.live-app__PIPELINE__ --build-arg PIPELINE=${PIPELINE} --build-arg VERSION=${VERSION} .
fi

docker stop live-video-to-video_${PIPELINE}_8900 || true
