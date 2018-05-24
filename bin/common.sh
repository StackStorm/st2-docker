# The following variables will be set for use by the calling script

#  latest       - the highest version tagged in the repo (beginning with "v")
#  st2_tag      - the MAJOR.MINOR.PATCH version of st2 installed in the image
#  short_tag    - MAJOR.MINOR from ${st2_tag}
#  latest_short - contains the highest version beginning with ${short_tag}
#  tagged_build - true if build was tagged, else false
#  tag          - tag image with this value (if tagged_build st2_tag else latest)

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

if [ -z ${CIRCLE_SHA1} ]; then
  echo "ERROR: CIRCLE_SHA1 is not defined."
  echo "To resolve, run:"
  echo "  $ export CIRCLE_SHA1=<commit_sha>"
  echo "  $ $0"
  exit 1
fi

CIRCLE_TAG=${CIRCLE_TAG:-}
echo CIRCLE_TAG=${CIRCLE_TAG}

BUILD_DEV=${BUILD_DEV:-}
echo BUILD_DEV=${BUILD_DEV}

# Get the highest tag prefixed with 'v'
# NOTE: We remove the 'v' prefix before returning
latest=`git tag -l "v*" | sort -r | head -1 | cut -c 2-`

if [ ! -z ${CIRCLE_TAG} ]; then
  if [[ ${CIRCLE_TAG} =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+).*$ ]]; then
    CIRCLE_TAG_MAJOR=${BASH_REMATCH[1]}
    CIRCLE_TAG_MINOR=${BASH_REMATCH[2]}
    CIRCLE_TAG_PATCH=${BASH_REMATCH[3]}
  else
    echo "ERROR: CIRCLE_TAG must begin with format 'vMAJOR.MINOR.PATCH'"
    exit 1
  fi
fi

short_tag=''

if [[ ${CIRCLE_TAG} =~ ^v(.+)$ ]]; then
  # A tag was pushed, so we'll build an image using this specific release.
  tagged_build=true
  st2_tag=${BASH_REMATCH[1]}
  tag=${st2_tag}
  short_tag="${CIRCLE_TAG_MAJOR}.${CIRCLE_TAG_MINOR}"
  latest_short=`git tag -l "v${short_tag}*" | sort -r | head -1 | cut -c 2-`
  echo latest_short=${latest_short}
else
  # NOTE: A valid version tag was not pushed
  # Build and tag an image using the highest StackStorm release
  tagged_build=false
  tag='latest'
  st2_tag=${latest}
fi

# These variables are available in calling scripts
echo latest=${latest}
echo short_tag=${short_tag}
echo st2_tag=${st2_tag}
echo tag=${tag}
echo tagged_build=${tagged_build}
