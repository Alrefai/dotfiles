{lib, ...}: from: to:
assert lib.assertMsg (lib.isAttrs from) ''
  The first argument must be an attribute set.
'';
assert lib.assertMsg (lib.isAttrs to) ''
  The second argument must be an attribute set.
'';
assert lib.assertMsg (
  lib.all (name: lib.hasAttr name from) (lib.attrNames to)
) ''
  Every attribute in the second argument must also exist in the first
  argument.
'';
assert lib.assertMsg (
  lib.all lib.isString (lib.attrValues from)
) ''
  All attribute values in the first argument must be strings.
'';
assert lib.assertMsg (
  lib.all lib.isString (lib.attrValues to)
) ''
  All attribute values in the second argument must be strings.
'';
  lib.mapAttrsToList (name: toValue: [from.${name} toValue]) to
