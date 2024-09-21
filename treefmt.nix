_: {
  projectRootFile = ".git/config";
  programs = {
    alejandra.enable = true;
    dprint = {
      enable = true;
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
        includes = [
          "**/*.{astro,html,ts,tsx,js,mjs,cjs,jsx,json,jsonc,toml,yaml,yml,md}"
          "**/*.{graphql,gql,ipynb,py,pyi}"
          "Dockerfile"
        ];
        excludes = ["node_modules" "*-lock.json" "*-lock.yaml" "dist"];
        # https://plugins.dprint.dev
        plugins = [
          "https://plugins.dprint.dev/typescript-0.93.0.wasm"
          "https://plugins.dprint.dev/json-0.19.3.wasm"
          "https://plugins.dprint.dev/markdown-0.17.8.wasm"
          "https://plugins.dprint.dev/toml-0.6.2.wasm"
          "https://plugins.dprint.dev/dockerfile-0.3.2.wasm"
          "https://plugins.dprint.dev/ruff-0.3.9.wasm"
          "https://plugins.dprint.dev/jupyter-0.1.4.wasm"
          "https://plugins.dprint.dev/g-plane/markup_fmt-v0.12.0.wasm"
          "https://plugins.dprint.dev/g-plane/pretty_yaml-v0.5.0.wasm"
          "https://plugins.dprint.dev/g-plane/pretty_graphql-v0.2.0.wasm"
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
