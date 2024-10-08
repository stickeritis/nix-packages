# sticker Nix package set

This is a [Nix](https://nixos.org/nix/) package set for sticker and
sticker2. It allows you to install sticker on most Linux
distributions, as well as macOS.

The [sticker](https://hub.docker.com/r/danieldk/sticker) and
[sticker2](https://hub.docker.com/r/danieldk/sticker2) Docker images
are also generated using this package set.

## Supported nixpkgs releases

We pin [nixpkgs](https://github.com/NixOS/nixpkgs) to ensure that the
packages build on every Nix/NixOS configuration. Consequently, it does
not matter whether you use the latest stable version or unstable version
of `nixpkgs`.

## Using the repository

### One-off installs

One-off package installs can be performed without configuration
changes, using e.g. `nix-env`:

~~~shell
$ nix-env \
  -f https://github.com/stickeritis/nix-packages/archive/master.tar.gz \
  -iA sticker2
~~~

### Adding the repository

If you want to use multiple packages from the repository or get
package updates, it is recommended to add the package set to your
local Nix configuration. You can do this be adding the package set to
your `packageOverrides`. To do so, add the following to
`~/.config/nixpkgs/config.nix`:

~~~nix
{
  packageOverrides = pkgs: {
    sticker = import (builtins.fetchTarball "https://github.com/stickeritis/nix-packages/archive/master.tar.gz") {};
  };
}
~~~

Then the packages will be available as attributes under `sticker`,
e.g.  `sticker.sticker2`.

### Pinning a specific revision

Fetching the repository tarball as above will only cache the
repository download for an hour. To avoid this, you should pin the
repository to a specific revision.

~~~nix
{
  packageOverrides = pkgs: {
    sticker = import (builtins.fetchTarball {
      # Get the archive for commit dde7772
      url = "https://github.com/stickeritis/nix-packages/archive/dde7772b36ce49e31be40a172df5120961d1e0b8.tar.gz";
      # Get the SHA256 hash using: nix-prefetch-url --unpack <url>
      sha256 = "0g7vb42vpivqc5xn9i5z64x7r3b4ijdbgmsc7jrcn9lsmrcjvs93";
    }) {};
  };
}
~~~
