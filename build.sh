#!/bin/sh
set -e

#
IMAGE=${DOCKER_ID:=janole}/laravel-apache-postgres
VERSION=`cat version`

#
MAINTAINER=${DOCKER_MAINTAINER:=Jan Ole Suhr <ole@janole.com>}

# Branch or Tag ...
if [ -n "${GITHUB_REF}" ]; then
    BRANCH=`echo ${GITHUB_REF} | sed 's=.*/==' | grep -v "^master$" || true`;
else
    BRANCH=`(git rev-parse --abbrev-ref HEAD 2>/dev/null) | grep -v "^master$" || true`;
fi

if [ -n "${BRANCH}" ]; then
    BRANCH=-${BRANCH};
fi

#
COUNT=`git rev-list HEAD --count 2>/dev/null`

# append "-manual" to image name if triggered manually
if [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ]; then
    COUNT="${COUNT}-manual"
fi

#
VERSION=${VERSION}.${COUNT}${BRANCH}

# Create hierarchical versions (1.2.3 => "1.2" and "1")
VERSION1=`sed "s/\(^[0-9]*\.[0-9]*\).*/\1/" version`${BRANCH}
VERSION0=`sed "s/\(^[0-9]*\).*/\1/" version`${BRANCH}

#
TARGET=${IMAGE}:${VERSION}

#
if [ "$1" = "-p" ]; then echo $TARGET; exit; fi

#
if [ "$1" = "--dry-run" ]; then DOCKER="echo docker"; else DOCKER="docker"; fi

#
build()
{
    local _DOCKERFILE=$1
    local _SUFFIX=$2
    local _FROM=$3

    local _TARGET=${IMAGE}:${VERSION}${_SUFFIX}
    local _TARGET1=${IMAGE}:${VERSION1}${_SUFFIX}
    local _TARGET0=${IMAGE}:${VERSION0}${_SUFFIX}

    local _CONTEXT=`dirname $_DOCKERFILE`

    echo "*** Build ${_TARGET} ${_DOCKERFILE} ${_FROM}"

    # build image and tag it with all subversions
    $DOCKER build --label "maintainer=${MAINTAINER}" --build-arg "FROM=${_FROM}" -t "${_TARGET}" -t "${_TARGET1}" -t "${_TARGET0}" -f ${_DOCKERFILE} $_CONTEXT

    # push image with all subversions
    echo "${_TARGET}" "${_TARGET1}" "${_TARGET0}" | xargs -n 1 $DOCKER push

    # build optional images if not "stop"
    if [ -z "$4" ]; then

        for option in options/*/Dockerfile ; do

            OPTION=`dirname $option | sed "s/[^/]*\///"`
            build $option $SUFFIX-$OPTION $_TARGET stop

        done

    fi
}

# build the base-image
build Dockerfile

# build all variants
for variant in */Dockerfile ; do
    SUFFIX=-`dirname $variant`
    build $variant $SUFFIX $TARGET
done
