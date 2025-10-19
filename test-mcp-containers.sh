#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
  echo -e "${BLUE}[MCP-TEST]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if container is running
check_container() {
  local name="$1"
  if podman ps --filter="name=${name}" --quiet | grep -q .; then
    return 0
  else
    return 1
  fi
}

# Function to wait for container to be ready
wait_for_container() {
  local name="$1"
  local timeout="${2:-30}"
  local count=0

  log "Waiting for container ${name} to be ready..."
  while [ $count -lt "$timeout" ]; do
    if check_container "$name"; then
      success "Container ${name} is running"
      return 0
    fi
    sleep 1
    ((count++))
  done

  error "Container ${name} failed to start within ${timeout} seconds"
  return 1
}

# Function to test HTTP endpoint
test_endpoint() {
  local url="$1"
  local name="$2"
  local timeout="${3:-10}"

  log "Testing endpoint: ${url}"

  if timeout "$timeout" curl -sf "$url" >/dev/null 2>&1; then
    success "Endpoint ${name} is responding"
    return 0
  else
    warn "Endpoint ${name} is not responding (this may be expected for some services)"
    return 1
  fi
}

# Function to clean up test containers
cleanup() {
  log "Cleaning up test containers..."

  for container in test-mcp-playwright test-mcp-semgrep; do
    if check_container "$container"; then
      log "Stopping container: $container"
      podman stop "$container" >/dev/null 2>&1 || true
    fi

    # Remove container if it exists
    if podman ps -a --filter="name=${container}" --quiet | grep -q .; then
      log "Removing container: $container"
      podman rm "$container" >/dev/null 2>&1 || true
    fi
  done
}

# Function to test a specific MCP server
test_mcp_server() {
  local server="$1"
  local port="$2"
  local network="$3"

  log "Testing MCP ${server} server..."

  # Container name for testing
  local container_name="test-mcp-${server}"

  # Run container in test mode
  log "Starting test container: ${container_name}"

  local run_args=(
    "podman" "run" "-d"
    "--name=${container_name}"
    "--network=${network}"
    "--user=9001:9001"
    "--memory=256m"
    "--memory-swap=256m"
    "--cpus=0.5"
    "--pids-limit=50"
    "--security-opt=no-new-privileges:true"
    "--cap-drop=ALL"
    "--cap-add=DAC_OVERRIDE"
    "--read-only"
    "--tmpfs=/tmp:rw,noexec,nosuid,size=50m"
  )

  # Add port binding for network-enabled containers
  if [ "$network" != "none" ]; then
    run_args+=("-p" "127.0.0.1:${port}:3000")
  fi

  # Get the actual image name with tag
  local actual_image
  actual_image=$(podman images --format "{{.Repository}}:{{.Tag}}" | grep "localhost/mcp-${server}" | head -1)
  if [ -z "$actual_image" ]; then
    error "No image found for localhost/mcp-${server}"
    return 1
  fi

  # Add the actual image to run_args
  run_args+=("$actual_image")

  # Start the container
  if "${run_args[@]}" >/dev/null 2>&1; then
    success "Started test container: ${container_name}"

    # Wait for container to be ready
    if wait_for_container "$container_name" 20; then
      # Test endpoint if network is enabled
      if [ "$network" != "none" ]; then
        test_endpoint "http://127.0.0.1:${port}" "${server}" 5
      else
        success "Container ${server} is running (network isolated)"
      fi

      # Show container logs (last 10 lines)
      log "Recent logs from ${container_name}:"
      podman logs --tail=10 "$container_name" 2>&1 || warn "No logs available"

      return 0
    else
      error "Container ${container_name} failed to start properly"
      return 1
    fi
  else
    error "Failed to start container: ${container_name}"
    return 1
  fi
}

# Main testing function
main() {
  log "Starting MCP Container Testing"
  echo

  # Check if we're in the right directory
  if [ ! -f "flake.nix" ]; then
    error "Must run from the flake directory"
    exit 1
  fi

  # Check if images exist (use pattern matching for hash-based tags)
  log "Checking if MCP images are available..."
  if ! podman images | grep -q "localhost/mcp-playwright"; then
    warn "localhost/mcp-playwright image not found - will try to load it"
  fi

  if ! podman images | grep -q "localhost/mcp-semgrep"; then
    warn "localhost/mcp-semgrep image not found - will try to load it"
  fi

  # Cleanup any existing test containers
  cleanup

  # Test configuration
  declare -A servers=(
    ["playwright"]="8991 bridge"
    ["semgrep"]="8993 none"
  )

  local overall_success=true

  # Test each server
  for server in "${!servers[@]}"; do
    IFS=' ' read -r port network <<<"${servers[$server]}"

    log "========================================="
    log "Testing ${server} server"
    log "Port: ${port}, Network: ${network}"
    log "========================================="

    if test_mcp_server "$server" "$port" "$network"; then
      success "✓ ${server} server test passed"
    else
      error "✗ ${server} server test failed"
      overall_success=false
    fi

    echo
  done

  # Cleanup after tests
  cleanup

  # Final result
  echo
  log "========================================="
  if [ "$overall_success" = true ]; then
    success "All MCP container tests passed!"
    log "Containers are ready for deployment"
    exit 0
  else
    error "Some MCP container tests failed"
    log "Review the output above and fix issues before deployment"
    exit 1
  fi
}

# Handle script arguments
case "${1:-test}" in
test)
  main
  ;;
cleanup)
  cleanup
  ;;
load-images)
  log "Loading MCP images using nix2container..."
  log "Loading Playwright image..."
  nix run .#mcp-playwright
  log "Loading Semgrep image..."
  nix run .#mcp-semgrep
  success "All images loaded successfully"
  ;;
*)
  echo "Usage: $0 [test|cleanup|load-images]"
  echo "  test        - Run full container tests (default)"
  echo "  cleanup     - Clean up test containers"
  echo "  load-images - Load images using nix2container"
  exit 1
  ;;
esac
