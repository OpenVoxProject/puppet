# OpenVox

OpenVox is a community implementation of Puppet, an automated administrative engine for your Linux, Unix, and Windows systems, performs
administrative tasks (such as adding users, installing packages, and updating server
configurations) based on a centralized specification.

## Documentation

As of now, OpenVox is effectively the same as the original Puppet™️ packages, aside from some minor build pipeline changes and package renaming.
This means that aside from the installation, all Puppet™️ docs and tutorials will still be completely applicable.
As the OpenVox project matures, we will create more documentation, guides, and tutorials.
For the time being though, now you’ll want to hop over to [Puppet’s own documentation](https://puppet.com/docs) and go from there.

### HTTP API

[HTTP API Index](https://puppet.com/docs/puppet/latest/http_api/http_api_index.html)

## Installation

To install OpenVox,
[see our installation guide.](https://voxpupuli.org/openvox/install/) and [quickstart page](https://voxpupuli.org/openvox/quickstart/).

If you need to run OpenVox from source as a tester or developer,
see the [Quick Start to Developing on Puppet](docs/quickstart.md) guide.

## Developing and Contributing

We'd love to get contributions from you! For a quick guide to getting your
system setup for developing, take a look at our [Quickstart
Guide](docs/quickstart.md). Once you are up and running, take a look at the
[Contribution Documents](https://github.com/OpenVoxProject/.github/blob/main/CONTRIBUTING.md) to see how to get your changes merged
in.

For more complete docs on developing with Puppet, take a look at the
rest of the [developer documents](docs/index.md).

## Licensing

See [LICENSE](LICENSE) file. OpenVox is licensed by Vox Pupuli as a community maintained
implementation of Puppet. Vox Pupuli can be contacted at: voxpupuli@groups.io.
Puppet itself is licensed by Puppet, Inc. under the Apache license. Puppet, Inc. can be contacted at: info@puppet.com

## Support

Please log issues in this project's [GitHub Issues](/issues).
Other channels for getting help can be found at our
[support page](https://voxpupuli.org/openvox/support/),
including the mailing list and other community spaces available
for asking questions and getting help from others.


We use semantic version numbers for our releases and recommend that users stay
as up-to-date as possible by upgrading to patch releases and minor releases as
they become available.

Bug fixes and ongoing development will occur in minor releases for the current
major version. Security fixes will be backported to a previous major version on
a best-effort basis, until the previous major version is no longer maintained.

For example: If a security vulnerability is discovered in Puppet 8.1.1, we
would fix it in the 8 series, most likely as 8.1.2. Maintainers would then make
a best effort to backport that fix onto earlier releases that haven't reached
their respective end-of-life dates.
