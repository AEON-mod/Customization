#!/bin/bash
# transcode-wallpapers.sh — Batch-optimise wallpaper videos for mpvpaper.
# Downscales to 1080p @ 30fps using NVENC (GPU). Converts GIFs to MP4.
# Run once per video — already-processed files are skipped automatically.
# Originals saved to live-wallpaper/original/ with .original suffix.

FFMPEG=/usr/bin/ffmpeg
FFPROBE=/usr/bin/ffprobe
DIR="${1:-$HOME/Pictures/Wallpapers/live-wallpaper}"
ORIG_DIR="$DIR/original"
SCREEN_W=1920
SCREEN_H=1080
TARGET_FPS=30

mkdir -p "$ORIG_DIR"

echo "=== Wallpaper Transcoder ==="
echo "Target : ${SCREEN_W}x${SCREEN_H} @ ${TARGET_FPS}fps"
echo "Dir    : $DIR"
echo "Originals → $ORIG_DIR"
echo ""

total_video=0; skipped_video=0; transcoded_video=0; errors_video=0
total_gif=0;   skipped_gif=0;   converted_gif=0;   errors_gif=0

# ── GIF → MP4 ────────────────────────────────────────────────────────────────
echo "--- GIF Conversion ---"
for f in "$DIR"/*.gif; do
    [ -f "$f" ] || continue
    total_gif=$((total_gif + 1))

    base="${f%.gif}"
    fname="$(basename "$f")"
    mp4_out="${base}.mp4"

    if [ -f "$mp4_out" ] && [ "$mp4_out" -nt "$f" ]; then
        echo "  ✓ SKIP (MP4 exists): $fname"
        skipped_gif=$((skipped_gif + 1))
        continue
    fi

    orig_gif="$ORIG_DIR/${fname%.gif}.original.gif"
    if [ -f "$orig_gif" ]; then
        echo "  ✓ SKIP (already converted): $fname"
        skipped_gif=$((skipped_gif + 1))
        continue
    fi

    echo ""
    echo "  🎞  CONVERT GIF: $fname"

    tmp_out="${base}.tmp_gif.mp4"
    palette_tmp="${base}.tmp_palette.png"
    success=0

    if "$FFMPEG" -y -i "$f" \
        -vf "palettegen=max_colors=256:stats_mode=diff" \
        "$palette_tmp" 2>/dev/null; then

        if "$FFMPEG" -y -i "$f" -i "$palette_tmp" \
            -lavfi "paletteuse=dither=bayer:bayer_scale=5" \
            -c:v libx264 -preset fast -crf 15 \
            -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
            -movflags +faststart -an \
            "$tmp_out" 2>/dev/null && [ -s "$tmp_out" ]; then
            success=1
        fi
        rm -f "$palette_tmp"
    fi

    if [ "$success" -eq 0 ]; then
        rm -f "$tmp_out" "$palette_tmp"
        if "$FFMPEG" -y -i "$f" \
            -c:v libx264 -preset fast -crf 15 \
            -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
            -movflags +faststart -an \
            "$tmp_out" 2>/dev/null && [ -s "$tmp_out" ]; then
            success=1
        fi
    fi

    if [ "$success" -eq 1 ]; then
        mv "$tmp_out" "$mp4_out"
        orig_dest="$ORIG_DIR/${fname%.gif}.original.gif"
        mv "$f" "$orig_dest"
        old_size=$(du -sh "$orig_dest" | cut -f1)
        new_size=$(du -sh "$mp4_out" | cut -f1)
        echo "     ✅ $old_size → $new_size  (original → original/${fname%.gif}.original.gif)"
        converted_gif=$((converted_gif + 1))
    else
        rm -f "$tmp_out" "$palette_tmp"
        echo "     ❌ GIF conversion failed: $fname"
        errors_gif=$((errors_gif + 1))
    fi
done

echo ""

# ── Video transcoding ─────────────────────────────────────────────────────────
echo "--- Video Transcoding ---"
for f in "$DIR"/*.mp4 "$DIR"/*.webm "$DIR"/*.mkv; do
    [ -f "$f" ] || continue
    [[ "$(dirname "$f")" == "$ORIG_DIR" ]] && continue

    fname="$(basename "$f")"
    base_noext="${fname%.*}"
    ext="${fname##*.}"

    [ -f "$ORIG_DIR/${base_noext}.original.gif" ] && continue

    orig_saved="$ORIG_DIR/${base_noext}.original.${ext}"
    if [ -f "$orig_saved" ]; then
        echo "  ✓ SKIP (already transcoded): $fname"
        skipped_video=$((skipped_video + 1))
        continue
    fi

    total_video=$((total_video + 1))

    read -r width height fps_str < <("$FFPROBE" -v quiet -select_streams v:0 \
        -show_entries stream=width,height,avg_frame_rate \
        -of csv=p=0 "$f" 2>/dev/null | tr ',' ' ' | head -1)

    if [ -z "$width" ] || [ "$width" = "0" ]; then
        echo "  ⚠ SKIP (can't read): $fname"
        skipped_video=$((skipped_video + 1))
        continue
    fi

    fps=0
    if [[ "$fps_str" =~ ^([0-9]+)/([0-9]+)$ ]]; then
        fps=$(( ${BASH_REMATCH[1]} / ${BASH_REMATCH[2]} ))
    elif [[ "$fps_str" =~ ^[0-9]+$ ]]; then
        fps=$fps_str
    fi

    needs_resize=0
    needs_fps_cap=0
    [ "$width" -gt "$SCREEN_W" ] || [ "$height" -gt "$SCREEN_H" ] && needs_resize=1
    [ "$fps" -gt "$TARGET_FPS" ] && needs_fps_cap=1

    if [ "$needs_resize" -eq 0 ] && [ "$needs_fps_cap" -eq 0 ]; then
        echo "  ✓ OK  (${width}x${height} @ ${fps}fps): $fname"
        skipped_video=$((skipped_video + 1))
        continue
    fi

    new_w=$width; new_h=$height
    if [ "$new_w" -gt "$SCREEN_W" ]; then
        new_h=$(( height * SCREEN_W / width ))
        new_h=$(( (new_h + 1) / 2 * 2 ))
        new_w=$SCREEN_W
    fi
    if [ "$new_h" -gt "$SCREEN_H" ]; then
        new_w=$(( width * SCREEN_H / height ))
        new_w=$(( (new_w + 1) / 2 * 2 ))
        new_h=$SCREEN_H
    fi

    reason=""
    [ "$needs_resize" -eq 1 ] && reason="${reason}resize "
    [ "$needs_fps_cap" -eq 1 ] && reason="${reason}fps-cap"

    echo ""
    echo "  🔄 TRANSCODE (${reason// /,}): $fname"
    echo "     ${width}x${height}@${fps}fps → ${new_w}x${new_h}@${TARGET_FPS}fps"

    out="${f%.*}.tmp_transcode.mp4"
    success=0

    # Path A: Full GPU pipeline (CUDA decode + NVENC encode)
    if "$FFMPEG" -y \
        -hwaccel cuda -hwaccel_output_format cuda \
        -i "$f" \
        -vf "scale_cuda=${new_w}:${new_h}:format=yuv420p" \
        -r $TARGET_FPS \
        -c:v h264_nvenc -preset p4 -cq 20 -b:v 0 \
        -an -movflags +faststart \
        "$out" 2>/dev/null && [ -s "$out" ]; then
        success=1
        echo "     (GPU: CUDA decode + NVENC encode)"
    fi

    # Path B: CPU decode + NVENC encode
    if [ "$success" -eq 0 ]; then
        rm -f "$out"
        if "$FFMPEG" -y \
            -i "$f" \
            -vf "scale=${new_w}:${new_h}:flags=lanczos" \
            -r $TARGET_FPS \
            -c:v h264_nvenc -preset p4 -cq 20 -b:v 0 \
            -an -movflags +faststart \
            "$out" 2>/dev/null && [ -s "$out" ]; then
            success=1
            echo "     (CPU decode + NVENC encode)"
        fi
    fi

    # Path C: Pure software fallback
    if [ "$success" -eq 0 ]; then
        rm -f "$out"
        if "$FFMPEG" -y \
            -i "$f" \
            -vf "scale=${new_w}:${new_h}:flags=lanczos" \
            -r $TARGET_FPS \
            -c:v libx264 -preset medium -crf 20 \
            -an -movflags +faststart \
            "$out" 2>/dev/null && [ -s "$out" ]; then
            success=1
            echo "     (software: libx264)"
        fi
    fi

    if [ "$success" -eq 1 ]; then
        orig_dest="$ORIG_DIR/${base_noext}.original.${ext}"
        mv "$f" "$orig_dest"
        mv "$out" "$f"
        old_size=$(du -sh "$orig_dest" | cut -f1)
        new_size=$(du -sh "$f" | cut -f1)
        echo "     ✅ $old_size → $new_size  (original → original/${base_noext}.original.${ext})"
        transcoded_video=$((transcoded_video + 1))
    else
        echo "     ❌ All paths failed, keeping original"
        rm -f "$out"
        errors_video=$((errors_video + 1))
    fi
done

echo ""
echo "=== Summary ==="
echo "  Videos : $total_video total | $transcoded_video transcoded | $skipped_video skipped | $errors_video errors"
echo "  GIFs   : $total_gif total   | $converted_gif converted    | $skipped_gif skipped   | $errors_gif errors"
echo ""
if [ "$transcoded_video" -gt 0 ] || [ "$converted_gif" -gt 0 ]; then
    echo "Originals saved in: $ORIG_DIR"
    echo "Remove when satisfied:  rm -rf \"$ORIG_DIR\""
fi
