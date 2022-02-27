#! /bin/sh -e

# Check that the state of vendor/ exactly matches the state described by jsonnetfile.lock.json

REPO_ROOT="${1:?"pass path to repository root as first argument"}"
cd "$REPO_ROOT"

jb install
git diff --exit-code -- vendor
echo "Success! No dependency drift"
