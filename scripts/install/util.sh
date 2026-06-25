cp ../util/.inputrc ~/.inputrc

# Update .bash_aliases with the latest dev-env-wsl aliases.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIASES_BLOCK_FILE="$SCRIPT_DIR/../util/bash_aliases.txt"
BASH_ALIASES_FILE="$HOME/.bash_aliases"

if [ -f "$BASH_ALIASES_FILE" ]; then
	# Remove any existing dev-env-wsl block before adding the latest version.
	awk '
		/^# START: dev-env-wsl$/ { skip = 1; next }
		/^# END: dev-env-wsl$/ { skip = 0; next }
		!skip { print }
	' "$BASH_ALIASES_FILE" > "$BASH_ALIASES_FILE.tmp"
	mv "$BASH_ALIASES_FILE.tmp" "$BASH_ALIASES_FILE"

	# Trim only surrounding blank lines before appending.
	awk '
		{
			lines[NR] = $0
			if ($0 ~ /[^[:space:]]/) {
				last_non_empty = NR
			}
		}
		END {
			if (!last_non_empty) {
				exit
			}
			for (i = 1; i <= last_non_empty; i++) {
				if (!started && lines[i] ~ /[^[:space:]]/) {
					started = 1
				}
				if (started) {
					print lines[i]
				}
			}
		}
	' "$BASH_ALIASES_FILE" > "$BASH_ALIASES_FILE.tmp"
	mv "$BASH_ALIASES_FILE.tmp" "$BASH_ALIASES_FILE"
fi

if [ -s "$BASH_ALIASES_FILE" ]; then
	printf "\n\n" >> "$BASH_ALIASES_FILE"
fi

cat "$ALIASES_BLOCK_FILE" >> "$BASH_ALIASES_FILE"


# Apply updates
source ~/.bashrc
