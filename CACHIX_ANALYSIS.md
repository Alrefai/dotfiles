# Binary Caching Analysis for Custom Nix Overrides

## Context

Analysis of using external binary caches (Cachix) to optimize build times for
custom Nix packages, specifically our `uutils-coreutils-fzf-compat` override
that adds GNU compatibility wrapper for fzf integration.

## The Problem

Our `overrideAttrs` approach forces rebuilds (~2+ minutes) when:

- First time building
- After flake updates that include uutils-coreutils
- After wrapper modifications

While Nix caches locally, we don't benefit from upstream binary caches since our
override creates a unique derivation.

## Free Tier Binary Cache Options

### Cachix (Recommended)

- ✅ **Free tier**: 5GB storage, unlimited public caches
- ✅ **Perfect for use case**: Share between machines
- ❌ **Paid tiers**: $20/month for private, $40/month for teams
- 💡 **Public cache = FREE for our needs**

### GitHub Packages (Alternative)

- ✅ **Free**: 500MB storage, 1GB bandwidth/month for public repos
- ✅ **Already integrated**: If using GitHub for dotfiles
- ❌ **Limited**: Might hit bandwidth limits for frequent builds

### Self-Hosted Options

```bash
# Simple HTTP server
nix-serve -p 8080 --store /nix/store

# S3-compatible + nix-serve
# Use any S3-compatible service with free tiers
```

## Cost Analysis

### Build Profile Estimation

```
Override size: ~200MB (uutils-coreutils + wrapper)
Update frequency: Monthly (when uutils-coreutils updates)
Machines: 3-4 machines
Annual bandwidth: 200MB × 4 machines × 12 updates = ~10GB/year
```

**Verdict**: Well within all free tier limits! 🎉

## Use Cases

### Multi-Machine Synchronization

```bash
# On main machine (build once)
home-manager switch
cachix push mohammed-dotfiles ~/.nix-profile

# On other machines (fast consumption)
home-manager switch  # Downloads from cache - seconds instead of minutes
```

### Old MacBook Server (2008) Optimization

**Problem**: 2+ hour builds on ancient hardware **Solution**: Binary cache
reduces to ~2 minutes download time

Alternative: Remote builds

```nix
nix.distributedBuilds = true;
nix.buildMachines = [{
  hostName = "fast-machine";
  systems = [ "x86_64-linux" ];
  maxJobs = 4;
  speedFactor = 10;
}];
```

## Implementation Strategy

### Phase 1: Basic Cachix Setup

```bash
# 1. Install and create cache
nix-env -iA nixpkgs.cachix
cachix create mohammed-dotfiles  # Public cache

# 2. Configure in flake.nix
nix.settings.substituters = [
  "https://cache.nixos.org"
  "https://mohammed-dotfiles.cachix.org"
];

# 3. Manual push after builds
home-manager switch && cachix push mohammed-dotfiles ~/.nix-profile
```

### Phase 2: Automation (If Beneficial)

```nix
# Add post-build hook for automatic pushing
# Implement only if manual process proves valuable
```

## Benefits

### Personal Benefits

- ✅ **Future machines**: New setups pull cached builds
- ✅ **Time savings**: 2min → 10sec for subsequent builds
- ✅ **Cross-device sync**: Same builds on laptop/desktop/server
- ✅ **Disaster recovery**: Rebuilds after system reinstalls

### Learning Benefits

- ✅ **Nix caching understanding**: Hands-on experience with binary caches
- ✅ **Infrastructure skills**: Cache management and optimization
- ✅ **Cost optimization**: Free tier maximization strategies

## Recommendations

### Immediate Action

**Start with Cachix free tier** because:

1. Zero cost for projected usage
2. Minimal setup complexity
3. Huge benefit for old MacBook
4. Valuable learning experience
5. No long-term commitment

### Future Considerations

- Monitor usage patterns and costs
- Consider upgrading if hitting free tier limits
- Explore self-hosted options for learning
- Share useful overrides with community

## Related Documentation

- GitHub Issue with technical details:
  https://github.com/Alrefai/dotfiles/issues/15
- Current working implementation: commit `8cd9333`

---

_Analysis completed: 2025-01-04_ _Context: fzf tmux integration debugging
session_
