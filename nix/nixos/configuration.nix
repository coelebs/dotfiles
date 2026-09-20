# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  # Module imports are resolved before NixOS creates `pkgs`. Keep the channel
  # path separate so the DMS module below can be imported at that early stage.
  unstablePath = <nixpkgs-unstable>;

  # Packages are resolved later, once `pkgs` is available. This is the package
  # set used for Hyprland, DMS Greeter, and the other explicit unstable pins.
  unstable = import unstablePath {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  opencode-1_18_29 =
    (builtins.getFlake
      "github:NixOS/nixpkgs/d91a239ca0118ff10ee22ba54f48929c38ab8114"
    ).legacyPackages.${pkgs.system}.opencode;

  # Use unstable Hyprland for omarchyDesktop helpers (hyprctl, etc.) so they
  # match the running compositor. Omarchy expects >=0.56.2 for the
  # `workspace.special_active` event in default/hypr/qconsole.lua, while
  # stable pkgs.hyprland is still 0.55.4 which logs a Lua error on startup.
  omarchyDesktop = pkgs.callPackage /home/vin/Projects/omarchy/default.nix { hyprland = unstable.hyprland; };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixos-hardware/framework/13-inch/intel-core-ultra-series3>

      # The stable NixOS module launches the legacy DMS Shell greeter script.
      # The current DMS greeter is a separate program, so it needs the newer
      # module from the same unstable channel as the program below.
      "${unstablePath}/nixos/modules/services/display-managers/dms-greeter.nix"
    ];

  # Do not load both DMS greeter modules. The stable module expects an old
  # `dms-shell/share/quickshell/dms/...` directory that newer DMS packages no
  # longer provide, which results in a black screen and "No such file or
  # directory" at login. The imported unstable module instead runs the
  # `dms-greeter` executable directly.
  disabledModules = [ "services/display-managers/dms-greeter.nix" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "0";
  boot.loader.efi.canTouchEfiVariables = true;

  # Show a graphical boot splash instead of the early boot console.
  boot.plymouth.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # DMS is the graphical login interface, but it is not a Wayland compositor.
  # Greetd therefore starts a small, temporary Hyprland session to display DMS.
  # After a successful login, that greeter session exits and your normal
  # Hyprland session starts.
  #
  # Keep the module and package on the same channel. The old stable module was
  # written for `dms-shell` 1.4.x. Modern DMS provides a separate
  # `dms-greeter` program that generates a Lua Hyprland configuration, avoiding
  # Hyprland's deprecated `.conf` configuration-format warning.
  services.displayManager.dms-greeter = {
    enable = true;
    package = unstable.dms-greeter;
    compositor.name = "hyprland";
    configFiles = [
      (pkgs.writeText "session.json" (builtins.toJSON {
        wallpaperPath = "";
        wallpaperPathDark = "";
        wallpaperPathLight = "";
      }))
    ];
  };

  # DMS Greeter's module populates this cache before this hook runs. Resolve
  # Omarchy's active-background link so the next greeter uses the same image.
  systemd.services.greetd.preStart = lib.mkAfter ''
    source="/home/vin/.local/state/omarchy/current/background"
    cache="/var/lib/dms-greeter"
    wallpaper="$cache/omarchy-wallpaper"

    if [ -e "$source" ]; then
      ${pkgs.coreutils}/bin/cp --dereference -- "$source" "$wallpaper"
      if [ -f "$cache/session.json" ]; then
        ${pkgs.jq}/bin/jq --arg wallpaper "$wallpaper" '
          .wallpaperPath = $wallpaper
          | .wallpaperPathDark = $wallpaper
          | .wallpaperPathLight = $wallpaper
        ' "$cache/session.json" > "$cache/session.json.tmp"
      else
        ${pkgs.jq}/bin/jq -n --arg wallpaper "$wallpaper" '
          {
            wallpaperPath: $wallpaper,
            wallpaperPathDark: $wallpaper,
            wallpaperPathLight: $wallpaper
          }
        ' > "$cache/session.json.tmp"
      fi
      ${pkgs.coreutils}/bin/mv "$cache/session.json.tmp" "$cache/session.json"
      ${pkgs.coreutils}/bin/chown dms-greeter:dms-greeter "$wallpaper" "$cache/session.json"
    fi
  '';

  # XFCE remains installed until Hyprland is ready to replace it.
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "overload(control, esc)";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."vin" = {
    isNormalUser = true;
    description = "Vincent Kriek";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # Pin compositor to unstable: Omarchy needs Hyprland >=0.56.2
    # (`workspace.special_active`), stable is 0.55.4 and emits
    # `qconsole.lua:156: unknown event "workspace.special_active"`.
    package = unstable.hyprland;
    # Keep portal from same unstable set as the compositor to avoid
    # protocol version skew. Must be set here, not in xdg.portal.extraPortals,
    # because the module already adds portalPackage to extraPortals itself;
    # listing it twice causes a duplicate
    # `xdg-desktop-portal-hyprland.service` symlink collision on rebuild.
    portalPackage = unstable.xdg-desktop-portal-hyprland;
  };

  # Core system services used by Omarchy's Quickshell desktop.
  security.polkit.enable = true;
  security.pam.services.omarchy-lock-password = {};
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  hardware.bluetooth.enable = true;

  # GTK applications, including Firefox, use this desktop color preference.
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };
    }
  ];

  #TODO move this to the nix-init things
  environment.sessionVariables.OMARCHY_PATH =
    "/run/current-system/sw/share/omarchy";

  environment.pathsToLink = [ "/share/omarchy" ];

  fonts = {
    packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
    fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    opencode-1_18_29
    ghostty
    quickshell
    git
    codex
    omarchyDesktop
    udiskie
    hyprpicker
    hyprsunset
    grim
    slurp
    wl-clipboard
    pamixer
    brightnessctl
    stow
    ripgrep
    lua-language-server
    stylua
    xdg-terminal-exec
    starship
    unzip
    rapid-photo-downloader
    tmux
    fzf
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
