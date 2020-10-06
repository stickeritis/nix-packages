{ callPackage, toPythonModule }:

{
  sticker = toPythonModule (callPackage ./sticker {});
}
