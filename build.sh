#!/bin/bash

set -e

# Define all the versions that should be generated
VERSIONS=(1.2.2 1.2.1 1.2.0 1.1.0 1.0.0)

# Define the "latest" version
LATEST=1.2.2

# Define which JRE versions to generate for
JRES=(7 8)

# Define the default JRE
DEFAULT_JRE=8

# Define default platform
DEFAULT_PLATFORM="debian"

VERIFY=0
PUSH=0
for arg in "$@"; do
    case "$arg" in
        --help)
            echo "Usage: $0 [--help] [--verify] [--push]"
            echo ""
            echo "   --help   : shows this help text"
            echo "   --verify : runs 'docker build' for each image"
            echo "   --push   : pushes each branch and its tags to Git"
            echo ""
            exit
            ;;
        --verify)
            VERIFY=1
            ;;
        --push)
            PUSH=1
            ;;
    esac
done

function error() {
    MSG=$1
    [[ ! -z $MSG ]] && echo $MSG
    exit 1
}

function build_branch() {
    VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_branch()"
    FROM=$2
    [[ -z $FROM ]] && error "Missing 'from' parameter for build_branch()"
    BRANCH=$3
    [[ -z $BRANCH ]] && error "Missing 'branch' parameter for build_branch()"
    DOCKERFILE=$4
    [[ -z $DOCKERFILE ]] && error "Missing 'dockerfile' parameter for build_branch()"
    INCLUDE_BOOTSTRAP=$5
    [[ -z $INCLUDE_BOOTSTRAP ]] && error "Missing 'include_bootstrap' parameter for build_branch()"
    shift 5
    TAGS=("$@")

    echo "Building branch $BRANCH with tags ${TAGS[@]} ..."
    rm -rf /tmp/docker-ceylon-build-templates
    mkdir /tmp/docker-ceylon-build-templates
    [[ $INCLUDE_BOOTSTRAP -eq 1 ]] && cp templates/bootstrap.sh /tmp/docker-ceylon-build-templates/
    cp templates/$DOCKERFILE /tmp/docker-ceylon-build-templates/Dockerfile
    sed -i "s/@@FROM@@/$FROM/g" /tmp/docker-ceylon-build-templates/Dockerfile
    sed -i "s/@@VERSION@@/$VERSION/g" /tmp/docker-ceylon-build-templates/Dockerfile
    git checkout --quiet $(git show-ref --verify --quiet refs/heads/$BRANCH || echo '-b') $BRANCH
    rm -rf build.sh templates LICENSE README.md
    cp /tmp/docker-ceylon-build-templates/* .
    rm -rf /tmp/docker-ceylon-build-templates
    [[ $VERIFY -eq 1 ]] && docker build -t "ceylon/ceylon:$BRANCH" -q .
    git add .
    git commit -q -m "Updated Dockerfile for $VERSION" || true
    for t in ${TAGS[@]}; do
        git tag -f $t
    done
    [[ $PUSH -eq 1 ]] && git push -u origin $BRANCH
    git checkout -q master
}

function build_normal_onbuild() {
    VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_normal_onbuild()"
    FROM=$2
    [[ -z $FROM ]] && error "Missing 'from' parameter for build_normal_onbuild()"
    JRE=$3
    [[ -z $JRE ]] && error "Missing 'jre' parameter for build_normal_onbuild()"
    PLATFORM=$4
    [[ -z $PLATFORM ]] && error "Missing 'platform' parameter for build_normal_onbuild()"
    shift 4
    TAGS=("$@")

    echo "Building for JRE $JRE with tags ${TAGS[@]} ..."

    OBTAGS=()
    for t in ${TAGS[@]}; do
        OBTAGS+=("$t-onbuild")
    done

    NAME="$VERSION-$JRE-$PLATFORM"
    build_branch $VERSION $FROM $NAME "Dockerfile.$PLATFORM" 1 "${TAGS[@]}"
    build_branch $VERSION "ceylon\\/ceylon:$NAME" "$NAME-onbuild" "Dockerfile.onbuild" 0 "${OBTAGS[@]}"
}

function build_jres() {
    VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_jres()"
    FROM_TEMPLATE=$2
    [[ -z $FROM_TEMPLATE ]] && error "Missing 'from_template' parameter for build_jres()"
    JRE_TEMPLATE=$3
    [[ -z $JRE_TEMPLATE ]] && error "Missing 'jre_template' parameter for build_jres()"
    PLATFORM=$4
    [[ -z $PLATFORM ]] && error "Missing 'platform' parameter for build_jres()"

    echo "Building for platform $PLATFORM ..."

    for t in ${JRES[@]}; do
        FROM=${FROM_TEMPLATE/@/$t}
        JRE=${JRE_TEMPLATE/@/$t}
        TAGS=()
        if [[ "$PLATFORM" == "$DEFAULT_PLATFORM" ]]; then
            TAGS+=("$VERSION-$JRE")
            if [[ "$t" == "$DEFAULT_JRE" ]]; then
                TAGS+=("$VERSION")
                if [[ "$VERSION" == "$LATEST" ]]; then
                    TAGS+=("latest")
                fi
            fi
        fi
        build_normal_onbuild $VERSION $FROM $JRE $PLATFORM "${TAGS[@]}"
    done
}

function build() {
    VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build()"

    echo "Building version $VERSION ..."

    build_jres $VERSION "java:@-jre" "jre@" "debian"
    build_jres $VERSION "jboss\\/base-jdk:@" "jre@" "redhat"
}

for v in ${VERSIONS[@]}; do
    build $v
done
[[ $PUSH -eq 1 ]] && git push --force --tags

