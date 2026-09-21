#!/bin/bash -ex

if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    # Get list of every file modified in this pull request
    files_to_lint="$(git diff --name-only --diff-filter=ACMRTUXB $COMMIT_RANGE | grep '^src/[^.]*[.]\(cpp\|h\)$' || true)"
    files_to_check="$(git diff --name-only --diff-filter=ACMRTUXB $COMMIT_RANGE || true)"
else
    # Check modified files against origin/main for branch pushes
    base_commit="$(git merge-base HEAD origin/main 2>/dev/null || echo HEAD~1)"
    files_to_lint="$(git diff --name-only --diff-filter=ACMRTUXB $base_commit..HEAD | grep '^src/[^.]*[.]\(cpp\|h\)$' || true)"
    files_to_check="$(git diff --name-only --diff-filter=ACMRTUXB $base_commit..HEAD || true)"
fi

if [ -n "$files_to_check" ]; then
    existing_files="$(echo "$files_to_check" | while read -r f; do [ -f "$f" ] && echo "$f"; done)"
    if [ -n "$existing_files" ]; then
        if echo "$existing_files" | xargs grep -nI '\s$' 2>/dev/null; then
            echo Trailing whitespace found, aborting
            exit 1
        fi
    fi
fi

CLANG_FORMAT=clang-format
$CLANG_FORMAT --version

# Turn off tracing for this because it's too verbose
set +x

for f in $files_to_lint; do
    d=$(diff -u "$f" <($CLANG_FORMAT "$f") || true)
    if ! [ -z "$d" ]; then
        echo "!!! $f not compliant to coding style, here is the fix:"
        echo "$d"
        fail=1
    fi
done

set -x

if [ "$fail" = 1 ]; then
    exit 1
fi
