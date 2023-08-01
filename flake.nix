{
  description = "odhcpd dev environment";

  inputs = {
    nixpkgs.url = "nixpkgs";
    odhcp = {
      url = "git+https://git.openwrt.org/project/odhcpd.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, odhcp }:
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
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = with pkgs; [ libnl-tiny libubox uci ];
          src = odhcp;
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
