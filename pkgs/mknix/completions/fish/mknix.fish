# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_mknix_global_optspecs
	string join \n completion= h/help
end

function __fish_mknix_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_mknix_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_mknix_using_subcommand
	set -l cmd (__fish_mknix_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c mknix -n "__fish_mknix_needs_command" -l completion -r -f -a "bash\t''
elvish\t''
fish\t''
powershell\t''
zsh\t''"
complete -c mknix -n "__fish_mknix_needs_command" -s h -l help -d 'Print help'
complete -c mknix -n "__fish_mknix_needs_command" -f -a "home"
complete -c mknix -n "__fish_mknix_needs_command" -f -a "module"
complete -c mknix -n "__fish_mknix_needs_command" -f -a "package"
complete -c mknix -n "__fish_mknix_needs_command" -f -a "host"
complete -c mknix -n "__fish_mknix_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mknix -n "__fish_mknix_using_subcommand home" -s h -l help -d 'Print help'
complete -c mknix -n "__fish_mknix_using_subcommand module" -s h -l help -d 'Print help'
complete -c mknix -n "__fish_mknix_using_subcommand package" -s h -l help -d 'Print help'
complete -c mknix -n "__fish_mknix_using_subcommand host" -s h -l help -d 'Print help'
complete -c mknix -n "__fish_mknix_using_subcommand help; and not __fish_seen_subcommand_from home module package host help" -f -a "home"
complete -c mknix -n "__fish_mknix_using_subcommand help; and not __fish_seen_subcommand_from home module package host help" -f -a "module"
complete -c mknix -n "__fish_mknix_using_subcommand help; and not __fish_seen_subcommand_from home module package host help" -f -a "package"
complete -c mknix -n "__fish_mknix_using_subcommand help; and not __fish_seen_subcommand_from home module package host help" -f -a "host"
complete -c mknix -n "__fish_mknix_using_subcommand help; and not __fish_seen_subcommand_from home module package host help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
