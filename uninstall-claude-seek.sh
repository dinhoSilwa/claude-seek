#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/.claude-seek"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🗑️  Uninstalling claude-seek${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Remove everything? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Cancelled${NC}"
    exit 0
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${BLUE}📁 Removing $INSTALL_DIR...${NC}"
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}   ✅ Removed${NC}"
fi

# Remove from shell profile
detect_profile() {
    case "$(basename "$SHELL")" in
        zsh) echo "$HOME/.zshrc" ;;
        bash)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        *) echo "" ;;
    esac
}

PROFILE=$(detect_profile)
if [ -n "$PROFILE" ] && [ -f "$PROFILE" ]; then
    if grep -q "/.claude-seek:" "$PROFILE" 2>/dev/null; then
        echo -e "${BLUE}📝 Cleaning $PROFILE...${NC}"
        sed -i.bak '/\/.claude-seek:/d' "$PROFILE"
        echo -e "${GREEN}   ✅ Cleaned${NC}"
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Uninstall complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"