#! /bin/bash

# instal mcp for lsp
go install github.com/isaacphi/mcp-language-server@latest
mcp-language-server --help

# Install Node.js-based LSPs
npm install -g typescript typescript-language-server pyright bash-language-server
# Install gopls (pinned to v0.18.1 - last version supporting Go 1.24)
go install golang.org/x/tools/gopls@v0.18.1
# Verify installations
typescript-language-server --version &&
  pyright --version &&
  bash-language-server --version

#
#

# Install Memory MCP servers (both backends)
npm install -g @modelcontextprotocol/server-memory mcp-memory-libsql

# Install Sequential Thinking MCP server
npm install -g @modelcontextprotocol/server-sequential-thinking

which mcp-server-memory &&
  which mcp-memory-libsql &&
  which mcp-server-sequential-thinking
