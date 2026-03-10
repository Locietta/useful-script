# config.nu
#
# Installed by:
# version = "0.111.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.show_banner = false

def --wrapped time [...args: string] {
	if ($args | is-empty) {
		print $"(ansi light_magenta)Usage: time [command [arg0 arg1 ...]](ansi reset)"
		return
	}

	let command_str = ($args | str join ' ')
	let start = (date now)
	do -i { nu -c $command_str }
	let elapsed_seconds = (((date now) - $start) / 1sec)
	print $"(ansi light_blue)Total Runtime: ($elapsed_seconds)(ansi reset)"
}

# Proxy
$env.http_proxy = "http://127.0.0.1:7890"
$env.https_proxy = "http://127.0.0.1:7890"

# import hooks
source $"($nu.config-path | path dirname)/sfsu.nu"
source $"($nu.config-path | path dirname)/zoxide.nu"
source $"($nu.config-path | path dirname)/pure.nu"

# alias sudo to gsudo
alias sudo = gsudo
alias su = gsudo

