#!/bin/sh
set -e

WORKFLOW='.github/workflows/test.yml'

MAJOR_VERSION=$(grep 'MAJOR_VERSION:' "$WORKFLOW" | grep -o 'v[0-9]*')
CHECKOUT_VER=$(grep 'actions/checkout@' "$WORKFLOW" | head -1 | sed 's/.*actions\/checkout@//')

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

awk '/@@BEGIN_EXAMPLE@@/{found=1; next} /@@END_EXAMPLE@@/{found=0} found{print}' "$WORKFLOW" \
  | sed \
    -e "s|\./_action_test|andy5995/gh-action-build-deb@${MAJOR_VERSION}|" \
    -e 's|archive_url:.*|archive_url: https://example.com/myproject-1.0.tar.gz|' \
    -e '/codename: \${{ matrix.codename }}/d' \
    -e '/lintian_check:/d' \
    -e '/fail_on_lintian_error:/d' \
    -e 's|name: \${{ env.DEB_FILENAME }}-\${{ matrix.codename }}|name: ${{ env.DEB_FILENAME }}|' \
  > "$tmpfile"

awk \
  -v checkout="$CHECKOUT_VER" \
  -v tmpfile="$tmpfile" \
  '{
    gsub(/@CHECKOUT_VERSION@/, checkout)
    if (/^@@EXAMPLE@@$/) {
      while ((getline line < tmpfile) > 0) print line
    } else {
      print
    }
  }' README.md.in > README.md

echo "README.md generated."
