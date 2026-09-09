<div align="center">
<pre>
       _        &nbsp;
 _   _| |_ _ __ &nbsp;
| | | | __| '__|&nbsp;
| |_| | |_| |   &nbsp;
 \__, |\__|_|   &nbsp;
 |___/          &nbsp;
</pre>

<b>youtube radio</b>

</div>

Pick a channel with `fzf`, and its uploads play as a shuffled audio stream in `mpv`.
No video, no browser, no tab left open for six hours. Just a station and a status line.

Around 50 lines of POSIX `sh`. It reads a plain text file, pipes it through `fzf`, asks
`yt-dlp` for the video IDs, and hands the list to `mpv`. There is nothing else to it.

## Requirements

- [`fzf`](https://github.com/junegunn/fzf) — the channel picker
- [`mpv`](https://mpv.io) — playback
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) — resolving the channel to a track list

## Install

```sh
make install
```

Installs to `~/.local/bin/ytr`. Override the destination if you want it elsewhere:

```sh
make install PREFIX=/usr/local          # /usr/local/bin/ytr
make install BINDIR=/opt/bin            # /opt/bin/ytr
make install DESTDIR=/tmp/pkg           # for packaging
```

Make sure the target directory is on your `$PATH`. To remove it again:

```sh
make uninstall
```

## Configuration

On first run `ytr` writes a starter config to `$XDG_CONFIG_HOME/ytr/channels`
(`~/.config/ytr/channels` if `XDG_CONFIG_HOME` is unset) and tells you where it put it.

One station per line, three fields separated by `|`:

```
name|TAG|url
```

- **name** — what you see in the picker and in the status line
- **TAG** — a free-form label, e.g. `LOFI`, `HOUSE`, `PIANO`. It is shown next to the name and is searchable, so typing `house` in `fzf` narrows to your house stations.
- **url** — a channel URL, usually `https://www.youtube.com/@handle/videos`. A playlist URL works just as well.

Anything with fewer than three fields is skipped, so lines starting with `#` act as comments:

```
# late night
Ksu4000|BREAKCORE|https://www.youtube.com/@ksu4000/videos
Sailence|PIANO|https://www.youtube.com/@sailencemusic/videos

# working
Grind FM|HOUSE|https://www.youtube.com/@grindfmradiochannel
Lofi Girl|LOFI|https://www.youtube.com/@LofiGirl/videos
```

Names cannot contain `|`, `$` or a backtick.

## Usage

```sh
ytr
```

Pick a station, wait a moment while the channel is listed, and it starts playing in a random
order. `Esc` in the picker quits without doing anything.

Playback is ordinary `mpv`, so the usual keys apply:

| key | |
| --- | --- |
| `space` | pause / resume |
| `>` `<` | next / previous track |
| `9` `0` | volume |
| `←` `→` | seek |
| `q` | quit |

## How it works

1. `awk` turns the config into a display column plus the raw line, and `fzf` picks one.
2. `yt-dlp --flat-playlist` lists the channel's video IDs. This is the cheap listing pass, not a full extraction, so it finishes in a couple of seconds even on large channels.
3. The IDs go into a temporary file, which `mpv --shuffle --no-video` plays and the script removes on exit.

The track list is fetched once, at startup. New uploads show up the next time you run `ytr`.

## Troubleshooting

**`ytr: no tracks`** — `yt-dlp`'s own error is printed just above this line and is the useful one. Usually the URL is wrong, or `yt-dlp` is out of date. Update it first; YouTube changes things often and `yt-dlp` is the part that breaks.

**Playback stutters** — raise the cache in the `mpv` invocation, e.g. `--cache-secs=60`.

**No sound but it looks like it is playing** — check `mpv` on its own first. If `mpv` works elsewhere, `ytr` is not the problem.

## License

MIT.
