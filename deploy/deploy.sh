#!/bin/bash
echo "Deploying ${DOCKER_NAMESPACE}/${CONTAINER_NAME}:${ARCH}"
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker push ${DOCKER_NAMESPACE}/${CONTAINER_NAME}