FROM arris/dev:latest

RUN \
    # See: https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
    curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - \
    # https://yarnpkg.com/lang/en/docs/install/#linux-tab
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
        && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
    # Install system packages
    && apt-get update -y \
    && apt-get install -yq \
        # Node
        nodejs yarn \
        # Watchman Dependencies
        autoconf automake build-essential python-dev libssl-dev libtool pkg-config \
    && apt-get clean \
    # Configure and install yarn packages
    && export PATH="`yarn global bin`:${PATH}" \
    && yarn global add \
        create-react-native-app \
        react-native-cli 

# Install Android SDK
RUN apt-get update -y \
    && apt-get install -yq \
        android-sdk android-sdk-platform-23 \
    && apt-get clean

# Install Watchman
RUN cd /tmp \
    && git clone https://github.com/facebook/watchman.git \
    && cd watchman/ \
    && git checkout v4.9.0 \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

# TODO(arris): Why purpose does this serve?
ENV ANDROID_HOME /usr/lib/android-sdk
# HACK!
ENV REACT_NATIVE_PACKAGER_HOSTNAME 192.168.138.132 
EXPOSE 5037 19000 19001

# Run
COPY config/android /root/.android
COPY config/supervisor/crna.conf /etc/supervisor/conf.d/crna.conf
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/crna.conf
