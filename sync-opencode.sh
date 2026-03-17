#!/usr/bin/env bash

C=chezmoi

for item in agents commands opencode.json prompts skills; do
  $C add ~/.config/opencode/$item
done
