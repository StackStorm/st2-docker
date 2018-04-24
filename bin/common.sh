# The following code snippet is used by build.sh and deploy.sh

# Set debug to 'echo' to test
dry_run=''
if [ ${DRY_RUN:-} ]; then
  dry_run='echo'
  echo "Dry run mode enabled..."
  sleep 2
fi

WORKSPACE=/workspace/tar
echo WORKSPACE=${WORKSPACE}

CIRCLE_SHA1=${CIRCLE_SHA1:-}
echo CIRCLE_SHA1=${CIRCLE_SHA1}

CIRCLE_TAG=${CIRCLE_TAG:-}
echo CIRCLE_TAG=${CIRCLE_TAG}

BUILD_DEV=${BUILD_DEV:-}
echo BUILD_DEV=${BUILD_DEV}

if [ -z ${CIRCLE_SHA1} ]; then
  echo "ERROR: CIRCLE_SHA1 is not defined."
  echo "To resolve, run:"
  echo "  $ export CIRCLE_SHA1=<commit_sha>"
  echo "  $ $0"
  exit 1
fi

# Get the latest tag beginning with 'v'
latest=`git tag -l "v*" | sort -r | head -1`
echo latest=${latest}

if [ ! -z ${CIRCLE_TAG} ]; then
  if [[ ! ${CIRCLE_TAG} =~ ^v(.+)$ ]]; then
    echo "ERROR: CIRCLE_TAG must begin with 'v'"
    exit 1
  fi
fi

short_tag=''

if [[ ${CIRCLE_TAG} =~ ^v(.+)$ ]]; then
  # A tag was pushed, so we'll build an image using this specific release.
  tag=${BASH_REMATCH[1]}
  if [[ ${CIRCLE_TAG} =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    short_tag="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  fi
else
  # Build and tag an image using the latest StackStorm release
  if [[ ${latest} =~ ^v(.+)$ ]]; then
    tag=${BASH_REMATCH[1]}
  else
    echo "ERROR: Could not find a git tag in the st2-docker repo with format vX.Y.Z"
    echo "To resolve, run:"
    echo "  $ git co master"
    echo "  $ git tag -a 'vX.Y.Z' -m 'Stamping X.Y.Z' HEAD"
    echo "  $ git push --tags"
    exit 1
  fi
fi

echo tag=${tag}
