ARG GH_REPO=ghcr.io/kenshin9977/ffmpeg-builds
FROM $GH_REPO/base:latest

# Install Android NDK r27c
RUN wget -q https://dl.google.com/android/repository/android-ndk-r27c-linux.zip -O /tmp/ndk.zip && \
    unzip -q /tmp/ndk.zip -d /opt && \
    rm /tmp/ndk.zip

ENV ANDROID_NDK=/opt/android-ndk-r27c \
    ANDROID_API=24

# NDK toolchain paths
ENV NDK_TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64
ENV PATH="${NDK_TOOLCHAIN}/bin:${PATH}"

# Android Bionic libc includes pthread/rt functions directly.
# Create empty stub libraries so -lpthread/-lrt/-ldl link flags work.
RUN for lib in pthread rt dl; do \
        llvm-ar rcs ${NDK_TOOLCHAIN}/sysroot/usr/lib/aarch64-linux-android/${ANDROID_API}/lib${lib}.a; \
    done

RUN mkdir /opt/ffbuild

ENV FFBUILD_TOOLCHAIN=aarch64-linux-android${ANDROID_API} \
    FFBUILD_RUST_TARGET="aarch64-linux-android"

RUN \
    rustup target add "$FFBUILD_RUST_TARGET" && \
    printf "[target.%s]\nlinker = \"%s\"\nar = \"llvm-ar\"\n" "$FFBUILD_RUST_TARGET" "${FFBUILD_TOOLCHAIN}-clang" > "$CARGO_HOME"/config.toml

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ENV FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --arch=aarch64 --target-os=android --enable-cross-compile --enable-mediacodec --enable-jni --cc=aarch64-linux-android${ANDROID_API}-clang --cxx=aarch64-linux-android${ANDROID_API}-clang++ --strip=llvm-strip" \
    FFBUILD_CROSS_PREFIX="aarch64-linux-android-" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_DESTDIR=/opt/ffdest \
    FFBUILD_DESTPREFIX=/opt/ffdest/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    CC="aarch64-linux-android${ANDROID_API}-clang" \
    CXX="aarch64-linux-android${ANDROID_API}-clang++" \
    LD="ld.lld" \
    AR="llvm-ar" \
    RANLIB="llvm-ranlib" \
    NM="llvm-nm" \
    STRIP="llvm-strip" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe -march=armv8-a -fPIC -DPIC -fstack-protector-strong -pthread" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe -march=armv8-a -fPIC -DPIC -fstack-protector-strong -pthread" \
    LDFLAGS="-L/opt/ffbuild/lib -O2 -pipe -march=armv8-a -fstack-protector-strong -Wl,-z,relro,-z,now -pthread -lm" \
    STAGE_CFLAGS="-fvisibility=hidden" \
    STAGE_CXXFLAGS="-fvisibility=hidden"
