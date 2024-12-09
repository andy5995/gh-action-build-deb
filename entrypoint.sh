#!/bin/bash
set -e
if [ -n "$INPUT_SOURCES" ]; then
    echo $INPUT_SOURCES >> /etc/apt/sources.list
fi
if [ -n "$INPUT_PPA" ]; then
    if [ "$INPUT_CODENAME" != "trixie" ]; then
        add-apt-repository "ppa:$INPUT_PPA" -y
    else
        # software-properties-common (package that contains add-apt-repository)
        # has been removed from testing
        # https://tracker.debian.org/pkg/software-properties
        #
        # Extract repository name from INPUT_PPA (e.g., "ppa:repo-name" -> "repo-name")
        repo_name=$(echo "$INPUT_PPA" | cut -d: -f2)

        # Add the PPA to the sources list
        echo "deb http://ppa.launchpad.net/$repo_name/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/$repo_name.list

        # Import the GPG key for the PPA
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$(curl -fsSL https://keyserver.ubuntu.com/pks/lookup?search=0x$repo_name | grep pub -m1 | awk '{print $2}')"
    fi
fi

apt update && apt upgrade -y

# Set the install command to be used by mk-build-deps (use --yes for non-interactive)
install_tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes"
# Install build dependencies automatically
mk-build-deps --install --tool="${install_tool}" debian/control
# First build the source package
dpkg-buildpackage --build=source $INPUT_ARGS
# Then a normal build
dpkg-buildpackage $INPUT_ARGS
# Output the filename
cd ..
ls -l
mkdir -p /workspace/output/
# Move the built package into the Docker mounted workspace
mv -v *.{deb,dsc,changes,buildinfo,tar.*} /workspace/output/
