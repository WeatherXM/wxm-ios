#!/bin/zsh

uploadDSyms(){
	CONFIGURATION=$1

	UPLOAD_SYMBOLS=$CI_DERIVED_DATA_PATH/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols

	APP_GOOGLE_SERVICES_PATH=${CI_PRIMARY_REPOSITORY_PATH}/wxm-ios/Resources/$CONFIGURATION/GoogleService-Info.plist
	WIDGET_GOOGLE_SERVICES_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-widget/Resources/$CONFIGURATION/GoogleService-Info.plist
	INTENT_GOOGLE_SERVICES_PATH=${CI_PRIMARY_REPOSITORY_PATH}/station-intent/Resources/$CONFIGURATION/GoogleService-Info.plist

	ZIP_DSYMS=./dsyms.zip
	zip -r $ZIP_DSYMS $CI_ARCHIVE_PATH/dSYMs

	echo "Upload Symbols"
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

if ([ "$CI_WORKFLOW" = "Unit tests" ])
then
# Exit on any command failure
set -e

# Convert xcresult to JSON

if ! xcrun xccov view --report --only-targets ${CI_RESULT_BUNDLE_PATH} > coverage_summary.txt; then
echo "Error: Failed to generate coverage report"
exit 1
fi

# Create formatted coverage JSON in a more readable way
echo '{' > coverage_summary.json
echo '  "body": "## Code Coverage Summary\n\n| Framework | Source Files | Coverage |\n|-----------|--------------|----------|\n' >> coverage_summary.json
awk 'NR>2 {printf "| %s | %s | %s |\\n", $2, $3, $4}' coverage_summary.txt >> coverage_summary.json
echo '"' >> coverage_summary.json
echo '}' >> coverage_summary.json

# Post the comment to the PR
if [ -z "$CI_PULL_REQUEST_NUMBER" ]; then
  echo "Error: Pull request number is not set"
  exit 1
fi

# Avoid exposing the token in logs by using a file
HEADER_FILE=$(mktemp)
echo "Authorization: token $GITHUB_TOKEN" > "$HEADER_FILE"
RESPONSE=$(curl -s -w "%{http_code}" -X POST "https://api.github.com/repos/WeatherXM/wxm-ios/issues/$CI_PULL_REQUEST_NUMBER/comments" \
-H @"$HEADER_FILE" \
-d @coverage_summary.json)
HTTP_CODE=${RESPONSE: -3}

if [ "$HTTP_CODE" -ne 201 ]; then
  echo "Error: Failed to post coverage report to PR. HTTP code: $HTTP_CODE"
  exit 1
fi

# Clean up
rm -f "$HEADER_FILE"
echo "Successfully posted coverage report to PR #$CI_PULL_REQUEST_NUMBER"

fi
