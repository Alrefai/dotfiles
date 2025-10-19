# Cachix Setup Guide

Based on your existing analysis in `CACHIX_ANALYSIS.md`, here's your complete
setup guide.

## Step 1: Authenticate with Cachix

1. Visit https://app.cachix.org
2. Sign up/log in (GitHub, Google, or email)
3. Go to https://app.cachix.org/tokens
4. Create a new authentication token
5. Run the authentication command:
   ```bash
   nix run nixpkgs#cachix -- authtoken <YOUR_TOKEN>
   ```

## Step 2: Create Your Cache

Run the setup script I created:

```bash
./setup-cachix.sh
```

This will:

- Create a cache named `{username}-dotfiles` (e.g., `mohammed-dotfiles`)
- Show you the cache public key
- Provide next steps

## Step 3: Configure Your Nix Settings

Add your cache to `configuration.nix` in the `nix.settings` section:

```nix
nix.settings = {
  # ... existing settings ...
  extra-substituters = [
    "https://cache.lix.systems"
    "https://mohammed-dotfiles.cachix.org"  # Your cache
  ];
  extra-trusted-public-keys = [
    # ... existing keys ...
    "mohammed-dotfiles.cachix.org-1:<YOUR_CACHE_PUBLIC_KEY>"
  ];
};
```

Replace `mohammed-dotfiles` with your actual cache name and add the public key
shown after cache creation.

## Step 4: Rebuild Configuration

```bash
sudo nixos-rebuild switch --flake .
```

## Step 5: Start Using the Cache

### Push to Cache After Builds

```bash
# After home-manager switch
home-manager switch
nix run nixpkgs#cachix -- push mohammed-dotfiles ~/.nix-profile

# Or push specific build outputs
nix-build | nix run nixpkgs#cachix -- push mohammed-dotfiles
```

### Automated Pushing (Optional)

You can automate this by creating aliases in your shell config:

```bash
alias hms='home-manager switch && nix run nixpkgs#cachix -- push mohammed-dotfiles ~/.nix-profile'
```

## Benefits You'll Get

Based on your analysis:

- **Build time**: 2+ minutes → ~10 seconds for cached builds
- **Multi-machine sync**: Same builds across laptop/desktop/server
- **MacBook server**: 2+ hours → 2 minutes download time
- **Disaster recovery**: Fast rebuilds after system reinstalls

## Monitoring Usage

Check your cache at: https://app.cachix.org/cache/mohammed-dotfiles

Your projected usage (from analysis):

- Override size: ~200MB
- Update frequency: Monthly
- Annual bandwidth: ~10GB/year (well within free tier)

## Troubleshooting

1. **Authentication issues**: Re-run `nix run nixpkgs#cachix -- authtoken`
2. **Cache creation fails**: Check cache name isn't taken
3. **Permission errors**: Ensure you're authenticated as the cache owner
4. **Build not using cache**: Verify substituters and public keys are correct

## Files Created

- `setup-cachix.sh` - Setup script
- `cachix-config-template.nix` - Configuration template
- `CACHIX_SETUP_GUIDE.md` - This guide

Clean up these files after setup if desired.
