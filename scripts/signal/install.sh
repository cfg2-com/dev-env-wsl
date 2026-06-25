USERNAME=$(whoami)

read -rp "Enter your Signal phone number in E.164 format (ex: +14142224455): " PHONE_NUMBER

mkdir -p ~/signal-cli && cd ~/signal-cli

# Get the latest version of signal-cli from GitHub
VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/AsamK/signal-cli/releases/latest | sed -e 's/^.*\/v//')

# Download the signal-cli tarball for the latest version
curl -L -O https://github.com/AsamK/signal-cli/releases/download/v"${VERSION}"/signal-cli-"${VERSION}".tar.gz

# Extract the tarball to /opt
sudo tar xf signal-cli-"${VERSION}".tar.gz -C /opt

# Create a symbolic link to the signal-cli binary in /usr/local/bin
sudo ln -sf /opt/signal-cli-"${VERSION}"/bin/signal-cli /usr/local/bin/

# Remove old versioned signal-cli directories from /opt
find /opt -maxdepth 1 -name 'signal-cli-*' ! -name "signal-cli-${VERSION}" -exec sudo rm -rf {} +

# Link device if not already registered
if ! signal-cli listDevices &>/dev/null 2>&1; then
    signal-cli link -n "Signal CLI" | xargs -L 1 qrencode -t ansi

    signal-cli -u "$PHONE_NUMBER" receive
fi

# Write systemd service file
sudo tee /etc/systemd/system/signal-cli.service > /dev/null << EOF
[Unit]
Description=Signal-CLI HTTP Daemon
After=network.target

[Service]
Type=simple
User=$USERNAME
ExecStart=/usr/local/bin/signal-cli --account $PHONE_NUMBER daemon --http 127.0.0.1:8080
Restart=always
RestartSec=5
Environment=HOME=$HOME

[Install]
WantedBy=multi-user.target
EOF

# Reload the user daemon configuration 
sudo systemctl daemon-reload 

# Enable it to start on login 
sudo systemctl enable signal-cli.service 

# Start it immediately 
sudo systemctl start signal-cli.service 

# Verify running
sudo systemctl status signal-cli.service 

# Check logs
journalctl -u signal-cli.service
