{
  description = "A simple Go package";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  # Flake utils to make it easier to work with flakes.
  inputs.flake-utils.url = "github:numtide/flake-utils";


  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, agenix }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      packageName = "go-web-skeleton";

      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
    in
    rec
    {
      nixosConfigurations.vbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { };

        modules = [ ./configuration.nix agenix.nixosModules.default ];
      };
      packages.${system} =
        {
          ${packageName} = pkgs.buildGoModule {
            pname = "${packageName}";
            inherit version;
            # In 'nix develop', we don't need a copy of the source tree
            # in the Nix store.
            src = ./.;

            # This hash locks the dependencies of this package. It is
            # necessary because of how Go requires network access to resolve
            # VCS.  See https://www.tweag.io/blog/2021-03-04-gomod2nix/ for
            # details. Normally one can build with a fake sha256 and rely on native Go
            # mechanisms to tell you what the hash should be or determine what
            # it should be "out-of-band" with other tooling (eg. gomod2nix).
            # To begin with it is recommended to set this, but one must
            # remeber to bump this hash when your dependencies change.
            #vendorSha256 = pkgs.lib.fakeSha256;

            vendorSha256 = "sha256-MJrxperTBqZAScrbWW3cIZ+pwCQkykx6XsP52Jgb1cg=";
          };
          dockerImage = pkgs.dockerTools.buildImage {
            name = "go-web-skeleton";
            config = {
              Cmd = [ "${defaultPackage}/bin/server" ];
            };
          };
        };
      defaultPackage.${system} = packages.${system}.${packageName};
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          buf-language-server
          delve
          go-tools
          gopls
          buf
          protobuf
          protoc-gen-go
          protoc-gen-go-grpc
          nixos-rebuild
        ];
        inputsFrom = [ defaultPackage ];
      };
    };

}
