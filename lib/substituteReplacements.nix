{lib, ...}: {
  withFail ? false,
  replacements,
}: let
  inherit (lib) all assertMsg concatMapStringsSep head isBool last length;

  example = ''
    Example:

    ```
    replacements = [
      ["#1e1e2e" "#000000"]
      ["#181825" "#010101"]
      ["#11111b" "#020202"]
    ];

    ```
  '';

  replace = pair: let
    from = head pair;
    to = last pair;
    option =
      if withFail
      then "--replace-fail"
      else "--replace-quiet";
  in "${option} '${from}' '${to}'";
in
  assert assertMsg (isBool withFail) ''
    `withFail` must be a boolean.
  '';
  assert assertMsg (replacements != []) ''
    Substitute replacements must be non-empty list of pairs.

    ${example}
  '';
  assert assertMsg (all (pair: length pair == 2) replacements) ''
    Each substitute replacement must be a pair.

    ${example}
  '';
    concatMapStringsSep " " replace replacements
