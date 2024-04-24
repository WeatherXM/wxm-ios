#!/bin/sh

#  git_version.sh
#  wxm-ios
#
#  Created by Pantelis Giazitsis on 12/4/24.
#

VERSION_CONFIG_PATH=$1;
echo $VERSION_CONFIG_PATH

TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
echo $TAG
LATEST_VERSION=$TAG
if [[ $TAG == RC* ]]
then
	LATEST_VERSION="${TAG#*_}"
fi

echo $LATEST_VERSION

APP_VERSION="AppVersion = $LATEST_VERSION;"

COMMAND=3s/.*/$APP_VERSION/g
sed -i '' "$COMMAND" $VERSION_CONFIG_PATH

echo "$(<$VERSION_CONFIG_PATH)"
