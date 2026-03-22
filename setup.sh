#!/bin/bash
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}AI Performance Guardrails — Setup${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# ============================================================================
# SECTION 1: Preflight Checks
# ============================================================================

echo -e "${YELLOW}[1/5] Checking dependencies...${NC}"

check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}✗ $1 not found${NC}"
    return 1
  fi
  echo -e "${GREEN}✓ $1${NC}"
  return 0
}

DEPS_OK=true
check_command "bash" || DEPS_OK=false
check_command "node" || DEPS_OK=false
check_command "npm" || DEPS_OK=false
check_command "jq" || DEPS_OK=false
check_command "curl" || DEPS_OK=false

if [ "$DEPS_OK" = false ]; then
  echo -e "${RED}✗ Missing required dependencies. Please install them and try again.${NC}"
  exit 1
fi

echo -e "${GREEN}✓ All dependencies found${NC}"
echo ""

# Check for Claude Code
if [ ! -d "$HOME/.claude" ]; then
  echo -e "${YELLOW}⚠ Claude Code not found at ~/.claude${NC}"
  echo "   This tool works best with Claude Code, but setup can continue."
  echo ""
fi

# ============================================================================
# SECTION 2: Credential Collection
# ============================================================================

echo -e "${YELLOW}[2/5] Collecting credentials...${NC}"
echo ""
echo "This tool needs access to your Google Cloud service account and Google services."
echo "Both Google Analytics and Search Console use the same service account for authentication."
echo ""

# Google Analytics
read -p "Set up Google Analytics? (y/N): " -n 1 -r GA_ENABLED
echo
if [[ $GA_ENABLED =~ ^[Yy]$ ]]; then
  read -p "  Enter GA4 Property ID (numeric, e.g., 123456789): " GA_PROPERTY_ID
  read -p "  Path to service account JSON file: " SA_JSON_PATH

  if [ ! -f "$SA_JSON_PATH" ]; then
    echo -e "${RED}✗ Service account file not found: $SA_JSON_PATH${NC}"
    exit 1
  fi

  # Validate it's a service account
  if ! grep -q '"type": "service_account"' "$SA_JSON_PATH"; then
    echo -e "${RED}✗ File does not appear to be a valid service account JSON${NC}"
    exit 1
  fi

  echo -e "${GREEN}✓ GA configured${NC}"
else
  GA_PROPERTY_ID=""
fi
echo ""

# Google Search Console
read -p "Set up Google Search Console? (y/N): " -n 1 -r GSC_ENABLED
echo
if [[ $GSC_ENABLED =~ ^[Yy]$ ]]; then
  read -p "  Enter GSC Site URL (e.g., https://example.com/ or sc-domain:example.com): " GSC_SITE_URL

  if [ -z "$SA_JSON_PATH" ]; then
    read -p "  Path to service account JSON file: " SA_JSON_PATH
    if [ ! -f "$SA_JSON_PATH" ]; then
      echo -e "${RED}✗ Service account file not found: $SA_JSON_PATH${NC}"
      exit 1
    fi
  fi

  echo -e "${GREEN}✓ GSC configured${NC}"
else
  GSC_SITE_URL=""
fi
echo ""

# ============================================================================
# SECTION 3: Install MCP Servers
# ============================================================================

echo -e "${YELLOW}[3/5] Installing MCP servers...${NC}"

if [[ $GA_ENABLED =~ ^[Yy]$ ]]; then
  echo "Installing google-analytics MCP (analytics-mcp)..."

  # Check for pipx
  if ! command -v pipx &> /dev/null; then
    echo "  pipx not found. Installing via pip..."
    python3 -m pip install --user pipx 2>/dev/null || {
      echo -e "${RED}✗ Failed to install pipx. Please install manually:${NC}"
      echo "    pip install --user pipx"
      echo "    pipx ensurepath"
      exit 1
    }
  fi

  pipx install analytics-mcp --upgrade --force 2>/dev/null || {
    echo -e "${RED}✗ Failed to install analytics-mcp. Ensure pipx is on PATH.${NC}"
    exit 1
  }
  echo -e "${GREEN}✓ analytics-mcp installed${NC}"
fi

if [[ $GSC_ENABLED =~ ^[Yy]$ ]]; then
  echo "Installing google-search-console MCP (mcp-server-gsc)..."
  npm install -g mcp-server-gsc 2>/dev/null || {
    echo -e "${RED}✗ Failed to install mcp-server-gsc${NC}"
    exit 1
  }
  echo -e "${GREEN}✓ mcp-server-gsc installed${NC}"
fi
echo ""

# ============================================================================
# SECTION 4: Wire up Claude Code Settings
# ============================================================================

echo -e "${YELLOW}[4/5] Configuring Claude Code...${NC}"

# Detect Claude config file
CLAUDE_CONFIG=""
if [ -f "$HOME/.claude/mcp_config.json" ]; then
  CLAUDE_CONFIG="$HOME/.claude/mcp_config.json"
elif [ -f "$HOME/.claude/settings.json" ]; then
  CLAUDE_CONFIG="$HOME/.claude/settings.json"
else
  CLAUDE_CONFIG="$HOME/.claude/mcp_config.json"
fi

echo "Using config: $CLAUDE_CONFIG"

# Ensure .claude directory exists
mkdir -p "$(dirname "$CLAUDE_CONFIG")"

# Back up the config
if [ -f "$CLAUDE_CONFIG" ]; then
  cp "$CLAUDE_CONFIG" "${CLAUDE_CONFIG}.bak"
  echo -e "${GREEN}✓ Backed up existing config to ${CLAUDE_CONFIG}.bak${NC}"
fi

# Convert absolute path for use in config
SA_JSON_ABS=$(cd "$(dirname "$SA_JSON_PATH")" && pwd)/$(basename "$SA_JSON_PATH")

# Extract project ID from service account
PROJECT_ID=$(jq -r '.project_id' "$SA_JSON_PATH")

# Initialize or read existing config
if [ -f "$CLAUDE_CONFIG" ]; then
  CONFIG=$(cat "$CLAUDE_CONFIG")
else
  CONFIG='{}'
fi

# Ensure mcpServers object exists
if ! echo "$CONFIG" | jq -e '.mcpServers' > /dev/null 2>&1; then
  CONFIG=$(echo "$CONFIG" | jq '.mcpServers = {}')
fi

# Add GA MCP if enabled
if [[ $GA_ENABLED =~ ^[Yy]$ ]]; then
  CONFIG=$(echo "$CONFIG" | jq \
    --arg cmd "pipx" \
    '.mcpServers["google-analytics"] = {
      "command": $cmd,
      "args": ["run", "analytics-mcp"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "'$SA_JSON_ABS'",
        "GOOGLE_PROJECT_ID": "'$PROJECT_ID'"
      }
    }')
fi

# Add GSC MCP if enabled
if [[ $GSC_ENABLED =~ ^[Yy]$ ]]; then
  CONFIG=$(echo "$CONFIG" | jq \
    '.mcpServers["google-search-console"] = {
      "command": "npx",
      "args": ["-y", "mcp-server-gsc"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "'$SA_JSON_ABS'"
      }
    }')
fi

# Write config back
echo "$CONFIG" | jq '.' > "$CLAUDE_CONFIG"
echo -e "${GREEN}✓ Claude Code settings updated${NC}"
echo ""

# ============================================================================
# SECTION 5: Validate and Finish
# ============================================================================

echo -e "${YELLOW}[5/5] Smoke testing credentials...${NC}"

# Create .env.analytics
cat > .env.analytics <<EOF
GA_PROPERTY_ID=$GA_PROPERTY_ID
GSC_SITE_URL=$GSC_SITE_URL
GOOGLE_APPLICATION_CREDENTIALS=$SA_JSON_ABS
EOF

# Run smoke test
if node scripts/check-analytics.js --smoke-test > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Credentials validated${NC}"
else
  echo -e "${YELLOW}⚠ Smoke test inconclusive (may need service account permissions)${NC}"
fi
echo ""

# ============================================================================
# Summary
# ============================================================================

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo "What was configured:"
if [[ $GA_ENABLED =~ ^[Yy]$ ]]; then
  echo -e "  ${GREEN}✓ Google Analytics${NC} (Property ID: $GA_PROPERTY_ID)"
fi
if [[ $GSC_ENABLED =~ ^[Yy]$ ]]; then
  echo -e "  ${GREEN}✓ Google Search Console${NC} (Site: $GSC_SITE_URL)"
fi
if [ -z "$GA_PROPERTY_ID" ] && [ -z "$GSC_SITE_URL" ]; then
  echo -e "  ${YELLOW}(Neither GA nor GSC configured — tool will work in Lighthouse-only mode)${NC}"
fi
echo ""
echo "Credentials saved to: .env.analytics (gitignored)"
echo "Service account path: $SA_JSON_ABS"
echo ""
echo "Next steps:"
echo "  1. In Google Cloud Console, ensure the service account has:"
echo "     - 'Analytics Viewer' role in Google Analytics"
echo "     - 'Property Administrator' role in Google Search Console"
echo ""
echo "  2. Restart Claude Code so it loads the new MCP servers"
echo ""
echo "  3. Ask Claude Code to make a change — it will now:"
echo "     - Phase 1: Pull baseline metrics from GA + GSC"
echo "     - Phase 2: Write code and enforce Lighthouse (100%)"
echo "     - Phase 3: Validate against real user data"
echo ""
echo -e "${BLUE}Happy coding!${NC}"
