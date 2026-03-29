# Homebrew Formula for hello-brew
# The filename must correspond to the class name: hello-brew.rb -> HelloBrew
class HelloBrew < Formula
  desc "A simple hello world CLI installed via Homebrew"
  homepage "https://github.com/yang-wang11/homebrew-hello"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.2.0/hello-brew-0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "af71c07af03545e3ebc90ada48945295c1a23559c7087208feff11dfc9084162"
    end
    on_intel do
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.2.0/hello-brew-0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "49d6c076d74a9835d294af1623317b6c4d524f2e77493efaa22b5c3a2ed5d0cc"
    end
  end

  def install
    if Hardware::CPU.arm?
      bin.install "aarch64-apple-darwin/release/hello-brew"
    else
      bin.install "x86_64-apple-darwin/release/hello-brew"
    end
  end

  test do
    assert_match "0.2.0", shell_output("#{bin}/hello-brew --version")
  end
end
