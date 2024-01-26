#!/bin/sh

touch ~/.netrc

echo "machine api.mapbox.com" > ~/.netrc
echo "login mapbox" >> ~/.netrc
echo "password ${MAPBOX_TOKEN}" >> ~/.netrc

CONFIGURATION_PATH=${CI_PRIMARY_REPOSITORY_PATH}/Configuration/Production/Config.xcconfig
DEBUG_CONFIGURATION_PATH=${CI_PRIMARY_REPOSITORY_PATH}/Configuration/Debug/ConfigDebug.xcconfig

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


touch $DEBUG_CONFIGURATION_PATH

echo "MBXAccessToken = ${MAPBOX_ACCESS_TOKEN};" > $DEBUG_CONFIGURATION_PATH
echo "UserAccessTokenService = accessTokenService;" >> $DEBUG_CONFIGURATION_PATH
echo "UserRefreshTokenService = refreshTokenService;" >> $DEBUG_CONFIGURATION_PATH
echo "Account = weatherXM;" >> $DEBUG_CONFIGURATION_PATH
echo "TeamId = ${CI_TEAM_ID};" >> $DEBUG_CONFIGURATION_PATH
echo "ApiUrl = ${API_URL};" >> $DEBUG_CONFIGURATION_PATH
echo "ClaimTokenUrl = ${CLAIM_TOKEN_URL};" >> $DEBUG_CONFIGURATION_PATH
echo "AppStoreUrl = ${APP_STORE_URL};" >> $DEBUG_CONFIGURATION_PATH
echo "SupportUrl = ${SUPPORT_URL};" >> $DEBUG_CONFIGURATION_PATH

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

echo "Setup Google Services"

WXM_GOOGLE_SERVICES_DEBUG_PATH=${CI_PRIMARY_REPOSITORY_PATH}/wxm-ios/Resources/Debug
mkdir -p $WXM_GOOGLE_SERVICES_DEBUG_PATH
echo ${GOOGLE_SERVICE_INFO_WXM_DEBUG} | base64 -d > $WXM_GOOGLE_SERVICES_DEBUG_PATH/GoogleService-Info.plist

WXM_GOOGLE_SERVICES_RELEASE_PATH=${CI_PRIMARY_REPOSITORY_PATH}/wxm-ios/Resources/Release
mkdir -p $WXM_GOOGLE_SERVICES_RELEASE_PATH
echo ${GOOGLE_SERVICE_INFO_WXM_RELEASE} | base64 -d > $WXM_GOOGLE_SERVICES_RELEASE_PATH/GoogleService-Info.plist

WIDGET_GOOGLE_SERVICES_DEBUG_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-widget/Resources/Debug
mkdir -p $WIDGET_GOOGLE_SERVICES_DEBUG_PATH
echo ${GOOGLE_SERVICE_INFO_WIDGET_DEBUG} | base64 -d > $WIDGET_GOOGLE_SERVICES_DEBUG_PATH/GoogleService-Info.plist

WIDGET_GOOGLE_SERVICES_RELEASE_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-widget/Resources/Release
mkdir -p $WIDGET_GOOGLE_SERVICES_RELEASE_PATH
echo ${GOOGLE_SERVICE_INFO_INTENT_RELEASE} | base64 -d > $WIDGET_GOOGLE_SERVICES_RELEASE_PATH/GoogleService-Info.plist

INTENT_GOOGLE_SERVICES_DEBUG_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-intent/Resources/Debug
mkdir -p $INTENT_GOOGLE_SERVICES_DEBUG_PATH
echo ${GOOGLE_SERVICE_INFO_INTENT_DEBUG} | base64 -d > $INTENT_GOOGLE_SERVICES_DEBUG_PATH/GoogleService-Info.plist

INTENT_GOOGLE_SERVICES_RELEASE_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-intent/Resources/Release
mkdir -p $INTENT_GOOGLE_SERVICES_RELEASE_PATH
echo ${GOOGLE_SERVICE_INFO_INTENT_RELEASE} | base64 -d > $INTENT_GOOGLE_SERVICES_RELEASE_PATH/GoogleService-Info.plist

ls

realpath $WXM_GOOGLE_SERVICES_DEBUG_PATH
realpath $WXM_GOOGLE_SERVICES_RELEASE_PATH
echo "\n"
realpath $WIDGET_GOOGLE_SERVICES_DEBUG_PATH
realpath $WIDGET_GOOGLE_SERVICES_RELEASE_PATH
echo "\n"
realpath $INTENT_GOOGLE_SERVICES_DEBUG_PATH
realpath $INTENT_GOOGLE_SERVICES_RELEASE_PATH
echo "\n"
