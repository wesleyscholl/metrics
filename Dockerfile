# Base image
FROM node:20-bookworm-slim

# Copy repository
COPY . /metrics
WORKDIR /metrics

# Setup
RUN chmod +x /metrics/source/app/action/index.mjs \
  && apt-get update \
  # Install Google Chrome dependencies + fonts
  && apt-get install -y wget gnupg ca-certificates libgconf-2-4 libxss1 libx11-xcb1 libxtst6 lsb-release --no-install-recommends \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf --no-install-recommends \
  # Install deno for miscellaneous scripts
  && apt-get install -y curl unzip \
  && curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=/usr/local sh \
  # Install build tools, Ruby, and development headers for Nokogiri
  && apt-get install -y \
      **build-essential** \
      ruby-full git g++ cmake pkg-config libssl-dev \
      python3 \
      libxml2-dev libxslt1-dev zlib1g-dev \
      --no-install-recommends \
  # Install licensed gem (Nokogiri is a dependency)
  && gem install licensed \
  # Clean apt/lists
  && rm -rf /var/lib/apt/lists/* \
  # Install node modules and rebuild indexes
  && npm ci \
  && npm run build
