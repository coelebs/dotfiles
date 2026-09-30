# This module installs the packaged Omarchy runtime and every executable its
# desktop configuration invokes, so feature dependencies do not pollute the
# general-purpose system package list.
{ omarchyShell, ... }:

{
  environment.systemPackages =
    [ omarchyShell ] ++ omarchyShell.runtimeDependencies;

  environment.sessionVariables.OMARCHY_PATH = "${omarchyShell}/share/omarchy";
  environment.pathsToLink = [ "/share/omarchy" ];
}
