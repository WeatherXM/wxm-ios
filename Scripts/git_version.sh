#!/bin/sh

#  git_version.sh
#  wxm-ios
#
#  Created by Pantelis Giazitsis on 12/4/24.
#

TAG=$(git describe --tags --abbrev=0)
echo $TAG
LATEST_VERSION=$TAG
if [[ $TAG == RC* ]]
then
	LATEST_VERSION="${TAG#*_}"
fi

VERSION_CONFIG_PATH=./Configuration/Version.xcconfig
APP_VERSION="AppVersion = $LATEST_VERSION;"

COMMAND=3s/.*/$APP_VERSION/g
sed -i '' "$COMMAND" $VERSION_CONFIG_PATH
