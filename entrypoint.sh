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

install_tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes"

# Download the source archive
WORK_DIR=$(mktemp -d /tmp/deb-work.XXXXXX)
ARCHIVE="$WORK_DIR/source.tar"
curl -fsSL "$INPUT_ARCHIVE_URL" -o "$ARCHIVE"

case "$INPUT_ARCHIVE_URL" in
    *.zip)
        apt install -y --no-install-recommends unzip
        unzip "$ARCHIVE" -d "$WORK_DIR"
        ;;
    *) tar -xf "$ARCHIVE" -C "$WORK_DIR" ;;
esac

rm "$ARCHIVE"

# Find the top-level extracted directory
SOURCE_DIR=$(find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d | head -n1)
if [ -z "$SOURCE_DIR" ]; then
    echo "No directory found after extracting archive"
    ls -la "$WORK_DIR"
    exit 1
fi

# Copy debian packaging files from workspace into the source tree
cp -a "/workspace/$INPUT_DEBIAN_PATH" "$SOURCE_DIR/debian"

# Install build dependencies
mk-build-deps -i -r --tool="${install_tool}" "$SOURCE_DIR/debian/control"

# dpkg-buildpackage writes output files to the parent of the source directory;
# WORK_DIR serves as that parent. Set ownership so builder can write everywhere.
chown -R builder:builder "$WORK_DIR"

runuser -u builder -- bash -c "
  cd '$SOURCE_DIR' &&
  dpkg-buildpackage -rfakeroot $INPUT_ARGS
"

ls -l "$WORK_DIR"

lintian_exit_code=0
if [ "$INPUT_LINTIAN_CHECK" = "true" ]; then
    CHANGES=$(ls "$WORK_DIR"/*.changes | head -n1)
    runuser -u builder -- lintian "$CHANGES" || lintian_exit_code=$?
    if [ "$INPUT_FAIL_ON_LINTIAN_ERROR" != "false" ] && [ "$lintian_exit_code" -ne 0 ]; then
        echo "lintian check failed (exit code $lintian_exit_code)"
        exit "$lintian_exit_code"
    fi
fi

mkdir -p /workspace/output/
for f in "$WORK_DIR"/*.deb "$WORK_DIR"/*.dsc "$WORK_DIR"/*.changes \
         "$WORK_DIR"/*.buildinfo "$WORK_DIR"/*.tar.*; do
    [ -f "$f" ] && mv -v "$f" /workspace/output/
done
