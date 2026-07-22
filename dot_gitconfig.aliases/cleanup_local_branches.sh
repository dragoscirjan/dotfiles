#!/bin/sh

cleanup_local_branches() {
  git branch --format='%(refname:short)' |
    while IFS= read -r branch; do
      case "$branch" in
      main | master | develop)
        continue
        ;;
      esac

      if git branch -D -- "$branch" >/dev/null; then
        printf 'Removed local branch: %s\n' "$branch"
      fi
    done
}
