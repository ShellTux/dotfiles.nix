use clap::CommandFactory;
use clap_complete::{
    generate_to,
    shells::{Bash, Fish, Zsh},
};
use std::{env, fs, io::Error};

include!("src/cli.rs");

fn main() -> Result<(), Error> {
    let pkg_name = env::var("CARGO_PKG_NAME").unwrap_or_else(|_| "mknix".to_string());

    //let outdir = match env::var_os("OUT_DIR") {
    //    None => return Ok(()),
    //    Some(outdir) => outdir,
    //};

    for shell in ["bash", "zsh", "fish"] {
        let directory = format!("completions/{}", shell);
        fs::create_dir_all(&directory).unwrap();

        match shell {
            "bash" => println!(
                "cargo:warning=completion file is generated: {:?}",
                generate_to(Bash, &mut Cli::command(), pkg_name.clone(), &directory)?
            ),
            "zsh" => println!(
                "cargo:warning=completion file is generated: {:?}",
                generate_to(Zsh, &mut Cli::command(), pkg_name.clone(), &directory)?
            ),
            "fish" => println!(
                "cargo:warning=completion file is generated: {:?}",
                generate_to(Fish, &mut Cli::command(), pkg_name.clone(), &directory)?
            ),
            _ => unreachable!(),
        }
    }

    Ok(())
}
