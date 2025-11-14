use bat::PrettyPrinter;
use clap::{CommandFactory, Parser};
use clap_complete::generate;
use mknix::{
    GodsRepository,
    cli::{Cli, Commands, ModuleType},
};
use std::{
    env,
    fs::{self, File},
    io::{self, Write},
    path::Path,
    process::exit,
};

fn create_file(filepath: &str, data: String, cli: &Cli) {
    // You are cringing at a lot of unwrap
    // IDC. Deal with it 󰱫
    if !cli.dry_run {
        fs::create_dir_all(Path::new(filepath).parent().unwrap()).unwrap();

        let mut file = File::create(filepath).expect("Unable to create file");
        file.write_all(data.as_bytes())
            .expect("Unable to write to file");
        println!("File {}: written successfully!", filepath);

        PrettyPrinter::new()
            .input_file(filepath)
            .line_numbers(true)
            .grid(true)
            .header(true)
            .rule(true)
            .theme("TwoDark")
            .print()
            .unwrap();
    } else {
        PrettyPrinter::new()
            .input_from_bytes(data.as_bytes())
            .line_numbers(true)
            .grid(true)
            .header(true)
            .rule(true)
            .theme("TwoDark")
            .print()
            .unwrap();
    }
}

fn main() {
    let pkg_name = env::var("CARGO_PKG_NAME").unwrap_or_else(|_| "mknix".to_string());
    let cli = Cli::parse();

    if let Some(shell) = cli.completion {
        let mut app = Cli::command();
        generate(shell, &mut app, pkg_name, &mut io::stdout());
        return;
    }

    match &cli.command {
        None => Cli::command().print_long_help().unwrap(),

        Some(command) => match command {
            Commands::Home { users } => {
                if users.len() == 0 {
                    eprintln!("No user provided!");
                    exit(1);
                };

                for user in users {
                    create_file(
                        format!("./homes/{}/README.md", &user).as_ref(),
                        include_str!("../templates/homes/README.md").replace("USERNAME", &user),
                        &cli,
                    );
                    create_file(
                        format!("./homes/{}/default.nix", user).as_ref(),
                        include_str!("../templates/homes/default.nix").replace("USERNAME", &user),
                        &cli,
                    );
                }
            }
            Commands::Module { module_type, names } => {
                if names.len() == 0 {
                    eprintln!("No module provided!");
                    exit(1);
                };

                for module_name in names {
                    let name_path = module_name.replace(".", "/");
                    match module_type {
                        ModuleType::NixOS => {
                            create_file(
                                format!("./modules/nixos/{}/default.nix", name_path).as_ref(),
                                include_str!("../templates/modules/nixos/default.nix")
                                    .replace("MODULE_NAME", &module_name),
                                &cli,
                            );
                        }
                        ModuleType::HomeManager => {
                            create_file(
                                format!("./modules/home-manager/{}/default.nix", name_path)
                                    .as_ref(),
                                include_str!("../templates/modules/home-manager/default.nix")
                                    .replace("MODULE_NAME", &module_name),
                                &cli,
                            );
                        }
                    }
                }
            }

            Commands::Package { names } => {
                if names.len() == 0 {
                    eprintln!("No package provided!");
                    exit(1);
                };

                for module_name in names {
                    create_file(
                        format!("./pkgs/{}/default.nix", module_name).as_ref(),
                        include_str!("../templates/pkgs/default.nix")
                            .replace("PACKAGE_NAME", &module_name),
                        &cli,
                    );

                    create_file(
                        format!("./pkgs/{}/{}.sh", module_name, module_name).as_ref(),
                        include_str!("../templates/pkgs/default.sh").to_string(),
                        &cli,
                    );
                }
            }
            Commands::Host { names } => {
                for name in if names.len() == 0 {
                    let god = GodsRepository::default().get_random_god().unwrap();
                    dbg!(&god);
                    [god].map(|god| god.to_host()).into_iter().collect()
                } else {
                    names.clone()
                } {
                    create_file(
                        format!("./hosts/{}/README.md", name).as_ref(),
                        include_str!("../templates/hosts/README.md").replace("HOST_NAME", &name),
                        &cli,
                    );
                    create_file(
                        format!("./hosts/{}/default.nix", name).as_ref(),
                        include_str!("../templates/hosts/default.nix").to_string(),
                        &cli,
                    );
                    create_file(
                        format!("./hosts/{}/configuration.nix", name).as_ref(),
                        include_str!("../templates/hosts/configuration.nix").to_string(),
                        &cli,
                    );
                    create_file(
                        format!("./hosts/{}/hardware.nix", name).as_ref(),
                        include_str!("../templates/hosts/hardware.nix").to_string(),
                        &cli,
                    );
                }
            }
        },
    }
}
