{
  pkgs,
  wrappers,
  ...
}: let
  starship = wrappers.wrapperModules.starship.apply {
    inherit pkgs;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      command_timeout = 3000;
      container = {disabled = true;};
      git_branch = {symbol = " ";};
      hostname = {ssh_symbol = " ";};
      os = {
        disabled = false;
        symbols = {
          Arch = " ";
          Macos = "";
          NixOS = " ";
          Ubuntu = " ";
        };
      };
      palettes.catppuccin_mocha = {
        base = "#000000";
        blue = "#89b4fa";
        crust = "#020202";
        flamingo = "#f2cdcd";
        green = "#a6e3a1";
        lavender = "#b4befe";
        mantle = "#010101";
        maroon = "#eba0ac";
        mauve = "#cba6f7";
        overlay0 = "#6c7086";
        overlay1 = "#7f849c";
        overlay2 = "#9399b2";
        peach = "#fab387";
        pink = "#f5c2e7";
        red = "#f38ba8";
        rosewater = "#f5e0dc";
        sapphire = "#74c7ec";
        sky = "#89dceb";
        subtext0 = "#a6adc8";
        subtext1 = "#bac2de";
        surface0 = "#313244";
        surface1 = "#45475a";
        surface2 = "#585b70";
        teal = "#94e2d5";
        text = "#cdd6f4";
        yellow = "#f9e2af";
      };
      shell = {
        disabled = false;
        format = "[$indicator]($style)";
        bash_indicator = " ";
        zsh_indicator = "";
      };
    };
  };
in {
  starship = starship.wrapper;
}
