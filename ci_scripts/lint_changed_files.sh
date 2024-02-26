#!/bin/sh
pwd
changedFiles=$(git diff --name-only main..HEAD | grep '\.swift$')
echo $changedFiles
changedFiles  | xargs -I% swiftlint lint --strict --quiet  codeclimate "%" | sed -E 's/^(.*):([0-9]+):([0-9]+): (warning|error|[^:]+): (.*)/::\4 title=Lint error,file=\1,line=\2,col=\3::\5\n\1:\2:\3/'
