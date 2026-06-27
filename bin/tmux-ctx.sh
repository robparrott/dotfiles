#!/usr/bin/env bash
# Show kubectl context and AWS profile when they are set/non-default.
# Called by tmux status-right via #(~/.dotfiles/bin/tmux-ctx.sh)

parts=()

# Kubernetes context (only if kubectl is available and context is set)
if command -v kubectl &>/dev/null; then
    ctx=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$ctx" && "$ctx" != "default" ]]; then
        parts+=("⎈ $ctx")
    fi
fi

# AWS profile (only if non-default)
if [[ -n "${AWS_PROFILE:-}" && "${AWS_PROFILE}" != "default" ]]; then
    parts+=(" ${AWS_PROFILE}")
fi

# Print space-separated, or nothing if both are default/unset
if [[ ${#parts[@]} -gt 0 ]]; then
    ( IFS=' | '; echo "${parts[*]}" )
fi
