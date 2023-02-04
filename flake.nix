{
  description = "Template for aiken projects";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    # aiken.url="github:waalge/aiken?ref=w/flake";
    # aiken.url="github:waalge/aiken/14f4ac735ea5509875ecb41a131901032bcba972";
    aiken.url = "github:waalge/aiken/8b1673f6bead5bc7e67e976ad7f7f4cb375c183f";
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
