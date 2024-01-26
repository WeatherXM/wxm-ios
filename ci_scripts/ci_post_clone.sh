#!/bin/sh

touch ~/.netrc

echo "machine api.mapbox.com" > ~/.netrc
echo "login mapbox" >> ~/.netrc
echo "password ${MAPBOX_TOKEN}" >> ~/.netrc

CONFIGURATION_PATH=${CI_PRIMARY_REPOSITORY_PATH}/Configuration/Production/Config.xcconfig
touch $CONFIGURATION_PATH

echo "MBXAccessToken = ${MAPBOX_ACCESS_TOKEN};" > $CONFIGURATION_PATH
echo "UserAccessTokenService = accessTokenService;" >> $CONFIGURATION_PATH
echo "UserRefreshTokenService = refreshTokenService;" >> $CONFIGURATION_PATH
echo "Account = weatherXM;" >> $CONFIGURATION_PATH
echo "TeamId = ${CI_TEAM_ID};" >> $CONFIGURATION_PATH
echo "ApiUrl = ${API_URL};" >> $CONFIGURATION_PATH
echo "ClaimTokenUrl = ${CLAIM_TOKEN_URL};" >> $CONFIGURATION_PATH
echo "AppStoreUrl = ${APP_STORE_URL};" >> $CONFIGURATION_PATH
echo "SupportUrl = ${SUPPORT_URL};" >> $CONFIGURATION_PATH

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
