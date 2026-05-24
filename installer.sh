#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building and installing Tokodon...${NC}"

# Check if PKGBUILD exists
if [ ! -f PKGBUILD ]; then
    echo -e "${RED}Error: PKGBUILD not found in the current directory.${NC}"
    exit 1
fi

# Run makepkg to build and install
# -s: Install missing dependencies
# -i: Install the package after build
if makepkg -si --noconfirm; then
    echo -e "${GREEN}Installation successful. Cleaning up temporary folders...${NC}"
    # Force clean up of src/ and pkg/ just in case
    rm -rf src pkg
    echo -e "${GREEN}Done!${NC}"
else
    echo -e "${RED}Error: Build or installation failed.${NC}"
    exit 1
fi
