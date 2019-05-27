#!/bin/sh
set -e

# load the versions
. ./loadenv.sh

FROM_IMAGE_NAME=centos
FROM_IMAGE_VERSION="${CENTOS}"
IMAGE_NAME=jlgrock/centos-openjdk
IMAGE_VERSION="${CENTOS}-${JDK}"
TMP_IMAGE_NAME="${IMAGE_NAME}-temp"

echo "Processing for CentOS + JDK - Version ${IMAGE_VERSION}" 

docker pull ${FROM_IMAGE_NAME}:${FROM_IMAGE_VERSION}

# Build the image
docker build -q --rm -t ${TMP_IMAGE_NAME}:${IMAGE_VERSION} .

# Start Image and get ID
ID=$(docker run -d ${TMP_IMAGE_NAME}:${IMAGE_VERSION} /bin/bash)
echo "Container ID '$ID' now running"

# Flatten the image (removes AUFS layers) and create a new image
# Note that you lose history/layers and environment variables with this method,
# but it slims down the image significantly.  The known necessary environment
# variables have been added back
docker export ${ID} | docker import - ${IMAGE_NAME}:${IMAGE_VERSION}
echo "Created Flattened image with ID: ${FLAT_ID} for ${IMAGE_NAME}:${IMAGE_VERSION}"

# Cleanup
echo "destroying images/containers related to $TMP_IMAGE_NAME (all versions)"
docker ps -a | awk '{ print $1,$2 }' | grep ${TMP_IMAGE_NAME} | awk '{ print $1 }' | xargs -I {} docker rm {}
docker images -a | awk '{ print $1, $3 }' | grep ${TMP_IMAGE_NAME} | awk '{ print $2 }' | xargs -I {} docker rmi {}

if [ $? -eq 0 ]; then
    echo "Container Successfully Built"
else
    echo "Error: Unable to Build Container"
fi
