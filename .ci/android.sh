#!/bin/bash -ex

export NDK_CCACHE=$(which ccache)

if [ ! -z "${ANDROID_KEYSTORE_B64}" ]; then
    export ANDROID_KEYSTORE_FILE="${GITHUB_WORKSPACE}/ks.jks"
    base64 --decode <<< "${ANDROID_KEYSTORE_B64}" > "${ANDROID_KEYSTORE_FILE}"
fi

cd src/android
chmod +x ./gradlew
mkdir -p "${GITHUB_WORKSPACE}/artifacts"

# 1. 建置獨立共存版 (io.github.lime3ds.android.zh)
./gradlew assembleRelease -PcustomAppId=io.github.lime3ds.android.zh
APK_COEXIST=$(find app/build/outputs/apk -type f -name "*.apk" | head -n 1)
cp "$APK_COEXIST" "${GITHUB_WORKSPACE}/artifacts/AzaharPlus-coexist-zh.apk"
rm -rf app/build/outputs/apk

# 2. 建置原版取代版 (io.github.lime3ds.android)
./gradlew assembleRelease -PcustomAppId=io.github.lime3ds.android
APK_REPLACE=$(find app/build/outputs/apk -type f -name "*.apk" | head -n 1)
cp "$APK_REPLACE" "${GITHUB_WORKSPACE}/artifacts/AzaharPlus-replace-zh.apk"

ccache -s -v

if [ ! -z "${ANDROID_KEYSTORE_B64}" ]; then
    rm "${ANDROID_KEYSTORE_FILE}"
fi
