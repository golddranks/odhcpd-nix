{
  description = "odhcpd dev environment";

  inputs = {
    nixpkgs.url = "nixpkgs";
    odhcpd = {
      url = "git+https://git.openwrt.org/project/odhcpd.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, odhcpd }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default = pkgs.stdenv.mkDerivation {
          pname = "odhcpd";
          version = "2023-01-16-c9e619f";
          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = with pkgs; [ libnl-tiny libubox uci ];
          src = odhcpd;
        };
      });
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = with pkgs; [ libnl-tiny libubox uci ];
          src = odhcpd;
          shellHook = ''
            rm -rf source
            unpackPhase
            cd source
            cmakeConfigurePhase
          '';
        };
      });
    };
}
