#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

die(){ echo "ERROR: $*"; exit 1; }

echo "=== Minecraft 1.21.1 Termux Installer (robust) ==="

# 0) Ensure repo is in Termux home
if [[ "$PWD" != "$HOME"* ]]; then
  echo "Detected repo outside Termux home (likely /sdcard or ~/storage)."
  echo "Copying repo into Termux home..."
  TARGET_DIR="$HOME/minecraft-termux"
  mkdir -p "$TARGET_DIR"
  cp -r . "$TARGET_DIR"
  cd "$TARGET_DIR"
  echo "Moved to: $PWD"
fi

# 1) Update + deps
echo "[1/6] Updating packages..."
pkg update -y && pkg upgrade -y
echo "[2/6] Installing dependencies..."
pkg install openjdk-17 wget curl git -y

# 2) Create folders
mkdir -p server worlds playit

# 3) Download server jar
SERVER_JAR_URL="https://piston-data.mojang.com/v1/objects/45810d238246d90e811d896f87b14695b7fb6839/server.jar"
if [ ! -f server/server.jar ]; then
  echo "[4/6] Downloading Minecraft 1.21.1 server jar..."
  curl -L -o server/server.jar "$SERVER_JAR_URL" || wget -O server/server.jar "$SERVER_JAR_URL"
else
  echo "server/server.jar already exists — skipping download."
fi

# 4) EULA
echo "eula=true" > server/eula.txt

# 5) Download Playit agent
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) PLAYIT_ASSET="playit-linux-arm64" ;;
  armv7l|arm)    PLAYIT_ASSET="playit-linux-armv7" ;;
  x86_64)        PLAYIT_ASSET="playit-linux-x86_64" ;;
  *)             PLAYIT_ASSET="playit-linux-arm64" ;;
esac
PLAYIT_BIN="$HOME/minecraft-termux/playit"
PLAYIT_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/${PLAYIT_ASSET}"

echo "Detected arch: $ARCH -> will try asset: $PLAYIT_ASSET"
if [ ! -f "$PLAYIT_BIN" ]; then
  echo "Downloading $PLAYIT_URL ..."
  curl -L -o "$PLAYIT_BIN" "$PLAYIT_URL" || wget -O "$PLAYIT_BIN" "$PLAYIT_URL"
fi

chmod +x "$PLAYIT_BIN"

# Test execution
if ! "$PLAYIT_BIN" --version >/dev/null 2>&1; then
  die "Playit binary cannot be executed. Ensure repo is in Termux home."
fi

# 6) Start Playit for claim token
LOG="$HOME/minecraft-termux/playit/playit.log"
rm -f "$LOG"
nohup "$PLAYIT_BIN" > "$LOG" 2>&1 &
PLAYIT_PID=$!

echo "playit started (pid: $PLAYIT_PID). Waiting for claim URL..."
CLAIM_URL=""
for i in $(seq 1 180); do
  if grep -qE "https://playit\.gg/claim/" "$LOG" 2>/dev/null; then
    CLAIM_URL=$(grep -oE "https://playit\.gg/claim/[A-Za-z0-9_-]+" "$LOG" | head -n1)
    break
  fi
  sleep 1
done

if [ -z "$CLAIM_URL" ]; then
  die "Failed to retrieve claim URL. Check $LOG"
fi

echo "=== Claim URL ==="
echo "$CLAIM_URL"
if command -v termux-open >/dev/null 2>&1; then
  termux-open "$CLAIM_URL" || echo "termux-open failed; open manually."
else
  echo "Open the above URL manually."
fi

read -p $'\nPress ENTER after claiming the agent...'

echo "Installation complete. Run './start.sh' to start the server."
