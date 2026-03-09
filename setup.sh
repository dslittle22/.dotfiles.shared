#!/bin/zsh
set -euo pipefail

DOTFILES_SHARED="$HOME/.dotfiles.shared"

pause() {
  echo "$1"
  echo 'Press any key to continue...'; read -k1 -s
}

# --- Homebrew ---

if ! command -v brew &> /dev/null; then
    echo "Installing homebrew..."
    /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew_install() {
  if ! brew list "$1" &> /dev/null; then
    echo "Installing $1..."
    brew install "$1"
  fi
}

brew_install 1password
brew_install git

# https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
brew_install font-meslo-lg-nerd-font
brew_install font-fira-code-nerd-font

# --- Symlinks: home/ -> ~/ ---

echo "Symlinking home/ -> ~/..."

for file in "$DOTFILES_SHARED"/home/.*; do
  name=$(basename "$file")
  [[ "$name" == "." || "$name" == ".." ]] && continue

  if [ -e "$HOME/$name" ] && [ ! -L "$HOME/$name" ]; then
    mkdir -p ~/.dotfilesbak
    echo "  $name already exists, backing up to ~/.dotfilesbak"
    mv "$HOME/$name" ~/.dotfilesbak/"$name".$(date +%s)
  fi

  ln -sf "$DOTFILES_SHARED/home/$name" "$HOME/$name"
  echo "  $name -> ~/$name"
done

# --- Symlinks: config/ -> ~/.config/ ---

echo "Symlinking config/ -> ~/.config/..."
mkdir -p ~/.config

for entry in "$DOTFILES_SHARED"/config/*; do
  name=$(basename "$entry")

  if [ -e "$HOME/.config/$name" ] && [ ! -L "$HOME/.config/$name" ]; then
    mkdir -p ~/.dotfilesbak
    echo "  $name already exists, backing up to ~/.dotfilesbak"
    mv "$HOME/.config/$name" ~/.dotfilesbak/"$name".$(date +%s)
  fi

  ln -sfn "$DOTFILES_SHARED/config/$name" "$HOME/.config/$name"
  echo "  $name -> ~/.config/$name"
done

# --- Bootstrap starter files if no .dotfiles.local yet ---

if [ ! -f "$HOME/.zshrc" ]; then
  echo "No ~/.zshrc found. Creating a starter that sources .zshrc.shared..."
  echo 'source ~/.zshrc.shared' > "$HOME/.zshrc"
fi

if [ ! -f "$HOME/.gitconfig" ]; then
  echo "No ~/.gitconfig found. Creating a starter that includes .gitconfig.shared..."
  printf '[include]\n\tpath = .gitconfig.shared\n' > "$HOME/.gitconfig"
fi

# --- Karabiner + Goku ---

if ! command -v goku &> /dev/null; then
  echo "Installing goku..."
  brew install yqrashawn/goku/goku
  pause "Setup Karabiner permissions and rename profile to \"default\"!"
fi

mkdir -p ~/.config/karabiner

echo "Running goku..."
goku

# --- macOS keyboard shortcuts ---

echo "Setting macOS keyboard shortcuts..."

# Spotify: Cmd+F = Search, Cmd+L = Filter
defaults write com.spotify.client NSUserKeyEquivalents -dict-add "Search" "@f"
defaults write com.spotify.client NSUserKeyEquivalents -dict-add "Filter" "@l"

# Google Chrome: Ctrl+Option+D = Duplicate Tab, Ctrl+Cmd+T = New Tab to the Right
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "Duplicate Tab" "^~d"
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "New Tab to the Right" "^@t"

# Safari: Option+Cmd+Left = Show Previous Tab, Option+Cmd+Right = Show Next Tab
defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "Show Previous Tab" "~@\\U2190"
defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "Show Next Tab" "~@\\U2192"

# Zoom: Ctrl+Cmd+F = Enter Full Screen
defaults write zoom.us.app NSUserKeyEquivalents -dict-add "Enter Full Screen" "^@f"

# --- Remaining manual steps ---

echo ""
echo "Done! Remaining manual steps:"
echo "- Clone .dotfiles.local and run its setup.sh"
echo "- Import safari adguard settings"
echo "- Install wavelink and import settings"
