#!/bin/bash
# 사용법: 아래 항목을 모두 입력한 후 아래 커맨드 실행
# sh push.sh {디바이스토큰} {메시지}

# 앱의 번들ID를 입력합니다(ex. com.myapp.PushTest)
BUNDLE_ID=
# 팀ID를 입력합니다(ex. Z6XXXXXXS6)
TEAM_ID=
# 다운로드한 푸시 키 파일(ex. ./AuthKey_XXXXXXXXXX.p8)
TOKEN_KEY_FILE_NAME=
# 위 푸시 키의 ID(ex. 9PXXXXXX2M)
AUTH_KEY_ID=

APNS_HOST_NAME=api.sandbox.push.apple.com
DEVICE_TOKEN=$1
ALERT_CONTENT=$2

JWT_ISSUE_TIME=$(date +%s)
JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"

curl -v \
--header "apns-topic: $BUNDLE_ID" \
--header "apns-push-type: alert" \
--header "authorization: bearer $AUTHENTICATION_TOKEN" \
--data \
"{\"aps\": {
    \"alert\": \"$ALERT_CONTENT\"
}}" \
--http2 \
https://${APNS_HOST_NAME}/3/device/$DEVICE_TOKEN


