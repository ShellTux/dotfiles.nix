# shellcheck disable=SC2148
_fzf_compgen_path() {
    fd \
        --hidden \
        --follow \
        --exclude .git \
        --exclude .direnv \
        --exclude node_modules \
        --exclude __pycache__ \
        . "$1"
}

_fzf_compgen_dir() {
    fd \
        --type d \
        --hidden \
        --follow \
        --exclude .git \
        --exclude .direnv \
        --exclude node_modules \
        --exclude __pycache__ \
        . "$1"
}
