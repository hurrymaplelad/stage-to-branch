#!npm test

ROOT="$(pwd)"
RELEASE_DIR=npm

setup() {
  rm -rf test-repo || echo "ignore"
  mkdir test-repo
  cd test-repo
  git init -b main
  echo "A" > a.txt
  mkdir $RELEASE_DIR
  git add .
  git commit -am"first"
  echo "a" > $RELEASE_DIR/a.min.txt
}

@test "Creates the release branch if it doesn't exist" {
  ../stage_to_branch
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  [ $BRANCH == "release" ]
}
