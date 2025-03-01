set -e

# DEPENDENCIES
#
# HOMEBREW
# brew install cmake meson ninja automake autoconf autoconf-archive libtool wget
#
# PYTHON
# python3 -m venv pyenv
# source pyenv/bin/activate
# pip install six pyparsing

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH

# DEPLOYMENT TARGET
export MACOSX_DEPLOYMENT_TARGET=11.3
export CFLAGS="-mmacosx-version-min=11.3"
export LDFLAGS="-mmacosx-version-min=11.3"

# PKG PATHS
OPUS_PKG="$SCRIPTPATH/opus/lib/pkgconfig"
PIXMAN_PKG="$SCRIPTPATH/pixman/lib/pkgconfig"
GLIB_PKG="$SCRIPTPATH/glib/lib/pkgconfig"
LIBSLIRP_PKG="$SCRIPTPATH/libslirp/lib/pkgconfig"

export PKG_CONFIG_PATH="$OPUS_PKG:\
$PIXMAN_PKG:\
$GLIB_PKG:\
$LIBSLIRP_PKG"

# QEMU SETTINGS

QEMU_UPSTREAM="https://download.qemu.org/qemu-9.2.2.tar.xz"

QEMU_UTM="$(curl -sL "https://api.github.com/repos/utmapp/qemu/releases/latest" | jq -r '.assets[] | select(.name | endswith(".tar.xz")) | .browser_download_url')"

QEMU_TARGETS="aarch64-softmmu,\
arm-softmmu,\
i386-softmmu,\
m68k-softmmu,\
ppc-softmmu,\
ppc64-softmmu,\
riscv32-softmmu,\
riscv64-softmmu,\
x86_64-softmmu,\
mips-softmmu,\
mips64-softmmu,\
mipsel-softmmu,\
mips64el-softmmu,\
sparc-softmmu,\
sparc64-softmmu"

# PCRE2
if [ ! -d "pcre2" ]; then

    if [ ! -d "pcre2-src" ]; then
        git clone https://github.com/PhilipHazel/pcre2.git pcre2-src
    fi

    cd pcre2-src && mkdir build
    
    cd build && cmake .. \
         -DCMAKE_INSTALL_PREFIX="$SCRIPTPATH/pcre2" \
         -DCMAKE_BUILD_TYPE=Release \
         -DBUILD_SHARED_LIBS=OFF \
         -DPCRE2_BUILD_PCRE2_8=ON \
         -DPCRE2_BUILD_PCRE2_16=OFF \
         -DPCRE2_BUILD_PCRE2_32=OFF
    
    mkdir "$SCRIPTPATH/pcre2"
    
    make && make install && make clean && cd ../..
fi

rm -fr pcre2-src

# GLIB
if [ ! -d "glib" ]; then

    if [ ! -d "glib-src" ]; then
        git clone https://gitlab.gnome.org/GNOME/glib.git glib-src
    fi

    cd glib-src
    
    meson setup build \
        --default-library=static \
        --prefix="$SCRIPTPATH/glib" \
        -Dglib_debug=disabled \
        -Dsystemtap=disabled \
        -Dlibmount=disabled \
        -Dc_args="-I$SCRIPTPATH/pcre2/include" \
        -Dcpp_args="-I$SCRIPTPATH/pcre2/include" \
        -Dcpp_link_args="-L$SCRIPTPATH/pcre2/lib -lpcre2-8"
    
    mkdir "$SCRIPTPATH/glib"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr glib-src

# ZLIB
if [ ! -d "zlib" ]; then

    if [ ! -d "zlib-src" ]; then
        git clone https://github.com/madler/zlib.git zlib-src
    fi
    
    cd zlib-src
    
    ./configure \
      --static \
      --prefix="$SCRIPTPATH/zlib"
    
    mkdir "$SCRIPTPATH/zlib"
    
    make && make install && make clean && cd ..
fi

rm -fr zlib-src

# PIXMAN
if [ ! -d "pixman" ]; then

    if [ ! -d "pixman-src" ]; then
        git clone https://gitlab.freedesktop.org/pixman/pixman.git pixman-src
    fi
    
    cd pixman-src
    
    meson setup build \
        --prefix="$SCRIPTPATH/pixman" \
        --default-library=static
    
    mkdir "$SCRIPTPATH/pixman"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr pixman-src

# OPUS
if [ ! -d "opus" ]; then

    if [ ! -d "opus-src" ]; then
        git clone https://github.com/xiph/opus.git opus-src
    fi
    
    cd opus-src && ./autogen.sh
    
    ./configure --prefix="$SCRIPTPATH/opus" \
        --enable-static \
        --disable-shared

    mkdir "$SCRIPTPATH/opus"

    make -j$(sysctl -n hw.logicalcpu) && make install && cd ..
fi

rm -fr opus-src

# LIBSLIRP
if [ ! -d "libslirp" ]; then

    if [ ! -d "libslirp-src" ]; then
        git clone https://gitlab.freedesktop.org/slirp/libslirp.git libslirp-src
    fi

    cd libslirp-src
    
    meson setup build \
        --default-library=static \
        --prefix="$SCRIPTPATH/libslirp"
    
    mkdir "$SCRIPTPATH/libslirp"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr libslirp-src

# QEMU
if [ ! -d "QEMU" ]; then

    if [ ! -d "qemu-src" ]; then
        wget "$QEMU_UPSTREAM" -O qemu-src.tar.xz
        tar xvJf qemu-src.tar.xz && rm qemu-src.tar.xz
        mv qemu* qemu-src
    fi

    cd qemu-src
    
    ./configure \
        --prefix="$SCRIPTPATH/QEMU" \
        --datadir="./share" \
        --target-list="$QEMU_TARGETS" \
        --enable-hvf \
        --enable-coreaudio \
        --enable-cocoa \
        --enable-slirp \
        --enable-lto \
        --disable-sdl \
        --disable-spice \
        --disable-vnc \
        --disable-debug-info \
        --disable-strip \
        --extra-cflags="-I$SCRIPTPATH/pixman/include \
                        -I$SCRIPTPATH/opus/include \
                        -I$SCRIPTPATH/glib/include \
                        -I$SCRIPTPATH/libslirp/include" \
        --extra-ldflags="-L$SCRIPTPATH/pixman/lib \
                         -L$SCRIPTPATH/opus/lib \
                         -L$SCRIPTPATH/glib/lib \
                         -L$SCRIPTPATH/libslirp/lib \
                         -Bstatic -lglib-2.0 -lpixman-1 -lopus -lslirp \
                         -lc++ -lc++abi \
                         -Bdynamic -lc -lSystem"

    mkdir "$SCRIPTPATH/QEMU"

    make -j$(sysctl -n hw.logicalcpu) && make install && cd ..
fi

rm -fr qemu-src
