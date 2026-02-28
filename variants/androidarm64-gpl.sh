#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/defaults-gpl.sh

package_variant() {
    IN="$1"
    OUT="$2"
    mkdir -p "$OUT"/bin
    cp "$IN"/bin/ffmpeg "$OUT"/bin/
    cp "$IN"/bin/ffprobe "$OUT"/bin/
}
