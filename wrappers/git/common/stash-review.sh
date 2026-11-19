#!/bin/sh

set -eu

LOG_FILE="${LOG_FILE:-./stash-review.log}"
TMP_DROP="$(mktemp)"

cleanup() {
    rm --force "$TMP_DROP"
}

trap cleanup EXIT INT TERM

# Colors (only if stdout is a terminal)
if [ -t 1 ]
then
    RED=$(printf '\033[0;31m')
    GREEN=$(printf '\033[0;32m')
    YELLOW=$(printf '\033[1;33m')
    BLUE=$(printf '\033[0;34m')
    NC=$(printf '\033[0m')
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    NC=""
fi

log() {
    level=$1
    shift
    printf '[%s] [%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$level" \
        "$*" >> "$LOG_FILE"
}

info() {
    printf '%s[INFO]%s %s\n' "$BLUE" "$NC" "$*"
    log INFO "$*"
}

warn() {
    printf '%s[WARN]%s %s\n' "$YELLOW" "$NC" "$*"
    log WARN "$*"
}

success() {
    printf '%s[OK]%s %s\n' "$GREEN" "$NC" "$*"
    log OK "$*"
}

error() {
    printf '%s[ERROR]%s %s\n' "$RED" "$NC" "$*"
    log ERROR "$*"
}

STASHES="$(git stash list | cut --delimiter=: --fields=1)"

if [ -z "$STASHES" ]
then
    warn "No stashes found."
    exit 0
fi

info "Logging to $LOG_FILE"

for stash in $STASHES
do
    [ -n "$stash" ] || continue

    clear 2>/dev/null || :

    printf '%s==================================================%s\n' "$BLUE" "$NC"
    printf '%sReviewing %s%s\n' "$BLUE" "$stash" "$NC"
    printf '%s==================================================%s\n\n' "$BLUE" "$NC"

    log INFO "Showing $stash"

    git stash show --patch "$stash"

    printf '\n'
    printf 'Mark %s for deletion? [y/N] ' "$stash"
    read -r answer

    case "$answer" in
        y|Y)
            echo "$stash" >> "$TMP_DROP"
            info "$stash marked for deletion"
            ;;
        *)
            info "$stash kept"
            ;;
    esac

    printf '\nPress ENTER to continue...'
    # shellcheck disable=SC2034
    read -r dummy
done

echo
printf '%s==================================================%s\n' "$YELLOW" "$NC"
printf '%sStashes marked for deletion%s\n' "$YELLOW" "$NC"
printf '%s==================================================%s\n' "$YELLOW" "$NC"

if [ ! -s "$TMP_DROP" ]
then
    info "No stashes selected."
    exit 0
fi

cat "$TMP_DROP"

echo
warn "The above stashes will be permanently removed."
printf 'Proceed with deletion? [y/N] '
read -r confirm

case "$confirm" in
    y|Y)
        ;;
    *)
        warn "Operation cancelled."
        exit 0
        ;;
esac

info "Starting stash cleanup"

# Drop highest stash indexes first
sed --regexp-extended 's|stash@\{([0-9]+)\}|\1 &|' "$TMP_DROP" | \
    sort --reverse --numeric-sort | \
    cut --delimiter=' ' --fields=2- | \
    while IFS= read -r stash
    do
        info "Dropping $stash"

        if git stash drop "$stash"
        then
            success "Dropped $stash"
        else
            error "Failed to drop $stash"
        fi
    done

success "Cleanup completed"
