_: {
  projectRootFile = ".git/config";
  programs = {
    alejandra.enable = true;
    dprint = {
      enable = true;
      includes = [
        "**/*.{astro,html,ts,tsx,js,mjs,cjs,jsx,json,jsonc,toml,yaml,yml,md}"
        "**/*.{graphql,gql,ipynb,py,pyi}"
        "Dockerfile"
      ];
      excludes = ["node_modules" "*-lock.json" "*-lock.yaml" "dist"];
      settings = {
        incremental = true;
        lineWidth = 80;
        indentWidth = 2;
        useTabs = false;
        newLineKind = "lf";
        typescript = {
          semiColons = "asi";
          quoteStyle = "alwaysSingle";
          "jsx.quoteStyle" = "preferSingle";
          quoteProps = "asNeeded";
          useBraces = "preferNone";
          singleBodyPosition = "sameLine";
          "arrowFunction.useParentheses" = "preferNone";
          "typeLiteral.separatorKind" = "comma";
        };
        json.trailingCommas = "never";
        markdown.textWrap = "always";
        markup.quotes = "single";
        ruff.lineLength = 80;
        # https://plugins.dprint.dev
        plugins = [
          "https://plugins.dprint.dev/typescript-0.95.5.wasm"
          "https://plugins.dprint.dev/json-0.20.0.wasm"
          "https://plugins.dprint.dev/markdown-0.18.0.wasm"
          "https://plugins.dprint.dev/toml-0.7.0.wasm"
          "https://plugins.dprint.dev/dockerfile-0.3.3.wasm"
          "https://plugins.dprint.dev/ruff-0.3.9.wasm"
          "https://plugins.dprint.dev/jupyter-0.2.0.wasm"
          "https://plugins.dprint.dev/g-plane/markup_fmt-v0.20.0.wasm"
          "https://plugins.dprint.dev/g-plane/pretty_yaml-v0.5.1.wasm"
          "https://plugins.dprint.dev/g-plane/pretty_graphql-v0.2.1.wasm"
        ];
      };
    };
    statix.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
  };
  settings = {
    global.excludes = ["bin/*" ".editorconfig" "*/ssh/*"];
    formatter.shfmt.priority = 1;
  };
}
