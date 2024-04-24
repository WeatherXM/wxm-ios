#!/bin/sh

uploadDSyms(){
	CONFIGURATION=$1

	UPLOAD_SYMBOLS=$CI_DERIVED_DATA_PATH/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols

	APP_GOOGLE_SERVICES_PATH=${CI_PRIMARY_REPOSITORY_PATH}/wxm-ios/Resources/$CONFIGURATION/GoogleService-Info.plist
	WIDGET_GOOGLE_SERVICES_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-widget/Resources/$CONFIGURATION/GoogleService-Info.plist
	INTENT_GOOGLE_SERVICES_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-intent/Resources/$CONFIGURATION/GoogleService-Info.plist

	ZIP_DSYMS=./dsyms.zip
	zip -r $ZIP_DSYMS $CI_ARCHIVE_PATH/dSYMs

	eval $UPLOAD_SYMBOLS -gsp $APP_GOOGLE_SERVICES_PATH -p ios ./dsyms.zip
	eval $UPLOAD_SYMBOLS -gsp $WIDGET_GOOGLE_SERVICES_PATH -p ios ./dsyms.zip
	eval $UPLOAD_SYMBOLS -gsp $INTENT_GOOGLE_SERVICES_PATH -p ios ./dsyms.zip
}

if ([ "$CI_WORKFLOW" = "QA Production" ]) || ([ "$CI_WORKFLOW" = "QA Dev" ]);
then
sh ./firebase_submission.sh -p ${CI_AD_HOC_SIGNED_APP_PATH}/WeatherXM.ipa -k ${FIREBASE_DEBUG_APP_ID} -t ${FIREBASE_REFRESH_TOKEN} -g "qa-group"
uploadDSyms Debug
fi

if ([ "$CI_WORKFLOW" = "Dev Build" ])
then
sh ./firebase_submission.sh -p ${CI_AD_HOC_SIGNED_APP_PATH}/WeatherXM.ipa -k ${FIREBASE_DEBUG_APP_ID} -t ${FIREBASE_REFRESH_TOKEN} -g "tech-team"
uploadDSyms Debug
fi

if ([ "$CI_WORKFLOW" = "Submit to App Store" ])
uploadDSyms Release
then
fi
