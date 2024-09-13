{
  description = "setup presenterm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # change this to `aarch64-darwin` for arm macbook
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.go
          pkgs.presenterm
        ];
        shellHook = ''
          if [ ! -f ~/.config/presenterm/config.yaml ]; then
            echo "Setting up custom presenterm config"

            mkdir -p ~/.config/presenterm
            echo "---
          snippet:
            exec:
              enable: true" >> ~/.config/presenterm/config.yaml
          fi
          
          exec fish
        '';
      };
    };
}
