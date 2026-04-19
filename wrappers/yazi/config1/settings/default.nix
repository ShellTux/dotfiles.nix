inputs: {
  keymap = import ./keymap.nix { inherit inputs; };
  opener = import ./opener.nix { inherit inputs; };
  open = import ./open.nix { inherit inputs; };
}
