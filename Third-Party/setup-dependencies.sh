set -e

# DEPENDENCIES
#
# HOMEBREW
# brew install cmake meson ninja automake autoconf autoconf-archive libtool wget

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH

# DEPLOYMENT TARGET
export MACOSX_DEPLOYMENT_TARGET=12.0
export CFLAGS="-mmacosx-version-min=12.0"
export LDFLAGS="-mmacosx-version-min=12.0"

# PKG PATHS
PCRE2_PKG="$SCRIPTPATH/pcre2/lib/pkgconfig"
PIXMAN_PKG="$SCRIPTPATH/pixman/lib/pkgconfig"
GLIB_PKG="$SCRIPTPATH/glib/lib/pkgconfig"
LIBSLIRP_PKG="$SCRIPTPATH/libslirp/lib/pkgconfig"

export PKG_CONFIG_PATH="$PCRE2_PKG:\
$PIXMAN_PKG:\
$GLIB_PKG:\
$LIBSLIRP_PKG"

# QEMU SETTINGS

QEMU_UPSTREAM="https://download.qemu.org/qemu-9.2.2.tar.xz"

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
        -Dlibmount=disabled
    
    mkdir "$SCRIPTPATH/glib"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr glib-src

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
        --enable-tcg \
        --enable-hvf \
        --enable-coreaudio \
        --enable-cocoa \
        --enable-lto \
        --enable-slirp \
        --enable-vnc \
        --disable-vmnet \
        --disable-sdl \
        --disable-spice \
        --disable-debug-info \
        --disable-strip

    mkdir "$SCRIPTPATH/QEMU"

    make -j$(sysctl -n hw.logicalcpu) && make install && cd ..
fi

rm -fr qemu-src
