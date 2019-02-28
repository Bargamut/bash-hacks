# Shows type of VCS, current branch and two markers based on status: changed and/or unknown

# https://unix.stackexchange.com/questions/105958/terminal-prompt-not-wrapping-correctly
# https://unix.stackexchange.com/questions/173851/how-do-i-handle-special-characters-like-a-bracket-in-a-bash-script

BOLD=01
YELLOW=33

function getVSCBranch() {
	VCS_BRANCH=""
	VCS_TYPE=""
	GIT_BRANCH="$(git branch 2>/dev/null | grep '^*' | colrm 1 2)"
	HG_BRANCH="$(hg branch 2>/dev/null)"

	if [ "$GIT_BRANCH" != '' ]; then
		VCS_TYPE="git"
		VCS_BRANCH="$GIT_BRANCH$(vcs_dirty 'git')"
	elif [ "$HG_BRANCH" != '' ]; then
		VCS_TYPE="hg"
		VCS_BRANCH="$HG_BRANCH$(vcs_dirty 'hg')"
	fi;

	if [ "$VCS_BRANCH" != '' ]; then
		echo -en " \e[${BOLD};${YELLOW}m[$VCS_TYPE]\e[0;${YELLOW}m \u2387 $VCS_BRANCH "
	fi
}

vcs_dirty() {
	FLAG=''

	if [ "$1" == 'git' ]; then
		FLAG='-s'
	fi;

	VCS_STATUS="$($1 status $FLAG 2> /dev/null \
    | awk '$1 == "??" || $1 == "?" { unknown = 1; } 
           $1 != "??" && $1 != "?" { changed = 1; }
           END {
						 status = "";
             if (changed) status = "\\e[97;100m changed \\e[0m"
             if (unknown) status = status "\\e[01;41;97m unknown \\e[0m"
             if (status != "") printf "\\e[0m %s\\e[0m", status;
           }')"
	echo -en $VCS_STATUS
}

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\e[01;32m\]\u@\h\[\e[0m\]:\[\e[01;34m\]\w\[\e[0m\]$(getVSCBranch)\[\e[0m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(getVSCBranch)\$ '
fi