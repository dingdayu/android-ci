FROM ubuntu

MAINTAINER dingdayu <614422099@qq.com>

ENV ANDROID_COMPILE_SDK 25
ENV VERSION_SDK_TOOLS 3859397
ENV ANDROID_HOME "/sdk"
ENV PATH "${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

RUN apt-get -qq update && \
	apt-get install -qqy --no-install-recommends \
	curl unzip lib32stdc++6 lib32z1 lib32ncurses5 lib32gcc1 lib32stdc++6 libc6-i386 html2text openjdk-8-jdk \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download android-sdk
RUN curl -s -o sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip && \
	unzip /sdk-tools.zip -d /sdk && rm -v /sdk-tools.zip

RUN mkdir -p $ANDROID_HOME/licenses/ && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license && \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# Upadte sdkmanager
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  sdkmanager --update 

# Install SDK Package
# RUN sdkmanager --proxy=http --proxy_host=android-mirror.bugly.qq.com --proxy_port=8080 \
#     "platform-tools" \
#     "build-tools;27.0.3" \
#     "extras;android;m2repository" \
#     "extras;google;m2repository" \
#     "extras;google;google_play_services" \
#     "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
#     "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1"