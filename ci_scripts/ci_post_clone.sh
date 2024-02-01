#!/bin/sh

setupConfiguration(){
	CONFIGURATION_PATH=$1
	touch $CONFIGURATION_PATH

	echo "MBXAccessToken = ${MAPBOX_ACCESS_TOKEN};" > $CONFIGURATION_PATH
	echo "UserAccessTokenService = accessTokenService;" >> $CONFIGURATION_PATH
	echo "UserRefreshTokenService = refreshTokenService;" >> $CONFIGURATION_PATH
	echo "Account = weatherXM;" >> $CONFIGURATION_PATH
	echo "TeamId = ${TEAM_ID};" >> $CONFIGURATION_PATH
	echo "ApiUrl = ${API_URL};" >> $CONFIGURATION_PATH
	echo "ClaimTokenUrl = ${CLAIM_TOKEN_URL};" >> $CONFIGURATION_PATH
	echo "AppStoreUrl = ${APP_STORE_URL};" >> $CONFIGURATION_PATH
	echo "SupportUrl = ${SUPPORT_URL};" >> $CONFIGURATION_PATH
}

touch ~/.netrc

echo "Create mapbox files"
echo "machine api.mapbox.com" > ~/.netrc
echo "login mapbox" >> ~/.netrc
echo "password ${MAPBOX_TOKEN}" >> ~/.netrc

if [ "$CI_WORKFLOW" = "Firebase Beta" ];
then
echo "Install Firebase CLI"
curl -Lo ./firebase-tools-macos https://firebase.tools/bin/macos/latest
chmod +x ./firebase-tools-macos

DEBUG_CONFIGURATION_PATH=${CI_PRIMARY_REPOSITORY_PATH}/Configuration/Debug/ConfigDebug.xcconfig
setupConfiguration $DEBUG_CONFIGURATION_PATH
echo "BranchName = ${CI_BRANCH};" >> $CONFIGURATION_PATH

fi

if [ "$CI_WORKFLOW" = "Submit to App Store" ];
then
CONFIGURATION_PATH=${CI_PRIMARY_REPOSITORY_PATH}/Configuration/Production/Config.xcconfig
setupConfiguration $CONFIGURATION_PATH
fi

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
