# Homebrew Formula for hello-brew
# The filename must correspond to the class name: hello-brew.rb -> HelloBrew
class HelloBrew < Formula
  desc "A simple hello world CLI installed via Homebrew"
  homepage "https://github.com/yang-wang11/homebrew-hello"

  # SHA256 checksum — replace with the value you obtained in Step 8.
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"

  # Open-source license.
  license "MIT"

  # Automatically select the correct binary based on the user's architecture.
  on_macos do
    on_arm do
      # Apple Silicon (M1/M2/M3/M4)
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.2.0/hello-brew-0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "af71c07af03545e3ebc90ada48945295c1a23559c7087208feff11dfc9084162"
    end
    on_intel do
      # Intel Mac
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.2.0/hello-brew-0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "49d6c076d74a9835d294af1623317b6c4d524f2e77493efaa22b5c3a2ed5d0cc"
    end
  end  

  # Build dependency: the Rust toolchain is needed at compile time.
  # Homebrew will install Rust automatically if the user doesn't have it.
  depends_on "rust" => :build

  def install
    # Use cargo to build and install the binary.
    # std_cargo_args is a Homebrew helper that automatically sets:
    #   --root=#{prefix}  (install into the Homebrew-managed directory)
    #   --path=.          (build from the current directory)
    system "cargo", "install", *std_cargo_args
  end

  # Post-install test — runs when the user executes: brew test hello-brew
  test do
    # Verify the --version output contains the expected version number.
    assert_match "0.2.0", shell_output("#{bin}/hello-brew --version")
  end
end
