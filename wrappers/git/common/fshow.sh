#!/bin/sh
# shellcheck disable=2142

_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogDiff="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"
_viewGitLogStat="$_gitLogLineToHash | xargs -I % sh -c 'git show --stat --color=always %'"

if command -v diff-so-fancy >/dev/null 2>/dev/null
then
	git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@" |
		fzf --no-sort --reverse --tiebreak=index --no-multi \
		--ansi --preview="$_viewGitLogDiff" \
		--header "enter to view, alt-y to copy hash, alt-s to show stat, alt-d to show diff" \
		--bind "enter:execute:$_viewGitLogDiff   | less -R" \
		--bind "alt-y:execute:$_gitLogLineToHash | wl-copy" \
		--bind "alt-s:change-preview:$_viewGitLogStat" \
		--bind "alt-d:change-preview:$_viewGitLogDiff"

else
	git log --graph --color=always \
		--format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
		fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
		--bind "ctrl-m:execute:
			(grep -o '[a-f0-9]\{7\}' | head -1 |
				xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
							{}
							FZF-EOF"
fi

