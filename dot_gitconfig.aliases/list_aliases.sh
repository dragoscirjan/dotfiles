#!/bin/sh

list_aliases() {
  if [ "$#" -gt 1 ]; then
    printf 'Usage: git aliases [<alias>]\n' >&2
    return 2
  fi

  if [ "$#" -eq 1 ]; then
    alias_name=$1
    description=$(git config --get "aliashelp.$alias_name.description") || {
      printf 'No help found for Git alias: %s\n' "$alias_name" >&2
      return 1
    }
    usage=$(git config --get "aliashelp.$alias_name.usage") || return 1

    printf 'Usage: %s\n\n%s\n' "$usage" "$description"
    return
  fi

  printf 'Git aliases:\n\n'
  git config --get-regexp '^aliashelp\..*\.description$' |
    while IFS=' ' read -r key description; do
      alias_name=${key#aliashelp.}
      alias_name=${alias_name%.description}
      printf '  %-8s %s\n' "$alias_name" "$description"
    done
}
