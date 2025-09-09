class TailscaleMcp < Formula
  desc "Tailscale MCP server for Warp terminal integration"
  homepage "https://github.com/lpmwfx/tailscale-mcp"
  url "https://github.com/lpmwfx/tailscale-mcp/archive/refs/heads/main.tar.gz"
  version "1.0.0"
  sha256 "554240547f0467a0463d4041cab25ad744ab72fca144988d0a82a76b9c628fc1"
  license "MIT"

  depends_on "node"

  def install
    # Install all files to the lib directory
    libexec.install Dir["*"]
    
    # Install npm dependencies
    system "npm", "install", "--prefix", libexec, "--production"
    
    # Create symlink to the main script
    bin.install_symlink libexec/"src/index.js" => "tailscale-mcp"
  end

  def caveats
    <<~EOS
      To use tailscale-mcp with Warp terminal, you'll need to:
      
      1. Get a Tailscale API token from: https://login.tailscale.com/admin/settings/keys
      
      2. Add this configuration to your Warp MCP settings:
      
      {
        "tailscale": {
          "command": "node",
          "args": [
            "#{opt_libexec}/src/index.js"
          ],
          "env": {
            "TAILNET": "your-tailnet.ts.net",
            "TAILSCALE_TOKEN": "tskey-auth-your-token-here"
          },
          "working_directory": null
        }
      }
      
      Replace "your-tailnet.ts.net" and "tskey-auth-your-token-here" with your actual values.
    EOS
  end

  test do
    # Test that the script can be executed
    assert_match "TAILNET and TAILSCALE_TOKEN environment variables are required",
                 shell_output("#{bin}/tailscale-mcp 2>&1", 1)
  end
end
