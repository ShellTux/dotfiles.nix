use clap::{Parser, Subcommand};
use clap_complete::Shell;

#[derive(Parser)]
#[command(name = "mknix")]
#[command(about = "CLI for creating Nix dotfiles and configurations")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,

    #[arg(long)]
    pub completion: Option<Shell>,

    #[arg(long)]
    pub dry_run: bool,
}

#[derive(Subcommand, Clone)]
pub enum Commands {
    Home {
        users: Vec<String>,
    },
    #[command(subcommand)]
    Module(Module),
    #[clap(alias = "pkg")]
    Package {
        names: Vec<String>,
    },
    #[clap(alias = "wrap")]
    Wrapper {
        names: Vec<String>,
    },
    Host {
        names: Vec<String>,
    },
}

#[derive(Subcommand, Clone)]
pub enum Module {
    #[command(name = "nixos")]
    NixOS {
        #[arg(required = true)]
        names: Vec<String>,
    },
    #[command(name = "home-manager")]
    HomeManager {
        #[arg(required = true)]
        names: Vec<String>,
    },
    #[command(name = "wrapper")]
    Wrapper {
        #[arg(required = true)]
        names: Vec<String>,
    },
}
