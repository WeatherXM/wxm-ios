#!/bin/sh
if [ "$CI_WORKFLOW" = "Firebase Beta" ];
then
sh ./firebase_submission.sh -p ${CI_AD_HOC_SIGNED_APP_PATH}/WeatherXM.ipa -k ${FIREBASE_DEBUG_APP_ID} -t {FIREBASE_REFRESH_TOKEN}
fi
