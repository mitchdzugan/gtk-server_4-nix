{
  description = "latest version of gtk-server with gtk4 support";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      # Generate a user-friendly version number.
      version = "2.4.7";

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      # Provide some binary packages for selected system types.
      packages = forAllSystems (system: with import nixpkgs { system = system; }; {
        gtk-server = nixpkgsFor.${system}.stdenv.mkDerivation {
          pname = "gtk-server";
          inherit version;

          src = fetchurl {
            url = "https://www.gtk-server.org/stable/gtk-server-${version}.tar.gz";
            sha256 = "sha256-YRvnE4fH5jWITSiMUbtlaOJFKAW0/Alzo1YVDlm8CO8=";
          };

          preConfigure = ''
            cd src
          '';

          nativeBuildInputs = [ pkg-config wrapGAppsHook4 ];
          buildInputs = [ libffcall glib gtk4 ];

          configureOptions = [ "--with-gtk4" ];

          meta = with lib; {
            homepage = "http://www.gtk-server.org/";
            description = "gtk-server for interpreted GUI programming";
            license = licenses.gpl2Plus;
            maintainers = [ ];
            platforms = platforms.linux;
          };
        };
      });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.gtk-server);

      devShell = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        pkgs.mkShell { buildInputs = with pkgs; [ ]; }
      );
    };
}
