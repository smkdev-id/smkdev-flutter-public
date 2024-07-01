#!/usr/bin/env bash
set -e

SUDO=""
VERSION="3.22.2"
FILE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$VERSION-stable.tar.xz"
DEST_DIR="$HOME"
FILE_NAME="$(basename "$FILE_URL")"

# Use sudo if not root
if [[ ! $(id -u) -eq 0 ]]; then
  if [[ -z $(which sudo) ]]; then
    echo "Please install sudo or run as root"
    exit 1
  fi
  SUDO="sudo"
fi

# Install common packages
function install_ubuntu_common_requirements() {
  $SUDO apt-get update
  $SUDO apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    libc6:amd64 \
    libstdc++6:amd64 \
    libbz2-1.0:amd64 \
    libncurses5:amd64
}

# Install extra packages
function install_extra_packages() {
  echo "Installing extra packages..."
  $SUDO apt-get install -y --no-install-recommends \
    casync \
    cmake \
    make \
    clinfo \
    libqt5sql5-sqlite \
    libreadline-dev \
    libdw1 \
    autoconf \
    libtool \
    bzip2 \
    libarchive-dev \
    libncursesw5-dev \
    libportaudio2 \
    locales
}

# Install Ubuntu 24.04 LTS packages
function install_ubuntu_lts_latest_requirements() {
  install_ubuntu_common_requirements

  $SUDO apt-get install -y --no-install-recommends \
    g++-12 \
    qtbase5-dev \
    qtchooser \
    qt5-qmake \
    qtbase5-dev-tools \
    python3-dev \
    python3-venv
}

# Install Ubuntu 20.04 packages
function install_ubuntu_focal_requirements() {
  install_ubuntu_common_requirements

  $SUDO apt-get install -y --no-install-recommends \
    libavresample-dev \
    qt5-default \
    python-dev
}

# Download and Install Flutter lts versions
function install_flutter_lts(){
  wget -O "$DEST_DIR/$FILE_NAME" "$FILE_URL"
  tar -xf "$DEST_DIR/$FILE_NAME" -C "$DEST_DIR"

  if ! grep -q 'export PATH="$HOME/flutter/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
  fi
  source ~/.bashrc
  rm -f "$DEST_DIR/$FILE_NAME"

  # Check if Flutter is properly installed
  flutter doctor
}

# Detect OS using /etc/os-release file
if [ -f "/etc/os-release" ]; then
  source /etc/os-release
  case "$VERSION_CODENAME" in
    "jammy" | "kinetic" | "noble")
      install_ubuntu_lts_latest_requirements
      ;;
    "focal")
      install_ubuntu_focal_requirements
      ;;
    *)
      echo "$ID $VERSION_ID is unsupported. This setup script is written for Ubuntu 20.04."
      read -p "Would you like to attempt installation anyway? " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
      fi
      if [ "$UBUNTU_CODENAME" = "focal" ]; then
        install_ubuntu_focal_requirements
      else
        install_ubuntu_lts_latest_requirements
      fi
  esac

  # Install extra packages
  if [[ -z "$INSTALL_EXTRA_PACKAGES" ]]; then
    read -p "Base setup done. Do you want to install extra development packages? [Y/n]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      INSTALL_EXTRA_PACKAGES="yes"
    fi
  fi
  if [[ "$INSTALL_EXTRA_PACKAGES" == "yes" ]]; then
    install_extra_packages
  fi
else
  echo "No /etc/os-release in the system. Make sure you're running on Ubuntu, or similar."
  exit 1
fi

# Install Flutter based on condition
if [[ -z "$INSTALL_FLUTTER" ]]; then
  read -p "Do you want to install Flutter? [Y/n]: " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    INSTALL_FLUTTER="yes"
  fi
fi

if [[ "$INSTALL_FLUTTER" == "yes" ]]; then
  install_flutter_lts
fi