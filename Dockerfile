# Base image
FROM node:20-bookworm-slim

# Copy repository
COPY . /metrics
WORKDIR /metrics

# Setup and install dependencies
RUN set -eux; \
  chmod +x /metrics/source/app/action/index.mjs; \
  \
  # Install Chrome + fonts (for Puppeteer rendering)
  apt-get update; \
  apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    libgconf-2-4 \
    libxss1 \
    libx11-xcb1 \
    libxtst6 \
    lsb-release \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    fonts-freefont-ttf; \
  \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -; \
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends google-chrome-stable; \
  \
  # Install deno
  apt-get install -y --no-install-recommends curl unzip; \
  curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=/usr/local sh; \
  \
  # Install Ruby + dependencies for Nokogiri/licensed
  apt-get install -y --no-install-recommends \
    ruby-full \
    git \
    g++ \
    cmake \
    pkg-config \
    libssl-dev \
    python3 \
    xz-utils; \
  \
  gem install nokogiri -- --use-system-libraries; \
  gem install licensed; \
  \
  # Clean up APT cache and temporary files to shrink image size
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
  \
  # Install Node dependencies
  npm ci; \
  npm run build

# Environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_BROWSER_PATH=google-chrome-stable

# Entrypoint
ENTRYPOINT ["node", "/metrics/source/app/action/index.mjs"]
