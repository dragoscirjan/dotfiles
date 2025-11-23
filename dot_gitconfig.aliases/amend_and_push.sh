#!/bin/sh

amend_and_push() {
  add_args=""
  c_args=""
  psh_args=""
  section=0

  for arg in "$@"; do
    case "$arg" in
    --)
      section=$((section + 1))
      ;;
    *)
      case $section in
      0) add_args="$add_args $arg" ;;
      1) c_args="$c_args $arg" ;;
      2) psh_args="$psh_args $arg" ;;
      esac
      ;;
    esac
  done

  echo "Calling: " >&2
  echo git add $add_args >&2
  echo git c --amend $c_args >&2
  echo git psh --force-with-lease $psh_args >&2
  echo "---" >&2

  git add $add_args
  git c --amend $c_args &&
    git psh --force-with-lease $psh_args
}
