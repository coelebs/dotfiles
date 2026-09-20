# This module declares the small owner-specific interface required by reusable
# workstation modules. Hosts set these values instead of embedding a username.
{ lib, ... }:

{
  options.dotfiles = {
    primaryUser = lib.mkOption {
      type = lib.types.str;
      description = "Name of the primary workstation user.";
    };

    primaryUserFullName = lib.mkOption {
      type = lib.types.str;
      description = "Display name of the primary workstation user.";
    };
  };
}
