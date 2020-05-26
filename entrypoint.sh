#!/bin/bash
set -e
# Set the install command to be used by mk-build-deps (use --yes for non-interactive)
install_tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes"
# Install build dependencies automatically
mk-build-deps --install --tool="${install_tool}" debian/control
# First build the source package
dpkg-buildpackage --build=source $@
# Then a normal build
dpkg-buildpackage $@
# Output the filename
cd ..
ls -l
# Move the built package into the Docker mounted workspace
mv -v *.{deb,dsc,changes,buildinfo,tar.xz} workspace/
