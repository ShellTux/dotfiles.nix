{
  curl,
  readFile,
  writeShellApplication,
  ...
}:
{
  source = writeShellApplication {
    name = "09-timezone";

    runtimeInputs = [
      curl
    ];

    text = readFile ./09-timezone.sh;
  };

  type = "basic";
}
