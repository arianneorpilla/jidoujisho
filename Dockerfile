FROM eclipse-temurin:17-jdk-jammy

ENV FLUTTER_VERSION=3.13.9
ENV ANDROID_PLATFORM=33
ENV ANDROID_BUILD_TOOLS=33.0.2
ENV NDK_VERSION=25.1.8937393
ENV CMAKE_VERSION=3.22.1

ARG ANDROID_SDK_FILENAME=commandlinetools-linux-11076708_latest.zip

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    zip \
    xz-utils \
    ca-certificates \
    build-essential \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libglu1-mesa \
    libgtk-3-dev \
    libstdc++6 \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

# Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/${ANDROID_SDK_FILENAME} && \
    unzip -q ${ANDROID_SDK_FILENAME} && \
    rm ${ANDROID_SDK_FILENAME} && \
    mv cmdline-tools latest && \
    mkdir -p cmdline-tools && \
    mv latest cmdline-tools/latest

ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

RUN yes | sdkmanager --licenses
RUN sdkmanager \
    "platform-tools" \
    "platforms;android-${ANDROID_PLATFORM}" \
    "build-tools;${ANDROID_BUILD_TOOLS}" \
    "ndk;${NDK_VERSION}" \
    "cmake;${CMAKE_VERSION}" \
    "extras;android;m2repository"
RUN yes | sdkmanager --licenses

ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${NDK_VERSION}
ENV PATH=${PATH}:${ANDROID_NDK_HOME}

# Flutter SDK
RUN cd /opt && \
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

ENV FLUTTER_HOME=/opt/flutter
ENV PATH=${PATH}:${FLUTTER_HOME}/bin

RUN git config --global --add safe.directory /opt/flutter

RUN flutter config --enable-android --no-enable-ios --no-analytics && \
    flutter precache --android --no-ios && \
    (yes | flutter doctor --android-licenses) && \
    flutter doctor -v


WORKDIR /mnt
