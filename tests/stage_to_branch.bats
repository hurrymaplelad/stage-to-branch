#!npm test

ROOT="$(pwd)"
RELEASE_DIR=npm

setup() {
  rm -rf tmp || echo "ignore"
  mkdir -p tmp/repo
  cd tmp/repo
  git init -b main
  echo "A" > a.txt
  mkdir $RELEASE_DIR
  git add .
  git commit -am"first"
  echo "a" > $RELEASE_DIR/a.min.txt
}

@test "Creates a release branch if there isn't one" {
  # Creates the release branch if it doesn't exist
  $ROOT/stage_to_branch
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  [ $BRANCH == "release" ]
  # Wipes the non-release files from the release branch
  [ ! -f a.txt ]
  [ -f a.min.txt ]
}

@test "Appends to a local release branch" {
  # Create the branch the first time
  $ROOT/stage_to_branch
  git commit -am"first release"
  git co main
  mkdir npm
  echo "b" > $RELEASE_DIR/b.min.txt
  $ROOT/stage_to_branch
  # We're addind a descendant of the first release
  git log | grep "first release"
  # Wipes previously released files absent in this build
  [ ! -f a.min.txt ]
  [ -f b.min.txt ]
}

@test "Checks out a remote-only release branch" {
  $ROOT/stage_to_branch
  git commit -am"first release"
  git clone --branch main . ../downstream

  cd ../downstream
  # Confirm no local copy of release branch
  ! git show-ref --heads "$RELEASE_BRANCH"
  mkdir npm
  echo "b" > $RELEASE_DIR/b.min.txt
  $ROOT/stage_to_branch
  # We pulled the first release
  git log | grep "first release"
  [ -f b.min.txt ]
}

