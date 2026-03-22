#!/bin/bash

# Detect the correct Claude Code MCP config file path
# Returns the path to use for MCP server configuration

if [ -f "$HOME/.claude/mcp_config.json" ]; then
  echo "$HOME/.claude/mcp_config.json"
elif [ -f "$HOME/.claude/settings.json" ]; then
  echo "$HOME/.claude/settings.json"
else
  # Default to mcp_config.json if neither exists
  echo "$HOME/.claude/mcp_config.json"
fi
