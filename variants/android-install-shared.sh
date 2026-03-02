#!/bin/bash

package_variant() {
    IN="$1"
    OUT="$2"

    mkdir -p "$OUT"/bin
    cp "$IN"/bin/ffmpeg "$OUT"/bin/
    cp "$IN"/bin/ffprobe "$OUT"/bin/

    mkdir -p "$OUT"/lib/pkgconfig
    cp -a "$IN"/lib/*.so* "$OUT"/lib/
    docker run --rm "$IMAGE" sh -c 'cat $NDK_TOOLCHAIN/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so' > "$OUT"/lib/libc++_shared.so
    cp -a "$IN"/lib/pkgconfig/*.pc "$OUT"/lib/pkgconfig/
    sed -i \
        -e 's|^prefix=.*|prefix=${pcfiledir}/../..|' \
        -e 's|/ffbuild/prefix|${prefix}|' \
        -e '/Libs.private:/d' \
        "$OUT"/lib/pkgconfig/*.pc

    mkdir -p "$OUT"/include
    cp -r "$IN"/include/* "$OUT"/include
}
