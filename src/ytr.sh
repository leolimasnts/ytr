#!/bin/sh
# config: one "name|tag|url" per line; short lines are ignored, so # comments work.

config="${XDG_CONFIG_HOME:-$HOME/.config}/ytr/channels"

for c in fzf mpv yt-dlp; do
  command -v "$c" >/dev/null || {
    echo "ytr: need $c" >&2
    exit 1
  }
done

if [ ! -f "$config" ]; then
  mkdir -p "${config%/*}" || exit 1
  cat >"$config" <<'EOF'
Grind FM|HOUSE|https://www.youtube.com/@grindfmradiochannel
Ksu4000|BREAKCORE|https://www.youtube.com/@ksu4000/videos
Lofi Girl|LOFI|https://www.youtube.com/@LofiGirl/videos
Productivity FM|HOUSE|https://www.youtube.com/@productivityonyt/videos
Pure Grit Studio|HOUSE|https://www.youtube.com/@PureGritStudio/videos
Sailence|PIANO|https://www.youtube.com/@sailencemusic/videos
livinobody|LOFI|https://www.youtube.com/@livinobody/videos
EOF
  echo "ytr: created $config" >&2
fi

line=$(awk -F'|' 'NF>=3 { printf "%-22s \033[36m[%s]\033[0m\t%s\n", $1, $2, $0 }' "$config" |
  fzf --ansi --prompt='radio> ' --delimiter='\t' --with-nth=1 |
  cut -f2)
[ -n "$line" ] || exit 0

IFS='|' read -r name tag url <<EOF
$line
EOF

playlist=$(mktemp) || exit 1
trap 'rm -f "$playlist"' EXIT INT TERM HUP

echo "ytr: fetching $name..." >&2
yt-dlp --flat-playlist --print 'https://youtube.com/watch?v=%(id)s' "$url" >"$playlist" || exit 1
[ -s "$playlist" ] || {
  echo "ytr: no tracks" >&2
  exit 1
}

hl=$(printf '\033[1;36m')
rst=$(printf '\033[0m')
bold=$(printf '\033[1m')

clear
printf '%s' "$bold"
cat <<'EOF'
           _
     _   _| |_ _ __
    | | | | __| '__|
    | |_| | |_| |
     \__, |\__|_|
     |___/
EOF
printf '%s' "$rst"

mpv \
  --no-video \
  --shuffle \
  --cache=yes \
  --ytdl-format='bestaudio/best' \
  --msg-level=all=error,statusline=status \
  --term-osd=force \
  --term-osd-bar=yes \
  --term-status-msg="\n    You are listening to ${hl}\${media-title}${rst} from ${hl}$name${rst}\n\n    \${time-pos} / \${duration}" \
  --playlist="$playlist"
