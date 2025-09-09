class TailscaleMcp < Formula
  desc "Comprehensive Tailscale MCP server for Warp terminal"
  homepage "https://github.com/TB-Warp/tailscale-mcp"
  url "https://github.com/TB-Warp/tailscale-mcp/archive/refs/heads/main.tar.gz"
  version "2.0.0"
  sha256 "34d90a0286f00a69e4d0a4934edc63c67715e6758a8a5794a29973775e48b544"
  license "MIT"

  depends_on "node"

  def install
    # Install all files to libexec
    libexec.install Dir["*"]
    
    # Create a wrapper script
    (bin/"tailscale-mcp").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["node"].opt_bin}:$PATH"
      cd "#{libexec}" && exec node src/index.js "$@"
    EOS
    
    # Make it executable
    chmod 0755, bin/"tailscale-mcp"
    
    # Install npm dependencies
    system Formula["node"].opt_bin/"npm", "install", "--production", "--prefix", libexec
  end

  def caveats
    <<~EOS
      To use tailscale-mcp with Warp terminal:

      1. Get your Tailscale API token from: https://login.tailscale.com/admin/settings/keys

      2. Add this configuration to your Warp MCP settings:

      {
        "tailscale": {
          "command": "tailscale-mcp",
          "env": {
            "TAILSCALE_TOKEN": "your-api-token-here",
            "TAILNET": "your-tailnet-name"
          }
        }
      }

      3. Available tools:
         - Device Management: List, get, update, delete devices
         - ACL Management: Get and update access control policies
         - DNS Management: Get and update DNS settings including MagicDNS
         - Auth Keys: List and create authentication keys
         - Subnet Routes: Manage subnet routes

      For full documentation visit: https://github.com/TB-Warp/tailscale-mcp
    EOS
  end

  test do
    # Test that the wrapper script exists and is executable
    assert_predicate bin/"tailscale-mcp", :exist?
    assert_predicate bin/"tailscale-mcp", :executable?
    
    # Test that Node.js and main files are accessible
    assert_predicate libexec/"src/index.js", :exist?
    assert_predicate libexec/"package.json", :exist?
  end
end
