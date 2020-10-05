let self =
  import (import ./sources.nix).nixpkgs {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (self.lib.getName pkg) [
        "libtorch"
      ];
    };
  };
in self
