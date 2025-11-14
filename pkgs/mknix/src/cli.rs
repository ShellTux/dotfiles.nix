use clap::{Parser, Subcommand};
use clap_complete::Shell;
use std::{fmt, str::FromStr};

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

#[derive(Clone)]
pub enum ModuleType {
    NixOS,
    HomeManager,
}

impl FromStr for ModuleType {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "nixos" => Ok(Self::NixOS),
            "home-manager" => Ok(Self::HomeManager),
            _ => todo!(),
        }
    }
}

impl fmt::Display for ModuleType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ModuleType::NixOS => write!(f, "nixos"),
            ModuleType::HomeManager => write!(f, "home-manager"),
        }
    }
}

#[derive(Subcommand, Clone)]
pub enum Commands {
    Home {
        users: Vec<String>,
    },
    Module {
        module_type: ModuleType,
        names: Vec<String>,
    },
    #[clap(alias = "pkg")]
    Package {
        names: Vec<String>,
    },
    Host {
        names: Vec<String>,
    },
}
