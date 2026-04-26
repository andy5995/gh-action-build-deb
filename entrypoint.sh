#!/bin/bash
set -e
if [ -n "$INPUT_SOURCES" ]; then
    echo $INPUT_SOURCES >> /etc/apt/sources.list
fi
if [ -n "$INPUT_PPA" ]; then
    add-apt-repository "ppa:$INPUT_PPA" -y
fi

# Normalize INPUT_ARGS: users may supply a multiline YAML block scalar, which
# embeds newlines. Collapse them to spaces so the args stay on one line when
# expanded inside the bash -c string passed to dpkg-buildpackage.
INPUT_ARGS="${INPUT_ARGS//$'\n'/ }"

apt update && apt upgrade -y

# Set the install command to be used by mk-build-deps (use --yes for non-interactive)
install_tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes"
# Install build dependencies automatically
mk-build-deps -i -r --tool="${install_tool}" debian/control

# dpkg-buildpackage writes output files (*.deb, *.changes, etc.) to the
# parent of the source directory. Copy the source into a staging area
# owned by builder so both the source dir and its parent are writable.
STAGING=$(mktemp -d /tmp/deb-build.XXXXXX)
SRC_COPY="$STAGING/$(basename "$PWD")"
cp -a "$PWD/." "$SRC_COPY"
chown -R builder:builder "$STAGING"

runuser -u builder -- bash -c "
  cd '$SRC_COPY' &&
  dpkg-buildpackage -rfakeroot $INPUT_ARGS
"

ls -l "$STAGING"

lintian_exit_code=0
if [ "$INPUT_LINTIAN_CHECK" = "true" ]; then
    CHANGES=$(ls "$STAGING"/*.changes | head -n1)
    runuser -u builder -- lintian "$CHANGES" || lintian_exit_code=$?
    if [ "$INPUT_FAIL_ON_LINTIAN_ERROR" != "false" ] && [ "$lintian_exit_code" -ne 0 ]; then
        echo "lintian check failed (exit code $lintian_exit_code)"
        exit "$lintian_exit_code"
    fi
fi

mkdir -p /workspace/output/
# Move the built packages into the Docker mounted workspace
for f in "$STAGING"/*.deb "$STAGING"/*.dsc "$STAGING"/*.changes \
         "$STAGING"/*.buildinfo "$STAGING"/*.tar.*; do
    [ -f "$f" ] && mv -v "$f" /workspace/output/
done
