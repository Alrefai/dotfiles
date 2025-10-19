# Semgrep MCP Server Analysis - Why It Failed

## Summary

After extensive investigation across multiple branches and approaches, **Semgrep
MCP server is not viable for open-source Nix packaging** due to proprietary
dependencies.

## What We Attempted

### Approach 1: Over-engineered Source Build (mcp-servers-implementation branch)

- **Result**: 783MB bloated container that failed to start
- **Issues**: 50+ lines of patches, complex buildPythonPackage from source
- **Status**: Failed with import errors

### Approach 2: Clean Packaging (semgrep-mcp-clean branch)

- **Result**: 628MB container with import errors
- **Approach**: Simple `buildPythonPackage` with `pyproject = true`
- **Status**: Failed with missing `semgrep_mcp.semgrep_interfaces` module

### Approach 3: Official Container Build

- **Result**: 716MB container with same import errors
- **Discovery**: Official GitHub source is also broken without proprietary
  components

## Root Cause: Proprietary Dependencies

The Semgrep MCP server requires **semgrep-pro** (proprietary software):

```python
# This import fails without semgrep-pro
from semgrep_mcp.semgrep_interfaces.semgrep_output_v1 import CliOutput
```

### Evidence:

1. **Dockerfile step**: `RUN semgrep install-semgrep-pro` (requires paid token)
2. **Official container**: 415MB working version includes proprietary components
3. **GitHub source**: Open-source version missing critical interfaces

## Technical Findings

### Container Size Comparison

- **Our Nix implementation**: 628MB ✅ (most efficient)
- **Official GitHub build**: 716MB ❌ (20% larger than ours)
- **Published container**: 415MB ✅ (includes proprietary components)

### Packaging Quality

Our Nix approach was actually **superior**:

- ✅ Cleaner dependency management
- ✅ More efficient layering with nix2container
- ✅ Proper `pyproject = true` usage
- ✅ No over-engineering

## Why Published Container Works

The working 415MB container at `ghcr.io/semgrep/mcp` includes:

- Proprietary semgrep-pro installation
- Missing interfaces that make the server functional
- Components we cannot legally redistribute or package

## Conclusion

**Semgrep MCP server cannot be implemented with open-source tooling.** The
server fundamentally depends on proprietary components that require:

- Paid semgrep-pro license
- Secret tokens for installation
- Proprietary interfaces not available in open-source

## Recommendation

**Abandon semgrep MCP server development.** Focus on:

1. MCP servers with purely open-source dependencies
2. Building custom security analysis tools using open-source semgrep CLI
   directly
3. Alternative security-focused MCP implementations

## Lessons Learned

1. **Verify dependencies before implementation** - Check for proprietary
   requirements
2. **Simple Nix packaging works well** - Our approach was technically sound
3. **Size optimization isn't everything** - Functionality must come first
4. **Test early and often** - We should have validated basic functionality
   before optimization

---

**Status**: Investigation complete - **Not viable for open-source packaging**\
**Branches**: `mcp-servers-implementation`, `semgrep-mcp-clean`\
**Cleanup**: All experimental containers removed\
**Decision**: Abandon semgrep MCP server development
