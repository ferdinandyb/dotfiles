#!/bin/sh

if command -v vim >/dev/null 2>&1; then
  echo "Bootstraping Vim"
  vim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+qall'
fi
