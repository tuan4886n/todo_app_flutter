# Use the base image from ghcr.io/cirruslabs/flutter:stable
FROM ghcr.io/cirruslabs/flutter:stable

# Install OpenJDK 17 and necessary tools
RUN apt-get update && apt-get install -y openjdk-17-jdk wget unzip

# Download and install the latest Dart SDK
RUN wget https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip && \
    unzip dartsdk-linux-x64-release.zip -d /usr/local

# Set environment variable for Dart SDK
ENV PATH="/usr/local/dart-sdk/bin:$PATH"

# Download and install Android SDK Command-Line Tools
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    curl -o /opt/android-sdk/cmdline-tools/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip /opt/android-sdk/cmdline-tools/cmdline-tools.zip -d /opt/android-sdk/cmdline-tools && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest && \
    rm /opt/android-sdk/cmdline-tools/cmdline-tools.zip

# Install Android SDK components
ENV ANDROID_HOME="/opt/android-sdk"
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Set the working directory to /app
WORKDIR /app

# Create the /app directory and copy the project source code into it
COPY . .

# Remove the build directory if it exists
RUN rm -rf build

# Rebuild the Flutter cache structure and copy the new Dart SDK
RUN mkdir -p /sdks/flutter/bin/cache/dart-sdk && \
    cp -r /usr/local/dart-sdk/* /sdks/flutter/bin/cache/dart-sdk

# Install Flutter dependencies
RUN flutter pub get

# Build the Flutter application into a release APK
RUN flutter build apk --release

# Start the container with bash for interaction
CMD ["bash"]
