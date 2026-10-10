#!/bin/bash -ex

export NDK_CCACHE=$(which ccache)

if [ ! -z "${ANDROID_KEYSTORE_B64}" ]; then
    export ANDROID_KEYSTORE_FILE="${GITHUB_WORKSPACE}/ks.jks"
    base64 --decode <<< "${ANDROID_KEYSTORE_B64}" > "${ANDROID_KEYSTORE_FILE}"
fi

cd src/android
chmod +x ./gradlew
mkdir -p "${GITHUB_WORKSPACE}/artifacts"

# 建置專屬獨立共存版 (io.github.lime3ds.android.zh)
./gradlew assembleRelease -PcustomAppId=io.github.lime3ds.android.zh
APK_FILE=$(find app/build/outputs/apk -type f -name "*.apk" | head -n 1)
cp "$APK_FILE" "${GITHUB_WORKSPACE}/artifacts/AzaharPlus-zh.apk"

ccache -s -v

if [ ! -z "${ANDROID_KEYSTORE_B64}" ]; then
    rm "${ANDROID_KEYSTORE_FILE}"
fi
