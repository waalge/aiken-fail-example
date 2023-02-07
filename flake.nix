{
  description = "Template for aiken projects";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    # aiken.url="github:waalge/aiken?ref=w/flake";
    # aiken.url = "github:waalge/aiken/d88548bf17b5b7d91d604f18f53c2c93dd4f2c1f";
    aiken.url = "github:aiken-lang/aiken/5cefe260789e0e0c4c3f33ceced31565c46e2aeb";
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
              nvim -S ${self}/.nvim-aiken/ftdetect/aiken.vim \
                   -S ${self}/.nvim-aiken/indent/aiken.vim \
                   -S ${self}/.nvim-aiken/syntax/aiken.vim \
                   --cmd "autocmd FileType aiken setlocal shiftwidth=2 tabstop=2" \
                  $1
            '';
          }
        ];
      };
    });
}
