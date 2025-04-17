rec {
  core = import ./core;

  desktop = inputs: core inputs // (import ./desktop inputs);
  laptop = inputs: core inputs // (import ./laptop inputs);
}
