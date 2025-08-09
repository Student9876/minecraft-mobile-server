#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# -------------------------
# Installer: Minecraft 1.21.1 + Playit agent
# place this in your repo and run from Termux
# -------------------------

# Helper
die(){ echo "ERROR: $*"; exit 1; }

echo "=== Minecraft 1.21.1 Termux Installer (robust) ==="

# 0) Ensure running inside Termux home (not /sdcard)
if [[ "$PWD" != "$HOME"* ]]; then
  echo "It looks like you're running from outside Termux home:"
  echo "  Current dir: $PWD"
  echo "Termux will not allow executables on /sdcard (noexec)."
  echo "Please move the repo to Termux home and run again:"
  echo "  mv \"$PWD\" \"$HOME/minecraft-termux\" && cd \"$HOME/minecraft-termux\" && bash install.sh"
  die "Repository must be inside $HOME to execute downloaded binaries."
fi

# 1) Update + deps
echo "[1/6] Updating packages..."
pkg update -y && pkg upgrade -y

echo "[2/6] Installing dependencies (openjdk-17, wget, curl)..."
pkg install openjdk-17 wget curl git -y

# 2) Create folders
echo "[3/6] Creating folder structure..."
mkdir -p server worlds playit

# 3) Download server jar (locked to 1.21.1)
SERVER_JAR_URL="https://piston-data.mojang.com/v1/objects/45810d238246d90e811d896f87b14695b7fb6839/server.jar"
if [ ! -f server/server.jar ]; then
  echo "[4/6] Downloading Minecraft 1.21.1 server jar..."
  curl -L -o server/server.jar "$SERVER_JAR_URL" || wget -O server/server.jar "$SERVER_JAR_URL"
else
  echo "[4/6] server/server.jar already exists — skipping download."
fi

# 4) EULA
echo "[5/6] Writing eula.txt..."
echo "eula=true" > server/eula.txt

# 5) Download playit agent (detect arch)
echo "[6/6] Downloading Playit agent for your architecture..."
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) PLAYIT_ASSET="playit-linux-arm64" ;;
  armv7l|arm)    PLAYIT_ASSET="playit-linux-armv7" ;;
  x86_64)        PLAYIT_ASSET="playit-linux-x86_64" ;;
  *)             PLAYIT_ASSET="playit-linux-arm64" ;;
esac

PLAYIT_BIN="playit/playit"
PLAYIT_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/${PLAYIT_ASSET}"

echo "Detected arch: $ARCH  -> will try asset: $PLAYIT_ASSET"
if [ ! -f "$PLAYIT_BIN" ]; then
  echo "Downloading $PLAYIT_URL ..."
  # prefer curl, fallback to wget
  if command -v curl >/dev/null 2>&1; then
    curl -L -o "$PLAYIT_BIN" "$PLAYIT_URL" || true
  fi
  if [ ! -s "$PLAYIT_BIN" ]; then
    echo "curl download failed or empty; trying wget..."
    wget -O "$PLAYIT_BIN" "$PLAYIT_URL" || true
  fi
  if [ ! -s "$PLAYIT_BIN" ]; then
    echo "Could not download the Playit binary automatically."
    echo "Visit: https://github.com/playit-cloud/playit-agent/releases and manually download the correct linux binary for $ARCH"
    die "Playit download failed."
  fi
fi

# Ensure executable
chmod +x "$PLAYIT_BIN" || true

# Quick runtime test (permission / noexec detection)
echo "Checking if playit binary can be executed..."
if ! "$PLAYIT_BIN" --version >/dev/null 2>&1 && ! "$PLAYIT_BIN" --help >/dev/null 2>&1; then
  # If the file exists but is not executable, explain likely cause
  if [ ! -x "$PLAYIT_BIN" ]; then
    echo "playit binary is not marked executable. Applied chmod +x, but still not executable."
  fi
  echo ""
  echo "Common cause: repo is on a noexec filesystem (e.g. /sdcard)."
  echo "Please move the repo to Termux home and re-run:"
  echo "  mv \"$PWD\" \"$HOME/minecraft-termux\" && cd \"$HOME/minecraft-termux\" && bash install.sh"
  die "Cannot run playit binary from this location."
fi

# 6) Start Playit in background and capture claim URL
echo ""
echo "Starting playit agent (background). Will display the claim URL here when available..."
LOG="playit/playit.log"
rm -f "$LOG"
# start agent (nohup so it survives ctrl-c of parent shell; we will still manage it)
nohup "$PLAYIT_BIN" > "$LOG" 2>&1 & 
PLAYIT_PID=$!

echo "playit started (pid: $PLAYIT_PID). Waiting for claim URL in $LOG..."

# Wait up to 180s for claim URL
CLAIM_URL=""
for i in $(seq 1 180); do
  if grep -qE "https://playit\.gg/claim/" "$LOG" 2>/dev/null; then
    CLAIM_URL=$(grep -oE "https://playit\.gg/claim/[A-Za-z0-9_-]+" "$LOG" | head -n1)
    break
  fi
  sleep 1
done

if [ -z "$CLAIM_URL" ]; then
  echo "Could not find a claim URL in $LOG after waiting. Show $LOG to debug."
  echo "You can also run: tail -f $LOG"
  echo "If playit printed nothing, try running ./playit in foreground to see output."
  die "Failed to retrieve claim URL."
fi

echo ""
echo "=== Claim URL ==="
echo "$CLAIM_URL"
echo "Opening it in your phone's browser (if termux-open available)..."
if command -v termux-open >/dev/null 2>&1; then
  termux-open "$CLAIM_URL" || echo "termux-open failed; open the URL manually."
else
  echo "termux-open not installed — open the URL manually in your browser."
fi

read -p $'\nPress ENTER after you have claimed the agent in the browser (or if you already claimed it).'

echo "Continuing... playit agent is still running in background. You can check $LOG for status."

echo ""
echo "Installation and playit claim step complete."
echo "You can now run './start.sh' to choose/load a world and start the Minecraft server (playit agent will keep forwarding)."
echo ""
echo "If you prefer install.sh to start the server automatically, run: bash start.sh"
