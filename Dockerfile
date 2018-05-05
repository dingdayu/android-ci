FROM ubuntu

MAINTAINER dingdayu <614422099@qq.com>

ENV ANDROID_COMPILE_SDK 25
ENV ANDROID_BUILD_TOOLS 24.0.0
ENV ANDROID_SDK_TOOLS 24.4.1

RUN apt-get --quiet update --yes && \
	apt-get --quiet install --yes --no-install-recommends \
	wget tar unzip lib32stdc++6 lib32z1 lib32ncurses5 lib32gcc1 lib32stdc++6 libc6-i386 \
	bzip2 curl git-core html2text openjdk-8-jdk \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# download android-sdk
RUN wget --quiet --output-document=android-sdk.tgz https://dl.google.com/android/android-sdk_r${ANDROID_SDK_TOOLS}-linux.tgz && \
	tar --extract --gzip --file=android-sdk.tgz && rm -v android-sdk.tgz

RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter android-${ANDROID_COMPILE_SDK} && \
	echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter platform-tools && \
	echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter build-tools-${ANDROID_BUILD_TOOLS} && \
	echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository && \
	echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository

RUN wget --quiet --output-document=android-wait-for-emulator https://raw.githubusercontent.com/travis-ci/travis-cookbooks/0f497eb71291b52a703143c5cd63a217c8766dc9/community-cookbooks/android-sdk/files/default/android-wait-for-emulator


# 更新创建avd
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter sys-img-x86-google_apis-${ANDROID_COMPILE_SDK} && \
	echo no | android-sdk-linux/tools/android create avd -n test -t android-${ANDROID_COMPILE_SDK} --abi google_apis/x86 && \

# 设置环境变量
RUN export ANDROID_HOME=$PWD/android-sdk-linux && \
    export PATH=$PATH:$PWD/android-sdk-linux/platform-tools/ && \
    chmod +x android-wait-for-emulator