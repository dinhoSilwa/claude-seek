# ShellCheck configuration for claude-seek

# Enable all checks
enable=all

# Disable some warnings we don't care about
disable=SC1091  # Can't follow non-constant source
disable=SC2034  # Variable appears unused
disable=SC2154  # Variable is referenced but not assigned
disable=SC2086  # Double quote to prevent globbing

# Set shell to bash
shell=bash

# Exclude paths
exclude=node_modules/

# Color output
color=auto

# External sources
external-sources=true