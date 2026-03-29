# Homebrew Formula for hello-brew
# The filename must correspond to the class name: hello-brew.rb -> HelloBrew
class HelloBrew < Formula
  desc "A simple hello world CLI installed via Homebrew"
  homepage "https://github.com/yang-wang11/homebrew-hello"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.3.0/hello-brew-aarch64-apple-darwin.tar.gz"
      sha256 "c8ed6c0e00544b8c7fe75eb75dff4b4853ec090bdd4ee2fd4df90848f41e32f2"
    end
    on_intel do
      url "https://github.com/yang-wang11/homebrew-hello/releases/download/v0.3.0/hello-brew-x86_64-apple-darwin.tar.gz"
      sha256 "4c41320e61e97f81b4781de0cc11df1738544572bae9d758ac6af40ea780e18a"
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
