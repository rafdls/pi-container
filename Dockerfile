FROM node:22-bookworm

RUN apt-get update && apt-get install -y \
    bash \
    ca-certificates \
    curl \
    fd-find \
    git \
    jq \
    less \
    openjdk-17-jdk-headless \
    openssh-client \
    ripgrep \
    unzip \
    vim \
    zsh \
  && rm -rf /var/lib/apt/lists/*

# JDK 17 is required to run Gradle 8.2 / Android Gradle Plugin 8.2.2.
# The install path is arch-specific (amd64/arm64), so resolve it dynamically.
RUN ln -s "$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")" /opt/java-home
ENV JAVA_HOME=/opt/java-home
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Android SDK. Only the command-line tools plus the packages the app needs:
# platform-tools, platforms;android-34 (compileSdk/targetSdk 34) and
# build-tools;34.0.0. No NDK or emulator (unit tests run on the JVM).
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_CMDLINE_TOOLS_VERSION=11076708
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

RUN mkdir -p "${ANDROID_HOME}/cmdline-tools" \
  && curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" -o /tmp/cmdline-tools.zip \
  && unzip -q /tmp/cmdline-tools.zip -d "${ANDROID_HOME}/cmdline-tools" \
  && mv "${ANDROID_HOME}/cmdline-tools/cmdline-tools" "${ANDROID_HOME}/cmdline-tools/latest" \
  && rm /tmp/cmdline-tools.zip \
  && (yes || true) | sdkmanager --licenses > /dev/null \
  && sdkmanager --install \
       "platform-tools" \
       "platforms;android-34" \
       "build-tools;34.0.0" \
  && chmod -R a+rwX "${ANDROID_HOME}"

# Install Pi coding agent.
RUN npm install -g @earendil-works/pi-coding-agent@0.80.7

# Create a non-root user.
RUN useradd -m -s /bin/bash piagent

# Add common Git hosts to known_hosts so SSH git works without prompting.
RUN mkdir -p /home/piagent/.ssh \
  && ssh-keyscan github.com gitlab.com bitbucket.org >> /home/piagent/.ssh/known_hosts \
  && chown -R piagent:piagent /home/piagent/.ssh \
  && chmod 700 /home/piagent/.ssh \
  && chmod 644 /home/piagent/.ssh/known_hosts

USER piagent

RUN mkdir -p /home/piagent/.pi/agent

WORKDIR /workspace

CMD ["/bin/bash"]
