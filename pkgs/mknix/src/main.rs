use bat::PrettyPrinter;
use clap::{CommandFactory, Parser};
use clap_complete::generate;
use mknix::{
    GodsRepository,
    cli::{Cli, Commands, Module},
};
use std::{
    env,
    fs::{self, File},
    io::{self, Write},
    path::Path,
    process::exit,
};

fn create_file(filepath: &str, data: &str, cli: &Cli) {
    // You are cringing at a lot of unwrap
    // IDC. Deal with it 󰱫
    if cli.dry_run {
        PrettyPrinter::new()
            .input_from_bytes(data.as_bytes())
            .line_numbers(true)
            .grid(true)
            .header(true)
            .rule(true)
            .theme("TwoDark")
            .print()
            .unwrap();
    } else {
        fs::create_dir_all(Path::new(filepath).parent().unwrap()).unwrap();

        let mut file = File::create(filepath).expect("Unable to create file");
        file.write_all(data.as_bytes())
            .expect("Unable to write to file");
        println!("File {filepath}: written successfully!");

        PrettyPrinter::new()
            .input_file(filepath)
            .line_numbers(true)
            .grid(true)
            .header(true)
            .rule(true)
            .theme("TwoDark")
            .print()
            .unwrap();
    }
}

#[allow(clippy::too_many_lines)]
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
                if users.is_empty() {
                    eprintln!("No user provided!");
                    exit(1);
                };

                for user in users {
                    create_file(
                        format!("./homes/{}/README.md", &user).as_ref(),
                        &include_str!("../templates/homes/README.md").replace("USERNAME", user),
                        &cli,
                    );
                    create_file(
                        format!("./homes/{user}/default.nix").as_ref(),
                        &include_str!("../templates/homes/default.nix").replace("USERNAME", user),
                        &cli,
                    );
                }
            }
            Commands::Module(module) => {
                let (r#type, names, template) = match module {
                    Module::NixOS { names } => (
                        "nixos",
                        names,
                        include_str!("../templates/modules/nixos/default.nix"),
                    ),
                    Module::HomeManager { names } => (
                        "home-manager",
                        names,
                        include_str!("../templates/modules/home-manager/default.nix"),
                    ),
                    Module::Wrapper { names } => (
                        "wrapper",
                        names,
                        include_str!("../templates/modules/wrapper/default.nix"),
                    ),
                };

                if names.is_empty() {
                    eprintln!("No module provided!");
                    exit(1);
                }

                for module_name in names {
                    let name_path = module_name.replace(".", "/");
                    create_file(
                        format!("./modules/{type}/{name_path}/default.nix").as_ref(),
                        &template.replace("MODULE_NAME", module_name),
                        &cli,
                    );
                }
            }
            Commands::Package { names } => {
                if names.is_empty() {
                    eprintln!("No package provided!");
                    exit(1);
                };

                for module_name in names {
                    create_file(
                        format!("./pkgs/{module_name}/default.nix").as_ref(),
                        &include_str!("../templates/pkgs/default.nix")
                            .replace("PACKAGE_NAME", module_name),
                        &cli,
                    );

                    create_file(
                        format!("./pkgs/{module_name}/{module_name}.sh").as_ref(),
                        include_str!("../templates/pkgs/default.sh"),
                        &cli,
                    );
                }
            }
            Commands::Host { names } => {
                let names = if names.is_empty() {
                    let god = GodsRepository::default().get_random_god().unwrap();
                    dbg!(&god);
                    [god].map(|god| god.to_host()).into_iter().collect()
                } else {
                    names.clone()
                };

                for name in names {
                    create_file(
                        format!("./hosts/{name}/README.md").as_ref(),
                        &include_str!("../templates/hosts/README.md").replace("HOST_NAME", &name),
                        &cli,
                    );
                    create_file(
                        format!("./hosts/{name}/default.nix").as_ref(),
                        include_str!("../templates/hosts/default.nix"),
                        &cli,
                    );
                    create_file(
                        format!("./hosts/{name}/configuration.nix").as_ref(),
                        include_str!("../templates/hosts/configuration.nix"),
                        &cli,
                    );
                    create_file(
                        format!("./hosts/{name}/hardware.nix").as_ref(),
                        include_str!("../templates/hosts/hardware.nix"),
                        &cli,
                    );
                }
            }
            Commands::Wrapper { names: _ } => todo!(),
        },
    }
}
