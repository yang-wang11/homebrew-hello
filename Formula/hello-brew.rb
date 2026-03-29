# Homebrew Formula for hello-brew
# The filename must correspond to the class name: hello-brew.rb -> HelloBrew
class HelloBrew < Formula
  desc "A simple hello world CLI installed via Homebrew"
  homepage "https://github.com/yang-wang11/homebrew-hello"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.3.0/hello-brew-aarch64-apple-darwin.tar.gz
"
      sha256 "207c8cbb9523b5a1b5874418e8775f2e198fd265af8a937da12799e35fcccb29"
    end
    on_intel do
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.3.0/hello-brew-x86_64-apple-darwin.tar.gz
"
      sha256 "08d1c54af9fcfa6610f95f3271d716570f1279491b65bcdfcbd81c3e41bb9352"
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
