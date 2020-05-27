# Build Debian Package

This is a [GitHub Action](https://github.com/features/actions) that will
build a [Debian package](https://en.wikipedia.org/wiki/Deb_%28file_format%29)
(`.deb` file) for various Debian or Ubuntu versions.

## Usage

```yaml
on: [push]

jobs:
  build-deb:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - uses: legoktm/gh-action-build-deb@debian-buster
        id: build-debian-buster
        with:
          args: --nosign

      - uses: actions/upload-artifact@v1
        with:
          name: Packages for buster
          path: output
```

This Action will build both a source package and then a binary package and place
them in a `output/` directory.

Each Debian/Ubuntu version to build for has its own branch. The following are
currently supported:

* `debian-buster` aka [Debian 9](https://www.debian.org/releases/buster/)
* `debian-bullseye` aka Debian 10 (currently testing, still unreleased)
* `debian-unstable` aka Debian Sid

* `ubuntu-bionic` aka [Ubuntu 18.04 LTS](https://en.wikipedia.org/wiki/Ubuntu_version_history#1804)
* `ubuntu-eoan` aka [Ubuntu 19.10](https://en.wikipedia.org/wiki/Ubuntu_version_history#1910)
* `ubuntu-focal` aka [Ubuntu 20.04 LTS](https://en.wikipedia.org/wiki/Ubuntu_version_history#2004)
* `ubuntu-groovy` aka [Ubuntu 20.10](https://en.wikipedia.org/wiki/Ubuntu_version_history#2010) (unreleased)

The optional `args` input will be passed to `dpkg-buildpackage`.

## Related actions

* [gh-action-auto-dch](https://github.com/legoktm/gh-action-auto-dch) automatically adds a changelog entry based on the git information and distro.
* [gh-action-dput](https://github.com/legoktm/gh-action-dput) uploads built packages to a PPA or repository.


## Multiple OS versions

A multi-OS version package building matrix might look like:

```yaml
on: [push, pull_request]

jobs:
  build-deb:
    runs-on: ubuntu-latest
    strategy:
      matrix: 
        distro: [ubuntu-focal, ubuntu-eoan, ubuntu-bionic, debian-buster]
    steps:
      - uses: actions/checkout@v2

      - uses: legoktm/gh-action-build-deb@ubuntu-focal
        if: matrix.distro == 'ubuntu-focal'
        name: Build package for ubuntu-focal
        id: build-ubuntu-focal
        with:
          args: --no-sign

      - uses: legoktm/gh-action-build-deb@ubuntu-eoan
        if: matrix.distro == 'ubuntu-eoan'
        name: Build package for ubuntu-eoan
        id: build-ubuntu-eoan
        with:
          args: --no-sign

      - uses: legoktm/gh-action-build-deb@ubuntu-bionic
        if: matrix.distro == 'ubuntu-bionic'
        name: Build package for ubuntu-bionic
        id: build-ubuntu-bionic
        with:
          args: --no-sign

      - uses: legoktm/gh-action-build-deb@debian-buster
        if: matrix.distro == 'debian-buster'
        name: Build package for debian-buster
        id: build-debian-buster
        with:
          args: --no-sign

      - uses: actions/upload-artifact@v2
        with:
          name: Packages for ${{ matrix.distro }}
          path: output
```

## License

Copyright © 2020 Kunal Mehta under the GPL, version 3 or any later version.
Originally based off of the [nylas/gh-action-build-deb-buster](https://github.com/nylas/gh-action-build-deb-buster)
action, which is Copyright © 2020 David Baumgold under the MIT License.
