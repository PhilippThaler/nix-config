{
  description = "Philipp's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix/b027ee29d959fda4b60b57566d64c98a202e0feb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    lanzaboote,
    agenix,
    ...
  } @ inputs: {
    # agenix CLI exposed so `nix run .#agenix -- -e ...` uses the pinned version
    packages = nixpkgs.lib.genAttrs ["x86_64-linux"] (system: {
      agenix = agenix.packages.${system}.agenix;
      default = agenix.packages.${system}.default;
    });

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./nixos/configuration.nix

        lanzaboote.nixosModules.lanzaboote

        agenix.nixosModules.age

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
          home-manager.backupFileExtension = "hm-backup";
          home-manager.users.philipp = import ./home-manager/home.nix;
        }
      ];
    };
  };
}
