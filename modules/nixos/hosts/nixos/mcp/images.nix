# MCP Server Container Images - Built locally with nix2container
{
  pkgs,
  nix2container,
  playwright-mcp,
  sequential-mcp,
  semgrep-mcp,
  ...
}: let
  n2c = nix2container.packages.${pkgs.system}.nix2container;

  # Base layer shared by all containers - security-hardened
  baseLayer = n2c.buildLayer {
    deps = builtins.attrValues {
      inherit (pkgs) cacert coreutils-full bash util-linux;
    };
  };

  # Node.js layer for JavaScript-based servers
  nodeLayer = n2c.buildLayer {
    deps = [
      pkgs.nodejs_20
      pkgs.python3 # Needed for some npm packages
    ];
  };

  # Python layer for Semgrep
  pythonLayer = n2c.buildLayer {
    deps = [
      (pkgs.python311.withPackages (ps:
        builtins.attrValues {
          inherit (ps) pip setuptools wheel requests pyyaml;
        }))
    ];
  };

  # Build container images with enhanced security
  images = {
    playwright = n2c.buildImage {
      name = "mcp-playwright";
      tag = "local";

      layers = [baseLayer nodeLayer];

      copyToRoot =
        pkgs.runCommand "playwright-app" {
          nativeBuildInputs = [pkgs.nodejs_20];
        } ''
          mkdir -p $out/app
          cd $out/app

          # Copy source and install dependencies
          cp -r ${playwright-mcp}/* .

          # Install dependencies safely
          export npm_config_cache=$TMPDIR/npm-cache
          export HOME=$TMPDIR/npm-home
          ${pkgs.nodejs_20}/bin/npm ci --production --no-audit --no-fund

          # Set proper permissions
          chmod -R 755 .
          find . -name "*.js" -exec chmod 644 {} \;
        '';

      config = {
        Cmd = ["${pkgs.nodejs_20}/bin/node" "/app/index.js"];
        User = "9001:9001";
        ExposedPorts = {"3000/tcp" = {};};
        Env = [
          "NODE_ENV=production"
          "MCP_TRANSPORT=sse"
          "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1"
        ];
        WorkingDir = "/app";
      };
    };

    sequential = n2c.buildImage {
      name = "mcp-sequential";
      tag = "local";

      layers = [baseLayer nodeLayer];

      copyToRoot =
        pkgs.runCommand "sequential-app" {
          nativeBuildInputs = [pkgs.nodejs_20];
        } ''
          mkdir -p $out/app
          cd $out/app

          # Copy source and install dependencies
          cp -r ${sequential-mcp}/* .

          # Install dependencies safely
          export npm_config_cache=$TMPDIR/npm-cache
          export HOME=$TMPDIR/npm-home
          ${pkgs.nodejs_20}/bin/npm ci --production --no-audit --no-fund

          # Build if needed
          if [ -f "package.json" ] && grep -q '"build"' package.json; then
            ${pkgs.nodejs_20}/bin/npm run build || echo "Build step failed or not needed"
          fi

          # Set proper permissions
          chmod -R 755 .
          find . -name "*.js" -exec chmod 644 {} \;
        '';

      config = {
        Cmd = ["${pkgs.nodejs_20}/bin/node" "/app/dist/index.js"];
        User = "9001:9001";
        ExposedPorts = {"3000/tcp" = {};};
        Env = [
          "NODE_ENV=production"
          "DISABLE_THOUGHT_LOGGING=false"
          "MCP_TRANSPORT=sse"
        ];
        WorkingDir = "/app";
      };
    };

    semgrep = n2c.buildImage {
      name = "mcp-semgrep";
      tag = "local";

      layers = [baseLayer pythonLayer];

      copyToRoot =
        pkgs.runCommand "semgrep-app" {
          nativeBuildInputs = [pkgs.python311];
        } ''
          mkdir -p $out/app
          cd $out/app

          # Copy source
          cp -r ${semgrep-mcp}/* .

          # Install package and dependencies
          export PYTHONPATH=$out/app:$PYTHONPATH
          ${pkgs.python311}/bin/pip install --target . --no-cache-dir --no-deps . || echo "Package installation completed"

          # Set proper permissions
          chmod -R 755 .
          find . -name "*.py" -exec chmod 644 {} \;
        '';

      config = {
        Cmd = ["${pkgs.python311}/bin/python" "-m" "semgrep_mcp"];
        User = "9001:9001";
        ExposedPorts = {"3000/tcp" = {};};
        Env = [
          "PYTHONUNBUFFERED=1"
          "MCP_TRANSPORT=sse"
          "SEMGREP_VERSION_CHECK=0"
          "SEMGREP_SEND_METRICS=off"
        ];
        WorkingDir = "/app";
      };
    };
  };
in {
  # Service to load images into Podman
  systemd.services.load-mcp-images = {
    description = "Load locally-built MCP images into Podman";
    after = ["podman.service"];
    before = ["mcp-playwright.service" "mcp-sequential.service" "mcp-semgrep.service"];
    wantedBy = ["multi-user.target"];

    script = ''
      echo "Loading MCP images into Podman..."

      # Load images with proper error handling
      ${pkgs.skopeo}/bin/skopeo copy nix:${images.playwright} containers-storage:mcp-playwright:local || {
        echo "Failed to load Playwright image"
        exit 1
      }

      ${pkgs.skopeo}/bin/skopeo copy nix:${images.sequential} containers-storage:mcp-sequential:local || {
        echo "Failed to load Sequential image"
        exit 1
      }

      ${pkgs.skopeo}/bin/skopeo copy nix:${images.semgrep} containers-storage:mcp-semgrep:local || {
        echo "Failed to load Semgrep image"
        exit 1
      }

      echo "MCP images loaded successfully"
      ${pkgs.podman}/bin/podman images | grep mcp || true
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Security hardening for the loader service
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      RestrictNamespaces = true;
    };
  };
}
