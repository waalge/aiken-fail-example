{
  description = "Template for aiken projects";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    aiken.url = "github:aiken-lang/aiken/f747ee0aca9dd1a7a0dbd7889f3e11ccb5bc0655";
  };

  outputs = {self, ...} @ inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.devshell.overlay
          (self: super: {aiken = inputs.aiken.packages.${system}.aiken;})
        ];
      };
    in {
      devShell = pkgs.devshell.mkShell {
        name = "hello-aiken";
        packages = with pkgs; [
          aiken
          deno
          rnix-lsp
          alejandra
        ];
        commands = [
          {
            name = "edit";
            category = "editor";
            help = "open nvim with aiken config";
            command = ''
              nvim -c "source ${self}/.nvim-aiken/ftdetect/aiken.vim" \
                   -c "source ${self}/.nvim-aiken/indent/aiken.vim" \
                   -c "source ${self}/.nvim-aiken/syntax/aiken.vim" \
                   -c "set shiftwidth=2" \
                  $1
            '';
          }
        ];
      };
    });
}
