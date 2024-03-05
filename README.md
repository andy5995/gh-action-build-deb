# GitHub Action to build Debian packages

This is a [GitHub Action](https://github.com/features/actions) that will
build a [Debian package](https://en.wikipedia.org/wiki/Deb_%28file_format%29)
(`.deb` file) for Debian bookworm.

This is a fork of
[legoktm/gh-action-build-deb](https://github.com/legoktm/gh-action-build-deb).

Note this Action is not yet complete.

## Usage

```yaml
on: [push]

jobs:
  build-deb:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: andy5995/gh-action-build-deb@v1
        id: build-debian-bookworm
        with:
          args: --no-sign

      - uses: actions/upload-artifact@v4
        with:
          name: Packages for bookworm
          path: output
```

This Action will build both a source package and then a binary package and place
them in a `output/` directory.

## Configuration

* `args`: arguments to pass to `dpkg-buildpackage`
* `sources`: repositories to add to `/etc/apt/sources.list`
* `ppa`: Name of Ubuntu PPA to add (no ppa: prefix)

## Related actions

* [gh-action-auto-dch](https://github.com/legoktm/gh-action-auto-dch) automatically adds a changelog entry based on the git information and distro.
* [gh-action-dput](https://github.com/legoktm/gh-action-dput) uploads built packages to a PPA or repository.

## License

Copyright © 2020 Kunal Mehta under the GPL, version 3 or any later version.
Originally based off of the [nylas/gh-action-build-deb-buster](https://github.com/nylas/gh-action-build-deb-buster)
action, which is Copyright © 2020 David Baumgold under the MIT License.
