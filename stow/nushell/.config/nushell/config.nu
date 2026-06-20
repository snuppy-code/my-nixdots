$env.config.show_banner = false

# copy path to target or working dir
def pc [path?: string] {
  let p = if ($path == null) { $env.PWD } else { $path | path expand }
  $p | wl-copy --trim-newline
  print $"Copied: ($p)"
}

# copy whole target file to clipboard, meant for text files
# written by ai, but I first implemented this myself so I would be able to look over this AI version
def fc [path: string] {
  let p = ($path | path expand)
  if ($p | path type) == "dir" {
    error make {msg: $"(ansi red_bold)error:(ansi reset) ($p) is a directory — did you mean `pc`?"}
  }
  let ftype = (^file -b $p)
  if not ($ftype | str contains "text") {
    print $"(ansi yellow_bold)warning:(ansi reset) file appears to be binary \(($ftype)\) — copying anyway"
  }
  let fsize = (ls $p | get size | first)
  if $fsize > 1mb {
    print $"(ansi yellow_bold)warning:(ansi reset) large file ($fsize) — copying anyway"
  }
  open --raw $p | wl-copy
  print $"Copied contents of ($p)"
}

# write clipboard contents to target
def fp [name: string] {
  wl-paste | save $name
  print $"Wrote clipboard contents to: ($name)"
}

# add, commit, push to both remotes
def pg [msg: string] {
  git add .
  git commit -m $msg
  git push origin main
  git push local-server main
}

# Straight AI slop
# Overwrites an Obsidian vault with a .tar.gz backup
def restore-vault [
    backup_file: path,  # Path to the .tar.gz backup
    vault_dir: path     # Path to the Obsidian vault to overwrite
] {
    let b = ($backup_file | path expand)
    let v = ($vault_dir | path expand)

    # 1. Safety check: Does the backup exist?
    if not ($b | path exists) {
        error make { msg: $"Backup file not found: ($b)" }
    }

    print $"[1/4] Preparing to restore from ($b)..."

    # 2. Halt Syncthing to prevent sync chaos
    print $"[2/4] Suspending Syncthing..."
    systemctl --user stop syncthing.service

    # 3. Wipe the existing vault
    if ($v | path exists) {
        print $"[3/4] Deleting current vault at ($v)..."
        rm -rf $v
    } else {
        print $"[3/4] No existing vault found at ($v), creating new one..."
    }

    # 4. Recreate the directory and extract
    print $"[4/4] Extracting archive..."
    mkdir $v
    ^tar -xzf $b -C $v

    # 5. Wake Syncthing back up
    print $"Waking Syncthing back up..."
    systemctl --user start syncthing.service

    print $"Done! Vault successfully restored. 🚀"
}

# ------------
          #-- the following is straight AI slop: -----------------
          # 1. Trim a recording and prep for Discord (End time is optional)
          # Usage: prep-discord-trim "recording.mkv" "00:00:15" "00:01:30"
          #    OR: prep-discord-trim "recording.mkv" "00:00:15"
          #    OR: prep-discord-trim "recording.mkv" "00:00:15" --quality high
          # Quality presets: low (720p, crf 28 — tiny), med (1080p, crf 23),
          #                  high (1440p, crf 20 — near-lossless, big file)
          def "prep-discord-trim" [
              input: string,
              start: string,
              end?: string # The '?' makes this parameter optional
              --quality (-q): string = "low" # low | med | high
          ] {
              let preset = match $quality {
                  "low"  => { vf: "scale=-1:720,fps=30",  crf: "28", ab: "128k" }
                  "med"  => { vf: "scale=-1:1080,fps=30", crf: "23", ab: "160k" }
                  "high" => { vf: "scale=-1:1440,fps=30", crf: "20", ab: "192k" }
                  _ => {
                      error make { msg: $"unknown quality '($quality)': use low, med, or high" }
                  }
              }
              let file_info = ($input | path parse)
              let out = $"($file_info.stem)_discord.mp4"

              if ($end == null) {
                  print $"✂️ Trimming '($input)' from ($start) to the end... [quality: ($quality)]"
                  ^ffmpeg -y -ss $start -i $input -vf $preset.vf -c:v libx264 -crf $preset.crf -preset faster -c:a aac -b:a $preset.ab $out
              } else {
                  print $"✂️ Trimming '($input)' from ($start) to ($end)... [quality: ($quality)]"
                  ^ffmpeg -y -ss $start -to $end -i $input -vf $preset.vf -c:v libx264 -crf $preset.crf -preset faster -c:a aac -b:a $preset.ab $out
              }

              print $"✅ Done! Saved for Discord as: ($out)"
          }


          # 2. Prep a full recording for DaVinci Resolve Free
          # Usage: prep-resolve "recording.mkv"
          def "prep-resolve" [
              input: string
          ] {
              let file_info = ($input | path parse)
              let out = $"($file_info.stem)_editable.mov"

              print $"🎬 Converting '($input)' to DNxHR HQ for Resolve..."

              # Fixed the codec flag and added -y to overwrite existing files
              ^ffmpeg -y -i $input -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le $out

              print $"✅ Done! Ready to edit: ($out)"
          }


          # 3. Take DaVinci Resolve output and prep for Discord
          # Usage: prep-discord "resolve_export.mov"
          def "prep-discord" [
              input: string
          ] {
              let file_info = ($input | path parse)
              let out = $"($file_info.stem)_discord.mp4"

              print $"📦 Crushing '($input)' down for Discord..."

              # Strips HDR metadata by re-tagging as bt709 — avoids broken tonemapping that produces
              # black frames. HLG is backward-compatible enough that SDR players show an acceptable
              # picture. yuv420p + Main profile = universal phone decoder support.
              ^ffmpeg -y -i $input -vf "scale=-2:720,fps=30" -c:v libx264 -profile:v main -level 4.0 -pix_fmt yuv420p -color_primaries bt709 -color_trc bt709 -colorspace bt709 -crf 28 -preset faster -c:a aac -b:a 128k -movflags +faststart $out

              print $"✅ Done! Saved for Discord as: ($out)"
          }
                       # ------------------------------------
