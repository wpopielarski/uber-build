#!/bin/sh
#
# Installs aws command line interface. It is needed by uber-build to upload a releaese to S3.

source "$(pwd)/uber-build-config.sh"

VERSION="14.0.6"
PYTHON=$(which python | tail -n 1)
# Installation directory for virtualenv
ENV="."

# Install virtualenv
mkdir -p "$AWS_DIR"
cd "$AWS_DIR" || exit
curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-${VERSION}.tar.gz
tar xfz virtualenv-${VERSION}.tar.gz
$PYTHON virtualenv-$VERSION/virtualenv.py $ENV

# Enter virtualenv
source $AWS/activate

# Install aws tools
pip install awscli

# Asks to add credentials
aws configure

# Leave virtualenv
deactivate

echo ""
echo "Installation of aws environment succeeded."
echo "Enter with:"
echo "  $ source $AWS/activate"
echo "Leave with:"
echo "  $ deactivate"

