# Build a Rust CLI Tool and Publish It via Homebrew — Step by Step Guide

> This guide walks you through building a simple Rust CLI tool called `hello-brew` and publishing it
> so anyone can install it with `brew install`.
>
> Prerequisites: macOS + Homebrew installed + GitHub account

---

## Table of Contents

1. [Install the Rust Toolchain](#1-install-the-rust-toolchain)
2. [Create a New Rust Project](#2-create-a-new-rust-project)
3. [Write the Code](#3-write-the-code)
4. [Build and Test Locally](#4-build-and-test-locally)
5. [Initialize a Git Repository](#5-initialize-a-git-repository)
6. [Push to GitHub](#6-push-to-github)
7. [Create a GitHub Release](#7-create-a-github-release)
8. [Get the SHA256 Checksum](#8-get-the-sha256-checksum)
9. [Create a Homebrew Tap Repository](#9-create-a-homebrew-tap-repository)
10. [Write the Homebrew Formula](#10-write-the-homebrew-formula)
11. [Test the Installation](#11-test-the-installation)
12. [Publish a New Version (Update Workflow)](#12-publish-a-new-version-update-workflow)
13. [Advanced: Precompiled Binaries (Skip Build on User Side)](#13-advanced-precompiled-binaries-skip-build-on-user-side)
14. [Advanced: Automate Releases with GitHub Actions](#14-advanced-automate-releases-with-github-actions)

---

## 1. Install the Rust Toolchain

> Rust officially recommends `rustup` to manage toolchains. It lets you switch versions and
> manage compilation targets easily.

```bash
# Download and run the rustup installer.
# When prompted, press 1 and Enter to choose the default installation.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Load the environment variables (or open a new terminal window).
source "$HOME/.cargo/env"

# Set stable as the default toolchain (needed if you see "no default is configured").
rustup default stable

# Verify the installation.
rustc --version   # Expected: rustc 1.x.x
cargo --version   # Expected: cargo 1.x.x
```

**What are these tools?**
- `rustc` — the Rust compiler
- `cargo` — the Rust package manager and build tool (like npm / pip)
- `rustup` — the Rust toolchain manager (like nvm / pyenv)

---

## 2. Create a New Rust Project

```bash
# Create a workspace directory (feel free to use any path you prefer).
mkdir -p ~/Projects
cd ~/Projects

# Create a new project with cargo.
# This generates a Cargo.toml (project config) and src/main.rs (entry point).
cargo new hello-brew

# Enter the project directory.
cd hello-brew
```

After creation, the directory structure looks like this:

```
hello-brew/
├── Cargo.toml      # Project config: name, version, dependencies
├── src/
│   └── main.rs     # Application entry point
```

---

## 3. Write the Code

### 3.1 Edit `Cargo.toml`

Open `Cargo.toml` in your favorite editor and replace its contents with:

```toml
[package]
name = "hello-brew"              # Project name — also the name of the compiled binary
version = "0.1.0"                # Version number, following Semantic Versioning (SemVer)
edition = "2024"                 # Rust edition — determines which language features are enabled
description = "A simple hello world CLI installed via Homebrew"
license = "MIT"                  # Open-source license
authors = ["Your Name <your@email.com>"]  # Replace with your real info
repository = "https://github.com/YOUR_USERNAME/hello-brew"  # Replace YOUR_USERNAME

[dependencies]
# No external dependencies needed for now.
```

> **Important:** Replace `YOUR_USERNAME` with your actual GitHub username, and update `authors`.

### 3.2 Edit `src/main.rs`

Replace the contents of `src/main.rs` with:

```rust
use std::env;

fn main() {
    // Collect command-line arguments into a vector.
    // The first element (args[0]) is always the path to the binary itself.
    let args: Vec<String> = env::args().collect();

    // If the user passed --version, print the version and exit.
    // env!("CARGO_PKG_VERSION") is a compile-time macro that reads the version from Cargo.toml.
    if args.len() > 1 && args[1] == "--version" {
        println!("hello-brew {}", env!("CARGO_PKG_VERSION"));
        return;
    }

    // If the user passed --help, print usage information.
    if args.len() > 1 && args[1] == "--help" {
        println!("hello-brew {}", env!("CARGO_PKG_VERSION"));
        println!();
        println!("A simple hello world CLI installed via Homebrew");
        println!();
        println!("Usage: hello-brew [OPTIONS]");
        println!();
        println!("Options:");
        println!("  --version    Print version information");
        println!("  --help       Print this help message");
        return;
    }

    // Default behavior: print a greeting.
    println!("Hello from hello-brew v{}!", env!("CARGO_PKG_VERSION"));
}
```

---

## 4. Build and Test Locally

```bash
# Make sure you are in the project directory.
cd ~/Projects/hello-brew

# Build and run in debug mode (fast compilation, no optimizations).
cargo run
# Expected output: Hello from hello-brew v0.1.0!

# Test the --version flag.
# Note: -- separates cargo's own arguments from your program's arguments.
cargo run -- --version
# Expected output: hello-brew 0.1.0

# Test the --help flag.
cargo run -- --help
# Expected output: help text

# Build the optimized release binary.
cargo build --release
# The binary is at: target/release/hello-brew

# Run the release binary directly to verify.
./target/release/hello-brew
./target/release/hello-brew --version
```

**What's the difference?**
- `cargo run` = compile + run in debug mode (good for development)
- `cargo build --release` = compile with optimizations (smaller, faster binary)
- `target/release/hello-brew` = the final distributable executable

---

## 5. Initialize a Git Repository

```bash
# Make sure you are in ~/Projects/hello-brew

# Initialize a new git repository.
git init

# Create a .gitignore file to exclude build artifacts.
cat > .gitignore << 'EOF'
# Rust build artifacts
/target/

# macOS system files
.DS_Store
EOF

# Check which files will be committed.
git status

# Stage all files.
git add .

# Create the initial commit.
git commit -m "feat: init hello-brew project"
```

---

## 6. Push to GitHub

### 6.1 Create a Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `hello-brew`
3. Description: `A simple hello world CLI installed via Homebrew`
4. Set to **Public** (Homebrew taps require public repositories)
5. **Do NOT** check "Add a README file" (we already have code locally)
6. Click **Create repository**

### 6.2 Push Your Local Code

```bash
# Replace YOUR_USERNAME with your GitHub username.
git remote add origin https://github.com/YOUR_USERNAME/hello-brew.git

# Push to GitHub.
git branch -M main
git push -u origin main
```

> **Using SSH instead?** Use `git remote add origin git@github.com:YOUR_USERNAME/hello-brew.git`

Refresh the GitHub page — you should see your code.

---

## 7. Create a GitHub Release

> A **tag** is a version marker in Git. A **release** is a GitHub feature built on top of tags.
> Homebrew needs a downloadable source archive — GitHub automatically generates one for each release.

### Option A: Using the Command Line (Recommended)

```bash
# Make sure GitHub CLI (gh) is installed.
# If not: brew install gh
# First-time login: gh auth login

# Create an annotated tag.
git tag -a v0.1.0 -m "Release v0.1.0: initial release"

# Push the tag to GitHub.
git push origin v0.1.0

# Create a GitHub Release from the tag.
gh release create v0.1.0 \
  --title "v0.1.0" \
  --notes "Initial release of hello-brew - a simple CLI tool."
```

### Option B: Using the GitHub Web UI

1. Go to your repository page -> **Releases** -> **Create a new release**
2. Click **Choose a tag** -> type `v0.1.0` -> select **Create new tag on publish**
3. Release title: `v0.1.0`
4. Write a brief description
5. Click **Publish release**

### Verify the Release

After creating the release, this URL should download the source archive (replace YOUR_USERNAME):

```
https://github.com/YOUR_USERNAME/hello-brew/archive/refs/tags/v0.1.0.tar.gz
```

---

## 8. Get the SHA256 Checksum

> Homebrew uses SHA256 checksums to verify the integrity of downloaded files and prevent tampering.

```bash
# Replace YOUR_USERNAME with your GitHub username.
curl -sL https://github.com/YOUR_USERNAME/hello-brew/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
```

You will see output like:

```
a1b2c3d4e5f6... (a 64-character hex string)  -
```

**Copy and save this hash — you will need it in the next step when writing the Formula.**

---

## 9. Create a Homebrew Tap Repository

> **What is a Tap?**
> A Tap is Homebrew's mechanism for third-party repositories. Users add your tap with
> `brew tap username/hello`, and then they can `brew install` your tools.

### 9.1 Create the Tap Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `homebrew-hello`
   - **Must start with `homebrew-`** — this is a Homebrew naming convention
   - When users run `brew tap YOUR_USERNAME/hello`, Homebrew automatically looks for a repo named `homebrew-hello`
3. Set to **Public**
4. Check "Add a README file" (it's fine to check it this time)
5. Click **Create repository**

### 9.2 Clone It Locally

```bash
cd ~/Projects

# Replace YOUR_USERNAME with your GitHub username.
git clone https://github.com/YOUR_USERNAME/homebrew-hello.git
cd homebrew-hello

# Create the Formula directory.
mkdir -p Formula
```

---

## 10. Write the Homebrew Formula

> A Formula is a Ruby file that tells Homebrew how to download, build, and install your application.

Create a file at `Formula/hello-brew.rb` with the following content:

```ruby
# Homebrew Formula for hello-brew
# The filename must correspond to the class name: hello-brew.rb -> HelloBrew
class HelloBrew < Formula
  desc "A simple hello world CLI installed via Homebrew"
  homepage "https://github.com/YOUR_USERNAME/hello-brew"

  # Source download URL — points to the tar.gz auto-generated by GitHub Releases.
  url "https://github.com/YOUR_USERNAME/hello-brew/archive/refs/tags/v0.1.0.tar.gz"

  # SHA256 checksum — replace with the value you obtained in Step 8.
  sha256 "REPLACE_WITH_YOUR_SHA256"

  # Open-source license.
  license "MIT"

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
    assert_match "0.1.0", shell_output("#{bin}/hello-brew --version")
  end
end
```

**Important — you must replace two things in this file:**
- `YOUR_USERNAME` -> your actual GitHub username (appears 2 times)
- `REPLACE_WITH_YOUR_SHA256` -> the SHA256 hash from Step 8

### Commit and Push

```bash
git add Formula/hello-brew.rb
git commit -m "feat: add hello-brew formula v0.1.0"
git push origin main
```

---

## 11. Test the Installation

> This is the moment of truth — let's verify everything works end to end.

```bash
# Step 1: Add your tap (replace YOUR_USERNAME).
brew tap YOUR_USERNAME/hello

# Step 2: Install.
brew install hello-brew

# Step 3: Verify it works.
hello-brew
# Expected output: Hello from hello-brew v0.1.0!

hello-brew --version
# Expected output: hello-brew 0.1.0

# Step 4: Run the test block defined in the Formula.
brew test hello-brew

# Step 5 (optional): Audit the Formula for style issues.
brew audit --formula hello-brew
```

### Troubleshooting

**Installation fails:**

```bash
# View detailed build logs.
brew install hello-brew --verbose --debug
```

**SHA256 mismatch:**

```bash
# Re-download and recalculate the checksum.
curl -sL https://github.com/YOUR_USERNAME/hello-brew/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
# Update the sha256 value in the Formula, commit, and push again.
```

**Tap fails to add:**

```bash
# Make sure the repository is named exactly "homebrew-hello" and is set to Public.
# Verify you can access: https://github.com/YOUR_USERNAME/homebrew-hello
```

**Want to start over?**

```bash
brew uninstall hello-brew
brew untap YOUR_USERNAME/hello
# Then re-run tap and install.
```

---

## 12. Publish a New Version (Update Workflow)

When you update your code and want to release a new version, follow these steps:

### 12.1 Update Code and Version Number

```bash
cd ~/Projects/hello-brew

# Edit Cargo.toml — change version to the new value.
# Example: version = "0.2.0"

# Edit src/main.rs — add new features or fix bugs.

# Build and test locally.
cargo run
cargo run -- --version

# Commit your changes.
git add .
git commit -m "feat: describe your changes here"
```

### 12.2 Create a New Release

```bash
# Create and push a new tag.
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin main
git push origin v0.2.0

# Create a GitHub Release.
gh release create v0.2.0 \
  --title "v0.2.0" \
  --notes "What's new in v0.2.0: ..."
```

### 12.3 Get the New SHA256

```bash
curl -sL https://github.com/YOUR_USERNAME/hello-brew/archive/refs/tags/v0.2.0.tar.gz | shasum -a 256
```

### 12.4 Update the Formula

```bash
cd ~/Projects/homebrew-hello

# Edit Formula/hello-brew.rb:
#   1. Change the version in the url from v0.1.0 to v0.2.0
#   2. Replace the sha256 with the new value
#   3. Update the version in the test block as well

# Commit and push.
git add Formula/hello-brew.rb
git commit -m "feat: bump hello-brew to v0.2.0"
git push origin main
```

### 12.5 How Users Upgrade

```bash
# Users just need to run:
brew update              # Refresh tap index
brew upgrade hello-brew  # Upgrade to the new version
```

---

## 13. Advanced: Precompiled Binaries (Skip Build on User Side)

> **Why?**
> Compiling Rust from source takes several minutes. By uploading precompiled binaries,
> users can install in seconds without needing a Rust toolchain.

### 13.1 Build for Multiple Architectures

```bash
cd ~/Projects/hello-brew

# Apple Silicon Mac (M1/M2/M3/M4)
cargo build --release --target aarch64-apple-darwin

# Intel Mac (you may need to add the target first)
rustup target add x86_64-apple-darwin
cargo build --release --target x86_64-apple-darwin

# Linux x86_64 (requires a cross-compilation toolchain — best done in CI)
# rustup target add x86_64-unknown-linux-gnu
# cargo build --release --target x86_64-unknown-linux-gnu
```

### 13.2 Package and Upload

```bash
# Example for Apple Silicon:
cd target/aarch64-apple-darwin/release
tar -czf hello-brew-0.1.0-aarch64-apple-darwin.tar.gz hello-brew

# Get the SHA256.
shasum -a 256 hello-brew-0.1.0-aarch64-apple-darwin.tar.gz

# Example for Intel Mac:
cd ../../x86_64-apple-darwin/release
tar -czf hello-brew-0.1.0-x86_64-apple-darwin.tar.gz hello-brew
shasum -a 256 hello-brew-0.1.0-x86_64-apple-darwin.tar.gz

# Upload both to the existing GitHub Release.
gh release upload v0.1.0 \
  target/aarch64-apple-darwin/release/hello-brew-0.1.0-aarch64-apple-darwin.tar.gz \
  target/x86_64-apple-darwin/release/hello-brew-0.1.0-x86_64-apple-darwin.tar.gz
```

### 13.3 Update the Formula to Use Precompiled Binaries

Replace the contents of `Formula/hello-brew.rb` with:

```ruby
class HelloBrew < Formula
  desc "A simple hello world CLI installed via Homebrew"
  homepage "https://github.com/YOUR_USERNAME/hello-brew"
  version "0.1.0"
  license "MIT"

  # Automatically select the correct binary based on the user's architecture.
  on_macos do
    on_arm do
      # Apple Silicon (M1/M2/M3/M4)
      url "https://github.com/YOUR_USERNAME/hello-brew/releases/download/v0.1.0/hello-brew-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "REPLACE_WITH_ARM64_SHA256"
    end
    on_intel do
      # Intel Mac
      url "https://github.com/YOUR_USERNAME/hello-brew/releases/download/v0.1.0/hello-brew-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "REPLACE_WITH_X86_64_SHA256"
    end
  end

  # Uncomment if you also support Linux:
  # on_linux do
  #   url "https://github.com/YOUR_USERNAME/hello-brew/releases/download/v0.1.0/hello-brew-0.1.0-x86_64-unknown-linux-gnu.tar.gz"
  #   sha256 "REPLACE_WITH_LINUX_SHA256"
  # end

  def install
    # No compilation needed — just copy the precompiled binary into the bin directory.
    bin.install "hello-brew"
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/hello-brew --version")
  end
end
```

**Comparison:**

| | Build from Source | Precompiled Binary |
|---|---|---|
| Install time | 2–5 minutes | A few seconds |
| User needs Rust | Yes (auto-installed) | No |
| Your effort | Just upload source | Build multi-arch + upload |

---

## 14. Advanced: Automate Releases with GitHub Actions

> **Why?**
> Manually building for multiple architectures, uploading, and updating the Formula is tedious.
> With GitHub Actions you can automate the entire flow: push a tag -> build -> release -> done.

Create the file `.github/workflows/release.yml` in your `hello-brew` project:

```bash
mkdir -p .github/workflows
```

Then create `release.yml` with the following content:

```yaml
# .github/workflows/release.yml
# Triggers when a tag starting with "v" is pushed (e.g., v0.1.0, v1.0.0).
name: Release

on:
  push:
    tags:
      - 'v*'

# Write permission is needed to create Releases.
permissions:
  contents: write

jobs:
  # Step 1: Build on multiple platforms.
  build:
    name: Build ${{ matrix.target }}
    strategy:
      matrix:
        include:
          # macOS Apple Silicon
          - target: aarch64-apple-darwin
            os: macos-latest
          # macOS Intel
          - target: x86_64-apple-darwin
            os: macos-latest
          # Linux x86_64
          - target: x86_64-unknown-linux-gnu
            os: ubuntu-latest

    runs-on: ${{ matrix.os }}

    steps:
      # Check out the repository.
      - uses: actions/checkout@v4

      # Install the Rust toolchain.
      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable
        with:
          targets: ${{ matrix.target }}

      # Build the optimized release binary.
      - name: Build
        run: cargo build --release --target ${{ matrix.target }}

      # Package the binary into a tar.gz archive.
      - name: Package
        shell: bash
        run: |
          cd target/${{ matrix.target }}/release
          tar -czf hello-brew-${{ matrix.target }}.tar.gz hello-brew
          shasum -a 256 hello-brew-${{ matrix.target }}.tar.gz > hello-brew-${{ matrix.target }}.tar.gz.sha256

      # Upload the build artifacts for the release job.
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: hello-brew-${{ matrix.target }}
          path: |
            target/${{ matrix.target }}/release/hello-brew-${{ matrix.target }}.tar.gz
            target/${{ matrix.target }}/release/hello-brew-${{ matrix.target }}.tar.gz.sha256

  # Step 2: Create a GitHub Release and upload all binaries.
  release:
    name: Create Release
    needs: build  # Wait for all builds to finish.
    runs-on: ubuntu-latest

    steps:
      # Download all build artifacts.
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          path: artifacts

      # Create the Release and attach the binaries.
      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          files: artifacts/**/*
          generate_release_notes: true
```

### Usage

With this workflow in place, your release process becomes:

```bash
# 1. Update the version in Cargo.toml.
# 2. Commit your changes.
git add .
git commit -m "feat: bump version to 0.2.0"

# 3. Create and push a tag.
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin main
git push origin v0.2.0

# 4. GitHub Actions kicks off automatically.
# 5. When done, the Release page will have binaries for all platforms.
# 6. Update the Formula in homebrew-hello with the new SHA256 values.
```

> **Going further:** You can add another job to the workflow that automatically updates
> the homebrew-hello repository. This requires a Personal Access Token (PAT) with write
> access to the tap repo.

---

## Quick Reference Card

### How users install your tool

```bash
brew tap YOUR_USERNAME/hello
brew install hello-brew
```

### Your release workflow

```bash
# Edit code -> bump version -> commit -> tag -> push -> update Formula
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin main && git push origin vX.Y.Z
# Then update url + sha256 in homebrew-hello
```

### Useful commands

```bash
brew tap YOUR_USERNAME/hello       # Add the tap
brew install hello-brew          # Install
brew upgrade hello-brew          # Upgrade to latest version
brew uninstall hello-brew        # Uninstall
brew untap YOUR_USERNAME/hello     # Remove the tap
brew test hello-brew             # Run the Formula's test block
brew audit --formula hello-brew  # Check Formula for style issues
```

---

> **Congratulations!** You have completed the full journey from zero to `brew install`.
> Replace all occurrences of `YOUR_USERNAME` in this guide with your GitHub username, and you're ready to go.
