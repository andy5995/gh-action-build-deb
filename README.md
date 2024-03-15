# GitHub Action to build a Debian package

This is a [GitHub Action](https://github.com/features/actions) that will build
a [Debian package](https://en.wikipedia.org/wiki/Deb_%28file_format%29)
(`.deb` file) for the latest Debian release. Multiple architectures are
supported.

This is a fork of
[legoktm/gh-action-build-deb](https://github.com/legoktm/gh-action-build-deb).

This Action will build both a source package and then a binary package and
place them in a `output/` directory.

The 'debian' directory containing the files required to create a Debian
package must be in the source root directory (in the example below, it's
copied to the source root directory before the action is run).

## Example
<!-- Don't forget to check the version after the action when copying and pasting -->
```yaml
on: [push]

jobs:
  build-deb:
    strategy:
      matrix:
        platform:
          - amd64
          - arm64
          - 386

    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Copy debian directory
      run: cp -a packaging/debian .

    - uses: andy5995/gh-action-build-deb@v1
      with:
        args: --no-sign
        platform: ${{ matrix.platform }}

    - name: Create sha256sum
      run: |
        DEB_FILENAME=$(basename `find output/*deb`)
        echo "DEB_FILENAME=$DEB_FILENAME" >> $GITHUB_ENV
        cd output
        sha256sum "$DEB_FILENAME" > "../$DEB_FILENAME.sha256sum"

    - name: Upload Artifacts
      uses: actions/upload-artifact@v4
      with:
        name: ${{ env.DEB_FILENAME }}
        path: |
          output/*.deb
          *deb.sha256sum
        if-no-files-found: error
```

## Supported Architectures

    386
    amd64
    arm64
    arm/v7
    ppc64le

## Optional arguments

```
  sources:
    description: 'Any extra sources to add to apt'
    required: false
    default: ''
  ppa:
    description: 'An extra PPA to add to apt (no ppa: prefix)'
    required: false
    default: ''
  args:
    description: 'Arguments to pass to dpkg-buildpackage'
    required: false
  platform:
    description: 'Target architecture'
    required: false
    default: 'amd64'
```

## Related actions

* [gh-action-auto-dch](https://github.com/legoktm/gh-action-auto-dch) automatically adds a changelog entry based on the git information and distro.
* [gh-action-dput](https://github.com/legoktm/gh-action-dput) uploads built packages to a PPA or repository.

## License

Copyright © 2020 Kunal Mehta under the GPL, version 3 or any later version.
Originally based off of the [nylas/gh-action-build-deb-buster](https://github.com/nylas/gh-action-build-deb-buster)
action, which is Copyright © 2020 David Baumgold under the MIT License.
