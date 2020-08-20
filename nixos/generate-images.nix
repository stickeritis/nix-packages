{ nixpkgs, nixos-generators }:

configuration:

let
  # Get the image attribute of the VM configuration.
  generate = format-config: let
    self = generate' format-config;
  in self.config.system.build.${self.config.formatAttr};

  # Generate a VM system configuration.
  generate' = format-config: import "${nixos-generators}/nixos-generate.nix" {
    inherit configuration format-config nixpkgs;
  };

  # QEMU qcow configuration.
  qcowConfiguration = import "${nixos-generators}/formats/qcow.nix";
in {
  qcow = generate qcowConfiguration;
}
