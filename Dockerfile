# Use the base App Engine Docker image, based on Ubuntu 16.0.4.
FROM gcr.io/gcp-runtimes/ubuntu_16_0_4:latest

# Install updates and dependencies
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y -q \
      build-essential \
      ca-certificates \
      curl \
      git \
      nodejs \
      npm \
      imagemagick \
      libkrb5-dev \
      netbase \
      python && \
    apt-get clean && \
    rm /var/lib/apt/lists/*_*

# Add the files necessary for verifying and installing node.
#ADD contents/ /opt/gcp/runtime/
RUN ln -s /opt/gcp/runtime/install_node /usr/local/bin/install_node

# Install the latest LTS release of nodejs directly from nodejs.org
# with the installation aborting if verification of the nodejs binaries fails.
#RUN /opt/gcp/runtime/bootstrap_node \
#    --direct \
#    v10.14.2
ENV PATH $PATH:/nodejs/bin

# Install yarn
RUN mkdir -p /opt/yarn && curl -L https://yarnpkg.com/latest.tar.gz | tar xvzf - -C /opt/yarn --strip-components=1
ENV PATH $PATH:/opt/yarn/bin

# The use of --unsafe-perm is used here so that the installation is done
# as the current (root) user.  Otherwise, a failure in running 'npm install'
# (for example through a failure in a pre-or-post install hook) won't cause
# npm install to have a non-zero exit code.

# Install semver as required by the node version install script.
# Set common env vars
ENV NODE_ENV production
ENV PORT 8080

WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source
COPY . .

EXPOSE 8080
CMD ["npm", "start"]
