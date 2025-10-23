#!/bin/bash
# ========================================================
# Setup Script: Chrome Launcher for user 'LabsKraft'
# Makes Chrome open with --user-data-dir automatically
# Also cleans old lock files to prevent profile errors
# ========================================================

set -e

CHROME_PATH=$(command -v google-chrome-stable || true)
if [ -z "$CHROME_PATH" ]; then
  echo "❌ Google Chrome is not installed or not in PATH."
  echo "Please install it first (e.g. sudo apt install google-chrome-stable -y)"
  exit 1
fi

echo "✅ Chrome found at: $CHROME_PATH"
echo "Setting up launcher for user: LabsKraft"

# --------------------------------------------------------
# 1. Create a wrapper command accessible as 'chrome'
# --------------------------------------------------------
sudo tee /usr/local/bin/chrome >/dev/null <<'EOF'
#!/bin/bash
# Temporary Chrome launcher with automatic cleanup

# 🧹 Remove old lock files before launch
rm -f ~/.config/google-chrome/SingletonLock
rm -f ~/.config/google-chrome/SingletonCookie
rm -f ~/.config/google-chrome/SingletonSocket

# 🚀 Launch Chrome with isolated temp profile
google-chrome-stable --user-data-dir=/tmp/chrome-temp-profile --no-first-run --no-default-browser-check "$@"
EOF

sudo chmod +x /usr/local/bin/chrome
echo "✅ Created launcher command: /usr/local/bin/chrome"

# --------------------------------------------------------
# 2. Add alias for LabsKraft user (for convenience)
# --------------------------------------------------------
BASHRC_PATH="/home/LabsKraft/.bashrc"
if ! grep -q "alias chrome=" "$BASHRC_PATH"; then
  echo "alias chrome='/usr/local/bin/chrome'" >> "$BASHRC_PATH"
  echo "✅ Added alias to $BASHRC_PATH"
else
  echo "ℹ Alias already exists in $BASHRC_PATH"
fi

# --------------------------------------------------------
# 3. Update the Chrome desktop launcher (GUI fix)
# --------------------------------------------------------
DESKTOP_FILE="/usr/share/applications/google-chrome.desktop"
if [ -f "$DESKTOP_FILE" ]; then
  echo "🛠 Updating desktop entry for GUI usage..."
  sudo sed -i 's|Exec=/usr/bin/google-chrome-stable.*|Exec=/usr/bin/google-chrome-stable --user-data-dir=/tmp/chrome-temp-profile %U|' "$DESKTOP_FILE"
  echo "✅ Desktop launcher updated."
else
  echo "⚠ Could not find $DESKTOP_FILE — skipping GUI update."
fi

# --------------------------------------------------------
# 4. Final instructions
# --------------------------------------------------------
echo
echo "🎉 Setup complete for user 'LabsKraft'!"
echo "You can now open Chrome in any of these ways:"
echo "  • From terminal: chrome"
echo "  • From Applications menu: Google Chrome"
echo
echo "If 'chrome' command is not recognized immediately, run:"
echo "  source ~/.bashrc"
echo
echo "✅ Done!"