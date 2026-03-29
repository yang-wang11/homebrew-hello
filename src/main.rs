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

    // If the user passed --os, print operating system information.
    if args.len() > 1 && args[1] == "--os" {
        println!("Current OS: {}", env::consts::OS);
        println!("Architecture: {}", env::consts::ARCH);
        println!("OS Family: {}", env::consts::FAMILY);
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
        println!("  --os         Print operating system information");
        println!("  --help       Print this help message");
        return;
    }

    // Default behavior: print a greeting.
    println!("Hello from hello-brew v{}!", env!("CARGO_PKG_VERSION"));
}