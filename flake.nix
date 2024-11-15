{
  description = "latest version of gtk-server with gtk4 support";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system: with import nixpkgs { system = system; }; {
        packages.default = stdenv.mkDerivation rec {
          pname = "gtk-server";
          version = "2.4.7";

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
}
